// Shader downloaded from https://www.shadertoy.com/view/4l23DD
// written by shadertoy user aiekick
//
// Name: Mirage Ball
// Description: Mirage Ball
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define mpi 3.14159
#define m2pi 6.28318

// tex2d to sphere 3d
vec2 uvMap(vec3 p)
{
    p = normalize(p);
    vec2 tex2DToSphere3D;
    tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / m2pi;
    tex2DToSphere3D.y = 0.5 - asin(p.y) / mpi;
    return tex2DToSphere3D;
}

vec4 displace(vec2 uv)
{
    vec3 tex = texture2D(iChannel1, uv).rgb;
    
    return vec4(dot(tex, vec3(0.02)), tex);
}

vec4 map(vec3 p, float d)
{
    vec4 c = displace(uvMap(p));
    float dist = length(p) -1.;
    c.x = dist - c.x;
    return c;
}

vec3 nor(vec3 p, float prec, float d)
{
    vec2 e = vec2(prec, 0.);
    
    float x = map(p+e.xyy,d).x - map(p-e.xyy,d).x; 
    float y = map(p+e.yxy,d).x - map(p-e.yxy,d).x; 
    float z = map(p+e.yyx,d).x - map(p-e.yyx,d).x;  
    
    vec3 n = vec3(x,y,z);
        
    return normalize(n); 
}

vec4 scene(vec4 col, vec3 ro, vec3 rd)
{
    vec2 md = vec2(0.000001, 20.); // distance mini / maxi du ray marcher pour l'evaluation de la distance avec la map 
    float s = md.x; // rayon de sphere du sphere tracer
    float d = 0.; // distance to ro // somme des rayons de sphere
    vec3 p = ro+rd*d; // point trouve sur la map
    
    vec2 hit = vec2(0.); 
    
    float b = 0.35;
    
    vec4 c;
    
    float t = 1.1*(sin(iGlobalTime*.3)*.5+.6);
    
    // evaluation de la map
    for(int i=0;i<100;i++)
    {
        hit = vec2(s/md.x,s/md.y); // ratio des limites
        if ( s < md.x || s > md.y ) break;
        c = map(p,d)*t;
        s = c.x;
        d += s;
        p = ro+rd*d;
    }
    
    if (s<md.x)
    {
        vec3 n = nor(p, 0.05,d); // normale de la map au point p

        vec3 ray = reflect(rd, n);
        vec4 cubeRay = textureCube(iChannel0, ray) * 0.6 ;

        col += cubeRay + c; 
    }
    else
    {
        col = textureCube(iChannel0, rd);
    }
    
    return col;
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 org, float persp)
{
	vec3 rorg = normalize(org-ro); // direction de la camera
    vec3 u =  normalize(cross(cu, rorg)); // u du plan de la camera
    vec3 v =  normalize(cross(rorg, u)); // v du plan de la camera
    vec3 rd = normalize(rorg + u*uv.x + v*uv.y); // direction de rendu
    return rd;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 s = iResolution.xy;
    vec2 g = fragCoord.xy;
    vec2 uv = (2.*g-s)/s.y;
    vec2 m = iMouse.xy;
    
    float t = iGlobalTime*0.2;
    float axz = -t; // angle XZ
    float axy = .4; // angle XY
    float cd = 1.5; // cam dist to scene origine
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) axz = m.x/s.x * m2pi; // mouse x axis 
    if ( iMouse.z>0.) axy = m.y/s.y * m2pi; // mouse y axis 
    /////////////////////////////////////////////////////////
   
    float ap = 0.; // angle de perspective
    vec3 cu = vec3(0.,1.,0.); // haut de la camera suivant
    vec3 org = vec3(0., 0., 0.); // origine de la scene
    vec3 ro = vec3(cos(axz),sin(axy),sin(axz))*cd; // origine de la camera
    
    vec3 rd = cam(uv, ro, cu, org, ap);
    
    vec4 c = vec4(0.,0.,0.,1.); // couleur
    
    c = scene(c, ro, rd);
    
    fragColor = c;
}