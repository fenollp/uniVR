// Shader downloaded from https://www.shadertoy.com/view/XsBXWR
// written by shadertoy user FabriceNeyret2
//
// Name: tile illusion
// Description: inspired from https://pic.twitter.com/MXrb1L8rrv
float t = iGlobalTime;
float f(float x) { return x + .2*sin(1.6*x); }

float solve(float x0,float x1,float y) {
    float y0=f(x0), y1=f(x1);
    if (y1<y0) { float x2=x1;x1=x0;x0=x2; float y2=y1;y1=y0;y0=y2; }
    float xn, yn;
    for (int i=0; i<20; i++) {
	    xn = x0 + (x1-x0)/(y1-y0)*(y-y0),
    	yn=f(xn);
        if (yn>y) {x1=xn; y1=yn;} else {x0=xn; y0=yn; }
     }
    return xn;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    uv *= 15.;
     float y0 = solve(uv.y-3.,uv.y,  floor(f(uv.y))),
           y1 = solve(uv.y,uv.y+3., floor(f(uv.y))+1.);
    uv.y = f(uv.y);
    uv.x /= (y1-y0);
    float s = mod(floor(uv.y),2.);
    float v = .55;
    if (fract(uv.y)>.07) {
    	uv.x += t*sign(s-.5);
    	float c = mod(floor(uv.x)+floor(uv.y),2.);
    	v = c;
    }
	fragColor = vec4(v);
}