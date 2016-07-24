// Shader downloaded from https://www.shadertoy.com/view/XlS3zt
// written by shadertoy user Branch
//
// Name: EGA Style
// Description: EGA Style
//    I was trying to get oldschool system style with sprite outlines to this video by using fairly crude edge detection tech.
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv=vec2(floor(uv.x*320.)/320.,floor(uv.y*240.)/240.);
    vec4 sample = texture2D(iChannel0, uv);
    vec4 sample2 = texture2D(iChannel0, uv+vec2(1./ 320.0,0.0));
    vec4 sample3 = texture2D(iChannel0, uv+vec2(0.0,1./ 240.0));
    vec4 sample4 = texture2D(iChannel0, uv+vec2(-1./ 320.0,0.0));
    vec4 sample5 = texture2D(iChannel0, uv+vec2(0.0,-1./ 240.0));
    
    float I=floor(length(sample.rgb)+0.5)*.5+1.2;
    vec3 C=vec3(
        		floor(sample.r*3.)/3.*I,
        		floor(sample.g*3.)/3.*I,
        		floor(sample.b*3.)/3.*I
    			);
    float border = floor(distance(sample2,sample)+distance(sample3,sample)+distance(sample4,sample)+distance(sample5,sample)+0.73);
    uv.x*=0.6+sin(uv.y/7.+iGlobalTime)/3.;
    uv.y*=0.3+sin(uv.x+iGlobalTime)/5.;
    vec3 effect = vec3(0.0);
    effect.r=sin(sin(uv.x*2.+iGlobalTime)+uv.y*10.+2.*iGlobalTime+sin(iGlobalTime)*2.)*.5+.5;
    effect.g=sin(sin(uv.x*5.+iGlobalTime)+uv.y*70.+iGlobalTime+sin(iGlobalTime/8.)*2.)*.5+.5;
    effect.b=sin(sin(uv.x*8.+iGlobalTime)+uv.y*100.+iGlobalTime+sin(iGlobalTime/3.)*2.)*.5+.5;
    float Ieffect=floor(length(effect.rgb)+0.5)*.5+1.2;
    vec3 Ceffect=vec3(
        		floor(effect.r*3.)/3.*I,
        		floor(effect.g*3.)/3.*I,
        		floor(effect.b*3.)/3.*I
    			);
    vec3 finalColor=vec3(0.);
    
    //laazyy
    if(C.g > 0.5 && C.r<0.5 && C.b<0.5) //laazyy
        finalColor = Ceffect*(1.-vec3(border)); //laazyy
    else { //laazyy
        finalColor = C*(1.-vec3(border)); //laazyy
    } //laazyy
    
	fragColor = vec4(finalColor, 1.0);
}