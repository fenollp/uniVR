// Shader downloaded from https://www.shadertoy.com/view/Ms3SWH
// written by shadertoy user sibaku
//
// Name: Simple discrete waves
// Description: Just some very basic waves for testing and to play around with. Click to add some splashes. You can also create obstacles. More instructions at the top of the shader
// **************************** INFO ***************************************
//
//
// Click (Hold) the left mouse button to create waves (perform some action)
// 
// Pressing 'c' on your keyboard will change your action. 
// The actions are as follows:
//
// 1. Waves
//		- Creates waves in free regions
// 2. Block
//		- Blocks a small area -> Waves will splash against it
// 3. Clear
//		- Clears both blocks and waves in a small area
// 
// The default action is 'Waves'
//
//
// Holding down 'a' on your keyboard increases the area affected by your mouse
// 
// Pressing 'r' on your keyboard resets everything
//
//
//
// *************************************************************************


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    
  
        vec2 uv = fragCoord.xy / iResolution.xy;
    	vec4 vals = texture2D(iChannel1,uv);
    
    	
        vec2 delta = vec2(1.,1.)/ iChannelResolution[1].xy;
        
        vec3 offset = vec3(delta.x,delta.y,0.);
        
    
   
    	vec4 fxp = texture2D(iChannel1,uv + offset.xz);
        vec4 fxm = texture2D(iChannel1,uv - offset.xz);
        
        vec4 fyp = texture2D(iChannel1,uv + offset.zy);
        vec4 fym = texture2D(iChannel1,uv - offset.zy);
        
    	// partial derivatives d/dx, d/dy
    	float dx = fxp.y - fxm.y;
    	float dy = fyp.y - fym.y;
		
    	// partials in 3d space
    	
    	vec3 fx = vec3(2.,0.,dx);
    	vec3 fy = vec3(0.,2.,dy);
    	
    
    	vec3 n = normalize(cross(fx,fy));
    
    	vec3 campos = vec3(0.5,0.5,200.);
    	vec3 p = vec3(uv,0.);
    
    	vec3 v = campos - p;
    
        vec3 l = normalize(vec3(10.,70.,400.));
    
    	vec3 h = normalize(l + v);
    
    	float specular = pow(max(0.,dot(h,n)),16.);
    
    	vec3 r = refract(-v,n,1./1.35);
    	// very simple hacky refraction
    	vec2 roffset = 10.* vals.y*normalize(r.xy - n.xy)/iChannelResolution[2].xy;
    
    	vec3 color = texture2D(iChannel2,uv + roffset).xyz;
    
    	float block = 1. - vals.w;
    	
    	color*= block;
   
    	float factor = clamp(max(dot(n,l),0.) + specular + 0.2,0.,1.);
    	fragColor = vec4(color*factor,1.);
 
	
    
}