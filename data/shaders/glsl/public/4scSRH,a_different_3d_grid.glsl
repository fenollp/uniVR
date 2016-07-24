// Shader downloaded from https://www.shadertoy.com/view/4scSRH
// written by shadertoy user Mr_E
//
// Name: A different 3D grid
// Description: I made a mistake on one of my previous programs, and this looked vaguely cool so YAY! 
float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float opU( float d1, float d2 )
{
    return min(d1,d2);
}
vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}


float sdGrid(vec3 p) {
	return opU(opU(sdBox(p,vec3(5.,.8,.3)),
               sdBox(p,vec3(1.31,55.2,.3))),
               sdBox(p,vec3(0.,0.,0.)));
}
float sdCross(vec3 p) {
	return opU(sdBox(p,vec3(0.,0.,0.)),
            sdBox(p,vec3(0.,.0,.0)));
}
float smin( float a, float b, float k )
{
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float sdCrossedGrid( vec3 p )
{
    float d1 = sdCross(p);
    float d2 = sdGrid(p);
    return smin( d2, d1, d2);
}

vec2 distance_to_obj(in vec3 p) {
    vec3 q = opRep(p,vec3(10.0,10.0,10.0));
    return vec2(
       	sdCrossedGrid(q)
    );
}

// primitive color
vec3 prim_c(in vec3 p) {
    //return vec3(0.6,0.6,0.8);
    return vec3(sin(p.x*p.y*p.z/10.),cos(p.x*p.y*p.z/5.),.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 cam_pos = vec3(sin(iGlobalTime/6.)*30.4,cos(iGlobalTime/2.)*40.0,20.0);

	vec2 tx = fragCoord.xy / iResolution.xy;
    vec2 vPos = -1.0 + 2.0 * tx;

    //camera up vector
    vec3 vuv = vec3(1,1,1);

    //camera lookat
    vec3 vrp=vec3(1,1,1);

    vec3 prp = cam_pos;
    vec3 vpn = normalize(vrp-prp);
    vec3 u = normalize(cross(vuv,vpn));
    vec3 v = cross(vpn,u);
    vec3 vcv = (prp+vpn);
    vec3 scrCoord = vcv+vPos.x*u*1.0+vPos.y*v*1.0;
    vec3 scp=normalize(scrCoord-prp);

    //Raymarching
    const vec3 e=vec3(0.04,0,0.8);
    const float maxd=200.0;
    vec2 d=vec2(1.02,1.0);
    vec3 c,p,N;

    float f=1.0;
    for(int i=0;i<256;i++) { // Change i value to 256 for 3D-ness and 2 for coolness
        if ((abs(d.x)<.001) || (f > maxd)) break;

        f+=d.x*0.8;
        p=prp+scp*f;
        d = distance_to_obj(p);
    }
    if (f<maxd) {
        c=prim_c(p);
        vec3 n = vec3(
            d.x-distance_to_obj(p-e.xyy).x,
            d.x-distance_to_obj(p-e.yxy).x,
            d.x-distance_to_obj(p-e.yyx).x
            );
        N = normalize(n);
        
        float b=dot(N,normalize(prp-p));
		vec2 xy = fragCoord.xy / iResolution.xy;//Condensing this into one line
    	xy.y = 1.0 - xy.y;
    	
        vec2 uv = fragCoord.xy/iResolution.xy;
		vec4 texColor = texture2D(iChannel0,xy,b);//Get the pixel at xy from iChannel0
        fragColor = vec4(b);
        
        //fragColor = vec4(b, 0.1, b, cos(iGlobalTime/2.));//Set the screen pixel to that color
    } else {
    fragColor=vec4(0,0,0,1);
    }
}



