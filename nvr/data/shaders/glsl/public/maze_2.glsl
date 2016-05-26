// Shader downloaded from https://www.shadertoy.com/view/4sSXWR
// written by shadertoy user FabriceNeyret2
//
// Name: maze 2
// Description: .
float t = iGlobalTime;
#define rnd( x)    fract(1000.*sin(345.2345*x))
#define id( x,y)   floor(x)+100.*floor(y)

float maze(vec2 u) {
    float n = id(u.x,u.y);  u = fract(u);
    return 1.-smoothstep(.1,.15,((rnd(n)>.5)?u.x:u.y));
}

void mainImage( out vec4 o, vec2 u ){
	u  /= iResolution.y;
    u = (u + vec2(1.8*cos(.2*t)+.6*sin(.4*t), sin(.3*t)+.4*cos(.4*t)) ) * (1.2-cos(.5*t));
    float a = 3.*(cos(.05*t)-.5*cos(1.-.1*t)), C=cos(a), S=sin(a),
          v = 0., w=1., s=0.; u *= 2.*mat2(C,-S,S,C);

 #define L  v+= w*maze(u*=4.); s+= w;  w *= .3;
    L L L L
    
	o += 1.-v/s -o;
}


/* // --- expended version

float t = iGlobalTime;
float rnd(float x) { return fract(1000.*sin(345.2345*x)); }
float id(float x, float y) { return floor(x)+100.*floor(y); }

float maze(vec2 uv) {
    float n = id(uv.x,uv.y);  uv = fract(uv);
    return 1.-smoothstep(.1,.15,((rnd(n)>.5)?uv.x:uv.y));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord.xy / iResolution.y;
    uv = (uv + vec2(1.8*cos(.2*t)+.6*sin(.4*t),sin(.3*t)+.4*cos(.4*t)) ) * (1.2-cos(.5*t));
    float a = 3.*(cos(.05*t)-.5*cos(1.-.1*t)), C=cos(a), S=sin(a); uv*=mat2(C,-S,S,C);

    float v = 0., w=1., s=0.; uv *= 2.;
    for(int i=0; i<3; i++) { 
        uv *= 4.;  
        v+= w*maze(uv); s+= w; 
        w *= .3;
    }
	fragColor = vec4(1.-v/s);
}
/**/