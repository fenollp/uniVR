// Shader downloaded from https://www.shadertoy.com/view/llS3zz
// written by shadertoy user Branch
//
// Name: STYLE?5
// Description: STYLE?5
float roundBox(vec2 coord, vec2 pos, vec2 b ){
  return 1.-floor(length(max(abs(coord-pos)-b,0.0)));
}
mat2 rotate(float Angle)
{
    mat2 rotation = mat2(
        vec2( cos(Angle),  sin(Angle)),
        vec2(-sin(Angle),  cos(Angle))
    );
	return rotation;
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
float PIT(vec2 pt, vec2 v1, vec2 v2, vec2 v3){
	int b1, b2, b3;

	if(sign(pt, v1, v2) < 0.0) b1=1;
	if(sign(pt, v2, v3) < 0.0) b2=1;
	if(sign(pt, v3, v1) < 0.0) b3=1;
	if((b1 == b2) && (b2 == b3))
		return 1.;
	return 0.;
}
float arrow(vec2 coord, vec2 pos){
	return box(coord, pos, vec2(.4,.1))+box(coord, pos+vec2(.3,-.3), vec2(.1,.4));
}
float guy(vec2 coord, vec2 pos){
	vec2 leftrotate=coord*rotate(0.7+sin(iGlobalTime*20.)*0.05);
	vec2 rightrotate=coord*rotate(-0.7+cos(iGlobalTime*20.)*0.05);
	float upndown=max(cos(iGlobalTime*7.+3.14)*0.1,0.);
	float random=sin(iGlobalTime*9.0)*0.01; //not really
	return 	box(coord, vec2(.2,-.34+upndown)+pos, vec2(.1,.2))+
			box(coord, vec2(-.2,-.34+upndown)+pos, vec2(.1,.2))+
			box(coord, vec2(0.,.2+upndown)+pos, vec2(.4,.3))+
			box(leftrotate*vec2(1.), vec2(.55,.3+upndown*.5)+pos, vec2(.1,.2))+
			box(rightrotate*vec2(1.), vec2(-.55,.3+upndown*.5)+pos, vec2(.1,.2))+
			box(coord, vec2(0.,.75+upndown)+pos, vec2(.3,.2))-
			box(coord, vec2(0.,.75+upndown)+pos, vec2(.2+random,.1+random))+
			box(coord, vec2(.1,.78+upndown)+pos, vec2(.05+random,.05+random))+
			box(coord, vec2(-.1,.78+upndown)+pos, vec2(.05-random,.05-random))+
			box(coord, vec2(0.,.79+upndown*2.), vec2(.1,.12))+
			box(coord, vec2(0.,.56+upndown*2.), vec2(.1,.045));	
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	float t=mod(iGlobalTime,5.5);
	vec4 tulos;
	vec4 lopullinentulos=vec4(1.0);
	vec2 uv = fragCoord.xy / iResolution.xy;
	float aspectCorrection = (iResolution.x/iResolution.y);
	vec2 coordinate_entered = 2.0 * uv - 1.0;
	vec2 c = vec2(aspectCorrection,1.0) *coordinate_entered;
	vec2 coord = c;
	coord*=sin(iGlobalTime*2.435)*.2+1.2;
	tulos=vec4(1.0);
	tulos-=guy(coord,vec2(0.,-.5))*4.;
	if(mod(fragCoord.y,2.0)<1.0)   /////////////////////////
	tulos=tulos/1.3;
	float vignette = min(max(1.4 / (1.25 + 0.28*dot(c, c)),0.),1.);
	fragColor =tulos*vignette-0.01+rand(c*t)*0.02;
}