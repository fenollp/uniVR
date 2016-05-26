// Shader downloaded from https://www.shadertoy.com/view/MstGz4
// written by shadertoy user MrASL
//
// Name: Just Sun &amp; Water
// Description: .......
vec3 drawHolo(vec2 pos,vec2 uv, float range,float power,float aspect){
 	uv.x*=aspect; 
    float dis = distance(uv.xy,pos.xy);
    vec3 result = vec3(0.0,0.0,0.0);
    if(dis<range)
        result = mix(vec3(0.36,0.174,0.119),vec3(0.0,0.0,0.0),pow(dis/range,power));
    return result;
}

vec3 drawSun(vec2 pos,vec2 uv, float range,float sunrange,float power,float aspect){
    uv.x*=aspect;
    float dis = distance(uv.xy,pos.xy);
    vec3 result = vec3(0.0,0.0,0.0);
    if(dis<range)
        result = vec3(1.0,0.974,0.647);
    else if(dis>=range && dis<range+sunrange)
        result = mix(vec3(1.0,0.974,0.007),vec3(0.0,0.0,0.0),pow((dis-range)/sunrange,power));
    return result;
}

vec3 drawWave(float speed, float range, float height,float offset, float power, vec2 uv, float dis){
 	vec3 finb = mix(vec3(0.796,0.796,0.745),vec3(0.513,0.513,0.486),dis);
    float siny = offset + height*pow(sin(uv.x * range + iGlobalTime * speed)+1.0,power);
    if(uv.y>siny)
        finb = vec3(1.0,1.0,1.0);
    return finb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.x/iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
    float dis = distance(uv.xy,vec2(0.5,0.5));
    vec4 fin = mix(vec4(0.91,0.91,0.87,1),vec4(0.65,0.65,0.517,1),dis);
    fin.rgb += drawHolo(vec2(0.5,0.7),uv,0.7,0.7,aspect);
    fin.rgb *= drawWave(1.4,70.0,0.017,0.5,1.3,uv,dis);
    fin.rgb *= drawWave(1.8,60.0,0.015,0.487,1.3,uv,dis);
    fin.rgb *= drawWave(2.2,50.0,0.013,0.462,1.3,uv,dis);
    fin.rgb *= drawWave(2.5,35.0,0.011,0.45,1.3,uv,dis);
    //vec3 sunc = drawSun(vec2(0.5,0.7),uv,0.03,0.03,0.3,aspect);
    //fin.rgb = fin.rgb * (1.0 - sunc.a) + sunc.rgb*sunc.a;
    fin.rgb += drawSun(vec2(0.5,0.7),uv,0.03,0.03,0.02,aspect);
    fragColor = fin;
	//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}