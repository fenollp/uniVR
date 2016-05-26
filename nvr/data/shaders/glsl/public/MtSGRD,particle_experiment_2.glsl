// Shader downloaded from https://www.shadertoy.com/view/MtSGRD
// written by shadertoy user aiekick
//
// Name: Particle Experiment 2
// Description: Mouse.x =&gt; particle duration
//    Mouse.y =&gt; Zoom
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
        
    // vars
    float z = 1.;
    
    const int n = 500; // particle count
    
    vec3 startColor = normalize(vec3(1.,0.,0.));
    vec3 endColor = normalize(vec3(1.,sin(t)*.5+.5,cos(t)*.5+.5));
    
    float startRadius = 0.3;
    float endRadius = 0.8;
    
    float power = 0.5;
    float duration = 0.9;
    //
    
    vec2 
        s = iResolution.xy,
		v = z*(2.*fragCoord.xy-s)/s.y;
    
    // Mouse axis y => zoom
    if(iMouse.z>0.) v *= iMouse.y/s.y * 20.;
    
    // Mouse axis x => duration
    if(iMouse.z>0.) duration = iMouse.x/s.x * 10.;
    
    vec3 col = vec3(0.);
    
    vec2 pm = vec2(3.,2.5);
    
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
        
        v = mod(v,pm) - 0.5*pm;
        
        vec2 p = v - vec2(x,y);
    	mb = mbRadius/dot(p,p);
    	
        sum += mb;
        
        col = mix(col, mix(startColor, endColor, distRatio), mb/sum);
    }
    
    sum /= float(n);
    
    col = normalize(col) * sum;
    
    sum = clamp(sum, 0., .4);
    
    vec3 tex = vec3(1.);
     
    col *= smoothstep(tex, vec3(0.), vec3(sum));
        
	fragColor.rgb = col;
}
