// Shader downloaded from https://www.shadertoy.com/view/XlfXzM
// written by shadertoy user glk7
//
// Name: Reactive Sphere
// Description: A reactive ray marched sphere. The typical sphere perturbed by a couple ceiled sin waves based on some frequencies of the music played.
// Created by genis sole - 2015
// License Creative Commons Attribution 4.0 International License.

// Enable more representative frequency analysis.
//#define CF 

// Toggle non-reactive version.
// #define S

vec4 freqs = vec4(0.6, 0.7, 0.2, 0.2);

vec4 FreqAnalysis() {
#ifdef S
    return freqs;
#endif
    
    vec4 sy = vec4(0.0);    
    
#ifdef CF
    // 0.25 / (512 / 4) = 0.001953125
    for(float i = 0.0; i < 0.25; i += 0.001953125) {
   		sy.x += texture2D(iChannel0, vec2(i, 0.0)).x;
    }
    
    for(float i = 0.25; i < 0.5; i += 0.001953125) {
   		sy.y += texture2D(iChannel0, vec2(i, 0.0)).x;
    }
    
    for(float i = 0.5; i < 0.75; i += 0.001953125) {
   		sy.z += texture2D(iChannel0, vec2(i, 0.0)).x;
    }
    
    for(float i = 0.75; i <= 1.0; i += 0.001953125) {
   		sy.w += texture2D(iChannel0, vec2(i, 0.0)).x;
    }
    sy *= vec4(0.0078125); // 1 / (512 / 4) = 0.0078125
    
#else
    
    sy.x = texture2D(iChannel0, vec2(0.0, 0.0)).x;
	sy.y = texture2D(iChannel0, vec2(0.33, 0.0)).x;
    sy.z = texture2D(iChannel0, vec2(0.66, 0.0)).x;
    sy.w = texture2D(iChannel0, vec2(1.0, 0.0)).x;
    
#endif
    
    return sy;
    //return step(0.01, iChannelTime[0])*sy + (1.0 - step(0.01, iChannelTime[0]))*freqs;
}


vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float sin3(in vec3 p) {
	return (sin(p.x) + sin(p.y) + sin(p.z));
}

float noise(in vec3 p) {
    float j = iGlobalTime * 0.045;
    float v = (sin3((p+vec3(j*7.0, j*2.3, j*1.0)) * 10.0) * freqs.w +
               sin3((p+vec3(j*3.0, j*1.2, j*0.4)) * 8.0) * freqs.z +
               sin3((p+vec3(j*2.4, j*0.6, j*2.6)) * 6.0) * freqs.y +
               sin3((p+vec3(j*1.4, j*5.8, j*1.9)) * 4.0) * freqs.x) * 0.25;
    //return 0.0;
    
    v = abs(v);
    float f = floor(v*10.0);
    
    v = clamp((smoothstep(0.0, 1.0, mix(0.1, 0.2, v*10.0-f)) + f)* 0.1, 0.0, 1.0);
    return v;
}

// Taken from http://iquilezles.org/www/articles/palettes/palettes.htm
vec3 ColorPalette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}


bool RaySphereIntersection(in vec3 ro, in vec3 rd, in vec3 c, in float r, out vec3 p0, out vec3 p1) {
    p0 = vec3(0.0);
    p1 = vec3(0.0);
    
   	vec3 oc = ro - c;
    float poc = dot(rd, oc);
    
    float sloc = dot(oc, oc);
    float test = poc*poc - sloc + r*r;
        
    if (test < 0.0) return false;
    
    float sqt = sqrt(test);
    float d0 = -poc - sqt;
    float d1 = -poc + sqt;
    
	p0 = ro + d0*rd;
    p1 = ro + d1*rd;
    return true;
}

vec3 SphereNormal(in vec3 d, in float r, in float e) {
    float theta = atan(d.y,d.x) ;
    float phy = acos(d.z);
    
    vec3 dy0 = vec3(cos(theta+e)*sin(phy), sin(theta+e)*sin(phy), cos(phy));
    vec3 dy1 = vec3(cos(theta-e)*sin(phy), sin(theta-e)*sin(phy), cos(phy));

    vec3 dx0 = vec3(cos(theta)*sin(phy+e), sin(theta)*sin(phy+e), cos(phy+e));
    vec3 dx1 = vec3(cos(theta)*sin(phy-e), sin(theta)*sin(phy-e), cos(phy-e));
    
    float ny0 = noise(dy0*r);
    float ny1 = noise(dy1*r);
    float nx0 = noise(dx0*r);
    float nx1 = noise(dx1*r);
    
    dy0 *= r + ny0;
    dy1 *= r + ny1;
    dx0 *= r + nx0;
    dx1 *= r + nx1;
    
    return normalize(cross(dy0 - dy1, dx1 - dx0));
}

bool RayMarchPerturbedSphere(in vec3 ro, in vec3 rd, in vec3 c, in float r, in float br, 
                             out vec3 n, out vec3 sd) {
    n = vec3(0.0);
    sd = vec3(0.0);
    
    vec3 bp0 = vec3(0.0);
    vec3 bp1 = vec3(0.0);
    bool bres = RaySphereIntersection(ro, rd, c, br, bp0, bp1);
    if (!bres) return false;
    
    vec3 p0 = vec3(0.0); 
    vec3 p1 = vec3(0.0);
    bool res = RaySphereIntersection(ro, rd, c, r, p0, p1); 
    
    float dist = float(res)*length(p0 - bp0) + (1.0-float(res)) * length(bp0 - bp1);
	//float dist = length(bp0 - bp1);
    const float sc = 128.0;
    const float invsc = 1.0 / sc;
    float s = dist * invsc;
    
    bool ret = false;
    vec3 pn = vec3(0.0);
    for (float d = 0.0; d < sc; ++d) {
    	pn = (bp0 + d*s*rd) - c;
		
        sd = normalize(pn) * r;
        float h = length(pn) - r - s;
        
        float h0 = noise(sd);
        if (h0 > h) {
            ret = true;
            break;
        } 
    }
    
    n = SphereNormal(normalize(pn), r, s);
    return ret;
}


// Based on this: http://iquilezles.org/www/articles/rmshadows/rmshadows.htm        
float ShadowFactor(in vec3 sd, in vec3 ld, in vec3 c, in float r, in float br) {
    float w = noise(sd);
    vec3 ro = c + (normalize(sd) * (w+r));
    
    vec3 bp0 = vec3(0.0);
    vec3 bp1 = vec3(0.0);
    bool bres = RaySphereIntersection(ro, -ld, c, br, bp0, bp1);
    
    vec3 p0 = vec3(0.0);
    vec3 p1 = vec3(0.0);
    bool res = RaySphereIntersection(ro, -ld, c, r, p0, p1);
    
    float dist = min(length(ro - bp0)+ float(!bres) * 10000.0, 
                     length(ro - p0) + float(!res) * 10000.0);
    
    const float sc = 128.0;
    const float invsc = 1.0 / sc;
    float s = dist * invsc;
    
    float dmin = 1.0;
    
    for (float d = 0.0; d < sc; ++d) {
    	vec3 pn = (ro + d*s*-ld) - c;
		
        sd = normalize(pn) * r;
        float h = length(pn) - r + s;
        
        float h0 = noise(sd);
        if (h0 > h) {
            dmin = 0.0;
            break;
        }
        
        dmin = min(dmin, 4.0*(h-h0)/(d*s));
    }
    
    return clamp(dmin, 0.0, 1.0);
    
}


vec3 GetColor(vec3 sd) {
    float n = noise(sd);
    vec3 c = ColorPalette(n, vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5),
                             vec3(1.0, 1.0, 0.5), vec3(0.4, 0.3, 0.5));
    
    c = rgb2hsv(c);
    c.y += 0.30;
    c.z += 0.1;
    c = hsv2rgb(c);
    
    return c;
    
}

vec3 CameraRay(vec2 fragCoord, float n) {
    float a = 1.0/max(iResolution.x, iResolution.y);
    
    return normalize(vec3((fragCoord - iResolution.xy*0.5)*a, n));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 rd = CameraRay(fragCoord, 1.0);
    
    vec3 sc = vec3(0.0, 0.0, 10.0);
    float sr = 1.0;
 
    vec3 n = vec3(0.0);
    vec3 sd = vec3(0.0);
    if (RaySphereIntersection(vec3(0.0), rd, sc, sr+1.0, n, sd)) {
        freqs = FreqAnalysis();
    }
    
    bool hit = RayMarchPerturbedSphere(vec3(0.0), rd, sc, sr, sr+1.0, n, sd);
    
    vec3 color = vec3(0.05);
    if (hit) {
        
        float w = max(max(freqs.x,freqs.y) , max(freqs.z, freqs.w));
        vec2 nM = vec2(sin(iGlobalTime*1.4), cos(iGlobalTime*1.2));
        
        vec3 l = normalize(vec3(-(nM.x*2.0 -1.0), -(nM.y*2.0 - 1.0), -0.9 + w*3.0));
        
        float sf = ShadowFactor(sd, l, sc, sr, sr+1.0);
        
        color = GetColor(sd);
        vec3 diff = color * max(dot(-l, n), 0.0 ) * sf * 0.95;
        vec3 amb = color * 0.05;
        
        color = diff;
    	color += amb;
    }
    
    fragColor = vec4(pow(color, vec3(0.55)), 1.0);
}