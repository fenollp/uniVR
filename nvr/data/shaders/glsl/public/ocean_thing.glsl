// Shader downloaded from https://www.shadertoy.com/view/Xl23zc
// written by shadertoy user Kyle273
//
// Name: Ocean Thing
// Description: Wroley noise + distance fields. Terribly optimized!
//    Going for a wind-waker style water.
const int MAX_ITER = 100;
const float MAX_DIST = 20.0;
const float EPS = 0.001;



vec3 camOrigin = vec3(1.0 ,0.0,0.0);


float length2(vec2 p){
    return dot(p,p);
}

float noise(vec2 p){
	return fract(sin(fract(sin(p.x) * (43.13311)) + p.y) * 31.0011);
}

float worley(vec2 p) {
    //Set our distance to infinity
	float d = 1e30;
    //For the 9 surrounding grid points
	for (int xo = -1; xo <= 1; ++xo) {
		for (int yo = -1; yo <= 1; ++yo) {
            //Floor our vec2 and add an offset to create our point
			vec2 tp = floor(p) + vec2(xo, yo);
            //Calculate the minimum distance for this grid point
            //Mix in the noise value too!
			d = min(d, length2(p - tp - noise(tp)));
		}
	}
	return 3.0*exp(-4.0*abs(2.5*d - 1.0));
}

float fworley(vec2 p) {
    //Stack noise layers 
	return sqrt(sqrt(sqrt(
		worley(p*5.0 + 0.05*iGlobalTime) *
		sqrt(worley(p * 50.0 + 0.12 + -0.1*iGlobalTime)) *
		sqrt(sqrt(worley(p * -10.0 + 0.03*iGlobalTime))))));
}
   

float vNoisePlane(vec3 pos)
{
    vec2 xz = (pos.xz)*0.008;
    float h = fworley(xz) - 2.0;
    return -pos.y - h;
    
}
float sphere(vec3 pos, float radius, vec3 center)
{
    float phi = dot(vec3(0.0,1.0,0.0),(normalize(center-pos)));
    float theta = dot(vec3(1.0,0.0,0.0),(normalize(center-pos)));
    return length(center-pos)-radius + 0.025*sin(10.0*(phi)) + 0.025*cos(10.0*(theta));
}
float distFunc(vec3 pos)
{
   
   return  vNoisePlane(pos);
}

vec4 march(vec3 ray)
{
    float totalDist = 0.0;
    vec3 pos = camOrigin;
    float dist = EPS;
    
    for(int i = 0; i < MAX_ITER; i++)
    {
        if(dist < EPS || totalDist > MAX_DIST)
        	break;
        dist = distFunc(pos);
        totalDist += dist;
        pos += dist*ray;
    }
    return vec4(pos,dist);
}

vec3 light(vec3 pos, vec3 rayDir)
{
    float amb = 0.1;
    vec2 eps = vec2(0.0,EPS);
    vec3 norm = normalize(vec3(
        distFunc(pos+eps.yxx)-distFunc(pos-eps.yxx),
        distFunc(pos+eps.xyx)-distFunc(pos-eps.xyx),
        distFunc(pos+eps.xxy)-distFunc(pos-eps.xxy)));
    float diffuse = max(0.0,dot(-rayDir,norm));
    float spec = pow(diffuse,32.0);
    return vec3(amb,diffuse,spec);
                      
}
vec4 sun(vec2 uv)
{
    float sundist = dot(uv,uv)-0.25;
    if(sundist < 0.)
    {
       	return vec4(mix(vec3(0.6,0.5,0.0),vec3(1.0), -sundist/0.5), 1.0);
    }
    return vec4(0.0);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	 vec3 camTarget = vec3(0.0);
	
	vec3 upDir = vec3(0.0,1.0,0.0);	
	vec3 camDir = normalize(camTarget-camOrigin);
	vec3 camRight = normalize(cross(upDir,camOrigin));
	vec3 camUp = cross(camDir, camRight);
	vec2 uv = -1.0 + 2.0*fragCoord.xy / iResolution.xy;
    uv.x *= iResolution.x/iResolution.y;
    //Orthographic ray march
    vec3 rayDir = normalize(camRight*uv.x  + camUp*uv.y + camDir);
    vec4 point = march(rayDir);
    if(point.w < EPS)
    {
        vec3 amb = vec3(0.4,0.4,0.4);
        vec3 dif = vec3(0.2,0.2,0.8);
        vec3 spec =vec3(1.0,1.0,1.0);
        vec3 l = light(point.xyz,rayDir);
        vec3 col = amb*l.x + dif*l.y + spec * l.z;
        fragColor = vec4(col, 1.0);
        
        if(fworley(point.xz * 0.008) > 0.9)
        {
            fragColor +=vec4(0.6);
        }
       
        
    }
    else if(uv.y > -0.03)
    {
        
        fragColor = vec4(mix(vec3(1.5,0.3,0.5),vec3(0.4,0.4,0.9),uv.y),1.0) + sun(uv);
    }
    else
    {
        fragColor = vec4(0.0);
    }
	
}