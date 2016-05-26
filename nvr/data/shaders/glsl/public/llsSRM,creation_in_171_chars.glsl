// Shader downloaded from https://www.shadertoy.com/view/llsSRM
// written by shadertoy user GregRostami
//
// Name: Creation in 171 chars
// Description: My attempt at reducing the brilliant Creation by Silexars:
//    https://www.shadertoy.com/view/XsXXDn
//    Any help reducing this further will be appreciated. Thank you.
//Thanks to coyote the shader is now 171 chars!
void mainImage(out vec4 f,vec2 u)
{
    float L = length(u=u/iResolution.x-.5), t=iDate.w;
    for(int i=0;i<3;i++)
        f[i] = .01/length( fract(.5+u+u/L*(sin(t+=.05)+1.) * sin(L*9.-t-t))-.5)/L;
}

/*
//Original Shader
void mainImage(out vec4 f, vec2 u )
{
    f = iDate;
	for(int i=0;i<3;i++)
    {
		vec2 u = u/iResolution.x, v=u;
		float l = length(u-=.5);
		v += u/l * (sin(f.a+=.05)+1.) * sin(l*9.-f.a/.5);
		f[i] = .01/length(mod(v,1.)-.5)/l;
	}
}
*/