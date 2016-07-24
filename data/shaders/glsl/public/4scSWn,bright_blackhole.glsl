// Shader downloaded from https://www.shadertoy.com/view/4scSWn
// written by shadertoy user cooler
//
// Name: Bright blackhole
// Description: This is modified version of https://www.shadertoy.com/view/4lf3Rj&lt;br/&gt;&lt;br/&gt;I started playing with that code and just after some tweaks got inspired by Interstellar &lt;img src=&quot;/img/emoticonLaugh.png&quot;/&gt;.
//It is modified version of https://www.shadertoy.com/view/4lf3Rj -> author Kali
//:)



// rendering params
const float sphsize=.7; // planet size
const float dist=.77; // distance for glow and distortion
const float perturb=0.55; // distortion amount of the flow around the planet
const float displacement=0.50; // hot air effect
const float windspeed=.1; // speed of wind flow
const float steps=110.; // number of steps for the volumetric rendering
const float stepsize=.025; 
const float brightness=.56;
const vec3 planetcolor=vec3(0.55,0.4,0.3);
const float fade=.005; //fade by distance
const float glow=2.0; // glow amount, mainly on hit side


// fractal params
const int iterations=13; 
const float fractparam=.7;
const vec3 offset=vec3(1.5,2.,-1.5);


float wind(vec3 p) 
{
	float d=max(0.0,dist-max(0.,length(p)-sphsize)/sphsize)/dist; // for distortion and glow area
	float x=max(0.8,p.x*0.5); // to increase glow on left side
    
	p.y*=1.+max(0.2,-p.x-sphsize*0.70)*10.; // left side distortion (cheesy)
	p-=d*normalize(p)*perturb; // spheric distortion of flow
	p+=vec3(iGlobalTime*windspeed,0.5,0.5); // flow movement
	p=abs(fract((p+offset)*.1)-.5); // tile folding 
	for (int i=0; i<iterations; i++) 
    {  
		p=abs(p)/dot(p,p)-fractparam; // the magic formula for the hot flow
	}
	return length(p)*(1.+d*glow*x)+d*glow*x; // return the result with glow applied
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// get ray dir	
	vec2 uv = fragCoord.xy / iResolution.xy-.5;
	vec3 dir=vec3(uv,1.);
	dir.x*=iResolution.x/iResolution.y;
	vec3 from=vec3(0.,0.,-2.+texture2D(iChannel0,uv*.5+iGlobalTime).x*stepsize); //from+dither
    

    // volumetric rendering
	float v=0., l=-0.0001, t=iGlobalTime*windspeed*.2;
	for (float r=10.;r<steps;r++)
    {
		vec3 p=from+r*dir*stepsize;
		float tx=texture2D(iChannel0,uv*.2+vec2(t,0.)).x*displacement; // hot air effect
        v+=min(10.,wind(p))*max(0.,1.-r*fade); 

    }
   
    v/=steps; v*=brightness; // average values and apply bright factor
	vec3 col=vec3(v*1.25,v*v,v*v*v)+l*planetcolor; // set color
	col*=1.-length(pow(abs(uv),vec2(5.)))*14.; // vignette (kind of)
    
    fragColor = vec4(col,1.0);
}