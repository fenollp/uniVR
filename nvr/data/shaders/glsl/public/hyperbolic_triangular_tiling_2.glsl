// Shader downloaded from https://www.shadertoy.com/view/XsVXzW
// written by shadertoy user soma_arc
//
// Name: Hyperbolic triangular tiling 2
// Description: Tiling with Hyperbolic triangle. Their interior angles are (PI/2, PI/3, PI/8), (PI/2, PI/4, PI/8), and (PI/2, PI/5, PI/8). We use the Algorithm which called Iterated Inversion System (IIS) developed with Kazushi Ahara (Meiji University).
/*
Created by soma_arc, Kazushi Ahara - 2016
This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported.
*/

// from Syntopia http://blog.hvidtfeldts.net/index.php/2015/01/path-tracing-3d-fractals/
vec2 rand2n(vec2 co, float sampleIndex) {
    vec2 seed = co * (sampleIndex + 1.0);
	seed+=vec2(-1,1);
    // implementation based on: lumina.sourceforge.net/Tutorials/Noise.html
    return vec2(fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453),
                fract(cos(dot(seed.xy ,vec2(4.898,7.23))) * 23421.631));
}

vec2 tp1 = vec2(0.26607724, 0);
vec2 tp2 = vec2(0, 0.14062592);
vec2 cPos = vec2(2.01219217, 3.62584500);
float r = 4.02438434;
const float PI = 3.14159265359;

void calcCircle(float theta, float phi){
	float tanTheta = tan(PI/2. - theta);
    float tanPhi = tan(phi);
    float tanTheta2 = tanTheta * tanTheta;
    float tanPhi2 = tanPhi * tanPhi;
    
    tp1 = vec2(sqrt((1. + tanTheta2)/(-tanPhi2 + tanTheta2)) - 
               tanTheta * sqrt((1. + tanPhi2)/(-tanPhi2 + tanTheta2))/tanTheta, 0.);
    tp2 = vec2(0., -tanPhi * sqrt(-(1. + tanTheta2)/(tanPhi2 - tanTheta2))+
              tanTheta * sqrt(-(1. + tanPhi2)/(tanPhi2 - tanTheta2)));
    
    
    cPos = vec2(sqrt((1. + tanTheta2)/(-tanPhi2 + tanTheta2)),
                 sqrt((1. + tanPhi2)*tanTheta2/(-tanPhi2 + tanTheta2))
               );
    r = sqrt((1. + tanPhi2)*(1. + tanTheta2) /(-tanPhi2 + tanTheta2));
}

vec2 circleInverse(vec2 pos, vec2 circlePos, float circleR){
	return ((pos - circlePos) * circleR * circleR)/(length(pos - circlePos) * length(pos - circlePos) ) + circlePos;
}

const int ITERATIONS = 50;
float loopNum = 0.;
int IIS(vec2 pos){
    if(length(pos) > 1.) return 0;

    int invCount = 1;
    bool fund = true;
	for(int i = 0 ; i < ITERATIONS ; i++){
		fund = true;
        if (pos.x < 0.){
            pos *= vec2(-1, 1);
            invCount++;
	       	fund = false;
        }
        if(pos.y < 0.){
            pos *= vec2(1, -1);
            invCount++;
            fund = false;
        }
        if(distance(pos, cPos) < r ){
        	pos = circleInverse(pos, cPos, r);
            invCount++;
            fund = false;
        }
        if(fund)
        	return invCount;
    }

	return invCount;
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

const float sampleNum = 50.;
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    float ratio = iResolution.x / iResolution.y / 2.0;
    vec3 sum = vec3(0);
    calcCircle(PI/(4. + sin(iGlobalTime)), PI/8.);
    for(float i = 0. ; i < sampleNum ; i++){
        vec2 position = ( (fragCoord.xy + rand2n(fragCoord.xy, i)) / iResolution.yy ) - vec2(ratio, 0.5);

        position = position * 2.;
        //position *= 0.03 + abs(1. * sin(iGlobalTime) * sin(iGlobalTime));
        position *= 1.0;
        //position += vec2(cos(iGlobalTime), 0.3 * sin(iGlobalTime));

        int d = IIS(position);

        if(d == 0){
            sum += vec3(0.,0.,0.);
        }else{
            if(mod(float(d), 2.) == 0.){
                sum += hsv2rgb(vec3(0.3, 1., 1.));
            }else{
                sum += hsv2rgb(vec3(0.7, 1., 1.));
            }
        }
    }
    fragColor = vec4(sum/sampleNum, 1.);
}