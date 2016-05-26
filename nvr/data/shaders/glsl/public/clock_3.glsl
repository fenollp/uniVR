// Shader downloaded from https://www.shadertoy.com/view/ldSGDt
// written by shadertoy user FabriceNeyret2
//
// Name: clock 3
// Description: .
const float R = .045;

float SQR(float x) { return x*x; }

float drawBit(vec2 p, float v,float bit) {
	float r = length(p)/R;
	if (r > 1.) return -1.;

	float bg = .1*smoothstep(.003,.0,SQR(r-.95));
	float fg = 1.-r*r*r*r;
	return floor(mod(v,2.*bit)/bit)*smoothstep(1.,.9,r)*fg + bg;
}

float drawQuartet(vec2 p, float v) {
	if (abs(p.y)/R>1.) return 0.;
	float r;
		
	r = drawBit(p-vec2(.2,0.),v,8. ); if (r>=0.) return r; 
	r = drawBit(p-vec2(.3,0.),v,4. ); if (r>=0.) return r; 
	r = drawBit(p-vec2(.4,0.),v,2. ); if (r>=0.) return r; 
	r = drawBit(p-vec2(.5,0.),v,1. ); if (r>=0.) return r; 
	return 0.;
}
	float drawOctet(vec2 p, float v) {
	if (abs(p.y)/R>1.) return 0.;
	float r;
		
	r = drawBit(p-vec2(.0,0.),v,32.); if (r>=0.) return r;
	r = drawBit(p-vec2(.1,0.),v,16.); if (r>=0.) return r;
	return drawQuartet(p,v);
}

	
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pos = fragCoord.xy / iResolution.y - vec2(.3,0);
	vec3 col = vec3(0.);
	float year = iDate.x, time = iDate.a;
	float v; vec2 p;
	v = mod(year/1000.,10.); 
	col.r  += drawQuartet(p=(pos-vec2(.4,.1))*2.,v);
	v = mod(year/100.,10.); 
	col.r  += drawQuartet(p=(pos-vec2(.4,.15))*2.,v);
	v = mod(year/10.,10.); 
	col.r  += drawQuartet(p=(pos-vec2(.4,.2))*2.,v);
	v = mod(year,10.); 
	col.r  += drawQuartet(p=(pos-vec2(.4,.25))*2.,v);
	v = iDate.y; 
	col.g  += drawQuartet(pos-vec2(.2,.35),v);
	v = iDate.z; 
	col.b  += 2.5*drawOctet(pos-vec2(.2,.45),v);
	v = floor(time/3600./12.); 
	v = drawBit((pos-vec2(.2,.55))*2.,v,1.); if (v>=0.) col.rg += vec2(v); // am:pm
    v = floor(mod(time/3600.,12.)); 
	col.rg += vec2(drawQuartet(pos-vec2(.2,.55),v));
	v = mod(time,3600.)/60.;	
	col.gb += vec2(drawOctet(pos-vec2(.2,.65),v));
    v = mod(time,60.); 
	col.rb += vec2(drawOctet(pos-vec2(.2,.75),v));
	v = mod(iGlobalTime,1.)*10.;	 
	col.rgb += vec3(drawQuartet(pos-vec2(.2,.85),v));
	//v = mod(iGlobalTime*10.,1.);	 
		
	fragColor = vec4(col,1.0);
}