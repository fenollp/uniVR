// Shader downloaded from https://www.shadertoy.com/view/ltS3zz
// written by shadertoy user Branch
//
// Name: STYLE?3
// Description: STYLE?3
float roundBox(vec2 coord, vec2 pos, vec2 b, float c ){
  return 1.-floor(length(max(abs(coord-pos)-b,c)));
}
float circle(vec2 coord, vec2 pos, float size){
    return min(floor(distance(coord,pos)-size),0.);
}
float sdCapsule( vec2 p, vec2 a, vec2 b, float r ){
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return min(floor(length( pa - ba*h ) - r),0.);
}
mat2 rotate(float Angle)
{
    mat2 rotation = mat2(
        vec2( cos(Angle),  sin(Angle)),
        vec2(-sin(Angle),  cos(Angle))
    );
	return rotation;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 p = fragCoord.xy / iResolution.xy;
	float aspectCorrection = (iResolution.x/iResolution.y);
	vec2 coordinate_entered = 2.0 * p - 1.0;
	vec2 coord = vec2(aspectCorrection,1.0) *coordinate_entered;
    vec2 s = coord;
	float vignette = 1.0 / max(0.25 + 0.3*dot(coord,coord),1.);
    
	vec3 COLOR =(vec3(0.9,0.4,0.5)
        		+vec3(0.2,0.5,0.2) );
    if(mod(coord.y*200.+coord.x*200.,8.)<1.1){
        COLOR -= vec3(0.05);
    }else if(mod(coord.y*200.-coord.x*200.,8.)<1.1){
        COLOR -= vec3(0.05);
    }
    coord *= rotate(iGlobalTime*0.1);
	coord /= 1.0+iGlobalTime*iGlobalTime*0.11;
    coord += 0.01*vec2(cos(iGlobalTime),sin(iGlobalTime))/(1.0+iGlobalTime*0.1);
    for(float j = 0.0; j < 6.0; j+=2.0){
    for(float i = 0.0; i < 20.0; i++){
        float spin = iGlobalTime*.1111*sin(j);
        float depth = 0.01*iGlobalTime+j;
    	float Tfast = max(iGlobalTime - (2.0 * depth), 0.0) * 10.0;
        float bouncing = (0.5-0.5*cos(Tfast)/(1.0+Tfast*Tfast*0.01));
    	COLOR -= (0.4*j)*vec3(0.4+sin(j)*.1,0.4,0.3)*sdCapsule(coord, vec2(0.0), bouncing*(1.0/(depth*2.0))*vec2(cos(spin+depth+i*3.141*0.1),sin(spin+depth+i*3.141*0.1)), 0.05/depth);
    }
    for(float i = 0.0; i < 20.0; i++){
        float spin = iGlobalTime*.1*sin(j);
        float depth = 0.01*iGlobalTime+j;
    	float Tfast = max(iGlobalTime - 2.0 - (2.0 * depth), 0.0) * 10.0;
        float bouncing = (0.5-0.5*cos(Tfast)/(1.0+Tfast*Tfast*0.01));
    	COLOR += (0.4*j)*vec3(1.6)*sdCapsule(coord, vec2(0.0), bouncing*(0.5/(depth*2.0))*vec2(cos(spin+depth+i*3.141*0.1),sin(spin+depth+i*3.141*0.1)), 0.025/depth);
    }
    }

    coord = vec2(mod(s.x,.999)-.333,mod(s.y,.75)-0.21);
    
	fragColor = vec4( texture2D(iChannel0,s).rgb*.04+.7*COLOR*vignette
         				,1.0);
} 