// Shader downloaded from https://www.shadertoy.com/view/4tSXWV
// written by shadertoy user yiwenl
//
// Name: 03 Substraction
// Description: Substraction
vec2 rotate(vec2 pos, float angle) {
	float c = cos(angle);
	float s = sin(angle);

	return mat2(c, s, -s, c) * pos;
}

float smin( float a, float b, float k )
{
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float smin( float a, float b )
{
    return smin(a, b, 3.0);
}

float iPlane(vec3 pos) {
    return pos.y;
}

float iSphere(vec3 pos, float radius) {
    return length(pos) - radius;
}


float map(vec3 pos) {
    float dSphere = iSphere(pos, 4.0);
    
    float s1 = iSphere(pos - vec3(sin(iGlobalTime*.55)*1.85, cos(iGlobalTime*.19) * 0.95, sin(iGlobalTime*.91) * 1.21) * 1.0, 2.6451);
    float s2 = iSphere(pos - vec3(cos(iGlobalTime*.43)*1.55, sin(iGlobalTime*.38) * 1.12, cos(iGlobalTime*.76) * 1.67) * 1.4, 2.564821);
    float s3 = iSphere(pos - vec3(sin(iGlobalTime*.26)*2.52, cos(iGlobalTime*.57) * 0.56, sin(iGlobalTime*.12) * 1.58) * 1.2, 2.98441);
    float s4 = iSphere(pos - vec3(sin(iGlobalTime*.97)*1.72, sin(iGlobalTime*.22) * 0.81, cos(iGlobalTime*.34) * 0.97) * 1.5, 2.12373);
    float s5 = iSphere(pos - vec3(sin(iGlobalTime*.62)*1.47, cos(iGlobalTime*.76) * 0.73, sin(iGlobalTime*.75) * 1.45) * 1.7, 2.2748186);
    
    float d = smin(s1, smin(s2, smin(s3, smin(s4, s5))));
    
    return max(-d, dSphere);
}

const float PI = 3.141592657;
const vec3 lightDirection = vec3(1.0, 1.0, -1.0);
const vec4 lightBlue = vec4(186.0, 209.0, 222.0, 255.0)/255.0;

float diffuse(vec3 normal) {
    return max(dot(normal, normalize(lightDirection)), 0.0);   
}

float specular(vec3 normal, vec3 dir) {
	vec3 h = normalize(normal - dir);
	return pow(max(dot(h, normal), 0.0), 40.0);
}

vec3 getColor(vec3 pos, vec3 normal, vec3 dir) {
    pos.xz = rotate(pos.xz, sin(iGlobalTime*.25)*.2);
    pos.yz = rotate(pos.yz, cos(sin(iGlobalTime*.25)*.2)+iGlobalTime*.1) * .3;    
    float zOffset = 200.0 + sin(cos(iGlobalTime*0.443256)*0.716786) * 200.0;
    zOffset = 1.0 + zOffset*.05;
    float grey = fract(pos.z*zOffset - iGlobalTime*.1);
    grey = 1.0 - sin(grey * PI);
    grey *= mix(1.0 + sin(pos.z*50.0 - iGlobalTime*.1) * 0.5, 0.0, .25);
    grey = grey * grey;
    
    float diff = diffuse(normal);
    float spec = specular(normal, dir);
    
//    return vec3(grey+diff*.75);
    return vec3(grey+spec*.75+diff*.5);
}

vec3 computeNormal(vec3 pos) {
	vec2 eps = vec2(0.01, 0.0);

	vec3 normal = vec3(
		map(pos + eps.xyy) - map(pos - eps.xyy),
		map(pos + eps.yxy) - map(pos - eps.yxy),
		map(pos + eps.yyx) - map(pos - eps.yyx)
	);
	return normalize(normal);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = -1.0 + uv * 2.0;
    uv.x *= iResolution.x / iResolution.y;
    
    float focus = 1.25;
    vec3 pos = vec3(0.0, 0.0, -10.0);
    vec3 dir = normalize(vec3(uv, focus));
    
    vec4 color = vec4(.0);
    float d;
    
    const int NUM_ITER = 64;
    for(int i=0; i<NUM_ITER; i++) {
        d = map(pos);
        if(d < 0.0001) {
            vec3 normal = computeNormal(pos);
            color.rgb = getColor(pos, normal, dir);
            color.a = 1.0;
            break;
        }
        
        pos += d * dir;
        if(length(pos) > 10.0) break;
    }
    
    color = color;
    
	fragColor = vec4(color) * lightBlue;
}