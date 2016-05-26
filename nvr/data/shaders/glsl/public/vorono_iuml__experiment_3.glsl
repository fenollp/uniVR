// Shader downloaded from https://www.shadertoy.com/view/llsGRM
// written by shadertoy user aiekick
//
// Name: Vorono&iuml; Experiment 3
// Description: Voronoi Experiment 3
//    Mouse axis Y : control voronoi cells density (Current number in bottom left)
//    Mouse axis X : control rugosity density (current number in bottom right)
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#define ITERATIONS_MAX 100
#define RUGOSITY_DENSITY_MAX 50.
#define RUGOSITY_DENSITY_DEFAULT 20.
#define ROT_SPEED 0.6
#define TIME_RATIO iGlobalTime
float voroRatio = 2.;
// GLSL Number Printing - @P_Malin (CCO 1.0)=> https://www.shadertoy.com/view/4sBSWW
float DigitBin(const in int x){
    if(x==0) return 480599.0; if(x==1) return 139810.0; if(x==2) return 476951.0; if(x==3) return 476999.0;	if(x==4) return 350020.0; 
    if(x==5) return 464711.0; if(x==6) return 464727.0; if(x==7) return 476228.0; if(x==8) return 481111.0; if(x==9) return 481095.0; 
    return 0.0;}
float PrintValue(vec2 fragCoord, const in vec2 vPixelCoords, const in vec2 vFontSize, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces){
    vec2 vStringCharCoords = (fragCoord.xy - vPixelCoords) / vFontSize;
    if ((vStringCharCoords.y < 0.0) || (vStringCharCoords.y >= 1.0)) return 0.0;
	float fLog10Value = log2(abs(fValue)) / log2(10.0);
	float fBiggestIndex = max(floor(fLog10Value), 0.0);
	float fDigitIndex = fMaxDigits - floor(vStringCharCoords.x);
	float fCharBin = 0.0;
	if(fDigitIndex > (-fDecimalPlaces - 1.01)) {
		if(fDigitIndex > fBiggestIndex) {
            if((fValue < 0.0) && (fDigitIndex < (fBiggestIndex+1.5))) fCharBin = 1792.0;} 
        else {		
			if(fDigitIndex == -1.0) {
				if(fDecimalPlaces > 0.0) fCharBin = 2.0;} 
            else {
				if(fDigitIndex < 0.0) fDigitIndex += 1.0;
				float fDigitValue = (abs(fValue / (pow(10.0, fDigitIndex))));
                float kFix = 0.0001;
                fCharBin = DigitBin(int(floor(mod(kFix+fDigitValue, 10.0))));} } }
    return floor(mod((fCharBin / pow(2.0, floor(fract(vStringCharCoords.x) * 4.0) + (floor(vStringCharCoords.y * 5.0) * 4.0))), 2.0));}
vec3 WriteValueToScreenAtPos(vec2 fragCoord, float vValue, vec2 vPixelCoord, vec3 vColour, vec2 vFontSize, float vDigits, float vDecimalPlaces, vec3 vColor){
    float num = PrintValue(fragCoord, vPixelCoord, vFontSize, vValue, vDigits, vDecimalPlaces);
    return mix( vColour, vColor, num);}
/////////////////////////////////////////////////////////////////
// VORONOI based on IQ shader https://www.shadertoy.com/view/ldl3W8
//vec2 getHash2BasedTex(vec2 p) {return texture2D( iChannel0, (p+0.5)/256.0, -100.0 ).xy;}//texture based white noise
vec2 getHash2BasedProc(vec2 p){return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);}//procedural white noise
vec3 getVoronoi(vec2 x){
    vec2 n=floor(x),f=fract(x),mr;
    float md=5.;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ ){
        vec2 g=vec2(float(i),float(j));
		vec2 o=0.5+0.5*sin(TIME_RATIO+6.2831*getHash2BasedProc(n+g));//animated
        vec2 r=g+o-f;
        float d=dot(r,r);
        if( d<md ) {md=d;mr=r;} }
    return vec3(md,mr);}
// sphere mapping of v2 voronoi
vec3 voronoiSphereMapping(vec3 n){
	vec2 uv=vec2(atan(n.x,n.z),acos(n.y));
    if ( iMouse.z > 0. ) {voroRatio=iMouse.y/iResolution.y * 10.;}
    return getVoronoi(voroRatio*uv);}
// rotate
float RotY=0.0,RotX=0.0;
vec3 rotateX(vec3 pos, float alpha) {
mat4 trans= mat4(1.0, 0.0, 0.0, 0.0, 0.0, cos(alpha), -sin(alpha), 0.0, 0.0, sin(alpha), cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0);
return vec3(trans * vec4(pos, 1.0));}
vec3 rotateY(vec3 pos, float alpha) {
mat4 trans2= mat4(cos(alpha), 0.0, sin(alpha), 0.0, 0.0, 1.0, 0.0, 0.0,-sin(alpha), 0.0, cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0);
return vec3(trans2 * vec4(pos, 1.0));}
// sphere + sphere cloud with center points and radius from voronoi
float box(vec3 pos){
    vec3 d = abs(pos) - 1.0;
  	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));}
float density=RUGOSITY_DENSITY_DEFAULT;
float map(vec3 p){
    vec3 rotPX = rotateX(p, RotX*ROT_SPEED);
    vec3 rotPXY = rotateY(rotPX, RotY*ROT_SPEED);
    if ( iMouse.z > 0. ) {density=iMouse.x/iResolution.x * RUGOSITY_DENSITY_MAX;}
	float rugosity=cos(density*rotPXY.x)*sin(density*rotPXY.y)*sin(density*rotPXY.z)*cos(256.1)*sin(0.8);
	float disp=length(vec4(voronoiSphereMapping(normalize(p)),1.))*0.4-0.8;
    return length(p)-1.+disp+rugosity;}
// ray-marcher based on sebastien shader https://www.shadertoy.com/view/XtXGzM
float march(vec3 ro,vec3 rd, int iter){
	float maxd=10.;
    float tmpDist=1.;
    float finalDist;
    for(int i=0;i<ITERATIONS_MAX;i++){
        if(i>iter)break;
        if( tmpDist<0.0001||finalDist>maxd) break;
	    tmpDist=map(ro+rd*finalDist);
        finalDist+=tmpDist; }
    if(finalDist>maxd) finalDist=-1.;
	return finalDist; }
// normal calc based on nimitz shader https://www.shadertoy.com/view/4sSSW3
vec3 getNormal(const in vec3 p){  
    vec2 e = vec2(-1., 1.)*0.005;   
	return normalize(e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec3 vColour = vec3(0.);
    vec2 uv = fragCoord.xy/iResolution.xy*2.-1.;
    uv.x*=iResolution.x/iResolution.y;
    RotY = iGlobalTime * ROT_SPEED;
    RotX = iGlobalTime * ROT_SPEED;    
    vec3 ro=vec3(0.,0.,1.9),rd=normalize(vec3(uv,-0.8));
   	float t=march(ro,rd,ITERATIONS_MAX);
    if(t>0.){
       	vec3 pos = ro+t*rd;
        vec3 nor = getNormal(pos);
        vec3 norp = normalize(pos);
        vec3 rayReflect = reflect(rd, nor);
        vec3 cube = textureCube(iChannel0, rayReflect).rgb;  
        float bright=0.8;
        vec3 voroCol = voronoiSphereMapping(norp);
        vec3 marchCol = vec3(max(0.,2.3-t));
        vec3 col = mix(marchCol,voroCol,0.5);   
        vColour = mix(vColour, bright*col+cube/bright+pow(bright,15.0)*(1.-t*.01), 0.5);}
    else {
       vColour = textureCube(iChannel0, vec3(uv,1.)).rgb;      }
    // count iteration printing bottom left => Mouse Axis Y
    vColour = WriteValueToScreenAtPos(fragCoord, iGlobalTime, vec2(2.), vColour, vec2(8.0, 15.0), 1., 2., vec3(0.9));
    // rugosity density printing bottom right => Mouse Axis X
   	vColour = WriteValueToScreenAtPos(fragCoord, density, vec2(iResolution.x-16., 2.), vColour, vec2(8.0, 15.0), 1., 0., vec3(0.9));
    fragColor.rgb = vColour; 
}