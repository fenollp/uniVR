// Shader downloaded from https://www.shadertoy.com/view/XsK3Rd
// written by shadertoy user Flyguy
//
// Name: Lorenz Attractor Divergence (3D)
// Description:  A volumetric ray marched version of my previous shader: https://www.shadertoy.com/view/Msy3R3
//    The volumetric texture is computed in Buf A at a resolution of floor(cuberoot(resolution.x * resolution.y)).
//Press space to reset.

#define RotateX(v,a) v.yz *= mat2(cos(a),sin(a),-sin(a),cos(a))
#define RotateY(v,a) v.xz *= mat2(cos(a),sin(a),-sin(a),cos(a))
#define RotateZ(v,a) v.xy *= mat2(cos(a),sin(a),-sin(a),cos(a))

#define MIN_MARCH_DIST 0.001
#define MAX_MARCH_STEPS 64
#define MAX_VOLUME_STEPS 290
#define VOLUME_STEP_SIZE 0.02

#define DISP_MODE XYZ

#define XYZ 0
#define XYZ_STEP 1
#define LENGTH 2
#define VOLUME_BUFFER 3

vec3 vres = vec3(0);

vec4 sample3D(sampler2D tex, vec3 uvw, vec3 vres)
{
    uvw = mod(floor(uvw * vres), vres);
    
    //XYZ -> Pixel index
    float idx = (uvw.z * (vres.x*vres.y)) + (uvw.y * vres.x) + uvw.x;
    
    //Pixel index -> Buffer uv coords
    vec2 uv = vec2(mod(idx, iResolution.x), floor(idx / iResolution.x));
    
    return texture2D(tex, (uv + 0.5) / iResolution.xy);
}

vec4 sample3DLinear(sampler2D tex, vec3 uvw, vec3 vres)
{
    vec3 blend = fract(uvw*vres);
    vec4 off = vec4(1.0/vres, 0.0);
    
    //2x2x2 sample blending
    vec4 b000 = sample3D(tex, uvw + off.www, vres);
    vec4 b100 = sample3D(tex, uvw + off.xww, vres);
    
    vec4 b010 = sample3D(tex, uvw + off.wyw, vres);
    vec4 b110 = sample3D(tex, uvw + off.xyw, vres);
    
    vec4 b001 = sample3D(tex, uvw + off.wwz, vres);
    vec4 b101 = sample3D(tex, uvw + off.xwz, vres);
    
    vec4 b011 = sample3D(tex, uvw + off.wyz, vres);
    vec4 b111 = sample3D(tex, uvw + off.xyz, vres);
    
    return mix(mix(mix(b000,b100,blend.x), mix(b010,b110,blend.x), blend.y), 
               mix(mix(b001,b101,blend.x), mix(b011,b111,blend.x), blend.y),
               blend.z);
}

vec4 Volume(vec3 pos)
{
      return sample3DLinear(iChannel0, pos*0.5+0.5, vres);
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
        
        //Stop if the sample leaves the volume.
        if(max(max(abs(pos.x),abs(pos.y)),abs(pos.z))-1.0 > 0.0) {break;}
        
        vec4 vol = vec4(0);
        #if(DISP_MODE == XYZ)
        	vol = abs(Volume(pos)) * 0.001;
        #elif(DISP_MODE == XYZ_STEP)
        	vol = smoothstep(6.0, 0.8, abs(Volume(pos))) * 0.02;
        #elif(DISP_MODE == LENGTH)
        	vol = vec4(20.0 / pow(length(Volume(pos)),2.0) * 0.1);
        #endif
        
        
        col += vol;
    }
    
    return col.rgb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vres = vec3(floor(pow(iResolution.x*iResolution.y, 1.0/3.0)));
    
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    
    vec3 dir = normalize(vec3(uv-res/2.0,1.0));
    vec3 orig = vec3(0,0,-3.5);

        
    RotateX(dir,radians(iMouse.y));
    RotateX(orig,radians(iMouse.y));
    RotateY(dir,radians(-iMouse.x));
    RotateY(orig,radians(-iMouse.x));
    
    vec3 color = MarchVolume(orig,dir);
    
    #if(DISP_MODE == VOLUME_BUFFER)
    	color = texture2D(iChannel0, uv/res).rgb;
    #endif
    
	fragColor = vec4(color, 1.0);
}