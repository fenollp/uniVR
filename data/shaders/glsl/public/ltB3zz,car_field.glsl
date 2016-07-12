// Shader downloaded from https://www.shadertoy.com/view/ltB3zz
// written by shadertoy user Branch
//
// Name: CAR-FIELD
// Description: char
struct polygon{
	vec2 A, B, C;
};
float roundBox(vec2 coord, vec2 pos, vec2 b ){
  return length(max(abs(coord-pos)-b,0.0));
}
float box(vec2 coord, vec2 pos, vec2 size){
	if((coord.x<(pos.x+size.x)) &&
	   (coord.x>(pos.x-size.x)) &&
	   (coord.y<(pos.y+size.y)) && 
	   (coord.y>(pos.y-size.y)) ) 
		return 1.0;
	return 0.0;
}
float sun(vec2 coord, vec2 pos, float size){
	if(length(coord-pos)<size)
		return 1.0;
	return 0.0;
}
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float sign(vec2 p1, vec2 p2, vec2 p3){
  return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

int PointInTriangle(vec2 pt, vec2 v1, vec2 v2, vec2 v3){
	int b1, b2, b3;

	if(sign(pt, v1, v2) < 0.0) b1=1;
	if(sign(pt, v2, v3) < 0.0) b2=1;
	if(sign(pt, v3, v1) < 0.0) b3=1;
	if((b1 == b2) && (b2 == b3))
		return 1;
	return 0;
}

int PointInTriangle(vec2 pt, polygon X){
	int b1, b2, b3;

	if(sign(pt, X.A, X.B) < 0.0) b1=1;
	if(sign(pt, X.B, X.C) < 0.0) b2=1;
	if(sign(pt, X.C, X.A) < 0.0) b3=1;
	if((b1 == b2) && (b2 == b3))
		return 1;
	return 0;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float suu=1.01*10.0;
	vec4 tulos;
	vec4 lopullinentulos=vec4(1.0);
	vec2 uv = fragCoord.xy / iResolution.xy;
	float aspectCorrection = (iResolution.x/iResolution.y);
	vec2 coordinate_entered = 2.0 * uv - 1.0;
	for(float rgbare=0.0; rgbare<2.0; rgbare++){
	vec2 coord = vec2(aspectCorrection,1.0) *coordinate_entered;
	coord.x*=1.0+rgbare*0.009;
	coord*=1.0+0.1*sin(1.01*0.1);
	tulos=vec4(vec3(140.0/255.0, 110.0/255.0, 135.0/255.0),1.0);
        
        
    if(roundBox(coord, vec2(0.9,0.6), vec2(.2))<0.2)
        tulos.rgb = vec3(1.,.6,.0);
    if(roundBox(coord, vec2(-0.9,0.6), vec2(.2))<0.2)
        tulos.rgb = vec3(1.,.6,.0);
        
    if(roundBox(coord, vec2(0.), vec2(.7))<0.2)
        tulos.rgb = vec3(1.,.6,.0)*floor(mod(coord.x+coord.y,1.)+.4);
    if(roundBox(coord, vec2(0.), vec2(.6))<0.2)
        tulos.rgb = vec3(1.,.6,.0);
        
        
        
    if(roundBox(coord, vec2(0.4,-0.4), vec2(.2))<0.2)
        tulos.rgb = vec3(1.,.8,.6);
    if(roundBox(coord, vec2(0.5,0.3), vec2(.1))<0.2)
        tulos.rgb = vec3(1.);
    if(roundBox(coord, vec2(-0.5,0.1), vec2(.2))<0.2)
        tulos.rgb = vec3(1.);
    if(roundBox(coord, vec2(-0.5,0.1), vec2(.012))<0.12)
        tulos.rgb = vec3(0.);
    if(roundBox(coord, vec2(0.5,0.3), vec2(.012))<0.12)
        tulos.rgb = vec3(0.);
    if(roundBox(coord, vec2(1.,-0.6), vec2(0.3,.012))<0.02)
        tulos.rgb = vec3(0.);
    if(roundBox(coord, vec2(1.,-0.4), vec2(0.3,.012))<0.02)
        tulos.rgb = vec3(0.);
    if(roundBox(coord, vec2(-.2,-0.4), vec2(0.3,.012))<0.02)
        tulos.rgb = vec3(0.);
    if(roundBox(coord, vec2(-.2,-0.6), vec2(0.3,.012))<0.02)
        tulos.rgb = vec3(0.);
    if(roundBox(coord, vec2(.4,-0.6), vec2(0.1,.012))<0.02)
        tulos.rgb = vec3(0.);
	tulos.xyz=tulos.xyz-vec3(min(max(-0.44+length(coord)*0.41,0.0),1.0))+vec3(0.06*rand(vec2(coord.x+coord.y,1.01*coord.y*coord.x)));
	
	if(rgbare==0.0)
		lopullinentulos.r=tulos.r;
	if(rgbare==1.0)
		lopullinentulos.gb=tulos.gb;
	}
	if(mod(fragCoord.y,2.0)<1.0)   /////////////////////////
	lopullinentulos.xyz=lopullinentulos.xyz/1.3;
	fragColor = lopullinentulos;
}