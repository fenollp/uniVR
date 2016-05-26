// Shader downloaded from https://www.shadertoy.com/view/4tSSRh
// written by shadertoy user metaeaux
//
// Name: Metaeaux - Marball blobs
// Description: Learning to do textures, shadows and deformations
float dancingSphere(vec3 p, float rad) {
    float undulate = 5. * sin(iGlobalTime * 0.2);
    float radius = rad + 0.1 * (sin(p.x * undulate ) + sin(p.y * undulate +  2.*iGlobalTime));
    return length(p) - radius;
}

vec4 sphereColor( in vec3 pos, in vec3 nor, in sampler2D iChannel)
{
	vec2 uv = vec2( atan( nor.x, nor.z ), acos(nor.y) );
    vec3 col = (texture2D( iChannel, uv ).xyz);
    float ao = clamp( 0.75 + 0.25*nor.y, 0.0, 1.0 );
    return vec4( col, ao );
}

vec4 floorColor( in vec3 pos, in vec3 nor )
{
    vec3 col = texture2D( iChannel1, 0.5*pos.xz ).xyz;
	
    // fake ao
    float f = smoothstep( 0.1, 1.75, length(pos.xz) );

	return vec4(col, 0.5*f+0.5*f*f);
}

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
  float undulate = 5. * cos(iGlobalTime * 0.2);
  float radius = r + 0.1 * (sin(p.x * undulate ) + sin(p.y * undulate +  2.*iGlobalTime));
  return length(max(abs(p)-b,0.0))-r*radius;
}

float plane( vec3 p, vec4 n )
{
  return dot(p,n.xyz) + n.w;
}

// subtraction
float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

// union
vec2 opU( vec2 d1, vec2 d2 )
{
	return d1.x < d2.x ? d1 : d2;
}

// intersection
vec2 opI( vec2 d1, vec2 d2 )
{
    return d1.x > d2.x ? d1 : d2;
}

vec2 map(vec3 p) {
    
    vec2 d = opU(vec2(dancingSphere(p - vec3(1.5, 0., 0.), 1.), 1.), vec2(p.y + 2., 2.));
    
    d = opU(d, vec2(udRoundBox(p - vec3(-1.5, 0., 0.), vec3(.0, 0., 0.), 1.), 3.));
    
    return d;
}

vec3 normal(vec3 pos) {
    vec3 e = vec3(0.00001, 0., 0.);
    vec3 nor = normalize( vec3(map(pos+e.xyy).x - map(pos-e.xyy).x,
                               map(pos+e.yxy).x - map(pos-e.yxy).x,
                               map(pos+e.yyx).x - map(pos-e.yyx).x));
    return nor;
}

float shadow( in vec3 ro, in vec3 rd, in float maxt)
{
	float res = 1.0;
    float dt = 0.04;
    float t = .02;
    for( int i=0; i < 20; i++ )
    {       
        float h = map(ro + rd*t).x;
        if( h<0.001 )
            return 0.0;
        res = min( res, maxt*h/t );
        t += h;
    }
    return res;
}

vec3 raymarch(in vec3 ro, in vec3 rd, in float tmax)
{
	vec2 h = vec2(0.);
    float t = 0.;
    
    for(int i = 0; i < 64; i++)
    {
     	h = map(ro + t * rd);
        t += h.x;
        if( h.x < 0.001) break;
        if(t > tmax) return vec3(t, h.x, -1.);
    }
    
    return vec3(t, h);
    
}

vec4 selectColour(in float index, in vec3 pos, in vec3 nor) {
    vec4 ambient = 1.5 * vec4(0.1, 0.15, 0.2, 1.);
    vec4 planeColour = vec4(1.);
    vec4 blobColour = vec4(0.6, 0.8, 1., 1.);
    
    if (index == 1.) return sphereColor(pos, nor, iChannel3); //blobColour;
    else if(index == 2.) return planeColour;
    else if(index == 3.) return sphereColor(pos, nor, iChannel2);
    else return ambient; 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float grid = 4.;
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = uv * grid - grid/2.;
    
    p.x *= iResolution.x/iResolution.y;
    
    vec3 eye = vec3(0., 0., 0.);
    vec3 up = normalize(vec3(0., 1., 0.5));
    vec3 right = vec3(1., 0., 0.);
    vec3 forward = normalize(vec3(0., 2., -4.));
    float focalLength = 2.;

    vec3 ro = forward*focalLength + right * p.x + up * p.y;
    vec3 rd = normalize(cross(right, up));    
    vec4 col = vec4(0.);
    vec3 lig = vec3(0.9*cos(iGlobalTime), 0.9, 0.9*sin(iGlobalTime));
    vec4 ambient = 1.5 * vec4(0.1, 0.15, 0.2, 1.);
    vec3 planeColour = vec3(1.);
    vec3 blobColour = vec3(0.6, 0.8, 1.);
    float tmax = 20.0;
    
    // lets raymarch!
    vec3 march = raymarch(ro, rd, tmax);
    vec2 h = march.yz;
    float t = march.x;
    
    // did we intersect the primitive?
    if(t < tmax) {
    	vec3 pos = ro + t * rd;
        vec3 e = vec3(0.0001, 0., 0.);
        vec3 nor = normal(pos);
        
        col = selectColour(h.y, pos, nor);
        
        float lambert = clamp(dot(normalize(nor), normalize(lig)), 0., 1.);
        float phong = pow(lambert,128.);
        
        // lambert shading and ambient colour
        col = clamp(col*lambert + ambient * (1.0 - lambert) + phong, 0., 1.);  
        
        // shadow and ambient colour
        float sh = shadow( pos, lig, 1.0);
		col *= sh  + ambient * (1.0 - sh);
        
    }
    
    
	fragColor = col;
}