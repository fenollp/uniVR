// Shader downloaded from https://www.shadertoy.com/view/XdBSWR
// written by shadertoy user FabriceNeyret2
//
// Name: canvas
// Description: tune with mouse x and y.  
//    Space to show tiles.
float t = iGlobalTime;
bool keyToggle(int ascii) {
	return (texture2D(iChannel3,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv0 = fragCoord.xy / iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;
    if (iMouse.z<=0.) { // autodemo 
		    uv0 += vec2(1.8*cos(.15*t)+.5*sin(.4*t),sin(.22*t)-.5*cos(.3*t));
            uv0 *= 1.5-cos(.2*t);
			m = .5+.5*vec2(cos(t),sin(.6*t)); m.y*=m.x;
    }

    vec2 uv = uv0*10.;
    float d = mod(floor(uv.x)+floor(uv.y),2.), s = mod(floor(uv.y),2.);
    uv = fract (uv); if (d==1.) uv.x = 1.-uv.x; // checkered tile coordinates
    uv = vec2(uv.x-uv.y,uv.x+uv.y);
 
    float size = m.x+m.y*cos(.5*3.1415927*uv.y) *sign(s-.5)*sign(d-.5);
    float l = abs(uv.x)-size;
    float v = smoothstep(0.,.1,abs(l));
    float v0 = step(0.,l);
    
    size = m.x+m.y*cos(.5*3.1415927*uv.x); 
    float ofs = (1.-size)*sign(s-.5)*sign(d-.5); // corner distance
    l = (uv.y-1.)-ofs;
    float v1 = step(0.,l);
    float d0 =  mod(s+v1,2.);
    float d1 =  mod(s+d+v1,2.); // corner area
    v0 = ((d1<1.)?v0:0.); // background
    v = ((d1<1.)?v:1.)*smoothstep(0.,.1,abs(l)); // contour

    vec4 col = v0*texture2D(iChannel2,uv0) 
        + (1.-v0)*((d0==0.) ? texture2D(iChannel0,uv0) : texture2D(iChannel1,uv0));
    if (keyToggle(32)) v/= 1.+.5*d;
	fragColor = col*v;
}