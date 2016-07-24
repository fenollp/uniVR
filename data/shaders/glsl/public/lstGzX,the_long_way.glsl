// Shader downloaded from https://www.shadertoy.com/view/lstGzX
// written by shadertoy user Sgw32
//
// Name: The Long Way
// Description: Logo on the startup of the game
// by Nikos Papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// by Sgw32
#ifdef GL_ES
precision highp float;
#endif

#define PI	3.14159265359
#define SIZE 3.

#define S(t) tan(t.x*0.4+0.7)

float hash(in vec3 p)
{
	return fract(sin(dot(p,vec3(283.6,127.1,311.7))) * 43758.5453);
}

float noise(vec3 p, vec3 fft, vec3 wav){
	p.y -= iGlobalTime * 2. + 2. * fft.x * fft.y;
	p.z += iGlobalTime * .4 - fft.z;
	p.x += 2. * cos(wav.y);
	
    vec3 i = floor(p);
	vec3 f = fract(p); 
	f *= f * (3.-2.*f);
    
    vec2 c = vec2(0,1);

    return mix(
		mix(mix(hash(i + c.xxx), hash(i + c.yxx),f.x),
			mix(hash(i + c.xyx), hash(i + c.yyx),f.x),
			f.y),
		mix(mix(hash(i + c.xxy), hash(i + c.yxy),f.x),
			mix(hash(i + c.xyy), hash(i + c.yyy),f.x),
			f.y),
		f.z);
}

float fbm(vec3 p, vec3 fft, vec3 wav)
{
	return .5000 * noise(1. * p, fft, wav) 
		 + .2500 * noise(2. * p, fft, wav)
	     + .1250 * noise(4. * p, fft, wav)
	     + .0625 * noise(8. * p, fft, wav);
}

float rand2(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise2(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand2(b), rand2(b + d.yx), f.x), mix(rand2(b + d.xy), rand2(b + d.yy), f.x), f.y);
}

float fbm2(vec2 n) {
    float total = 0.0, amplitude = 1.0;
    for (int i = 0; i < 7; i++) {
        total += noise2(n) * amplitude;
        n += n;
        amplitude *= 0.5;
    }
    return total;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 fft = vec3(S(vec2(.0,.25)),S(vec2(.5,.25)),S(vec2(1.,.25)));
	vec3 wav = vec3(S(vec2(.0,.75)),S(vec2(.5,.75)),S(vec2(1.,.75)));
	float t  = cos(fft.x * 2. / PI);
	float ct = cos(t);
	float st = sin(t);

	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 vc = (2. * uv - 1.) * vec2(iResolution.x / iResolution.y, 1.);
	
	vc = vec2(vc.x * ct - vc.y * st
			 ,vc.y * ct + vc.x * st);

	vec3 rd = normalize(vec3(.5, vc.x, vc.y));
	vec3 c = 2. * vec3(fbm(rd, fft, wav)) * fft.xyz;
	c += hash(hash(uv.xyy) * uv.xyx * iGlobalTime) * .2;;
	c *= .9 * smoothstep(length(uv * .5 - .25), .7, .4);
	c = c.xyz*1.;
    c.x*=2.;
    
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;

    // calculate angle of current pixel from origin
    // atan return values are in [-pi/2, pi/2]
    // original tutorial uses function atan(p.y, p.x) which gives a horizontal line
    // in left middle as artefact so i will keep this
    
    float a = 0.;
    if (abs(p.y)<abs(p.x))
    	a = acos(p.y/p.x);
    
    // distance of point from origin
    float r = length(p);

    // note that uv are from lower left corner and should be in 0-1
    // r is in range [0, sqrt(2)]
    // a is in range [-pi/2, pi/2] so y will be in range [-1/2, 1/2]
    // 3.1416 = pi
    // note that texture is mapped twice devided by a horizontal line
    // spent hours trying to visualize below two line.. no luck ! :-/ :'(
    uv.x = .2/r; 
    uv.y = a/(3.1416);
    
    // add global time for a moving tunnel
    uv.x = uv.x + iGlobalTime/2.0;
    
    
    
    vec4 col = vec4(0,0,0,1);
    //vec2 uv = (vec2(atan(p.y,p.x), .2/cc.w))*cc.w;
   //uv = fragCoord.xy * 1.0 / iResolution.xy;
   
    // draw a line, left side is fixed
    vec2 tq = uv * vec2(2.0,1.0) - iGlobalTime*3.0;
    vec2 t2 = (vec2(1,-1) + uv) * vec2(2.0,1.0) - iGlobalTime*3.0; // a second strand
   
    // draw the lines,
//  this make the left side fixed, can be useful
//  float ycenter = mix( 0.5, 0.25 + 0.25*fbm( t ), uv.x*4.0);
//    float ycenter2 = mix( 0.5, 0.25 + 0.25*fbm( t2 ), uv.x*4.0);
    float ycenter = fbm2(tq)*0.5;
    float ycenter2= fbm2(t2)*0.5;

    // falloff
    float diff = abs(uv.y - ycenter);
    float c1 = 0.;
    c1 = 1.0 - mix(0.0,1.0,diff*20.0);
   
    float diff2 = abs(uv.y - ycenter2);
    float c2 = 1.0 - mix(0.0,1.0,diff2*20.0);
   
    float c3 = max(c1,c2);
    if (c3<0.)
        c3=0.;
    if (c2<0.)
        c2=0.;
    if (c1<0.)
        c1=0.;
    
    col = vec4(c3*0.6,0.2*c2,c3,1.0); // purple color
    
    float time = iGlobalTime;
    time = mod(time, 5.);
    uv = fragCoord.xy / iResolution.xy;
	
	vec3 color = vec3(0.0, 0.0, 0.0);
    
    
	float piikit  = 0.5+asin(sin(SIZE*uv.x*6.28))/5.;
    
    
    if (uv.x<(1./(SIZE)))
    {
            piikit=0.5;
    }  
    
    
    if (uv.x>(1.-1./(SIZE)))
    {
            piikit=0.5;
    }    
    
    float x1 = uv.x*2.;
    //float xt = time/10.;
    float pos = 2.+8.*pow(time,4.);
   
    //xx=-pow(xx,2.);
    
    //piikit=1.-exp(xx);
    
	float flash = 1.;
                
	float glow = (flash*0.02)/abs(piikit - uv.y);
                
	color = vec3(0.0, glow*0.5, 0);
	color += vec3(sqrt(glow*0.2));
    
	fragColor = col + vec4(c,1.)+vec4(color,1);
}