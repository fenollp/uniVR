// Shader downloaded from https://www.shadertoy.com/view/4tX3DM
// written by shadertoy user aiekick
//
// Name: 2D Snack Explosion
// Description: 2D Snack Explosion
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
        
    // vars
    float z = 1.;
    
    const int n = 500;
        
    vec3 startColor = normalize(vec3(1.5,0.,1.));
    vec3 endColor = normalize(vec3(1.,1.,0.5));
    
    float startRadius = 0.4;
    float endRadius = 0.7;
    
    float power = 0.3;
    float duration = 0.6;
    //
    
    vec2 
        s = iResolution.xy,
		v = z*(2.*fragCoord.xy-s)/s.y;
    
    if(iMouse.z>0.) v *= iMouse.y/s.y * 20.;
    if(iMouse.z>0.) duration = iMouse.x/s.x * 10.;
    
    vec3 col = vec3(0.);
    
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
    	mb = mbRadius/dot(p,p);
    	
        sum += mb;
        
        col = mix(col, mix(startColor, endColor, distRatio), mb/sum);
    }
    
    sum /= float(n);
    
    col = normalize(col) * sum;
    
    sum = clamp(sum, 0., .4);
    
    vec3 tex = texture2D(iChannel0, v).rgb;
     
    col *= smoothstep(tex, vec3(0.), vec3(sum));
        
	fragColor.rgb = col;
}

// 2
/*
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
        
    // vars
    float z = 1.;
    
    const int n = 400;
        
    vec3 startColor = normalize(vec3(1.5,0.,1.));
    vec3 endColor = normalize(vec3(1.,1.,0.5));
    
    float startRadius = 0.3;
    float endRadius = 0.3;
    
    float power = 0.2;
    float duration = 0.6;
    //
    
    vec2 
        s = iResolution.xy,
		v = z*(2.*fragCoord.xy-s)/s.y;
    
    if(iMouse.z>0.) v *= iMouse.y/s.y * 20.;
    if(iMouse.z>0.) duration = iMouse.x/s.x * 10.;
    
    vec3 col = vec3(0.);
    
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
    	mb = mbRadius/dot(p,p);
    	
        sum += mb;
        
        col = mix(col, mix(startColor, endColor, distRatio), mb/sum);
    }
    
    sum /= float(n);
    
    col = normalize(col) * sum;
    
    sum = clamp(sum, 0., 0.5);
    
    col = mix(col, texture2D(iChannel0, v).rgb, sum);
    
	fragColor = vec4(col,1);
}
*/

// 1
/*
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float 
        z = 25.,
        t = iGlobalTime;
    
    vec2 
        s = iResolution.xy,
		v = z*(2.*fragCoord.xy-s)/s.y;
    
    v/=10.;
    if(iMouse.z>0.) v *= iMouse.y/s.y*20.;
    
    const int n = 100;
        
    vec3 startColor = normalize(vec3(0.8,0.5,0.5));
    vec3 endColor = normalize(vec3(0.5,0.5,0.2));
    
    float radius = 0.005;
    float power = 1.2;
    float duration = 1.2;
    
    
    float sum = 0.;
    for(int i=0;i<n;i++)
    {
       	float d = fract(t*power+48934.4238*sin(float(i)*692.7398))*duration;
    	float a = 6.28*float(i)/float(n);
        
        float x = d*cos(a);
        float y = d*sin(a);
        
        vec2 p = v - vec2(x,y);
    	float mb = radius/dot(p,p);
    	
        sum += mb;
    }
    
    vec3 col = vec3(sum)*endColor;
    
    sum = clamp(sum, 0., 0.5);
    
    col = mix(col, texture2D(iChannel0, v).rgb, sum);
    
	fragColor = vec4(col,1);
}
*/