// Shader downloaded from https://www.shadertoy.com/view/4tfXRl
// written by shadertoy user antonOTI
//
// Name: Contour
// Description: my implementation of contour, I intend to use it for a small game of my own
vec4 FakeStencil(vec2 pos)
{
    float shape = 1. - smoothstep(.13,.16,distance(pos,vec2(0.5)));
    float t = iGlobalTime;
   	shape = max(shape,1. - smoothstep(.05,.09,distance(pos,vec2(cos(t)*1.1,sin(t)*.8) * .15 + vec2(.5))));
   	shape = max(shape, 1. - smoothstep(.025,.04,distance(pos,iMouse.xy/iResolution.xy * vec2(1.,.5) + vec2(0.,.25))));
	return vec4(1.) * shape;
}

#define P .001
vec4 outlineColor = vec4(.9,.15,0.04,1.);
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y = (uv.y - 0.5) * iResolution.y / iResolution.x + 0.5;
    
    float stencil = FakeStencil(uv + vec2(-1.,0.) * P).x;
    stencil += FakeStencil(uv + vec2(1.,0.) * P).x;
    stencil += FakeStencil(uv + vec2(0.,-1.) * P).x;
    stencil += FakeStencil(uv + vec2(0.,1.) * P).x;
    
    stencil += FakeStencil(uv + vec2(-.7,-.7) * P).x;
    stencil += FakeStencil(uv + vec2(.7,.7) * P).x;
    stencil += FakeStencil(uv + vec2(.7,-.7) * P).x;
    stencil += FakeStencil(uv + vec2(-.7,.7) * P).x;
    
    // Contour
    float a = smoothstep(3.5,4.5,stencil)*(1. - smoothstep(7.9,8.,stencil));
    
    // Stripes
    a += step(8.,stencil) * .2 * step(.7,sin((uv.x * 240. + uv.y *60.)+ iGlobalTime * 7.)*.4+.6);
    
    vec4 col = outlineColor * a;
    
	fragColor = col;
}