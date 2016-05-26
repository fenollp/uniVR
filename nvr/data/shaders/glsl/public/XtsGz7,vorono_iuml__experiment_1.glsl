// Shader downloaded from https://www.shadertoy.com/view/XtsGz7
// written by shadertoy user aiekick
//
// Name: Vorono&iuml; Experiment 1
// Description: Voronoi Experiment 1
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
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
		vec2 o=0.5+0.5*sin(iGlobalTime+6.2831*getHash2BasedProc(n+g));//animated
        vec2 r=g+o-f;
        float d=dot(r,r);
        if( d<md ) {md=d;mr=r;} }
    return vec3(md,mr);}
// sphere mapping of v2 voronoi
vec3 voronoiSphereMapping(vec3 n){
	vec2 uv=vec2(atan(n.x,n.z),acos(n.y));
   	return getVoronoi(1.5*uv);}
// blobby voronoi
float map(vec3 p){
    float disp=length(vec4(voronoiSphereMapping(normalize(p)),1.))*0.4-0.8;
	return length(p)-1.+disp;}
// normal calc based on nimitz shader https://www.shadertoy.com/view/4sSSW3
vec3 getNormal(const in vec3 p){  
    vec2 e = vec2(-1., 1.)*0.005;   
	return normalize(e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );}
// ray-marcher based on sebastien shader https://www.shadertoy.com/view/XtXGzM
float march(vec3 ro,vec3 rd){
	float maxd=10.;
    float tmpDist=1.;
    float finalDist=0.;
    for(int i=0;i<50;i++){
        if( tmpDist<0.001||finalDist>maxd) break;
	    tmpDist=map(ro+rd*finalDist);
        finalDist+=tmpDist; }
    if(finalDist>maxd) finalDist=-1.;
	return finalDist; }
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = fragCoord.xy/iResolution.xy*2.-1.;
    uv.x*=iResolution.x/iResolution.y;
    vec3 ro=vec3(0.,0.,2.),rd=normalize(vec3(uv,-1.));
   	float t=march(ro,rd);
     if(t>0.){
        vec3 pos = ro+t*rd;
        vec3 col = mix(vec3(max(0.,2.3-t)),voronoiSphereMapping(normalize(pos)),0.5);
        float bright=dot(getNormal(pos),normalize(pos))*0.8;
        fragColor= vec4(bright*col+pow(bright,8.0)*(1.-t*.01),1.); } }