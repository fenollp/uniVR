// Shader downloaded from https://www.shadertoy.com/view/XdKGW1
// written by shadertoy user glk7
//
// Name: BufferCubemap
// Description: Custom cubemaps using multipass buffers. The cubemap is rendered on the first frame and can be recomputed pressing the space key (useful when switching to/from fullscreen).&lt;br/&gt;&lt;br/&gt;The test scene is iq's Elevated (https://www.shadertoy.com/view/MdX3Rr)
// Created by genis sole - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

vec4 BufferCubemap(in sampler2D buffer, in float bufferAspect, in vec3 d) 
{
    vec3 c = 0.5 / d;
    vec3 t = min(-c, c);
    float f = max(max(t.x, t.y), t.z);
    
    vec3 p = -d*f;
    vec3 n = step(1e-7, abs(p + 0.5)) - step(1e-7, abs(0.5 - p));
    
    vec2 px = vec2(-p.z*n.x, p.y) * abs(n.x);
    vec2 py = vec2(p.x*n.y, -p.z) * abs(n.y);
    vec2 pz = vec2(p.x*n.z, p.y) * abs(n.z);

    float tx = ((1.0 - step(-0.5, n.z))*2.0 + 
                abs(n.x) + (1.0 - step(-0.5, n.x))*2.0) * (1.0 - abs(n.y)) +
                (1.0 - step(-0.5, n.y))*3.0 * abs(n.y);
    
	float ty = abs(n.y) * (1.0 - (2.0 - 4.0/bufferAspect));
    
    vec2 uv = (vec2(tx, ty) + (px + py + pz) + 0.5) * vec2(0.25, bufferAspect*0.25);
    return texture2D(buffer, uv, -100.0);
}

bool IRaySphere(in vec3 ro, in vec3 rd, in vec3 c, in float r, out vec3 p0, out vec3 p1) 
{
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

#define PI 3.14159
#define TAU 2.0*PI

void CameraOrbitRay(in vec2 fragCoord, in float n, in vec3 c, in float d, 
                    out vec3 ro, out vec3 rd, out mat3 t) 
{
    float a = 1.0/max(iResolution.x, iResolution.y);
    rd = normalize(vec3((fragCoord - iResolution.xy*0.5)*a, n));
 
    ro = vec3(0.0, 0.0, -d);
    
    float ff = min(1.0, step(0.001, iMouse.x) + step(0.001, iMouse.y));
    vec2 m = PI*ff + vec2(((iMouse.xy + 0.1) / iResolution.xy) * TAU);
    m.y = -m.y;
    
    mat3 rotX = mat3(1.0, 0.0, 0.0, 0.0, cos(m.y), sin(m.y), 0.0, -sin(m.y), cos(m.y));
    mat3 rotY = mat3(cos(m.x), 0.0, -sin(m.x), 0.0, 1.0, 0.0, sin(m.x), 0.0, cos(m.x));
    
    t = rotY * rotX;
    
    ro = t * ro;
    ro = c + ro;

    rd = t * rd;
    
    rd = normalize(rd);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float buffer_aspect = iChannelResolution[1].x / iChannelResolution[1].y;
    
    vec3 ro = vec3(0.0);
    vec3 rd = vec3(0.0);
    mat3 t = mat3(1.0);
    
    CameraOrbitRay(fragCoord, 0.5, vec3(0.0), 5.0, ro, rd, t);
    
    vec3 p0 = vec3(0.0);
    vec3 p1 = vec3(0.0);
    
    fragColor = vec4(vec3(0.0), 1.0);
    if (IRaySphere(ro, rd, vec3(0.0), 1.5, p0, p1)) {
        vec3 n = normalize(p0);
        vec3 r = reflect(rd, n);
        
    	fragColor = BufferCubemap(iChannel1, buffer_aspect, r);
    }
    else fragColor = BufferCubemap(iChannel1, buffer_aspect, rd);
    
    fragColor = vec4(pow(fragColor.rgb, vec3(0.55)), 1.0); 
}