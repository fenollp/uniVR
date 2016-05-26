// Shader downloaded from https://www.shadertoy.com/view/4sXGRX
// written by shadertoy user FabriceNeyret2
//
// Name: webcam game tracker - pong
// Description: track a green and red pannel in the video. 
//    (e.g. colored A4 paper or cardboard. Tune your color lines 4,5)
//    NB: game not fonctionnal. (for the moment :-) ).
// webcam game trackers - pseudo-pong game
// Fabrice Neyret 28/07/2013

// less is cheaper but less accurate
#define SAMPLE 16
#define LEVEL 5.  // int(log(iChannelResolution[0].xy/16.)/log(2.))
// no variable loop in webglsl. and no mipmap in shadertoy videos, anyway :-D

// strangely, L2 normalize works better than L1 luminance
#define lum(C) (length(C))
//#define lum(C) (((C).x+(C).y+(C).z)/3.)
#define unlight(C) ((C)/lum(C))

// target color is a compromise of most like target and least like scene 
vec3 targetA = unlight(vec3(1.,.0,.0)); // vec3(1.,.2,.2));
vec3 targetB = unlight(vec3(0.,1.,.0)); // vec3(.5,1.,.8)); 

float time = iGlobalTime;


// quality of potential match of C for targetC
float match(vec3 C, vec3 targetC)
{
	// normalize for no care luminance
	float I =.1+.9*lum(C); // ...but avoid dividing by 0
	C /= I;
    // distance to target (0 is good, 1-d = score, pow for contrast)
	float v = lum(abs(C-targetC));
	//v = pow(v,.3);
	v = clamp(1.-v,0.,1.);
	v = pow(I*v,3.); // I for very dark area count less
	return v;
}

// search in the texture at low res/
// compute barycenter weighted by fit quality to targets
float _ambientI;
void findTextureTargets(out vec2 pA, out vec2 pB)
{	
	vec3 Ctot = vec3(0.);
	pA = vec2(0.); float Atot=0.;
	pB = vec2(0.); float Btot=0.;
	for (int j=0; j< SAMPLE; j++)
	  for (int i=0; i< SAMPLE; i++)
	  {
		  vec2 pos = (.5+vec2(i,j))/float(SAMPLE);
		  vec3 c = texture2D(iChannel0,pos,LEVEL).rgb;
		  Ctot += c;
		  float v;
		  
		  v = match(c,targetA);
		  pA   += pos*v;
		  Atot += v;
		  
		  v = match(c,targetB);
		  pB   += pos*v;
		  Btot += v;	  
	  }
	pA /= Atot;
	pB /= Btot;
	_ambientI = lum(Ctot)/float(SAMPLE*SAMPLE);
	return;		 
}

// test collision with tracker p
bool test_collision(vec2 p, vec2 pong, vec2 Dpong)
{
	// is there a tracker on Pong-t*Dpong for some valid l ?
	// ie, | p - (pong-t.Dpong) | < trackerRadius ?
	// -> solve P2(t)=0
	float a = dot(Dpong,Dpong);
    float b = dot(p-pong,Dpong);
	float c = dot(p-pong,p-pong)-.1*.1;
    float t = -b*(1.-sqrt(1.-a*c/(b*b)));
    if (t>0.)
	{   // one found, but was it before or after the last bounce ?
		vec2 B = abs(pong-t*Dpong-.5);
	    if (max(B.x,B.y)<=.501)
			return true;
	}
	return false;
}
		
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 ratio = vec2(iResolution.x/iResolution.y,1.);
	vec3 col = texture2D(iChannel0,uv).rgb;
	
	// ball
	vec2 pong0 = vec2(.123,0.) + time*vec2(1.,.8);
	vec2 pong = abs(mod(pong0,2.)-1.);
	vec2 Dpong = (abs(mod(pong0+.01*vec2(1.,.8),2.)-1.)-pong)/.01;
		
	// trackers
	vec2 pA,pB;
    findTextureTargets(pA,pB);
	
	// display
	float l = length((uv-pong)*ratio);
	if ((l<.05)||(uv.y<.02)||(uv.y>.98)) col = vec3(1.);
	else
	{ l = length((uv-pA)*ratio);
	  if ( l<.1) 
	  { if(l>.09) col = targetA; }
	  else
	  { l = length((uv-pB)*ratio);
	    if (l<.1) 
	    { if(l>.09) col = targetB; }
	      else 
	      { //col = texture2D(iChannel0,uv).rgb;
			  float lA = lum(texture2D(iChannel0,pA,LEVEL).rgb),
				    lB = lum(texture2D(iChannel0,pB,LEVEL).rgb);
			        l = pow(_ambientI,3.);
			  col = vec3(5.*match(col,targetA)/(l),
						 5.*match(col,targetB)/(l),
						 .8*col.b);
		    // displays analyzer view... made more readable
		    //col = vec3(2.*pow(match(col,targetA),.3),
			//   	       5.*pow(match(col,targetB),.3),
			//	       .8*col.b);
	}}}
	
	// collision tests
	if (test_collision(pA, pong,Dpong))
		col *= targetA;
	else if(test_collision(pB, pong,Dpong))
		col *= targetB;
	
	fragColor = vec4(col,1.);
}