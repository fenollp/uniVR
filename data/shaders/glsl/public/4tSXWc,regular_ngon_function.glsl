// Shader downloaded from https://www.shadertoy.com/view/4tSXWc
// written by shadertoy user Aj_
//
// Name: Regular nGon Function
// Description: A function which generates ngons for a given apothem/radius
#define PIX2 6.28318530718
#define NEARMULT(V, OF) floor( (PIX2+V)/OF + .5 ) * OF
const float a = .10;
const float rad = .17;

float nGonCA(vec2 c, vec2 p, float n, float a) { //a = apothem

	
	float divAng = PIX2/n;
	vec2 pc = p-c;
	float lpc = length(pc);
	float ang = (atan(pc.y,pc.x)) ; 	
	float nearAng = NEARMULT(ang, divAng);	
	vec2 locRVec = a*(vec2(cos(nearAng), sin(nearAng)));
	vec2 nLRV = normalize(locRVec);
	float ct = dot(normalize(pc), nLRV);
	return a-ct*lpc;
	
}

float nGonCR(vec2 c, vec2 p, float n, float rad) { 
	
	float s = rad*2.*sin(3.14159265359/n);
	float a = sqrt(rad * rad - (s*s/4.));		
	return nGonCA(c, p, n, a);
}

#define circle(c,p,rad) rad - distance(p,c)
#define goodmix(col1, col2) mix(col1*(1. - floor(col2.a)) +col2*col2.a, col2, col2.a );



float line(vec2 p, vec2 c1, vec2 c2, float width) {
	vec2 dc = c2-c1;
	float lineLen = length(dc) - 2.*width;
	vec2 lineNorm = normalize(dc);
	c1+=lineNorm*width;
	float ang = atan(dc.y, dc.x);
	float dcl = distance(p, c1);
	float proj = dot(lineNorm, normalize(p-c1));
	//float radM = sign(min(proj,dot(-dc, p-c2)));
	vec2 np = (c1+clamp(dcl*proj, 0., lineLen)*lineNorm);
	return circle(np, p, width);;//*radM);
	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    vec2 p = ( fragCoord.xy / iResolution.x -.5*iResolution.xy/iResolution.x).xy;	
	vec4 back = vec4(.7, .0, 0.0, 0.) * ((.9 - length(p)));
	vec3 colP = vec3(0.1, 0.5 ,.6);
	vec3 colC = vec3(.2, .2, .5);
	vec4 colL, colR, colCL ;
	float ngCR = nGonCR(vec2(-.2,0.),p, 
			3.+floor(mod((iGlobalTime), 10.))			
			, rad);
	
	float ngCA = nGonCA(vec2(.2,0.),p, 
			3.+floor(mod((iGlobalTime), 10.))			
			, a);
	float c = circle(vec2(-.2,0.),p, rad);
	float l = line(p, vec2(.2, 0.), vec2(a+.2, 0.), .005);
	
	colCL = vec4(colC, smoothstep(0., .004, c));
	colL = vec4(colP,  smoothstep(0., .004, ngCR));
	colR = vec4(colP, smoothstep(0., .004, ngCA));
	vec4 colLine = vec4(colC, smoothstep(0., .004, l));
	
	back = mix(back, colCL, colCL.a);//
	back = goodmix(back, colCL);
	back = goodmix(back, colL);
	back = goodmix(back, colR);
	back = goodmix(back, colLine);
	
	
	fragColor = back;
}