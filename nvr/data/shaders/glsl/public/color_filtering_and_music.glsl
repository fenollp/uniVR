// Shader downloaded from https://www.shadertoy.com/view/MlS3zz
// written by shadertoy user Branch
//
// Name: color filtering and music
// Description: color filtering and music
vec3 dither1(vec2 uv){
    vec3 T=texture2D(iChannel0, uv).rgb;
    float I=floor(length(T)+0.5)*.5;
    vec3 TT = vec3(floor(T.r+.5)/2.+I,floor(T.g+.5)/2.+I,floor(T.b+.5)/2.+I);
    if(length(T)>0.9)
       return TT;
    if(length(T)>0.7 && mod(uv.y*iResolution.y+uv.x*iResolution.x,4.)<1.)
        return TT;
    if(length(T)>0.5 && mod(uv.y*iResolution.y+uv.x*iResolution.x,8.)<1.)
        return TT;
    if(length(T)>0.3 && mod(uv.y*iResolution.y+uv.x*iResolution.x,16.)<1.)
        return TT;
    return vec3(0.);
}
vec3 dither2(vec2 uv){
    vec3 T=texture2D(iChannel0, uv).rgb;
    float I=floor(length(T)+0.5)*.5;
    vec3 TT = vec3(floor(T.r+.5)/2.+I,floor(T.g+.5)/2.+I,floor(T.b+.5)/2.+I);
    if(length(T)>0.9 && length(texture2D(iChannel0, uv+vec2(1./iResolution.xy)))>0.5)
       return TT;
    if(length(T)>0.8 && mod(uv.y*iResolution.y+uv.x*iResolution.x,2.)<1.)
        return TT;
    if(length(T)>0.7 && mod(uv.y*iResolution.y+uv.x*iResolution.x,5.)<1.)
        return TT;
    if(length(T)>0.6 && mod(uv.y*iResolution.y,4.)<1. && mod(uv.x*iResolution.x,4.)<1.)
        return TT;
    return vec3(0.);
}
vec3 dither3(vec2 uv){
    vec3 T=texture2D(iChannel0, uv).rgb;
    vec3 TT = vec3(1.);
    if(length(T)>0.9 && length(texture2D(iChannel0, uv+vec2(1./iResolution.xy)))>0.5)
       return TT;
    if(length(T)>0.8 && mod(uv.y*iResolution.y+uv.x*iResolution.x,2.)<1.)
        return TT;
    if(length(T)>0.7 && mod(uv.y*iResolution.y+uv.x*iResolution.x,5.)<1.)
        return TT;
    if(length(T)>0.6 && mod(uv.y*iResolution.y,4.)<1. && mod(uv.x*iResolution.x,4.)<1.)
        return TT;
    return vec3(0.);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    float BPM=90./60.;
	vec2 uv = fragCoord.xy / iResolution.xy;
    //uv.x-=.5*iResolution.y/iResolution.x
    uv.x*=iResolution.x/iResolution.y;
    if(uv.x<0. || uv.x>1.) discard;
    vec4 C = texture2D(iChannel0, uv);
    float time = mod(iGlobalTime*BPM*.25,3.);
    if(time<3.)
        C.rgb=dither3(uv);
    if(time<2.)
        C.rgb=dither2(uv);
    if(time<1.)
        C.rgb=dither1(uv);
	fragColor = C;
}