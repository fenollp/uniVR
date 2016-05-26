// Shader downloaded from https://www.shadertoy.com/view/MdBSzt
// written by shadertoy user Branch
//
// Name: Awful Graphics from 2014 
// Description: Awful Graphics from 2014 
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
    
    vec2 Xpos = vec2(1.1,-0.35);
    COLOR += 3.*vec3(0.0,-2.0,-0.0)*sdCapsule(coord, vec2(-0.15,-0.15)+Xpos, vec2( 0.15, 0.15)+Xpos, 0.025);
    COLOR += 3.*vec3(0.0,-2.0,-0.0)*sdCapsule(coord, vec2( 0.15,-0.15)+Xpos, vec2(-0.15, 0.15)+Xpos, 0.025);
    
    COLOR += 3.*vec3(0.1,-0.3,-0.3)*sdCapsule(coord, vec2(-1.7,-0.5), vec2( -0.7,-0.5), 0.025);
    COLOR += 3.*vec3(1.)*sdCapsule(coord, vec2( -1.7,0.3), vec2( -0.7,0.3), 0.025);
    COLOR -= 2.*vec3(1.)*sdCapsule(coord, vec2( -1.7,0.5), vec2( -0.7, 0.5), 0.025);
    
    float surface = texture2D(iChannel0, coord*length(coord)+vec2(sin(iGlobalTime),cos(iGlobalTime))).r;
    COLOR -= vec3(1.)*circle(coord, vec2(0.0), surface);
    if(circle(coord, vec2(0.0), .4)<0.)
    	COLOR = vec3(1.9,0.97,0.4);
    if(circle(coord, vec2(0.0), .3)<0.)
    	COLOR = vec3(1.2,1.6,0.3);
    
    float total_circle = circle(coord, vec2(0.0), .08);
    for(float i=0.0; i<3.141*2.0; i+=0.2*3.141){
        total_circle += circle(coord, vec2(0.4*cos(i+iGlobalTime),0.4*sin(i+iGlobalTime)), .04);
    }
    if(total_circle<0.)
    	COLOR = vec3(1.9,0.97,0.4);
    vec2 position = vec2(0.0);
    vec2 size = vec2(6.,2.);
    float corner = 0.2;
    if( roundBox(coord*5., position, size, corner ) < 1.)
    COLOR =vec3(0.0);
    
    coord = vec2(mod(s.x,.999)-.333,mod(s.y,.75)-0.21);
    
	fragColor = vec4( texture2D(iChannel0,s).rgb*.04+.7*COLOR*vignette
         				,1.0);
} 