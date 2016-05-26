// Shader downloaded from https://www.shadertoy.com/view/4tBGWV
// written by shadertoy user skaven
//
// Name: test loading screen
// Description: the loading screen for my pet project. click inside gl view for changing &quot;loading progress&quot; value.
// Made with things shamelessly stolen from Iq, Hugo Campos, Zavie and GLTracy
// ray marching
const int max_iterations = 255;
const float stop_threshold = 0.001;
const float grad_step = 0.001;
const float clip_far = 1000.0;

// math
const float PI = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;

const mat2 m = mat2( 0.80,  0.60, -0.60,  0.80 );

// distance function
float dist_sphere( vec3 pos, float r ) {
	return length( pos ) - r;
}

float dist_roundbox( vec3 pos, vec3 size, float r )
{
  return length(max(abs(pos)-size,0.0))-r;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}


float dist_box( vec3 pos, vec3 size ) {
	return dist_roundbox( pos, size, 0.2);
    //return sdTorus( pos, vec2(size.x, size.x * 0.5));
}

float Vignette(vec2 uv)
{
	float OuterVig = 1.5;
	
	float InnerVig = 0.03;
	
	vec2 center = vec2(0.5,0.5);
	float dist  = distance(center,uv );
	float vig = clamp((OuterVig-dist) / (OuterVig-InnerVig),0.0,1.0);
	
	return vig;
}

float boxSize;

float dist_plan( vec3 pos, vec4 plan )
{
    return dot(pos, plan.xyz) + plan.w;
}
vec3 camd;

// get distance in the world
float dist_field( vec3 pos ) {
	// ...add objects here...
	
	// object 0 : sphere
	//float d0 = dist_sphere( pos, 2.6 );
	
	// object 1 : cube
	float d1 = dist_box( pos, vec3( 2.0 ) * boxSize );
		/*
    float d2 = dist_plan( pos, vec4(-camd.xyz,0.0));
    d2 += smoothstep(0.1,0.5,sin(d1*4.0-iGlobalTime*0.4));
    
    
    float d2b = dist_plan( pos, vec4(-camd.xyz,0.0));
    d2b += smoothstep(0.1,0.5,sin(d1*4.0-iGlobalTime*0.4))*0.9;
    
    
    float dband = max(d2,d2b);
	// union     : min( d0,  d1 )
	// intersect : max( d0,  d1 )
	// subtract  : max( d1, -d0 )
	return min(d1, d2);
*/
    return d1;//max(d1,-d0);
}

// phong shading
vec3 shading( vec3 v, vec3 n, vec3 eye ) {
	// ...add lights here...
	
	float shininess = 8.0;
	
	vec3 final = vec3( 0.0 );
	
	vec3 ev = normalize( v - eye );
	vec3 ref_ev = reflect( ev, n );
	
	// light 0
	{
		vec3 light_pos   = vec3( 10.0, 10.0, 20.0 );
		vec3 light_color = vec3( 1.1, 1.1, 1.1 );
	
		vec3 vl = normalize( light_pos - v );
	
		float diffuse  = max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, shininess );
		
		final += light_color * ( diffuse+specular ); 
	}
	
	// light 1
	{
		vec3 light_pos   = vec3( -10.0, -10.0, 0.0 );
		vec3 light_color = vec3( 0.4, 0.4, 0.5 );
	
		vec3 vl = normalize( light_pos - v );
	
		float diffuse  = max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, shininess );
		
		final += light_color * ( diffuse  ); 
	}
// light 2
	{
		vec3 light_pos   = vec3( 00.0, 0.0, -10.0 );
		vec3 light_color = vec3( 0.5, 0.4, 0.3 );
	
		vec3 vl = normalize( light_pos - v );
	
		float diffuse  = max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, shininess );
		
		final += light_color * ( diffuse  ); 
	}
	return final;
}

// get gradient in the world
vec3 gradient( vec3 pos ) {
	const vec3 dx = vec3( grad_step, 0.0, 0.0 );
	const vec3 dy = vec3( 0.0, grad_step, 0.0 );
	const vec3 dz = vec3( 0.0, 0.0, grad_step );
	return normalize (
		vec3(
			dist_field( pos + dx ) - dist_field( pos - dx ),
			dist_field( pos + dy ) - dist_field( pos - dy ),
			dist_field( pos + dz ) - dist_field( pos - dz )			
		)
	);
}

// ray marching
float ray_marching( vec3 origin, vec3 dir, float start, float end ) {
	float depth = start;
	for ( int i = 0; i < max_iterations; i++ ) {
		float dist = dist_field( origin + dir * depth );
		if ( dist < stop_threshold ) {
			return depth;
		}
		depth += dist;
		if ( depth >= end) {
			return end;
		}
	}
	return end;
}

// get ray direction
vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
	vec2 xy = pos - size * 0.5;

	float cot_half_fov = tan( ( 90.0 - fov * 0.5 ) * DEG_TO_RAD );	
	float z = size.y * 0.5 * cot_half_fov;
	
	return normalize( vec3( xy, -z ) );
}

// camera rotation : pitch, yaw
mat3 rotationXY( vec2 angle ) {
	vec2 c = cos( angle );
	vec2 s = sin( angle );
	
	return mat3(
		c.y      ,  0.0, -s.y,
		s.y * s.x,  c.x,  c.y * s.x,
		s.y * c.x, -s.x,  c.y * c.x
	);
}

float hash( vec2 p )
{
	float h = dot(p,vec2(127.1,311.7));
	
    return -1.0 + 2.0*fract(sin(h)*43758.5453123);
}


float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

float fbm( vec2 p )
{
    float f = 0.0;
    f += 0.5000*noise( p ); p = m*p*2.02; p.y += 0.02*iGlobalTime;
    f += 0.2500*noise( p ); p = m*p*2.03; p.y -= 0.02*iGlobalTime;
    f += 0.1250*noise( p ); p = m*p*2.01; p.y += 0.02*iGlobalTime;
    f += 0.0625*noise( p );
    return f/0.9375;
}

vec2 fbm2( vec2 p )
{
    return vec2( fbm(p.xy), fbm(p.yx) );
}
vec3 fbm3( vec3 p )
{
    return vec3( fbm(p.xy), fbm(p.yx), fbm(p.yz) );
}

float easeOut (float t, float b, float c, float d)
{
  float s = 1.70158;
  float p = 0.0;
  float a = c;

	if (t == 0.0) return b;
	if ((t /= d) == 1.0) return b + c;
	if (p == 0.0) p = d * 0.3;
	if (a < abs(c))
	{
		a = c;
		s = p / 4.0;
	}
	else s = p / (2.0 * PI) * asin (c / a);
	return a * pow(2.0, -10.0 * t) * sin((t * d - s) * (2.0 * PI) / p ) + c + b;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float progress = min(iMouse.x/iResolution.x + 0.25, 1.0);
	
	
	// default ray origin
    float distanceToCube = 20.0;
	vec3 eye = vec3( 7.0, -4.0, distanceToCube );

	// rotate camera
	mat3 rot = rotationXY( vec2( -0.6, iGlobalTime ) );
	
	eye = rot * eye;
    
	float locTime = iGlobalTime * (1.0+progress*0.5); 
	// ray marching
    boxSize = easeOut(mod(locTime,1.0), 0.3,0.41,1.0)*0.6+0.4;
    
    float o1 = 0.25;
    float o2 = 0.75;
    vec2 msaa[4];
    msaa[0] = vec2( o1,  o2);
    msaa[1] = vec2( o2, -o1);
    msaa[2] = vec2(-o1, -o2);
    msaa[3] = vec2(-o2,  o1);
    
    vec4 resColor = vec4(0.0);
    
    for (int i = 0;i<1;i++)
    {
        vec3 offset = vec3(msaa[i] / iResolution.y, 0.);
		vec3 dir = rot * ray_dir( 45.0, iResolution.xy, fragCoord.xy ) + offset;
        camd = dir;
        
        float depth = ray_marching( eye + offset, dir, 0.0, clip_far );

        if ( depth >= clip_far ) 
        {
            //float distToPlan = dot(eye,-camd.xyz);
            vec3 pos = eye + distanceToCube * camd;

            float dist2box = dist_box( pos, vec3( boxSize*0.66+0.33 )  );
            vec2 fbmv = fbm2((pos.xy + pos.yz) * 0.02) * pow(dist2box,0.8);
            float d1 = dist2box + fbmv.x; 
            float d1b = sin(dist2box) + fbmv.y*0.1;
            //float d2 = dist_plan( pos, vec4(-camd.xyz,0.0));
            float thres = smoothstep(0.45,0.55,sin(d1*2.0-locTime*2.0*PI + 2.0))*0.4;
            float thresb = smoothstep(0.45,0.55,sin(d1b*2.0-locTime*2.0*PI + 2.0))*0.03;
            float wave = 0.6 * (thres - thresb) * max( 1.0 - (dist2box/ 10.0)+(progress*2.5-1.0), 0.0);
            resColor += vec4(wave  + 0.6);
            //return;
        }
		else
        {
            // shading
            vec3 pos = eye + dir * depth;
            vec3 n = gradient( pos );
            float attn = 1.0;//smoothstep(0.3,0.32, abs(sin(length(pos/boxSize)*2.0 - iGlobalTime*4.0))) * 0.1 + 0.9;

            resColor += vec4( max(shading( pos, normalize(rot * -n), rot * eye ),0.2) * attn, 1.0 );
        }
    }
    vec2 tc = fragCoord.xy / iResolution.xy;
	fragColor = resColor * vec4(Vignette(tc + fbm2(tc*500.0)*0.02)); // remove vignette banding with some noise
}
