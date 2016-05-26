// Shader downloaded from https://www.shadertoy.com/view/ltXGWn
// written by shadertoy user pflowsoftware
//
// Name: crazy stupid fractal
// Description: this is an abomination. used the linear interpolation from http://en.wikipedia.org/wiki/Mandelbrot_set#Histogram_coloring and the algorithm shown is (z^z+z)/ln(z) + c
//    
//    log(complex number) is confusing on wikipedia
//    tldr:
//    real: log(|c|)
//    imag: atan(i/r)
//Julia Set for (.285,.01)
#define CREAL .268
#define CIMAG .060
#define DEPTH 1000
#define R x
#define I y

vec3 hsv(float h,float s,float v) {
	return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
}

float cMag2(vec2 c){
    return c.R*c.R+c.I*c.I;
}
float cArg(vec2 c){
 	return atan(c.I,c.R);   
}
float cMag(vec2 c){
 	return sqrt(c.R*c.R+c.I*c.I);   
}
vec2 cLog(vec2 c){
 	float real = log(cMag(c));
    float imag = cArg(c);
    return vec2(real,imag);
}
vec2 cConj(vec2 c){
	return vec2(c.R, -1.*c.I);   
}
vec2 cMult(vec2 c1, vec2 c2){
    float real = c1.R*c2.R-c1.I*c2.I; //real * real - imag * imag
    float imag = c1.R*c2.I+c1.I*c2.R; //real * imag + imag * real
    return vec2(real,imag);
}
vec2 cDivScalar(vec2 c, float s){
    return vec2(c.R/s,c.I/s);
}
vec2 cDiv(vec2 c1, vec2 c2){
	vec2 c2c = cConj(c2);
    vec2 numerator = cMult(c1,c2c);
    float denominator = cMult(c2,c2c).R;
    return cDivScalar(numerator,denominator);
}
vec2 cSum(vec2 c1,vec2 c2){
    return vec2(c1.R+c2.R,c1.I+c2.I);}

vec2 cSqr(vec2 c){
    return vec2(c.R*c.R-c.I*c.I,2.*c.R*c.I);}

float julia(vec2 z, vec2 C){
    float attSize = 0.; //.01*(sin(iGlobalTime/10.));
    float iteration = 0.;
    for( int i = 0; i < 10; i++){
        
        z = cSum(cDiv(cSum(cSqr(z),z),cLog(z)),C);
        
        //if (cMag2(z)>4.){return float(DEPTH-i)/float(DEPTH);} //escape
        //if (cMag2(z)<attSize){return 1.;} //creates Attractors (Spots)
        iteration += 1.;
        if (cMag2(z) > 16. || iteration>=float(DEPTH)){break;}
    }
    if ( iteration < float(DEPTH) ) {
        float zn = cMag(z);
        float nu = log( log(zn) / log(2.) ) / log(2.);
        // Rearranging the potential function.
        // Could remove the sqrt and multiply log(zn) by 1/2, but less clear.
        // Dividing log(zn) by log(2) instead of log(N = 1<<8)
        // because we want the entire palette to range from the
        // center to radius 2, NOT our bailout radius.
        iteration = iteration + 1. - nu;
  	}
    return float(iteration);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    mat2 rot;
    float zoom = 1.; //1.2*abs(sin(iGlobalTime/8.));
	
	float deg = iGlobalTime/4.+sin(iGlobalTime/4.);;
	
	rot[0] = vec2(cos(deg), sin(deg));
	rot[1] = vec2(-sin(deg), cos(deg));
    
    float aspectRatio = iResolution.x/iResolution.y;
    float xMod = (fragCoord.x / iResolution.x - .5)*3.0*aspectRatio;
    float yMod = (fragCoord.y / iResolution.y - .5)*3.0;
    vec2 z = vec2(xMod,yMod)*rot*zoom;
	
    //float realSeed = .285+1.*tan(iGlobalTime/tan(iGlobalTime/2000.)); //curly + stringy
    float realSeed = CREAL+.01*tan(iGlobalTime/2.)+.01*sin(iGlobalTime/2.);
    //float realSeed = CREAL;
    //float imagSeed = CIMAG;
    float imagSeed = CIMAG +.01*sin(iGlobalTime/3.0);
    vec2 C = vec2(realSeed,imagSeed);
    //vec2 C = vec2(0,0);
	float x = julia(z,C);
	fragColor = vec4(hsv(1.*x+sin(iGlobalTime/10.), 1., .2+x), 1.0);   
}

//hsv from gleurop "The Pulse", thanks
//rot from sander "Texture spin & zoom", thanks