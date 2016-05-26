// Shader downloaded from https://www.shadertoy.com/view/4dGSzR
// written by shadertoy user vox
//
// Name: Couldn't Resist
// Description: Couldn't Resist
#define t2D(o) texture2D(iChannel0, uv-o/res)

#define plane(p, n) 1. - abs(dot(p, n))*res.y

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time ((saw(float(__LINE__))*.001+1.0)*iGlobalTime)
#define saw(x) (acos(cos(x))/PI)
#define stair floor
#define jag fract

float cross( in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }

// given a point p and a quad defined by four points {a,b,c,d}, return the bilinear
// coordinates of p in the quad. Returns (-1,-1) if the point is outside of the quad.
vec2 invBilinear( in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d )
{
    vec2 e = b-a;
    vec2 f = d-a;
    vec2 g = a-b+c-d;
    vec2 h = p-a;
        
    float k2 = cross( g, f );
    float k1 = cross( e, f ) + cross( h, g );
    float k0 = cross( h, e );
    
    float w = k1*k1 - 4.0*k0*k2;

    w = sqrt(abs( w ));
    
    float v1 = ((-k1 - w)/(2.0*k2));
    float v2 = ((-k1 + w)/(2.0*k2));
    float u1 = ((h.x - f.x*v1)/(e.x + g.x*v1));
    float u2 = ((h.x - f.x*v2)/(e.x + g.x*v2));
    bool  b1a = v1>0.0 && v1<1.0;
    bool  b1b = u1>0.0 && u1<1.0;
    bool  b2a = v2>0.0 && v2<1.0;
    bool  b2b = u2>0.0 && u2<1.0;
    

    vec2 res = vec2(min(abs(u1), abs(u2)), min(abs(v1), abs(v2)));
    return saw(res*1.0*PI);
}


vec2 SinCos( const in float x )
{
	return vec2(sin(x), cos(x));
}
vec3 RotateZ( const in vec3 vPos, const in vec2 vSinCos )
{
	return vec3( vSinCos.y * vPos.x + vSinCos.x * vPos.y, -vSinCos.x * vPos.x + vSinCos.y * vPos.y, vPos.z);
}
      
vec3 RotateZ( const in vec3 vPos, const in float fAngle )
{
	return RotateZ( vPos, SinCos(fAngle) );
}
vec2 RotateZ( const in vec2 vPos, const in float fAngle )
{
	return RotateZ( vec3(vPos, 0.0), SinCos(fAngle) ).xy;
}
mat4 RotateZ( const in mat4 vPos, const in float fAngle )
{
	return mat4(RotateZ( vec3(vPos[0].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0,
                RotateZ( vec3(vPos[1].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0,
                RotateZ( vec3(vPos[2].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0,
                RotateZ( vec3(vPos[3].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0);
}
mat4 translate( const in mat4 vPos, vec2 offset )
{
	return mat4(vPos[0].xy+offset, 0.0, 0.0,
                vPos[1].xy+offset, 0.0, 0.0,
                vPos[2].xy+offset, 0.0, 0.0,
                vPos[3].xy+offset, 0.0, 0.0);
} 
mat4 scale( const in mat4 vPos, vec2 factor )
{
	return mat4(vPos[0].xy*factor, 0.0, 0.0,
                vPos[1].xy*factor, 0.0, 0.0,
                vPos[2].xy*factor, 0.0, 0.0,
                vPos[3].xy*factor, 0.0, 0.0);
} 
vec2 tree(vec2 uv)
{
    
    uv = uv*2.0-1.0;
    
    mat4 square = mat4(EPS, EPS, 0.0, 0.0,
                       1.0-EPS, EPS, 0.0, 0.0,
                       1.0-EPS, 1.0-EPS, 0.0, 0.0,
                       0.0, 1.0-EPS, 0.0, 0.0);
    
    float size =  .5;
    
    square = translate(square, vec2(-.5));
    square = scale(square, vec2(2.0));
    square = RotateZ(square, PI/6.0+sin(iGlobalTime)*.1);
    square = scale(square, vec2(.75));
    square = translate(square, vec2(.5, 0.0));
    
    
    vec2 uv1 = invBilinear(uv, square[0].xy, square[1].xy, square[2].xy, square[3].xy);
    square = scale(square, vec2(-1.0, 1.0));
    vec2 uv2 = invBilinear(uv, square[0].xy, square[1].xy, square[2].xy, square[3].xy);
    if(uv.x >= 0.0)
    	return uv1;
    if(uv.x < 0.0)
    	return uv2;
    else
    	return uv*.5+.5;
}


float square(vec2 uv, float iteration)
{
	if(abs(abs(saw(uv.x*(1.5+sin(iGlobalTime*.654321))*PI+iGlobalTime*.7654321)*2.0-1.0)-abs(uv.y)) < .5)
		return (1.0-abs(abs(saw(uv.x*(1.5+sin(iGlobalTime*.654321))*PI+iGlobalTime*.7654321)*2.0-1.0)-abs(uv.y))/.5)*uv.x;
	else
		return (0.0);
}


vec2 spiral(vec2 uv)
{
    float turns = 4.0+saw(time/4.0)*4.0;
    float r = pow(log(length(uv)+1.), .75);
    float theta = atan(uv.y, uv.x)*turns-r*PI;
    return vec2(saw(r*PI+theta/turns+iGlobalTime*.2), saw(theta/turns+iGlobalTime*.1));
}

vec3 phase(float map)
{
    return vec3(saw(map),
                saw(4.0*PI/3.0+map),
                saw(2.0*PI/3.0+map));
}

float get_max(){
  // find max offset (there is probably a better way)
  float jmax = 0.0;
  float jmaxf=0.0;
  float jf=0.0;
  float ja;
  for (int j=0;j<200;j++){
    jf = jf+0.005;
    ja = texture2D( iChannel0, vec2(jf,0.75)).x;
    if ( ja>jmaxf) {jmax = jf;jmaxf = ja;}
  }
  return jmax;
}

float wavelet( vec2 uv )
{
  float px = 2.0*(uv.x-0.5);
  float py = 2.0*(uv.y-0.5);

  float dx = uv.x;
  float dy = uv.y;

  // alternative mappings
  dx = abs(uv.x-0.5)*3.0;
  //dx =1.0*atan(abs(py),px)/(3.14159*2.0);
  //dy =2.0*sqrt( px*px + py*py );
	
  const float pi2 = 3.14159*2.0;

  // my wavelet 
  //float width = 1.0-dy; 
  //float width = (1.0-sqrt(dy)); // focus a little more on higher frequencies
  float width = 1.0-(pow(dy,(1.0/4.0) )); // focus a lot more on higher frequencies
  const float nperiods = 4.0; //num full periods in wavelet
  const int numsteps = 256; // more than 100 crashes nvidia windows (would love to know why)
  const float stepsize = 1.0/float(numsteps);
  
  float accr = 0.0;

  float si_max=0.0;
#ifdef OFFSET_ON
    si_max=get_max();
#endif
    
  // x is in 'wavelet packet space'
  for (float x=-1.0; x<1.0; x+=stepsize){
	
	// the wave in the wavelet 
    float yr = sin((dx+x*nperiods*pi2)); 
    
    // get a sample - center at uv.x, offset by width*x
    float si = dx + width*x;

      si+=si_max;

	  if (si>0.0 || si<1.0){
        
		// take sample and scale it to -1.0 -> +1.0
		float s = 2.0*( texture2D( iChannel1, vec2(si,0.75)).x - 0.5 + (12.5/256.0) ); 
         	
		// multiply sample with the wave in the wavelet
	    float sr=yr*s;
         
	    // apply packet 'window'
        float w = 1.0-abs(x);
	    sr*=w;

		// accumulate
        accr+=sr;
 	  }
  }

  float y=accr*accr/PI; //; //0.0*abs(accr)/accn;
 
  return clamp(y, 0.0, 1.0)*saw(y+time+py*PI)*PI;

 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 res = iResolution.xy;
    vec2 uv = fragCoord / res;
    vec2 p = fragCoord / res.y;
    vec3 o = vec3(1., -1., 0.);
    vec2 uv0 = uv.xy;
    
    float map = 0.0;
    
    float lambda = 4.0;
    
    float scale = 2.0*PI;
	const int max_iterations =16;
    
    vec2 dirs[4];
    dirs[0] = o.xz; dirs[1] = o.yz; dirs[2] = o.zx; dirs[3] = o.zy;
    
    // current position
    vec2 pos = t2D(o.zz).rg;
    
    float c, w = 0.;
    
    // cell gradient
	c = 2. * length(p-pos/res.y);
    
    // cell walls
    for(int i=0; i<4; i++) {
        vec2 iPos = t2D(dirs[i]).rg;
        if(pos!=iPos)
            w = max(w, plane(p-mix(pos, iPos, .5)/res.y, normalize(pos-iPos)));
    }
    
   	uv = (p-pos/res.y)*.125+.125;
    
    
    for(int i = 0; i <= max_iterations; i++)
    {
    	float iteration = PI*(float(i)/(float(max_iterations) ));
        scale = 2.0;//pow(amplitude, length(uv0*2.0-1.0)/sqrt(2.0)*sin(time*GR/2.0+float(i)-1.0));
        //if(i == 0) uv.xy = (uv.xy*2.0-1.0)*vec2(iResolution.x/iResolution.y, 1.0)*.5+.5;
        //    uv.xy += .125*vec2(sin(time/PI), cos(time/2.0*GR));
        uv.xy = tree(uv.xy);
        map += square(uv.xy, float(i));
    }
    
    float map2 = 0.0;
    /*
    noise = 1.0;
    for(int i = 0; i < max_iterations; i++)
    {
        uv.xy *= scale;
        uv.xy -= scale/2.0;
        if(i == 0)
            uv.x *= iResolution.x/iResolution.y;
        uv.xy = normalize(uv.xy)*log(length(uv.xy)+1.0);
        uv = spiral(uv);
        map2 += uv.g*noise;
        
        noise *= clamp(.95-fwidth(map2), 0.0, 1.0);
    }
    */
    
    
    
    
    fragColor.rg = uv.rg;//saw(uv.zw);//saw(uv.zw*PI);
    
    w = wavelet(uv.xy);
    map += w;
    
    fragColor.b = 0.0;
    fragColor.a = 1.0;
    //fragColor = vec4(noise);
    fragColor.rgb = w*phase(map+time);
}