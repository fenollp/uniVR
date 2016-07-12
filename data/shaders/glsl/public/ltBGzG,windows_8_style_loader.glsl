// Shader downloaded from https://www.shadertoy.com/view/ltBGzG
// written by shadertoy user BeRo
//
// Name: Windows 8 style loader
// Description: The Windows 8 style loader from the fr-078: Sweet night dreams 64k
const float PI = 3.14159265359;
float interpolateLinear(float a, float b, float t){
  return mix(a, b, clamp(t, 0.0, 1.0));
}
float interpolateEaseOut(float a, float b, float t){
  return mix(a, b, clamp(sin(clamp(t, 0.0, 1.0) * (PI * 0.5)), 0.0, 1.0));
}
float interpolateEaseInOut(float a, float b, float t){
  return mix(a, b, clamp((cos((clamp(t, 0.0, 1.0) * PI) + PI) + 1.0) * 0.5, 0.0, 1.0));
}
vec2 rotate(vec2 v, float a){
	return vec2((v.x*cos(a))-(v.y*sin(a)), (v.x*sin(a))+(v.y*cos(a)));
}
float t2;
float line(vec2 p1, vec2 p2, vec2 p, float t){
	vec2 a = p - p1, b = p2 - p1;
	a = rotate(a, -atan(b.y, b.x));
	return pow(clamp(t / ((a.x < 0.0) ? length(a) : ((a.x < length(b)) ? abs(a.y) : length(p - p2))), 0.0, 1.0), t2);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec4 c = vec4(vec3(0.0), 1.0);
  vec2 p = (((fragCoord.xy / iResolution.xy) - vec2(0.5)) * 2.0) * vec2(1., iResolution.y / iResolution.x);
	vec2 cp = (p + vec2(0.0, 0.3275)) * 32.0;  
  float t = mod(iGlobalTime, 5.5);
  vec4 ec0 = vec4(43.0 / 255.0, 128.0 / 255.0, 255.0 / 255.0, 1.0);
  vec4 ec1 = vec4(1.0);
  vec2 pp = p - vec2(0.0, 0.125);
  {
    vec2 cp = (pp * 4.0) + vec2(0., 0.0);
    cp.y *= 1.65;
    cp.x += 0.005;
    cp.y -= 0.3875;
    float d = dot(cp, normalize(vec2(-0.5, -0.5))) + 0.5;
    d = min(d, dot(cp, normalize(vec2(0.5, -0.5))) + 0.5);
    d = min(d, dot(cp, normalize(vec2(0.5, 0.0))) + 0.5);
    d = min(d, dot(cp, normalize(vec2(-0.5, 0.0))) + 0.5);
    cp.y += 0.5;
    d = min(d, dot(cp, normalize(vec2(0.5, 0.5))) + 0.5);
    d = min(d, dot(cp, normalize(vec2(-0.5, 0.5))) + 0.5);
		c = ec0 * clamp(d * 64.0, 0.0, 1.0); 
  }
  {
    vec2 cp = (pp * 1.5) + vec2(0.43, -0.29);
    vec2 ip = vec2(0.5, -0.5) / vec2(80.0, 80.0);
    float envelope1 = clamp(texture2D(iChannel0, vec2(0., 0.25)).x, 0.0, 1.0);
    float g = interpolateEaseInOut(0.002, 0.005, envelope1);
    t2 = interpolateEaseInOut(4.0, 1.25, envelope1);  
		c = mix(c, ec1, clamp(line(vec2(69., 69.) * ip, vec2(72., 67.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(72., 67.) * ip, vec2(72., 64.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(72., 64.) * ip, vec2(69., 62.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(69., 62.) * ip, vec2(66., 64.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(66., 64.) * ip, vec2(66., 67.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(66., 67.) * ip, vec2(69., 69.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(69., 62.) * ip, vec2(69., 59.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(69., 59.) * ip, vec2(73., 57.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(73., 57.) * ip, vec2(60., 48.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(60., 48.) * ip, vec2(63., 45.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(63., 45.) * ip, vec2(78., 54.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(78., 54.) * ip, vec2(83., 51.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(83., 51.) * ip, vec2(69., 43.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(69., 43.) * ip, vec2(73., 40.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(73., 40.) * ip, vec2(84., 47.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(84., 47.) * ip, vec2(84., 41.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(84., 41.) * ip, vec2(78., 37.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(78., 37.) * ip, vec2(84., 33.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(84., 33.) * ip, vec2(84., 37.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(69., 59.) * ip, vec2(52., 50.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(52., 50.) * ip, vec2(49., 52.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(82., 51.) * ip, vec2(86., 52.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(86., 52.) * ip, vec2(89., 50.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(89., 50.) * ip, vec2(90., 50.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(90., 50.) * ip, vec2(92., 52.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(92., 52.) * ip, vec2(92., 56.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(92., 56.) * ip, vec2(90., 58.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(90., 58.) * ip, vec2(89., 58.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(89., 58.) * ip, vec2(86., 56.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(86., 56.) * ip, vec2(86., 52.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(96., 57.) * ip, vec2(96., 26.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(96., 26.) * ip, vec2(68.5, 10.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(68.5, 10.) * ip, vec2(41., 26.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(41., 26.) * ip, vec2(41., 57.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(41., 57.) * ip, vec2(68.5, 73.) * ip, cp, g), 0.0, 1.0)); 
		c = mix(c, ec1, clamp(line(vec2(68.5, 73.) * ip, vec2(96.0, 57.0) * ip, cp, g), 0.0, 1.0)); 
  }
  for(int i = 0; i < 5; i++){
	  float ct = max(0.0, t - (float(i) * 0.24));
	  float cca = interpolateEaseInOut(225.0, 345.0, ct / 0.385);
	  cca = interpolateLinear(cca, 455.0, (ct - 0.385) / 1.265);
	  cca = interpolateEaseOut(cca, 690.0, (ct - 1.65) / 1.495);
	  cca = interpolateLinear(cca, 815.0, (ct - 2.149) / 1.705);
	  cca = (interpolateEaseOut(cca, 945.0, (ct - 3.85) / 0.275) * (PI / 180.0)) - (PI * 0.25);
   	c = mix(c, vec4(1.0), clamp(pow(1.0 - smoothstep(0., 1., length((vec2(sin(cca), cos(cca)) * 1.0) - cp) * 3.0), 8.0) * 2.0, 0.0, 1.0) * 
		                      interpolateEaseOut(interpolateEaseOut(0.0, 1.0, (ct - 0.0) / 0.055), 0.0, (ct - 4.125) / 0.055));
	} 
    fragColor=c;
}