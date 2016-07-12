// Shader downloaded from https://www.shadertoy.com/view/4s3SWs
// written by shadertoy user richm
//
// Name: TheBadOmen
// Description: theme is good versus evil
/* richm may 2016 */

mat2 rot(float t)
{
	return mat2(cos(t), sin(t), -sin(t), cos(t));
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float pentagram(vec3 p)
{
    float d = 0.0;
    float fp = 1.0;
    mat2 rm = rot(6.283185 / 5.0 * 3.0);
    vec2 pa = vec2(1.0, 0.0);
    vec2 pb = pa * rm * rm;
    for (int i = 0; i < 5; ++i) {
        vec2 del = normalize(pa - pb);
        mat2 xfm = mat2(del.x, del.y, -del.y, del.x);
        vec2 q = p.xz * xfm;
        float r = max(abs(q.x - 0.75) - 0.0125, abs(q.y) - 2.0);
        d = min(d, r);
        d = mix(d, r, fp);
        pa *= rm;
        pb *= rm;
        fp = 0.0;
    }
    float c = length(p.xz);
    c = max(c - 2.25, 2.2 - c);
    d = min(d, c);
    return d;
}

float mapmat = 0.0;
float mapdel = 0.0;
vec2 maptex = vec2(0.0);

float map(vec3 p)
{
    mapmat = 0.0;
    mapdel = 0.0;
    
	float d = 2.0 + p.y;
    float pen = pentagram(p);
    mapdel = abs(d - pen);
    if (pen < d) {
        d = max(pen, d);
        mapmat = 1.0;
    }
    
    float room = -sdBox(p, vec3(6.0, 8.0, 6.0));
    if (room < d) {
        d = min(d, room);
        mapmat = 2.0;
    }
    
    vec3 q = p;
    q.xz = abs(q.xz);
    q.xz = q.xz - vec2(3.0, 4.0);
    q.xz *= rot(3.14159 * 0.25);
    float mbox = sdBox(q, vec3(0.1, 3.0, 2.0));
    if (mbox < d) {
        d = mbox;
        mapmat = 3.0;
        maptex = 1.0 - q.zy * 2.0;
    }
    
    vec3 wp = p - vec3(-5.0, 2.0, 0.0);
    float wbox = sdBox(wp, vec3(5.25, 1.5, 0.2));
    if (-wbox > d) {
        d = max(d, -wbox);
        mapmat = -1.0;
    }
    
    wp = p - vec3(-5.0, 2.6, 0.0);
    wbox = sdBox(wp, vec3(5.25, 0.2, 1.0));
    if (-wbox > d) {
        d = max(d, -wbox);
        mapmat = -1.0;
    }
    
    wp = p - vec3(4.0, -2.0, 0.0);
    wbox = sdBox(wp, vec3(0.05, 1.0, 0.05));
    if (wbox < d) {
        d = min(d, wbox);
        mapmat = -2.0;
    }
    
    wp = p - vec3(4.0, -1.3, 0.0);
    wbox = sdBox(wp, vec3(0.05, 0.05, 0.25));
    if (wbox < d) {
        d = min(d, wbox);
        mapmat = -2.0;
    }
    
    return d;
}

vec3 normal(vec3 p)
{
    vec3 o = vec3(0.00001, 0.0, 0.0);
    return normalize(vec3(map(p+o.xyy) - map(p-o.xyy),
                          map(p+o.yxy) - map(p-o.yxy),
                          map(p+o.yyx) - map(p-o.yyx)));
}

float trace(vec3 o, vec3 r)
{
 	float t = 0.0;
    for (int i = 0; i < 32; ++i) {
        vec3 p = o + r * t;
        float d = map(p);
        t += d;
    }
    return t;
}

vec3 blood(vec3 p, vec3 r, float mat, float del)
{
    vec3 tex = texture2D(iChannel0, p.xz * 0.25).xyz;
    float spt = tex.x;
    spt = spt * 2.0 - 1.0;
    spt = sin(spt * 3.14159 * 5.0);
    tex *= tex;
    
    vec3 from = vec3(0.8, 0.2, 0.1);
    vec3 to = vec3(1.0, 1.0, 1.0);

    float mdp = 1.0 - pow(1.0 - min(del,0.5), 8.0);
    mdp = mix(mdp, 0.0, mat);
    float prod = max(-r.y, 0.0);
    float bld = 1.0 - 1.0 / (1.1 + mdp + spt);
    bld = mix(1.0, bld, 1.0-mdp);
    tex = vec3(pow(1.0 - tex.x, 1.0));
    return tex * mix(from, vec3(1.0), bld);
}

vec3 texture(vec3 p)
{
	vec3 ta = texture2D(iChannel0, p.yz).yyy;
	vec3 tb = texture2D(iChannel0, p.xz).yyy;
	vec3 tc = texture2D(iChannel0, p.xy).yyy;
    return (ta*ta + tb*tb + tc*tc) / 3.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 r = normalize(vec3(uv, 1.0 - dot(uv, uv) * 0.33));
    r.yz *= rot(-1.57 * 0.05);
    r.xz *= rot(iGlobalTime * 0.5);
    vec3 o = vec3(0.0, 0.0, -3.0);
    o.xz *= rot(iGlobalTime * 0.5);
    
    vec3 fc = vec3(1.0);
    float ft = 0.0;
    
    vec3 lpos = vec3(-2.0, 1.5, 0.0);
    
    for (int i = 0; i < 8; ++i) {
    
        float t = trace(o, r);
        ft += t;
        vec3 w = o + r * t;
        vec3 sn = normal(w);
        float fog = 1.0 / (1.0 + ft * ft * 0.05);
        
        vec3 ldel = w + sn * 0.01 - lpos;
        float ldist = length(ldel);
        ldel /= ldist;
        vec3 lit = vec3(1.0) / (1.0 + ldist * ldist * 0.01);
        
        if (mapmat < 3.0) {
            float premat = mapmat;
            float predel = mapdel;
            float lt = trace(lpos, ldel);
            float lm = max(sign(lt - ldist), 0.0);
            lit *= lm * max(dot(sn, -ldel), 0.0);
            lit *= fog;
            if (premat < 2.0) {
                if (premat == -1.0) {
                    fc *= vec3(1.0);
                } else if (premat == -2.0) {
                    fc *= texture(w * 0.125) * lit * 4.0;
                } else {
                	fc *= blood(w, r, premat, predel) * lit;
                }
            } else {
                fc *= texture(w * 0.125) * lit;
            }
            break;
        }

        vec3 dirt = texture2D(iChannel0, maptex * 0.125).xyz;
        float fres = abs(dot(r, -sn));
        float fade = 1.0 - float(i) / 7.0;
        fc = mix(fc, vec3(dirt), fres) * lit * fade;
        
        o = w + sn * 0.01;
        r = reflect(r, sn);
    }
    
	fragColor = vec4(sqrt(fc), 1.0);
}