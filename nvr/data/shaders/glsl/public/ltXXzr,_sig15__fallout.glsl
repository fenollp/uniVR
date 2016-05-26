// Shader downloaded from https://www.shadertoy.com/view/ltXXzr
// written by shadertoy user vgs
//
// Name: [SIG15] Fallout
// Description: Let's open the vault door to SIG15! This shader is still WIP! Please inform me if the shader is broken in your machine.
// Created by Vinicius Graciano Santos - vgs/2015
// This shader is WIP!!!
// I still need to model the inside of the vault,
// adjust the lighting (it's too dark), and rotate the noise function to hide some artifacts.

#define STEPS 128
#define FAR 50.0
#define PIX (1.0/iResolution.x)
#define PI 3.14159265359

#define DOOR_QUEUE 10.

float iGT = mod(iGlobalTime, DOOR_QUEUE+12.0);

// Dave Hoskins' hash: https://www.shadertoy.com/view/4djSRW
float hash(float p) { 
    vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
	return fract(p2.x * p2.y * 95.4337);
}

// iq's 3D noise: https://www.shadertoy.com/view/4sfGzS
float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}

float fbm(vec3 x) {
    float f = 0.0;
    f += 0.5*noise(x); x = 2.0*x;
    f += 0.25*noise(x); x = 2.0*x;
    f += 0.125*noise(x); x = 2.0*x;
    f += 0.0625*noise(x);
    return f/0.9375;
}

// Distance functions (thanks again to iq)
float box( vec3 p, vec3 b ) {
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

vec2 rep(vec2 p) {
    float a = atan(p.y, p.x);
    a = mod(a, 2.0*PI/9.) - PI/9.;
    return length(p)*vec2(cos(a), sin(a));
}

float cylinder(vec3 p, vec2 h) {
    vec2 d = abs(vec2(length(p.xy),p.z)) - h;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec3 doorAnim(vec3 p) {
    vec3 zero = vec3(0.0);
    p += mix(zero, vec3(0.0, 0.0, 0.8), smoothstep(DOOR_QUEUE, DOOR_QUEUE+3.0, iGT));
    p += mix(zero, vec3(2.0, 0.0, 0.0), smoothstep(DOOR_QUEUE+5.0, DOOR_QUEUE+10.0, iGT));
    
    float a = mix(0.0, PI/2.5, smoothstep(DOOR_QUEUE+5.0, DOOR_QUEUE+10.0, iGT));
    p.xy = cos(a)*p.xy + sin(a)*vec2(p.y, -p.x);
    return p;
}

float torus( vec3 p, vec2 t ) {
  vec2 q = vec2(length(p.xy)-t.x,p.z);
  return length(q)-t.y;
}

float door(vec3 p) {
    vec3 q = vec3(p.x, p.y, p.z-0.22);
    float d = cylinder(p, vec2(1., .25));
    d = min(d, torus(q, vec2(0.4, 0.05)));
    d = min(d, torus(q, vec2(0.9, 0.05))); 
    p.xy = rep(p.xy); q = vec3(p.z-0.22, p.y, -p.x+0.65);
    d = min(d, cylinder(q, vec2(0.05, 0.25))); 
    p.x += 0.5*abs(p.y) - 1.;
    return min(d, box(p, vec3(0.15, 0.15, 0.25)));
}

float frame(vec3 p) {
    float d = cylinder(p, vec2(1.2, .3)); p.z *= 0.7;
    return max(d, -door(p));
}

vec2 track(float z) {
	float x = 2.5*cos(0.2*z);
	float y = 2.0*cos(0.2*z) - 0.5*sin(0.8*z - 2.0);
	return vec2(x, y) - vec2(2.3, 2.3);
}

float cave(vec3 p) {
    p.xy += track(p.z);
	const float k = 4.0;
	return max(1.6-pow(pow(abs(0.5*p.x), k) + pow(abs(p.y), k), 1.0/k) + 0.35*noise(p), -p.z);
}

float rail(vec3 p, float s) {
    p = vec3(p.x, p.z, -p.y);
    vec3 q = vec3(-p.z, p.y, p.x);
    float d = cylinder(q, vec2(0.02, s-0.25));
    q.x -= 0.25;
    d = min(d, cylinder(q, vec2(0.02, s-0.25)));
    p.x = clamp(p.x, -s, s);
    p.x = mod(p.x, 0.5) - 0.25;
    return min(d, cylinder(p, vec2(0.02, 0.25)));
}

float rails(vec3 p) {
    vec3 pa = p + vec3(0.88, 0.25, 1.52);
    float d = rail(pa, 1.0);
    pa = vec3(pa.z, pa.y, -pa.x) + vec3(1.75, 0.0, 0.75);
    d = min(d, rail(pa, 2.0));
    pa.z += 1.55; 
    return min(d, rail(pa, 3.0));
}

float vault(vec3 p) {
    // walls and hole
    vec3 pa = p + vec3(0.0, 0.0, 5.0);
    float d = max(box(pa, vec3(4.5, 3.0, 5.2)), -box(pa, vec3(3.0, 1.51, 5.0)));
    d = max(d, -cylinder(p, vec2(1.2)));
            
    // upper left floor
    pa = p + vec3(1.0, 1.0, 4.0);
    d = min(d, box(pa, vec3(0.9, 0.5, 2.5)));
    
    // upper right floor
    pa = p + vec3(-2.4, 1.0, 3.5);
    d = min(d, box(pa, vec3(1.0, 0.5, 3.0)));
	
    // stairs
    pa = p + vec3(-0.75, 1.0, 7.1);
    d = min(d, box(pa, vec3(2.65, 0.5, 1.0)));
    pa.yz -= vec2(.12, 1.1); d = min(d, box(pa, vec3(2.0, 0.125, 0.1)));
    pa.yz -= vec2(-0.25, 0.2); d = min(d, box(pa, vec3(2.0, 0.125, 0.1)));
    pa.yz -= vec2(-0.25, 0.2); d = min(d, box(pa, vec3(2.0, 0.125, 0.1)));
    
    return d;        
}

float alarm(vec3 p) {
    p += vec3(1.0, -1.0, -0.3);
    return cylinder(p, vec2(0.1));
}

float map(vec3 p) {
    float d = min(door(doorAnim(p)), frame(p));
    d = min(min(d, vault(p)), rails(p));
    return min(min(d, cave(p)), alarm(p));
}

// IFtastic DE version for material selection
int mapID(vec3 p) {
    int id = -1;
    float d = FAR, mind = FAR;
    
    d = door(doorAnim(p)); if (d < mind) {id = 0, mind = d;}
    d = frame(p); if (d < mind) {id = 1, mind = d;}
    d = rails(p); if (d < mind) {id = 1, mind = d;}
    d = vault(p); if (d < mind) {id = 2, mind = d;}
    d = cave(p);  if (d < mind) {id = 3, mind = d;}
    d = alarm(p); if (d < mind) {id = 1, mind = d;}
    
    return id;
}

vec3 normal(vec3 p) {
    vec2 q = vec2(0., PIX);
    return normalize(vec3(map(p+q.yxx) - map(p-q.yxx),
                		  map(p+q.xyx) - map(p-q.xyx),
                		  map(p+q.xxy) - map(p-q.xxy)));
}

struct Material {
    float rough;
    vec3 alb, refl;
};

float box2D(vec2 p, vec2 b) {
	return smoothstep(b.x, b.x-0.01, abs(p.x))*smoothstep(b.y, b.y-0.01, abs(p.y));
}

float circle(vec2 p, float r1, float w) {
    return smoothstep(r1, r1-0.01, length(p)) - smoothstep(r1-w, r1-w-0.01, length(vec2(p.x, 0.65*p.y)));
}

float text(vec2 uv) {
    uv.x += 0.03;
    // one
    vec2 st = uv + vec2(0.1, 0.01);
    float d = box2D(st, vec2(0.04, 0.2));
    st += vec2(0.05, -0.1);
    st = st*cos(0.25*PI) + vec2(-st.y, st.x)*sin(0.25*PI);
    d = max(d, box2D(st, vec2(0.04, 0.08)));
    
    // five
    st = uv - vec2(0.15, 0.15);
    d = max(d, box2D(st, vec2(0.12, 0.04))); st += vec2(0.01, 0.215);
    d = max(d, circle(st, 0.14, 0.08)); st += vec2(0.08, -0.13);
    st = st*cos(0.45*PI) + vec2(st.y, -st.x)*sin(0.45*PI);
    d = max(d, box2D(st, vec2(0.12, 0.04))); st += vec2(0.12, 0.02);
    d -= box2D(st, vec2(0.05, 0.1));
    
    return clamp(d, 0.0, 1.0);
}

vec3 cubeMap(in sampler2D s, vec3 p, vec3 n) {
    vec3 a = texture2D(s, 0.1*p.yz).rgb;
    vec3 b = texture2D(s, 0.1*p.xz).rgb;
    vec3 c = texture2D(s, 0.1*p.xy).rgb;
    n = abs(n);
    return (a*n.x + b*n.y + c*n.z)/(n.x+n.y+n.z);   
}

vec3 bumpMap(in sampler2D s, vec3 p, vec3 n, float c) {
    vec2 q = vec2(0.0, 0.4);
	vec3 grad = -(vec3(cubeMap(s,p+q.yxx, n).b, cubeMap(s,p+q.xyx, n).b, cubeMap(s,p+q.xxy, n).b)-c)/q.y;
    vec3 t = grad - n*dot(grad, n);
    return normalize(n - t);
}

Material getMaterial(vec3 p, inout vec3 n) {
    int id = mapID(p);
    vec3 gamma = vec3(2.2);
    
	vec3 yellow = pow(vec3(255., 255., 93.)/255., gamma);
    vec3 blue = pow(vec3(136., 169., 184.)/255., gamma);
    
    if (id == 0) p = doorAnim(p);
        
    vec3 tex = cubeMap(iChannel0, p, n);
    n = bumpMap(iChannel0, p, n, tex.b);
    tex *= 1.5;
    
    if (id == 1) {
        return Material(60.0, yellow*tex, yellow*tex);
    } else if (id == 2) {
        tex *= blue;
        if (n.y > 0.8) {
            vec2 uv = fract(p.zx-0.5);
            float k = uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y);
    		float col = 1.0-smoothstep(0.1, 0.12, pow(k, 0.5));
    		col += 0.5*(sin(30.0*uv.x)+1.0)*(1.0-col);
    		tex *= col;
        }
    	return Material(30.0, tex, tex);
    } else if (id == 3) {
        vec3 tex2 = cubeMap(iChannel1, p, n);
        vec3 tex3 = cubeMap(iChannel2, p, n);
        float k = fbm(5.0*p);
        tex = mix(tex, tex2, k); tex = mix(tex, tex3, k);
        return Material(20.0, tex, vec3(1.0));
    } else if (id == 0){
        vec2 uv = p.xy;
        tex = yellow*text(uv) + tex*blue;
        return Material(60.0, tex, tex);
    }
    return Material(10.0, vec3(0.0, 1.0, 0.0), vec3(1.0));
}

float calcAO(in vec3 p, in vec3 n) {
	float occ = 0.0;
    for( int i=0; i<5; i++ ) {
        float h = 0.01 + 0.21*float(i)/5.0;
        occ += (h-map(p + h*n));
    }
    return clamp( 1.0 - 2.5*occ/5.0, 0.0, 1.0 );    
}

vec3 blinnPhong(in Material mat, vec3 view, vec3 n, vec3 light_col, vec3 l) {
    vec3 h = normalize(l + view);
    float dif = max(dot(n, l), 0.0);
    float spe = pow(max(dot(n, h), 0.0), mat.rough);
    return (mat.alb + mat.refl*spe)*dif*light_col;
}

vec3 shade(vec3 ro, vec3 rd, float t) {
    vec3 p = ro + t*rd;
    vec3 n = normal(p);
    
    Material mat = getMaterial(p, n);
    float ao = calcAO(p, n);
    vec3 col = vec3(0.0);
    
    // key light
    vec3 alarm_pos = vec3(-1.0, 1.0, 0.5);
    vec3 alarm_l = alarm_pos - p;
    float alarm_decay = dot(alarm_l, alarm_l); alarm_l *= inversesqrt(alarm_decay);
    vec3 alarm_col = vec3(1.5, 2.0, 1.0)*smoothstep(DOOR_QUEUE-4.0, DOOR_QUEUE-3.0, iGT);
    alarm_col *= smoothstep(DOOR_QUEUE+11.0, DOOR_QUEUE+10.0, iGT);
    alarm_col *= pow(abs(dot(alarm_l, vec3(cos(3.*iGT), sin(3.*iGT), 0.))), 5.0);
    alarm_col /= alarm_decay;
    col += blinnPhong(mat, -rd, n, alarm_col, alarm_l);
    
    // fill light
    col += blinnPhong(mat, -rd, n, vec3(0.0, 0.7, 0.25)/(0.5*t*t), -rd);
    
    col *= 0.2 + 1.2*ao;    
    return clamp(col / (col + 1.0), 0.0, 1.0);
}

float raymarch(vec3 ro, vec3 rd) {
    float me = FAR, t = 0.0, hit = -1.0;
    
    for (int i = 0; i < STEPS; ++i) {
        float d = map(ro + t*rd), e = d/t;
        if (e < me) {me = e; hit = t;}
        if (me < PIX || t > FAR) break;
        t += d;
    }
   
    return me < PIX && t < FAR ? hit : -1.0;
}

mat3 lookAt(vec3 p, vec3 t) {
    vec3 z = normalize(p - t);
    vec3 x = normalize(cross(vec3(0.0, 1.0, 0.0), z));
    vec3 y = normalize(cross(z, x));
    return mat3(x, y, z);
}

void camAnim(inout vec3 p, inout vec3 t) {
    p = vec3(0.0, 0.0, 10.0-iGT);
    p.xy -= track(p.z);
    
    p = mix(p, vec3(.8*sin(0.5*iGT-DOOR_QUEUE), 0.0, 2.0), smoothstep(DOOR_QUEUE-4.0, DOOR_QUEUE, iGT));
    p.x = mix(p.x, 0.0, smoothstep(DOOR_QUEUE+2.0, DOOR_QUEUE+10.0, iGT));
    p.z = mix(p.z, -10.0, smoothstep(DOOR_QUEUE+8.0, DOOR_QUEUE+25.0, iGT));
   	t = mix(vec3(0.0), vec3(0.0, 0.0, -10.0), smoothstep(DOOR_QUEUE+8.0, DOOR_QUEUE+10.0, iGT));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 st = fragCoord.xy/iResolution.xy;
	vec2 uv = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0), tar = vec3(0.0); 
    camAnim(ro, tar);
    vec3 rd = normalize(lookAt(ro, tar)*vec3(uv, -1.0));
        
    float t = raymarch(ro, rd);
    vec3 col = t > 0.0 ? shade(ro, rd, t) : vec3(0.0);
    
    col = mix(vec3(0.0), col, smoothstep(0.0, 2.0, iGT));
    col = mix(col, vec3(0.0), smoothstep(DOOR_QUEUE+10.0, DOOR_QUEUE+12.0, iGT));
    
    col = smoothstep(0.0, 0.7, col);
    col *= (0.2 + 0.8*sqrt(32.0*st.x*st.y*(1.0-st.x)*(1.0-st.y)));
    col *= 1.0 - smoothstep( 0.4, 0.41, abs(st.y-0.5) );
    
    col = pow(col, vec3(1.0/2.2));
	fragColor = vec4(col, 1.);
}