// Shader downloaded from https://www.shadertoy.com/view/MtS3zz
// written by shadertoy user Branch
//
// Name: STYLE?4
// Description: STYLE?4
float roundBox(vec2 coord, vec2 pos, vec2 b ){
  return length(max(abs(coord-pos)-b,0.05));
}
float circle(vec2 coord, vec2 pos, float size){
    return min(floor(distance(coord,pos)-size),0.);
}
float sdCapsule( vec2 p, vec2 a, vec2 b, float r ){
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return min(floor(length( pa - ba*h ) - r),0.);
}

mat2 rotate(float Angle){
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
    coord *= 0.7+sin(iGlobalTime)*0.2;
    coord *= rotate(sin(iGlobalTime*0.7)*0.1);
	float vignette = 1.0 / max(0.25 + 0.3*dot(coord,coord),1.);
	vec3 COLOR =vec3(1.0);
    
    
    for(float i = -2.0; i < 3.0; i++){
        
        vec2 cloud_pilar_position_A = vec2( (0.2-abs(i)*.015)*i, 0.0);
        vec2 cloud_pilar_position_B = vec2(  (0.2-abs(i)*.015)*i, 0.3-abs(i)*.1);
        if(coord.y>0.0 && sdCapsule( coord, cloud_pilar_position_A, cloud_pilar_position_B, 0.11-abs(i)*.02)<0.0)
            COLOR = vec3(	(0.0/225.0), 
                            (125.0/225.0), 
                            (207.0/225.0) );

        vec2 rain_pilar_position_A =vec2( i*0.19, 0.0);
        vec2 rain_pilar_position_B = vec2(  i*0.19, -1.);
        if(sdCapsule( coord, rain_pilar_position_A, rain_pilar_position_B, 0.03)<0.0)
            COLOR = vec3(	(0.0/225.0), 
                            (125.0/225.0), 
                            (207.0/225.0) );
        
    }
    
    for(float i = -3.0; i < 4.0; i++){
        
        vec2 box_position = vec2( i*0.5, -1.0+sin(i*i*111.6346361+iGlobalTime*3.0)*0.1);
        vec2 box_size = vec2(0.15,0.3);
        if(roundBox(coord, box_position, box_size )<0.1)
            COLOR = vec3(	(222.0/225.0), 
                            (0.0/225.0), 
                            (104.0/225.0) );
        
    }
    
    for(float i = -7.0; i < 13.0; i++){
        float tip = mod(i + iGlobalTime * 0.6 + 7.0, 14.0) - 7.0;
        vec2 circle_position =vec2( tip * 0.3 + sin(tip) * 0.1, 1.0 + sin(i + tip * tip) * 0.1);
        if(circle(coord, circle_position, 0.3 - sin(tip) * 0.1)<0.0)
            COLOR = vec3(	(1.0/225.0), 
                            (11.0/225.0), 
                            (23.0/225.0) );
    }
	fragColor = vec4( COLOR*vignette
         				,1.0);
} 