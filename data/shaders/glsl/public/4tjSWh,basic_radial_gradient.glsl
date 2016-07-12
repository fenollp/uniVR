// Shader downloaded from https://www.shadertoy.com/view/4tjSWh
// written by shadertoy user capitanNeptune
//
// Name: Basic Radial Gradient
// Description: basic radial gradient with motion
float dist(vec2 p0, vec2 pf){return sqrt((pf.x-p0.x)*(pf.x-p0.x)+(pf.y-p0.y)*(pf.y-p0.y));}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //mouse controlled version
    //float d = dist(iResolution.xy*0.5,fragCoord.xy)*(iMouse.x/iResolution.x+0.1)*0.01;
    
    //automatic version
    float d = dist(iResolution.xy*0.5,fragCoord.xy)*(sin(iGlobalTime)+1.5)*0.003;
	fragColor = mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(0.0, 0.0, 0.0, 1.0), d);
}