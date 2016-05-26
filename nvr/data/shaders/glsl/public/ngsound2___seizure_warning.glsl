// Shader downloaded from https://www.shadertoy.com/view/MtS3zD
// written by shadertoy user netgrind
//
// Name: ngSound2 - SEIZURE WARNING
// Description: my head hurts
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
    
    vec2 uv = (fragCoord.xy) / iResolution.yy;
    uv.y-=.5;
    uv.x-=iResolution.x/iResolution.y*.5;
    uv = abs(uv*.15);
    uv+=sin(12394.567*uv.x*uv.y+i)*.001;
    vec4 c = vec4(1.0);
    float a = atan(uv.y,uv.x);
    float d = length(uv);
    a+=d*20.;

        
    c.r = sin(-i*80.+d*100.+2.*sin(6.28*a))*.5+.5;
    
	float s = sin(i*40.);
    c.rgb = abs(floor(s+1.)-c.rgb);
	fragColor = c;
}