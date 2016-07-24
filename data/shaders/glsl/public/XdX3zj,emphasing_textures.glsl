// Shader downloaded from https://www.shadertoy.com/view/XdX3zj
// written by shadertoy user FabriceNeyret2
//
// Name: emphasing textures
// Description: yellow-blue: original texture
//    blue-green: displacement shrink
//    green-red: displacement inflate
//    red-cyan: differential shrink
//    cyan-red: differential inflate
// try "true" if your browser allows loops of variable length
#define VariableLoop 0

#define maxLOD 6.
#define CENTRED true
#define EPS .5e-2

float level;

vec3 mytex(vec2 uv) 
{
	vec3 t0 = texture2D(iChannel0, uv, 0.).xyz;
	vec3 t1 = texture2D(iChannel0, uv, level).xyz;
	return .5+.5*(t0-t1)*(1.+pow(2.,maxLOD-2.-level));

}
vec3 mytexg(vec2 uv) 
{
	return texture2D(iChannel0, uv, level).xyz;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	float mode = mod(uv.y+.1*iGlobalTime,1.);
	level = maxLOD*uv.x*uv.x;
	
	if (mod(mode*5.,1.)<.015) 
	{
		if (abs(mode-.0)<.003) fragColor = vec4(1.,0.,0.,1.0);
		if (abs(mode-.2)<.003) fragColor = vec4(0.,1.,0.,1.0);
		if (abs(mode-.4)<.003) fragColor = vec4(0.,0.,1.,1.0);
		if (abs(mode-.6)<.003) fragColor = vec4(1.,1.,0.,1.0);
		if (abs(mode-.8)<.003) fragColor = vec4(0.,1.,1.,1.0);
		return;
	}
	
   if(abs(mode-.5)>.1)
	{
		vec3 tex,texx,texy,texmx,texmy;
		vec2 uvx,uvy,uvmx,uvmy;
		uvx  = uv+vec2(EPS,0.);
		uvy  = uv+vec2(0.,EPS);	
		if (CENTRED)
		{	uvmx = uv-vec2(EPS,0.);
			uvmy = uv-vec2(0.,EPS);	
		}
		vec2 grad; 
		float g=1.; 
		bool isin = (mode>.5); 
		float sgn = sign(abs(mode-.5)-.3);
#if VariableLoop
		int disp = int(200.*(1.+sin(iGlobalTime)))/2;
		if (!isin)  disp /= 4;
#else
		const int disp = 30;
#endif
 		for (int i=0; i<disp; i++) 
		{
			tex = mytexg(uv);

			if (isin)
			{
				uvx  = uv+vec2(EPS,0.);
				uvy  = uv+vec2(0.,EPS);	
				if (CENTRED)
				{	uvmx = uv-vec2(EPS,0.);
					uvmy = uv-vec2(0.,EPS);	
				}
			}
			texx  = mytexg(uvx );
			texy  = mytexg(uvy );
			if (CENTRED)
			{	texmx = mytexg(uvmx);
				texmy = mytexg(uvmy);
				grad  = sgn*vec2(texx.x-texmx.x,texy.x-texmy.x); 
			}
			else
				grad  = sgn*vec2(texx.x-tex.x,texy.x-tex.x); 
			uv    += EPS*grad;
			uvx.x += EPS*grad.x;
			uvy.y += EPS*grad.y;
			if (CENTRED)
				{	uvmx.x -= EPS*grad.x;
				 	uvmx.y -= EPS*grad.y;
				}
		}
	}


	vec3 col;
	//col = t1;
	//col = .5+.5*(t0-t1)*pow(2.,10.-3.-level);
	//col = .5+.25*(t0-t1)*(1.+pow(2.,10.-level));
	//col = mytexg(uv);
	col = texture2D(iChannel0, uv, 0.).xyz;
	
	fragColor = vec4(col, 1.0);
}