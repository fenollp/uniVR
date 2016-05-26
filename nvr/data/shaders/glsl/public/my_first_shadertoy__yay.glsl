// Shader downloaded from https://www.shadertoy.com/view/XsyGzR
// written by shadertoy user sakri
//
// Name: My first shadertoy, yay
// Description: Just trying to get the hang of this, I created some &quot;seed&quot; animation, then fidgeted with the values for a few hours until I got something nifty enough together.   At some moments this looks interesting, at others crap. Such is life.
mat2 scale(vec2 _scale){
    return mat2(_scale.x,0.0,
                0.0,_scale.y);//copy paste from thebookofshaders
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));//copy paste from thebookofshaders
}

vec3 getFragColorForTime(float time, float d, vec2 uv){
    float moveDiv = 250.0;
    float moveTime = time + 55787.0;
    float moveValue = mod(moveTime , moveDiv) / moveDiv;
    float rotation = sin(moveValue * 5.0 );
    float scaleNum = moveValue / (moveValue * d);
    float scaleOffset = cos(moveValue) * 10.0;
    uv *= rotate2d( rotation );//apply rotation matrix
    uv -= vec2(scaleOffset);//apply scale matrix
    uv *= scale( vec2(scaleNum) );
    uv += vec2(scaleOffset);
    
    vec2 xy = vec2( cos(uv.x), sin(uv.y) );
    float div = 100.0;
    float colorValue = mod(moveTime * xy.x * xy.y , div) / div;
	return vec3(smoothstep(0.5, 0.7, colorValue));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    float d = max(iResolution.x, iResolution.y);
	vec2 uv = mod(fragCoord.xy , d);
    vec3 color = getFragColorForTime(iGlobalTime, d, uv);//"oldest value", then "smoooth"
    for(float i=0.01; i<0.3; i+=0.01){
    	color = mix(getFragColorForTime(iGlobalTime + i, d, uv), color, 0.82);
    }
    fragColor = vec4(smoothstep(0.5, 0.7, color), 1.0);
}