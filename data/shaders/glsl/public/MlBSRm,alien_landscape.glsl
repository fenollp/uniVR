// Shader downloaded from https://www.shadertoy.com/view/MlBSRm
// written by shadertoy user clayjohn
//
// Name: Alien Landscape
// Description: Some weird alien planet landscape thing. Oddly pleased with how the sky turned out.
/*
This started out as a testbed for playing with phong lighting. It was just a grid with a moving light 
and it slowly turned into this. I am fairly happy with the results, it's definitaly the best looking 
landscape I've made. I hope you like!

I was experimenting with sin based noise, but ended up stealing IQs from https://www.shadertoy.com/view/4sjXzG
also the ray marcher is based off of many other shaders from around shadertoy.

Disclaimer: There will defintaly be artifacts in the code from experimenting with things from before. I'm sorry 
if it clutters things up too much. But I like to keep them so I can come back later and play around with ideas I came up with 
during the process.

*/


vec3 MOON = vec3(-200.0+sin(iGlobalTime*0.5)*400.0, 60.0, 207.0);
const vec3 SKY = vec3( 0.1, 0.2, 0.4 );

float hash(vec2 p) {
 return fract(sin(dot(p*0.05, vec2(14.52, 76.38)))*43256.2895);   
}

float noise(vec2 pos) {
  vec2 a = vec2(1.0, 0.0);
  vec2 p = floor(pos);
  vec2 f = fract(pos);
  f = f*f*f*(3.0-2.0*f);
    float h = mix(mix(hash(p+a.yy), hash(p+a.xy), f.x), 
                  mix(hash(p+a.yx), hash(p+a.xx), f.x), f.y);
    return h;
}
   

float snoise(vec2 p) {
   float h = 0.0;
    float a = 0.5;
    for (float i=0.0;i<6.0;i++) {
        h+=noise(p)*a;
        p*=1.9;
        a*=0.4;
    } 
    return h;
}

float snoiser(vec2 p) {
   float h = 0.0;
    float a = 0.5;
    for (float i=0.0;i<6.0;i++) {
        h+= abs(noise(p)-0.5)*a*2.0;
        p*=2.5;
        a*=0.7;
    } 
    return h;
}


const mat2 m2 = mat2(1.8,-1.2,1.2,1.6);


float fbm(vec2 p) {
 float h = 0.0;
 float a = 0.5;
    for(float i = 0.0;i<3.0;i++) {
        h+= a*texture2D(iChannel0, p).x;
        p*=2.0;
        a*=0.5;
    }
    return abs(h-0.5)*2.0;
}
//low detail for ray tracing
float f(vec2 p) {
    p *= 0.13;
    float h = 0.0;
    float a = 1.0;
    for (float i=0.0;i<4.0;i++) {
        //h+=noise(p)*a;
        //h+=sin(p.x)*sin(p.y)*a;
        h+=0.5*(cos(6.2831*p.x) + cos(6.2831*p.y))*a;
        p = 0.97*m2*p + (h-0.5)*0.2;
        a*= 0.5 +0.1*h;
    }
    //return sin(p.x)*sin(p.y)-1.0;
    //return noise(p*0.5)-1.0;
    return  smoothstep(0.1, 2.0, (abs(h-0.5)))-2.0;
    

}
//high detail for shading
float fh(vec2 p) {
    p *= 0.13;
    float h = 0.0;
    float a = 1.0;
    for (float i=0.0;i<6.0;i++) {
        //h+=noise(p)*a;
        //h+=sin(p.x)*sin(p.y)*a;
        h+=0.5*(cos(6.2831*p.x) + cos(6.2831*p.y))*a;
        p = 0.97*m2*p + (h-0.5)*0.2;
        a*= 0.5 +0.1*h;
    }
    //return sin(p.x)*sin(p.y)-1.0;
    //return noise(p*0.5)-1.0;
    return  smoothstep(0.1, 2.0, (abs(h+fbm(p*0.01)*0.1-0.5)))-2.0;
    

}

vec3 norm(vec3 p, float t) {
    vec2 e = vec2(0.001*t, 0.0);
    return normalize(vec3(fh(p.xz-e.xy)-fh(p.xz+e.xy), 2.0*e.x, fh(p.xz-e.yx)-fh(p.xz+e.yx)));
}

vec3 material(vec3 p, vec3 n) {
    vec3 m = mix(vec3(0.3, 0.1, 0.0), vec3(1.0), smoothstep(0.7, 0.8, p.y+fbm(p.xz)+1.5));
    m = mix(vec3(0.3, 0.5, 0.1), m, smoothstep(0.0, 0.1, p.y+2.0));
    m = mix(vec3(0.5), m, smoothstep(0.1, 1.0, n.y));
    
    //m = vec3(clamp(step(fract(p.x + 0.5 * step(0.5, fract(p.z))), 0.5), 0.1, 1.0));
    return m;
}

vec3 get_col(vec3 p, float t, vec2 uv) {
    vec3 n = norm(p, t);
    
    vec3 m = material(p, n);
    
    vec3 I = normalize(MOON);
    float s = clamp(smoothstep(0.0, 0.5, dot(I, n)), 0.0, 1.0);
    return mix(m*s, SKY*(abs(uv.y-1.2)*0.4), clamp(pow(t, 0.8)/5.0, 0.0, 1.0));
    //return mix(m, SKY, clamp(pow(t, 0.8)/5.0, 0.0, 1.0));
    

}
float trace(out vec3 pos, vec3 dir) {
    float delta = 0.01;
    float j = 0.5;
    vec3 p;
    float lh = 0.0;
    float ly = 0.0;
    for (int i = 0;i<700;i++) {
        p = pos+dir*j;
        float h = f(p.xz);
        if(p.y-h<0.02*j) {
            pos = p;
            return j;
        }
        
    j+= delta;
    delta = 0.005*j;
    ly = p.y;
    lh = h;
    }
    
    return -1.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.2;
	vec2 uv = ( fragCoord.xy / iResolution.xy ) * 2.0 - 1.0;
	uv.x *= iResolution.x /  iResolution.y;
    
    vec3 dir = normalize(vec3(uv, 1.0));
    vec3 pos = vec3(0.0, f(vec2(0.0, time))+0.5, time);

    vec3 col = vec3(0.0);
    float t = trace(pos, dir);
    //t = -1.0;
    if (t>=0.0) {
    col = get_col(pos, t, uv);
    
    
    } else {
      //stars  
    col = vec3(smoothstep(0.7+0.3*smoothstep(0.0, 0.35, abs((uv.x*0.5-1.0)*iResolution.y/iResolution.x+uv.y)), 1.0, hash(fragCoord))*hash(fragCoord*2.0));
    

    
    vec2 moon = normalize(MOON).xy;
    float l = length(moon-uv);
    //moon penumbra
    col +=0.9*exp(-l*10.0);
    //sky gradient
    col += SKY*(abs(uv.y-1.2)*0.4);
        // save this effect for later
    //col+= (1.0-smoothstep(0.1, 0.15, l*snoise(uv)));
    //milky way
        //inner glow
    col = mix(vec3(1.0, 1.0, 0.8), col,0.5+0.5*smoothstep(0.0, 0.07, abs((uv.x*0.5-1.0)*iResolution.y/iResolution.x+uv.y)*snoise(5.0*(uv*vec2(iResolution.y/iResolution.x, 0.0)-vec2(1.0, -uv.y)))));
        //outer shape
    col = mix(SKY*1.2, col,0.8+0.2*smoothstep(0.0, 0.15, abs((uv.x*0.5-1.0)*iResolution.y/iResolution.x+uv.y)*snoise(4.0*(uv*vec2(iResolution.y/iResolution.x, 0.0)-vec2(1.0, -uv.y)))));
    //milky way clouds
    col = mix(SKY*(abs(uv.y-1.2)*0.4), col, 0.1+0.5*smoothstep(0.0, 0.1, abs((uv.x*0.5-1.0)*iResolution.y/iResolution.x+uv.y)*snoiser(15.0*(uv*vec2(iResolution.y/iResolution.x, 0.0)-vec2(1.0, -uv.y)))));
    col = mix(SKY*(abs(uv.y-1.2)*0.4), col, smoothstep(0.0, 0.03, abs((uv.x*0.5-1.0)*iResolution.y/iResolution.x+uv.y)*0.02+0.03*snoiser(15.0*(uv*vec2(iResolution.y/iResolution.x, 0.0)-vec2(1.0, -uv.y)))));

        //add nearby stars
    col += vec3(smoothstep(0.95, 1.0, hash(fragCoord))*hash(fragCoord*2.0));
    //add moon
    col= mix(col, vec3(0.6+0.2*smoothstep(0.25, 0.55, snoise((moon-uv+vec2(0.8))*12.0))), (1.0-smoothstep(0.15, 0.18, l)));

    }
    
    col = pow( col, vec3(0.45) );
    //col = vec3 (smoothstep(0.0, 0.05, abs((uv.x-1.0)*iResolution.y/iResolution.x+uv.y)*0.07+0.07*snoiser(15.0*(uv*vec2(iResolution.y/iResolution.x, 0.0)-vec2(1.0, -uv.y)))));
	//col = vec3 (smoothstep(0.0, 0.1, abs((uv.x-1.0)*iResolution.y/iResolution.x+uv.y)*snoiser(15.0*(uv*vec2(iResolution.y/iResolution.x, 0.0)-vec2(1.0, -uv.y)))));

    fragColor = vec4(col,1.0);
}