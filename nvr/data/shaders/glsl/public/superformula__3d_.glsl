// Shader downloaded from https://www.shadertoy.com/view/XlXXDs
// written by shadertoy user mech4rhork
//
// Name: Superformula (3D)
// Description: testing Johan Gielis's superformula&trade; in 3D
#define PI 3.14159265359
#define time iGlobalTime

#define ANIM
#define speed 5.
//#define MSAA
#define MSAA_SAMPLES 4
#define SHADOWS


const vec2 renderRange = vec2(0.001, 300.0);
// parameters ( shape1, shape2 ) // another cool shape // another
vec2 m  = vec2( 12, 3 ),   // 10, 4   // 12, 6      // 1, 10
     a  = vec2( 1, -4 ),   // .9, .6  // 1, .9      // 1, 1
     b  = vec2( .2, .2 ),  // -1, -.5 // .25, 10    // 1, 1
     n1 = vec2( -.4, .3 ), // 1, 1    // .05, -.05  // 1, 1
     n2 = vec2( 2, 1 ),    // 3, .2   // 25, 20     // 1, 1
     n3 = vec2( 1, 1 );    // 4, -1   // 9.79225, 8 // 1, 1
vec3 rd; // ray direction - used in map()
vec4 S1, S2; // m, n1, n2, n3
vec2 S1_ab, S2_ab; // a, b

vec2 rotate( vec2 p, vec2 c, float theta ) {
    float co=cos(theta), si=sin(theta);
    return (p-c)*mat2(co,-si,si,co);
}
vec3 rotate( vec3 p, vec3 theta ) {
    float cx=cos(theta.x), sx=sin(theta.x), cy=cos(theta.y),
          sy=sin(theta.y), cz=cos(theta.z), sz=sin(theta.z);
    p.yz*=mat2(cx, -sx, sx, cx); p.xz*=mat2(cy, -sy, sy, cy); p.xy*=mat2(cz, -sz, sz, cz);
    return p;
}
float superformula( float m, float a, float b, float n1, float n2, float n3, float phi ) {
    return pow(pow(abs(cos(m*phi/4.)/a), n2) + pow(abs(sin(m*phi/4.)/b), n3), -n1);
}
vec4 shape2d( float m, float a, float b, float n1, float n2, float n3, vec2 p ) {
    p *= 1.+(abs(a-b)+abs(n1-n2)+abs(n1-n3)+abs(n2-n3));
    float rd = length(p) - superformula(m, a, b, n1, n2, n3, atan(p.y/p.x));
    float alpha = step(0., rd*10.); // alpha = step(2.0, abs(rd*10.0)); // for outline
    return vec4(vec3(.37), 1.-alpha);
}
float shape3d( vec3 p ) {
    float d = length(p); 
    float theta = atan(p.z/p.x); // longitude
    float phi = asin(p.y/d); // latitude
    float r1 = superformula(m.x, a.x, b.x, n1.x, n2.x, n3.x, theta);
    float r2 = superformula(m.y, a.y, b.y, n1.y, n2.y, n3.y, phi);
    vec3 q = r2 * vec3(r1*cos(theta)*cos(phi), r1*sin(theta)*cos(phi), sin(phi));
	return d - length(q);
}
float map( vec3 p ) {
    float d = shape3d(p);
	float s = d*.5, dr = (d-shape3d(p + rd*s))/s; // from eiffie
	return d / (1.+max(dr, 0.)); // this one too
}
float castRay( vec3 ro, vec3 rd ) {
    float startDelta=renderRange.x, delta=startDelta, stopDelta=renderRange.y;
    float maxDist = 0.002;
    for(int i = 0; i < 64; i++) {
        float dist = map(ro + rd * delta);
        if(dist <= maxDist || dist > stopDelta) break;
        delta += dist;
    }
    return delta;
}
vec3 calcNormal( vec3 pos ) {
    float delta = 0.01;
    vec2 unit = vec2(1.0, 0.0);
    return normalize( vec3(
            map(pos + unit.xyy*delta) - map(pos - unit.xyy*delta),
            map(pos + unit.yxy*delta) - map(pos - unit.yxy*delta),
            map(pos + unit.yyx*delta) - map(pos - unit.yyx*delta)));
}
float calcSSS( vec3 pos, vec3 lig ) {
    float sss = 0.0, sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float delta = 0.01 + 0.03*float(i);
        vec3 sspos = pos + lig*delta;
        float dist = map(sspos);
        sss += -(dist - delta)*sca;
        sca *= 0.95;
    }
    return clamp(1. - 3.0*sss, 0., 1.);
}
// by iq
float calcAO( in vec3 pos, in vec3 nor ) {
	float occ = 0.0, sca = 1.0;
    for(int i = 0; i < 4; i++) {
        float hr = 0.01 + 0.03*float(i);
        vec3 aopos = nor*hr + pos;
        float dd = map(aopos);
        occ += -(dd - hr)*sca;
        sca *= 0.97;
    }
    return clamp(1. - 3.*occ, 0., 1.);    
}
// based on softshadow() by iq
float calcSoftShadow( vec3 ro, vec3 rd, float mint, float tmax, int samples ) {
	float res=1.0, t=mint, stepDist=(tmax - mint)/float(samples);
    for(int i = 0; i < 64; i++) {
		float h = map(ro + rd*t);
        res = min(res, 8.0*h / t);
        t += clamp(h, stepDist, 1e10);
        if(h < 0.001 || t > tmax) break;
    }
    return clamp(res, 0., 1.);
}
vec4 render( vec3 ro, vec3 rd ) {
    // color
    vec3 col = vec3(0);
    #ifndef ANIM
    float t = 2. + m.x+m.y + n1.x+n1.y,
          ps = m.x+m.y+a.x+a.y+b.x+b.y+n1.x+n1.y+n2.x+n2.y+n3.x+n3.y;
    vec3 com = 0.3 + 0.3*(0.5+vec3( .5*sin(ps + 2.*t), .5*sin(ps + 3.*t), .5*sin(ps + 4.*t) ));
    float maxCom = max(com.r, max(com.g, com.b));
    vec3 f = 0.8*(1.0 + vec3(step(1., com.r/maxCom), step(1., com.g/maxCom), step(1., com.b/maxCom)));
    col += com * f;
    #else
    col = vec3(.33,.49,.81)*(1.15 + .2*vec3(sin(m.x+a.y-n1.x+n3.y), cos(m.x+a.y-n1.y+n3.x), sin(m.y+a.y-n1.x+n2.y)));
    #endif
    
    float dist = castRay(ro, rd);
    vec3 pos = ro + rd * dist;
    
    if(dist > renderRange.y) return vec4(0); // background
    else {
        vec3 lig = normalize(vec3(1,3,-2)),
             nor = calcNormal(pos),
             ref = reflect(rd, nor);
        float dif = clamp(dot(nor, lig), 0., 1.),
              spe = pow(clamp(dot(reflect(-lig, nor), -rd), 0., 1.), 25.),
              fre = pow(clamp(1.0 + dot(nor, rd), 0., 1.), 5.),
              dom = smoothstep(-0.15, 0.15, ref.y),
              amb = 1.0,
              occ = calcAO(pos, nor),
              sss = calcSSS(pos, lig);
        #ifdef SHADOWS
        dif *= calcSoftShadow(pos, lig, .001, 3.1, 40);
        #endif
        vec3 brdf = vec3(0);
        brdf += 0.8 * dif;
        brdf += 1.0 * spe * dif;
    	brdf += 0.3 * amb * occ;
        brdf += 0.1 * fre * occ;
        brdf += 0.1 * dom * occ;
        brdf += 0.2 * sss * occ;
        col *= brdf;
    }
    return vec4(col, 1);
}
vec4 renderAA( vec3 ro, vec3 rd ) {
    const int k = (MSAA_SAMPLES < 0) ? 1 : MSAA_SAMPLES;
    vec4 c = vec4(0); // color
	vec2 o = vec2(10, 0); // offset
    o = rotate(o, vec2(0), PI/8.0);
    for(int i = 0; i < k; i++) {
        c += render(ro + o.x/iResolution.x, rd) / float(k);
        o = rotate(o, vec2(0), 2.*PI/float(k));
    }
    return c;
}
vec4 params( float t ){
	t=mod(t,10.0);
	if(t<1.0)return vec4(2., .9, 1.6, 2.5);
	if(t<2.0)return vec4(8, .2, -1.9, 1);
    if(t<3.0)return vec4(7, .8, 1, -1.39);
    if(t<4.0)return vec4(9, 1, 1, 1);
    if(t<5.0)return vec4(12, .1, 1.05, 4);
    if(t<6.0)return vec4(5, 1, 2, 2);
    if(t<7.0)return vec4(-4, 2, .4, 1.04);
    if(t<8.0)return vec4(-2, 1, 2, 6);
    if(t<9.0)return vec4(7, 1, 1, 1);
    if(t<10.)return vec4(8, 1, -1, 1);
    return vec4(7, 1, 4, -1);
}
vec2 params_ab( float t ){
	t=mod(t,10.0);
	if(t<1.0)return vec2(.8, 1.);
	if(t<2.0)return vec2(-1, 1);
    if(t<3.0)return vec2(-1, .95);
    if(t<4.0)return vec2(1.3, 1.);
    if(t<5.0)return vec2(-1, 1.3);
    if(t<6.0)return vec2(1.3, 1);
    if(t<7.0)return vec2(-1, 1.5);
    if(t<8.0)return vec2(1.3, 1.3);
    if(t<9.0)return vec2(1.15, 1);
    if(t<10.)return vec2(1, .9);
    return vec2(1.4, 1);
}

void mainImage( out vec4 o, in vec2 uv ) {
	vec2 R = iResolution.xy,
         p = (2.*uv - R)/R.y, q = p,
         mo = -(iMouse.xy / R - 0.5)*2.;
    p *= 3.0;
    
    // background
    o = vec4(vec3(.099), 1);
    
    // animation - from effie
    #ifdef ANIM
    float t = time*0.25*speed;
    S1 =    mix(params(t-1.),    params(t),    smoothstep(0.,1./speed*10.,fract(t)*2.));
    S1_ab = mix(params_ab(t-1.), params_ab(t), smoothstep(0.,1./speed*10.,fract(t)*2.)); t /= 10.;
    S2 =    mix(params(t-1.),    params(t),    smoothstep(0.,1./speed,fract(t)*2.));
    S2_ab = mix(params_ab(t-1.), params_ab(t), smoothstep(0.,1./speed,fract(t)*2.));
    m=vec2(S1.x, S2.x); n1=vec2(S1.y, S2.y); n2=vec2(S1.z, S2.z); n3=vec2(S1.w, S2.w);
    a=vec2(S1_ab.x, S2_ab.x); b=vec2(S1_ab.y, S2_ab.y); 
    #endif
    
    // 2d shape 1
    vec4 col = shape2d(m.x, a.x, b.x, n1.x, n2.x, n3.x, p - vec2(-3.0, 1.5));
    o = mix(o, vec4(col.rgb, 1.), col.a);
    // 2d shape 2
    col = shape2d(m.y, a.y, b.y, n1.y, n2.y, n3.y, p - vec2(-3.0, -1.5));
    o = mix(o, vec4(col.rgb, 1.), col.a);
    
    // 3d shape (raymarching)
    float camDist = 20.;
    vec2 drot = vec2(mo.x*PI*1.1, mo.y*PI/3.*1.1);
    vec3 camPos = rotate(vec3(-camDist, 0, -camDist), vec3(drot.y, drot.x, 0));
    vec3 forward=normalize(vec3(vec3(0)-camPos)), right=normalize(cross(vec3(0,1,0), forward)), up=cross(forward, right);
    vec3 rayDir = mat3(right, up, forward) * normalize(vec3(q-vec2(0.48, -.125), R.y / R.x * 12.5)); rd = rayDir;
    #ifdef MSAA
    col = renderAA(camPos, rayDir);
    #else
    col = render(camPos, rayDir);
    #endif
    o = mix(o, vec4(col.rgb, 1.), col.a);
}