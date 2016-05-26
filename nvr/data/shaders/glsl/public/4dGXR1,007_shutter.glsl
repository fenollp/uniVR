// Shader downloaded from https://www.shadertoy.com/view/4dGXR1
// written by shadertoy user FabriceNeyret2
//
// Name: 007 shutter
// Description: 007's like camera shutter
void mainImage( out vec4 O, vec2 U )
{
	vec2 R = iResolution.xy;
    U = (U+U-R)/R.y;
    
    O = texture2D(iChannel0,.5+.5*U);
    
    float N = 12., c = cos(6.28/N),s=sin(6.28/N),
          a = 3.14/4.*(.5+.5*sin(iGlobalTime)),d,A;
    
    for (int i=0; i<20; i++) {
        d = -dot(U-vec2(-1,1),vec2(sin(a),cos(a)));
        A = smoothstep(.01,0.,d);
        O.rgb += (1.-O.w) * A * vec3(1.-4.*smoothstep(.01,0.,abs(d)));
        O.w = A;
        U *= mat2(c,-s,s,c);
    }
    O *= smoothstep(1.,.99,length(U));
}