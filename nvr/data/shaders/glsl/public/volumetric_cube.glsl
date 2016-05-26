// Shader downloaded from https://www.shadertoy.com/view/XtsGRf
// written by shadertoy user Flyguy
//
// Name: Volumetric Cube
// Description: Testing a mix of ray marching and volume ray casting.
#define RotateX(v,a) v.yz *= mat2(cos(a),sin(a),-sin(a),cos(a))
#define RotateY(v,a) v.xz *= mat2(cos(a),sin(a),-sin(a),cos(a))
#define RotateZ(v,a) v.xy *= mat2(cos(a),sin(a),-sin(a),cos(a))

#define MIN_MARCH_DIST 0.001
#define MAX_MARCH_STEPS 48
#define MAX_VOLUME_STEPS 290
#define VOLUME_STEP_SIZE 0.01

vec4 Volume(vec3 pos)
{
    RotateY(pos,iGlobalTime);
    RotateZ(pos,-0.5);
    
    float vol = dot(normalize(pos),vec3(1,0,0));
    
    vec3 col = mix(vec3(1.0,0.2,0.2),vec3(0.2,0.2,1.0),step(0.0,vol));
    
    vol = smoothstep(0.6,0.9,abs(vol));
    
	return vec4(col, max(0.0,vol)*0.01);  
}

vec3 MarchVolume(vec3 orig, vec3 dir)
{
    //Ray march to find the cube surface.
    float t = 0.0;
    vec3 pos = orig;
    for(int i = 0;i < MAX_MARCH_STEPS;i++)
    {
        pos = orig + dir * t;
        float dist = 100.0;
        
        dist = min(dist, 8.0-length(pos));
        dist = min(dist, max(max(abs(pos.x),abs(pos.y)),abs(pos.z))-1.0);//length(pos)-1.0);
        
        t += dist;
        
        if(dist < MIN_MARCH_DIST){break;}
    }
    
    //Step though the volume and add up the opacity.
    vec4 col = vec4(0.0);
    for(int i = 0;i < MAX_VOLUME_STEPS;i++)
    {
    	t += VOLUME_STEP_SIZE;
        
    	pos = orig + dir * t;
        
        //Stop if the sample becomes completely opaque or leaves the volume.
        if(max(max(abs(pos.x),abs(pos.y)),abs(pos.z))-1.0 > 0.0) {break;}
        
        vec4 vol = Volume(pos);
        vol.rgb *= vol.w;
        
        col += vol;
    }
    
    return col.rgb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    
    vec3 dir = normalize(vec3(uv-res/2.0,1.0));
    vec3 orig = vec3(0,0,-3.5);

        
    RotateX(dir,radians(iMouse.y));
    RotateX(orig,radians(iMouse.y));
    RotateY(dir,radians(-iMouse.x));
    RotateY(orig,radians(-iMouse.x));

    
    vec3 color = MarchVolume(orig,dir);
    
	fragColor = vec4(color, 1.0);
}