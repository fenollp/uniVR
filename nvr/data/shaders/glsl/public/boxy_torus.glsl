// Shader downloaded from https://www.shadertoy.com/view/MsVGRy
// written by shadertoy user DrLuke
//
// Name: Boxy Torus
// Description: This is a doughnut rendered with cubes, inspired from the demo &quot;1995&quot; by kewlers and mfx (https://www.youtube.com/watch?v=dX-cVUg57EE)
//    
//    I've experimented with increasing performance by branching in the raymarching routine.
/*
Thanks to Inigo Quilez for the great distance functions showcase!
*/

mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

//----------------------------------------------------------------------

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdTorus( vec3 p, vec2 t )
{
  return length( vec2(length(p.xz)-t.x,p.y) )-t.y;
}

//----------------------------------------------------------------------

float stepround(float a, float s)	// See: https://www.wolframalpha.com/input/?i=x+-+modulo(x-0.2,+0.4)%2B0.2
{
	return a - mod(a-s, s*2.0)+s;
}

vec3 stepround(vec3 a, vec3 s)	// See: https://www.wolframalpha.com/input/?i=x+-+modulo(x-0.2,+0.4)%2B0.2
{
	return a - mod(a-s, s*2.0)+s;
}

float map(vec3 p, mat3 rotMat)
{
	//float r = sdPlane(p - vec3(0,-1.5,0));	// Return distance
    float r = 1000.0;
	
    #define GS 0.1
    //mat3 rotMat = rotationMatrix(vec3(1,1,0), iGlobalTime);
    vec3 boxmod = mix(mod(p+vec3(GS),vec3(GS*2.0))-vec3(GS), p, step(0.55, sdTorus(rotMat*stepround(p, vec3(GS)), vec2(2,.5))) );
    //vec3 boxmod = mod(p+vec3(GS),vec3(GS*2.0))-vec3(GS);
    vec3 sizemod = mix(vec3(clamp(0.3-sdTorus(rotMat*stepround(p, vec3(GS)), vec2(2,0.5))*0.6, 0.0, GS) ), vec3(0), step(0.6, sdTorus(rotMat*stepround(p, vec3(GS)), vec2(2,.5))) );
    
    r = min(r, sdBox(boxmod, sizemod));
    return r;
}

vec3 calcNormal( in vec3 pos, mat3 rotMat )
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    map(pos+eps.xyy, rotMat) - map(pos-eps.xyy, rotMat),
	    map(pos+eps.yxy, rotMat) - map(pos-eps.yxy, rotMat),
	    map(pos+eps.yyx, rotMat) - map(pos-eps.yyx, rotMat) );
	return normalize(nor);
}


vec3 colorize(vec3 p, vec3 d, float dist)
{
 	vec3 col = vec3(0);
    
    mat3 rotMat = rotationMatrix(vec3(1,1,0), iGlobalTime*0.2);
    vec3 boxsize = vec3(clamp(0.3-sdTorus(rotMat*stepround(p, vec3(GS)), vec2(2,0.5))*0.6, 0.0, GS) );
    vec3 relp = mix(mod(p+vec3(GS),vec3(GS*2.0))-vec3(GS), p, step(0.6, sdTorus(rotMat*stepround(p, vec3(GS)), vec2(2,.5))) );
    float a = smoothstep(boxsize.x*0.8, boxsize.x, abs(relp.x)) + smoothstep(boxsize.y*0.8, boxsize.y, abs(relp.y)) + smoothstep(boxsize.z*0.8, boxsize.z, abs(relp.z));
    col = vec3(smoothstep(0.3,0.8,a/3.0)) * vec3(1.0,0.4,0);
    

    vec3 n = calcNormal(p, rotMat);
    col = mix(col, textureCube(iChannel1, reflect(normalize(d), n)).rgb, (1.0-length(col))*0.2);
    //col = n;
    
    return mix(col, textureCube(iChannel0, d).rgb, step(10.0, dist));
}

#define MARCHLIMIT 2500
#define MARCHSTEPFACTOR mix(0.01,0.3,smoothstep(0.9,2.1, sdTorus(rotMat*stepround(s + d*dist, vec3(GS)), vec2(2,.5))))
float march(vec3 s, vec3 d)
{
    mat3 rotMat = rotationMatrix(vec3(1,1,0), iGlobalTime*0.2);
    float dist = 1.0;	// distance
    float distd = 0.1;
    for(int i = 0; i < MARCHLIMIT; i++)
    {
        distd = map(s + d*dist, rotMat)*MARCHSTEPFACTOR;
        if(distd < 0.00001 || dist > 10.0)
            break;
        dist += distd;
    }
    
	return min(dist, 100.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = ((fragCoord.xy * 2.0) / iResolution.xy) - vec2(1);	// Make UV go from -1 to 1 instead of 0 to 1
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 s = vec3(sin(iGlobalTime*0.1)*5.0,sin(iGlobalTime*0.04)*4.0,cos(iGlobalTime*0.1)*5.0);
    #define FOCALLEN 0.5
    vec3 d = vec3(uv*FOCALLEN, 1.0);
    mat3 rotMat = rotationMatrix(vec3(0,1,sin(iGlobalTime*3.14159*0.01)*0.1), -iGlobalTime*0.1 + 3.14159) * rotationMatrix(vec3(1,0,0), -0.7*sin(iGlobalTime*0.04) - 0.0);
    d = rotMat * d;
    
    float marchdist = march(s, normalize(d));
    
	fragColor = vec4(colorize(s+normalize(d)*marchdist, normalize(d), marchdist), 1.0);
    //fragColor = vec4(marchdist/100.0);
}