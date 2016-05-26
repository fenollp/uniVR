// Shader downloaded from https://www.shadertoy.com/view/4dSSW1
// written by shadertoy user FabriceNeyret2
//
// Name: Worley noise 4
// Description: variant from https://www.shadertoy.com/view/Md2SDz
float rnd(float x) { return fract(1000.*sin(234.56*x)); }
vec3 rnd3(float x) { return vec3(rnd(x),rnd(x+.1),rnd(x+.2)); }
float hash(float x,float y,float z) { return (x+432.432*y-1178.65*z); }
float hash(vec3 v) { return dot(v,vec3(1., 32.432, -1178.65)); }
    
vec4 Worley(vec3 uvw) {
    
   vec3 uvwi = floor(uvw);							// cell coords
   float dmin = 1e9, d2min=1e9, nmin=-1.;
    
    for (int i=-1; i<=1; i++)						// visit neighborhood
      for (int j=-1; j<=1; j++)						// to find the closest point
          for (int k=-1; k<=1; k++) 
          {
              vec3 c = uvwi + vec3(float(i),float(j),float(k)); // neighbor cells
              float n = hash(c);	 							// cell ID
              vec3 p = c + rnd3(n+.1);							// random point in cell
              float d = length(p-uvw);							// dist to point
              if (d<dmin) { d2min=dmin; dmin=d; nmin=n; }		// 2 closest dists
              else if (d<d2min) { d2min=d; }
          }
	return vec4(dmin,d2min,d2min-dmin, nmin);			// 2 closest dists + closest ID
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 uvw = vec3(2.*(fragCoord.xy / iResolution.y-vec2(.9,.5)), .2*iGlobalTime);
    float a = .2*iGlobalTime,c=cos(a),s=sin(a); uvw.xy *= mat2(c,-s,s,c);	// rotate
    uvw *= 4.*(.7+.6*vec3(vec2(cos(.5*iGlobalTime)),0.));					// zoom

    vec3 col = vec3(1.);
    vec3 uvw0 = uvw; 
    for (int i=0; i<4; i++) {
    	uvw = uvw0+ .2*texture2D(iChannel0,.1*uvw.xy).rgb;				// jitter pos
        vec4 wor = Worley(uvw);    
   		 vec3 ccol = mix(vec3(1.), rnd3(wor.a+.4), .4);
   		 float v = wor.z;
  		 int mode =  int(mod(.25*iGlobalTime,4.));						// demo mode
   		 if      (mode==0) v *= 4.;
  		 else if (mode==1) v = pow(v,.025);
  		 else if (mode==2) { v -= .3*sin(30.*uvw0.x)*sin(30.*uvw0.y); v = pow(v,.025); }
  		 else              { v -= .02; v = pow(v,.025); }
		col *= v*ccol;
        uvw0 *= 2.;
    }   

	fragColor = vec4(col,1.0);
}