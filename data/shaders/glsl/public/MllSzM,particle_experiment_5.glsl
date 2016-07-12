// Shader downloaded from https://www.shadertoy.com/view/MllSzM
// written by shadertoy user aiekick
//
// Name: Particle Experiment 5
// Description: Mouse.x =&gt; Zoom
//    Mouse.y =&gt; Particle Duration
//    i would be great to use this with sound but i dont know how :)
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
        float t = iGlobalTime+5.;
    
        // vars
        float z = 1.;
    
        const int n = 200; // particle count
    
        vec3 startColor = normalize(vec3(1,.1,0));
        vec3 endColor = normalize(vec3(1,sin(7.)*.5+.5,cos(7.)*.5+.5));
    
        float startRadius = .38;
        float endRadius = .42;
    
        float power = 1.;
        float duration = 0.8;
    
        vec2 
        	s = iResolution.xy,
        	v = z*(2.*gl_FragCoord.xy-s)/s.y;
    
        // Mouse axis y => zoom
        if(iMouse.z>0.) v *= iMouse.y/s.y * 20.;
    
        // Mouse axis x => duration
        if(iMouse.z>0.) duration = iMouse.x/s.x * 10.;
    
        vec3 col = vec3(0.);
    
        vec2 pm = v.yx*2.8;
    
        float dMax = duration;
    
        float mb = 0.;
        float mbRadius = 0.;
        float sum = 0.;
        for(int i=0;i<n;i++)
        {
                float d = fract(t*power+48934.4238*sin(float(i)*692.7398))*duration;
                float a = 6.28*float(i)/float(n);
                 
                float x = d*cos(a);
                float y = d*sin(a);
                
                float distRatio = d/dMax;
                
                mbRadius = mix(startRadius, endRadius, distRatio); 
                
                vec2 p = v - vec2(x,y);
                    
                //p = mod(p,pm) - 0.5*pm;
                
                mb = mbRadius/dot(p,p);
                    
                sum += mb;
                
                col = mix(col, mix(startColor, endColor, distRatio), mb/sum);
        }
    
        sum /= float(n);
    
        sum = clamp(sum, 7.6, 1000.);
    
        col = normalize(col) * sum;
    
        col = smoothstep(vec3(2.7), vec3(2.85), col);
        
        fragColor.rgb = col;
}
