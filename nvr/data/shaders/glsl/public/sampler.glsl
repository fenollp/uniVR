// Shader downloaded from https://www.shadertoy.com/view/MlfGRM
// written by shadertoy user w23
//
// Name: sampler
// Description: missed solskogen 2015 deadline :(
const vec2 E=vec2(1.,0.);
const float BPM = 140.;
const float QL = 60. / (BPM * 4.);
const float END = 60. / QL;
float hash(float x){return fract(sin(x)*265871.1723);}
float hash(vec2 x){return hash(dot(x,vec2(11.,313.)));}
float hash(vec3 x){return hash(dot(x,vec3(3.2,57.55,117.234)));}
vec3 hash3(vec3 x) {
    return vec3(hash(x),hash(x.yz),hash(x.x));
}

float noise(vec2 v) {
    vec2 V = floor(v);v-=V;
    return mix(mix(hash(V),hash(V+E.xy),v.x),mix(hash(V+E.yx),hash(V+E.xx),v.x),v.y);
}

float noise(vec3 v) {
    vec3 V = floor(v);v-=V;
    return mix(mix(
    	mix(hash(V),      hash(V+E.xyy),v.x),
        mix(hash(V+E.yxy),hash(V+E.xxy),v.x),v.y),
        mix(mix(hash(V+E.yyx),hash(V+E.xyx),v.x),
        mix(hash(V+E.yxx),hash(V+E.xxx),v.x),v.y),v.z);
}


float time = iGlobalTime;
float line = floor(time / QL);
const vec3 SZ = vec3(24.);
vec3 SUND = normalize(vec3(1.,.8,.3));
const vec3 SUNC = vec3(1.,.9,.7);
const vec3 SKYC = vec3(.22, .43, .76);
//const vec3 SUNC = vec3(1., .9, .5);//vec3(1.,.9,.7);
//const vec3 SKYC = vec3(101.,133.,162.) / 255.;//vec3(.22, .43, .76);

vec3 SKYD = reflect(-SUND, E.yxy);
#define STEPS 64

float max3(vec3 v){return max(v.x,max(v.y,v.z));}

mat3 m_orient(vec3 fwd, vec3 up) {
    fwd = normalize(fwd);
    vec3 right = normalize(cross(fwd, up));
    up = normalize(cross(right, fwd));
    return mat3(right, up, -fwd);
}

float d_box(vec3 a, vec3 sz){return max3(abs(a)-sz);}
vec3 o_rpt(vec3 a, vec3 sp){return mod(a, sp) - sp*.5;}

float w_gnd(vec3 a) {
    float d = 0.;
    if (time < 192. * QL) d = d_box(a-vec3(0.,.5,0.), vec3(SZ.x,1.,SZ.z));
    if (time > 160. * QL)
        d = mix(d, 3. + a.y -
                noise(.08*(a.xz+vec2(.3,.7)*time))*3., smoothstep(160.*QL,192.*QL,time));
    return d;
}

mat3 rotX(float a) {
    float c = cos(a), s = sin(a);
    return mat3(1.,0.,0.,0.,c,s,0.,-s,c);
}
mat3 rotY(float a) {
    float c = cos(a), s = sin(a);
    return mat3(c,0.,-s,0.,1.,0.,s,0.,c);
}

float smtime(float la, float lb, float t) {
    return smoothstep(la * QL, lb * QL, t);
}

float hc(vec3 C) {
    vec3 ndc = normalize(C);
    return pow(noise(ndc*7.),4.);
}

float w_cube(vec3 a) {
    float size =
        mix(22.,16.,smtime(190.,194.,time));
    float d = d_box(a, vec3(size));
    if (line > 262.) {
        float h = hc(a);
        d += mix(1., h*8., step(h,.1)) *
                smtime(262.,266.,time);
        
    }
    return d;
}

float w_clouds(vec3 a) {
    if (time < 62. * QL)
        return 2.;
    float t = line * .125;
    mat3 m = rotX(t*.17) * rotY(t*.23);
    float nz = pow(noise(vec3(a*m*.29)), 5.);
    return mix(2.,
               max(max(-d_box(a, vec3(19.)),d_box(a, vec3(24.))), .16 - nz),
               smtime(62.,66.,time));
}

vec3 ga(vec3 a) {
    if (line > 308.) {
        //vec3 na = a * .125 + vec3(0., 16., -24.+3.*(time - 308.*QL));
        float t = time * .26 - 6.;
        vec3 na = a * .25 + vec3(sin(t*.9)*11., 16., 12.*cos(t));
        return mix(a, na, smtime(308.,324.,time));
    }
    return a;
}

float w(vec3 a) {
    vec3 oa = a;
    float d;
    
    a = ga(a);
    
    d = w_cube(a);
    d = min(d, w_clouds(a));
    
    //d += .001;
    return max(d, d_box(oa, vec3(SZ-1.)));
}


const vec3 CGRASS = vec3(.23,.81,.31);
const vec3 CWATER = vec3(.13,.48,.83);
const vec3 CNOISE = vec3(.8);

const float MGROUND = 0.;
const float MGRASS = 1.;
const float MNOISE = 2.;
const float MBLD0 = 3.;

void mat(in vec3 C, in vec3 p, inout vec3 n, out vec3 c, out vec3 e) {
    p = ga(p);
    vec3 CC = C;
    C = ga(C);
    c = vec3(.5);
    e = vec3(.0);
    if (time < 190. * QL) {
        c = vec3(.5);
        return;
    }
    
    float wcb = w_cube(C);
    float wcl = w_clouds(C);
    
    if (wcb < wcl) {
        if (max3(abs(C)) < 14.) {
            c = vec3(.8,.7,.3) * (.77 + .23 * noise(floor(p*16.)));
            return;
        }
        float tk = smtime(216.,218.,time);
        float kn = .77 + .23 * noise(floor(p*16.));
        c = mix(c, CGRASS * kn, tk);
        tk = smtime(232.,234.,time);
        float h = hc(C);
        c = mix(c, CWATER * kn, tk * step(.1,h));
    } else {
        float tk = smtime(200.,202.,time);
        c = mix(c, vec3(1.) * (.8 + .2 * noise(floor(p*4.)+line*17.)), tk);
        e = mix(e, vec3(.5), tk);
    }
}

vec3 vminc(vec3 v){return step(v.xyz,v.yzx)*step(v.xyz,v.zxy);}
vec3 vmaxc(vec3 v){return step(v.yzx,v.xyz)*step(v.zxy,v.xyz);}

vec4 tracegrid(in vec3 O, in vec3 D, out vec3 N, out vec3 PCI){
    vec3 ci = floor(O);
    PCI = ci;
	vec3 Di = 1. / D, Ds = sign(D);
    vec3 sd = (ci - O + .5 + Ds * .5) * Di;
	
    vec3 n = vec3(0.);
    vec4 ret = vec4(-1.);
	for (int i = 0; i < STEPS; i++) {
        float ww = w(ci + .5);
        if (ww < 0.) {            
		    N = - n * Ds;
		    sd = (ci - O + .5 - Ds * .5) * Di;
            ret.xyz = ci + .5;
            ret.w = max(sd.x,max(sd.y,sd.z));
            break;
        }
        PCI = ci;
		n = vminc(sd);
        sd += n * Ds * Di;
        ci += n * Ds;
        if (any(greaterThan(abs(ci),SZ))) break;
	}
    
    return ret;
}

float occlude(vec3 pci, vec3 p, vec3 n) {
    vec3 nc = sign(n)*vmaxc(abs(n));
    //vec3 nc = abs(n);
    vec3 P = pci + .5;
    p = 2.*(P-p);
    float o = 0.;
    vec3 s1 = nc.yzx, s2 = nc.zxy;
    vec2 uv = vec2(dot(p,s1),dot(p,s2));
    //if (max(abs(uv.x),abs(uv.y))>.97) return vec3(0.);
    vec4 s = step(vec4(w(P+s1),w(P+s2),w(P-s1),w(P-s2)),E.yyyy),
         c = step(vec4(w(P+s1+s2),w(P+s1-s2),w(P-s1+s2),w(P-s1-s2)),E.yyyy);
    
    o += c.x * (1. - uv.x) * (1. - uv.y) * (1. - s.x) * (1. - s.y);
    o += c.y * (1. - uv.x) * (1. + uv.y) * (1. - s.x) * (1. - s.w);
    o += c.z * (1. + uv.x) * (1. - uv.y) * (1. - s.z) * (1. - s.y);
    o += c.w * (1. + uv.x) * (1. + uv.y) * (1. - s.z) * (1. - s.w);
    o *= .5;

    o += s.x * (1. - uv.x);
    o += s.y * (1. - uv.y);
    o += s.z * (1. + uv.x);
    o += s.w * (1. + uv.y);
        
    //return 1. - o / 6.;
    return clamp(o * .125,0.,1.);
}

vec3 shade(
    in vec3 n,
	in vec3 e,
	in vec3 mc,
	in vec3 ld,
    in vec3 lc)
{
    return max(0.,dot(n,ld)) * mc * lc;
}

vec4 bg(vec3 D) {
    float sk = max(0.,dot(SUND,D));
    return vec4(SKYC + SUNC * pow(sk,180.), sk*.9);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

    //   0 -  64 D
    //  64 - 192 D P
    // 192 - 320 D P B
    // 320 - 448   P B L
    // 448 - 560 D P B L
    
#if 0
    //const float LA = 192., LB = 336.;
    const float LA = 304., LB = 368.;
    time = (LA + mod(time / QL, LB-LA)) * QL;
    line = floor(time / QL);
#endif
    
    #define LN(a,b) (b > line && line >= a)
    if LN(512.,516.) {
        float t = time - QL * 512.;
      	time = QL * 512. + mod(t,QL*.5);
    }
    
    if LN(524.,532.) {
        float t = time - QL * 524.;
      	time = QL * 524. - t;
    }
    
    if LN(536.,540.) {
        float t = time - QL * 536.;
      	time = QL * 536. - mod(t,QL*.5);
    }
    
    time = clamp(time, 0., 560. * QL);
    line = clamp(line, 0., 560.);
    
    if (line > 544.) {
        float dl = 560. - 544.;
        float t = time - QL*544.;
        float T = dl * QL;
        time = QL * 544. + t * (1. - t / (2. * T));
    }

    if (time > 532. * QL) time -= 16. * QL;
    
    line = floor(time / QL);
    
	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    uv.x *= iResolution.x/iResolution.y;
    
    float R = mix(200.,64.,smoothstep(0.,QL*64.,time));
    float RF = R + 23.;
    
    
    float a = 2.*sin(time*.3), b = sin(time*.2+3.);
    if (iMouse.z > 0.) {
        a = iMouse.x / iResolution.x * 9.;
        b = (.5 - iMouse.y / iResolution.y) * 64.;
    }
    float htk = smtime(192.,320.,time);
    
    vec3 O = vec3(R*cos(a),
                  SZ.y * 2. * (htk - 1.) + 16. * (b + htk),
                  R*sin(a));
    vec3 D = m_orient(-O, vec3(0.,.9+.1*sin(time*.3),cos(time*.7)*.1)) * normalize(vec3(uv,-2.));
    float ls = 0.;
    
    if (O.x > SZ.x && D.x < 0.) ls = max(ls, (SZ.x - O.x) / D.x);
    if (O.y > SZ.y && D.y < 0.) ls = max(ls, (SZ.y - O.y) / D.y);
    if (O.z > SZ.z && D.z < 0.) ls = max(ls, (SZ.z - O.z) / D.z);
    if (O.x < -SZ.x && D.x > 0.) ls = max(ls, (- SZ.x - O.x) / D.x);
    if (O.y < -SZ.y && D.y > 0.) ls = max(ls, (- SZ.y - O.y) / D.y);
    if (O.z < -SZ.z && D.z > 0.) ls = max(ls, (- SZ.z - O.z) / D.z);
    
    vec4 bc = bg(D);
    vec3 color = bc.rgb;
    
    vec3 N, CI;
    vec4 x = tracegrid(O+D*ls, D, N, CI);
    if (x.w > 0.)
    {
        ls += x.w;
        vec3 p = O + D * ls;
        vec3 mc, me;
        mat(x.xyz, p, N, mc, me);
        //mc = vec3(.5);
        float o = occlude(CI,p,N);
        //o = 1. - o*o;
        o = 1. - o;
        
        color = me;
        //color += .5 * mc * o;
        color += o * mc * bg(N).rgb;//normalize(N+.1*hash3(N+time))).rgb;
        //color += occlude(CI,p,N) * shade(N,D,mc,SKYD,SKYC);
        
        vec3 _n, _c;
        vec4 shd = tracegrid(p + N * .1, SUND, _n, _c);
        color += step(shd.w, 0.) * shade(N,D,mc,SUND,SUNC);
        
        color = mix(color, bc.rgb, clamp(pow(ls/RF, 2.),0.,1.));
    }
    
    color += SUNC * pow(bc.a,8.);
    
    fragColor = vec4(sqrt(color), 1.);
}