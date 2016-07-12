// Shader downloaded from https://www.shadertoy.com/view/4ljSRc
// written by shadertoy user croqueteer
//
// Name: Standing Waves
// Description: Just playing around with sin functions and time. I like the flow.
#define PI 3.14159265359

float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) - 
          smoothstep( pct, pct+0.02, st.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float x = uv.x;
	float y = 0.5+0.5*sin(x*iGlobalTime*2.0*PI)*cos(x*2.*PI);
    vec3 color = vec3(0.0);
    
    float pct = plot(uv,y);
    color = (1.0-pct)*color+pct*vec3(0.0,1.0,0.0);

    fragColor = vec4(color,1.0);
}