// Shader downloaded from https://www.shadertoy.com/view/llsXzH
// written by shadertoy user frutbunn
//
// Name: Inflatable Analyser
// Description: Best seen fullscreen!
#define MAX_STEPS 			50
#define MAX_DISTANCE 		8.
#define MARCHING_STEP_INC 	.4
#define EPSILON 			.01

#define COLORS  4

#define PI 3.14159265358979323846
#define TIMER(sec, min, max) (((mod(iGlobalTime, (sec)) * ((max) - (min))) / (sec)) + (min))

float globalTimer = TIMER(80., 0., 60.);
#define SCENE1  0.
#define SCENE2  30.
#define SCENE3  40.
#define SCENE4  50.
#define SCENE5  60.

float scol[7];
float b[4];

vec4 texSphere(sampler2D t, vec3 p, vec3 n, float scale) {
    return texture2D(t, p.yz * scale) * abs (n.x)
     + texture2D(t, p.xz * scale) * abs (n.y)
     + texture2D(t, p.xy * scale) * abs (n.z);
}

mat2 mm2(in float a) {
    float c = cos(a), s = sin(a);
    
    return mat2(c, s, -s, c);
}

float smin(in float a, in float b ) {
    const float k=12.; 
    float res = exp( -k*a ) + exp( -k*b );
    
    return -log( res )/k;
}

float map(in vec3 p, out float o[COLORS]) {   
#   define SS 1.5
    float cx = cos(SS*p.x), cy = cos(SS*p.y), cz = cos(SS*p.z);
    float sx = sin(SS*p.x), sy = sin(SS*p.y), sz = sin(SS*p.z);
    
    float lpxz = length(p.xz);
    o[0] = (length(vec2((lpxz-1.5)-(b[0]), p.y))-.15) + cx*cy*sz;
    o[1] = (length(vec2((lpxz-1.5)-(b[1]), p.y))-.15) + cx*cy*cz;
    o[2] = (length(vec2((lpxz-1.5)-(b[2]), p.y))-.25) + cx*sy*sz;
    o[3] = (length(vec2((lpxz-1.5)-(b[3]), p.y))-.25) + sx*sy*sz;

    return smin(o[0]*1.5, smin(o[1], smin(o[2], o[3])));
}

float scene(in vec3 p, out float o[COLORS]) {
    return map(p, o);
}

float scene(in vec3 p) {
    float o[COLORS]; return map(p, o);
}

void colorize(in float d, in vec3 material_col, inout float z_depth, inout vec3 pixel_col) {
    const float max_displace = .25;
    const float max_col_bleed = 1.25;
    
    float nc = smoothstep(d-max_col_bleed, d+max_col_bleed, z_depth);
    float nzd = smoothstep(d-max_displace, d+max_displace, z_depth);
    
    z_depth = d*(nzd) + z_depth*(1.-nzd);
    pixel_col = (1.-nc)*pixel_col + (nc)*material_col;
}

float rayMarch(in vec3 origin, in vec3 ray, out vec3 col) {
    float o[COLORS];
    
    float t = 0.;
    for (int i=0; i < MAX_STEPS; i++) {
        float d = scene(origin + ray*t, o);

        if (d < EPSILON) 
            break;

        t += d*MARCHING_STEP_INC;

        if (t > MAX_DISTANCE) 
            break;
    }

    float z_depth = 1000.;
    colorize(o[0], vec3(scol[0]*.5, scol[6]*.0, scol[3]*.0), z_depth, col );
    colorize(o[1], vec3(scol[4]*.0, scol[4]*.3, scol[4]*.0), z_depth, col );
    colorize(o[2], vec3(scol[1]*.2, scol[5]*.0, scol[4]*.3), z_depth, col );
    colorize(o[3], vec3(scol[2]*.4, scol[4]*.3, scol[6]*.6), z_depth, col );
    
    col = clamp(col, 0., 1.);
    
    return t;
}

float ambientOcculation(in vec3 origin, in vec3 ray) {
    const float delta = .1;
    const int samples = 6;
    float r = 0.;
    
    for (int i=1; i <= samples; i++) {
        float t = delta * float(i);
        float d = scene(origin + ray*t);
        float len = abs(t - d);
        r += len * pow(2.0, -float(i));
    }
    
    return r;
}

float shadowSample(in vec3 origin, in vec3 ray) {
    float r = 1.;
    float t = 1.;
    const int samples = 12;
    
    for (int i=0; i <= samples; i++) {
        float d = scene(origin + ray*t);
        r = min(r, 2.0*d/t);
        t += d;
    }
    
    return max(r, 0.);
}

vec3 getNormal(in vec3 p, in float ep) {
    float d0 = scene(p);
    float dX = scene(p - vec3(ep, 0.0, 0.0));
    float dY = scene(p - vec3(0.0, ep, 0.0));
    float dZ = scene(p - vec3(0.0, 0.0, ep));

    return normalize(vec3(dX-d0, dY-d0, dZ-d0));
}

vec3 starfield(in vec2 uv) {
    vec3 col = vec3(.0);

    vec3 ray = vec3(uv*.8, .7);
    ray.xy*=mm2(TIMER(10. ,0., -PI*2.));
    ray.zy*=mm2(PI*2.1);

    vec3 t = ray/max(abs(ray.x), abs(ray.y));
    vec3 p = 1.*t+.5;
    
    if (globalTimer>SCENE4 && globalTimer<=SCENE5) {
        float dd = PI, c = cos(dd*p.y+dd), s = sin(dd*p.y+dd);
        p = vec3(mat2(c,-s,s,c)*p.xz,p.y);
    }
    
    for(int i=0; i<3; i++) {
        float n = fract(sin(dot((vec2(floor(p.xy*30.334))), vec2(12.9898, 78.233)))*43758.5453)+.5;
        float z = fract(cos(n)-sin(n)-iGlobalTime*.2);       
        
        float d = 60.*z-p.z;
        float j = max(0., 1.5-3.*length(fract(p.xy)-.5));
        vec3 c = max(vec3(0), vec3(1.0-abs(d))*(1./t.z*2.));
        
        col += (1.-z)*c*j;
        p += t;
    }

    if (globalTimer>SCENE2 && globalTimer<=SCENE4) {
        col.r *= scol[0];
    } else if (globalTimer>SCENE4 && globalTimer<=SCENE5) {
        col.g*=4.;
        col *= length(uv*.5);
    }

    return col;
}

float f1(in float x) {
    return sqrt(1.-(x-1.)*(x-1.));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (gl_FragCoord.xy / iResolution.xy) - vec2(.5);
    uv.x *= iResolution.x/iResolution.y;
   
    
#	define MM 6.5 
    scol[0]=texture2D(iChannel2, vec2(0., 0.25) ).x;     scol[0]=f1(clamp(1.*scol[0]*scol[0], 0., 1.)); scol[0]*=MM*scol[0]*scol[0];
    scol[1]=texture2D(iChannel2, vec2(.17*1., 0.25) ).x; scol[1]=f1(clamp(1.*scol[1]*scol[1], 0., 1.)); scol[1]*=MM*scol[1]*scol[1];
    scol[2]=texture2D(iChannel2, vec2(.17*2., 0.25) ).x; scol[2]=f1(clamp(1.*scol[2]*scol[2], 0., 1.)); scol[2]*=MM*scol[2]*scol[2];
    scol[3]=texture2D(iChannel2, vec2(.17*3., 0.25) ).x; scol[3]=f1(clamp(1.*scol[3]*scol[3], 0., 1.)); scol[3]*=MM*scol[3]*scol[3];
    scol[4]=texture2D(iChannel2, vec2(.17*4., 0.25) ).x; scol[4]=f1(clamp(1.*scol[4]*scol[4], 0., 1.)); scol[4]*=MM*scol[4]*scol[4];
    scol[5]=texture2D(iChannel2, vec2(.17*5., 0.25) ).x; scol[5]=f1(clamp(1.*scol[5]*scol[5], 0., 1.)); scol[5]*=MM*scol[5]*scol[5];
    scol[6]=texture2D(iChannel2, vec2(.99, 0.25) ).x;    scol[6]=f1(clamp(1.*scol[6]*scol[6], 0., 1.)); scol[6]*=MM*scol[6]*scol[6];    
    
    b[0] = (scol[1]+scol[2]+scol[3])*.33;
    b[1] = (scol[3]+scol[3]+scol[4])*.33;
    b[2] = (scol[4]+scol[5]+scol[6])*.33;
    b[3] = (scol[2]+scol[3]+scol[4])*.33;
    
    
    vec2 uv2 = uv;
   
    if (globalTimer>SCENE2 && globalTimer<=SCENE4) {
        float ts1 = abs(TIMER(5., -15.5, 15.5));
        float ts2 = abs(TIMER(10., 15.5, -15.5));
        uv2.y*=cos(uv2.y*-(ts1-ts2*1.));
        uv2.x*=sin(uv2.x*-(ts1-ts2*1.));
    }
    
    float o = min(TIMER(10., -PI*2., PI*2.), TIMER(10., PI*2., -PI*2.))+PI;    
    float o2 = min(TIMER(20., -PI*2., PI*2.), TIMER(20., PI*2., -PI*2.))+PI;
        
    float o3 = min(TIMER(5., -PI*2., PI*2.), TIMER(5., PI*2., -PI*2.))+PI;
    float o3b = min(TIMER(10., -PI*2., PI*2.), TIMER(10., PI*2., -PI*2.))+PI;
        
    uv.x+=cos(o)*.5;
    uv.y+=cos(o2)*.3;
    uv*= ( (1.5+cos(o3)) + (1.5+cos(o3b)) ) *.5;
    
    vec3 eye = vec3(0., 0., -5.);
    vec3 light = vec3(-2., -.5, -6.5);
    vec3 ray = vec3(uv.x, uv.y, 1.);
    vec3 scene_color = vec3(0.);

    float rx = TIMER(10. ,0., PI*2.);
    float ry = TIMER(8. ,0., PI*2.);
    float rz = TIMER(5. ,0., PI*2.);
    
    eye.zx*=mm2(rx); eye.xy*=mm2(rz); eye.zy*=mm2(ry);
    light.zx*=mm2(rx); light.xy*=mm2(rz); light.zy*=mm2(ry);
    ray.zx*=mm2(rx); ray.xy*=mm2(rz); ray.zy*=mm2(ry);
    
    float depth = rayMarch(eye, ray, scene_color);
    if (depth < MAX_DISTANCE) {
        vec3 p = (eye + ray*depth);
        
        float d_ep=length(p - depth);
        vec3 p_normal = getNormal(p, d_ep*d_ep*EPSILON*0.003);
        
        vec3 light_dir = -normalize(light-p);
        vec3 reflected_light_dir = reflect(-light_dir, -p_normal);

        const float j=.003;
        float shadow = shadowSample(p, -light_dir);
        float attenuation = 1./(1. + j*pow( length(light-p), 2.0));
        attenuation -= (1.-shadow)*.6;
        
        float ambient = pow(max(1.-ambientOcculation(p, -ray), 0.), 8.);
        float diffuse = max(0., dot(light_dir, p_normal));
        float lighting = max(0., (diffuse*.4 + ambient*.6)*attenuation);

        vec3 reflectioncolor = textureCube(iChannel1, reflected_light_dir).rgb;
        vec3 texcol = texSphere(iChannel0, .1*p, p_normal, 1.0 ).rgb*lighting;
        scene_color = (clamp(mix(scene_color, reflectioncolor, max(0., 1.+(dot(-p_normal, ray)))), 0., 1.)+scene_color)*lighting;
        scene_color = scene_color + texcol*.4;

        scene_color *= max(dot(-p_normal,-ray),.5);
    } else {
        scene_color=starfield(uv2);
    }
    
    scene_color = clamp(scene_color, 0., 1.);
    fragColor = vec4(pow(scene_color, vec3(.85)), 1.);
}