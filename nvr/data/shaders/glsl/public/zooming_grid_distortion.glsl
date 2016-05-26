// Shader downloaded from https://www.shadertoy.com/view/ldcSWr
// written by shadertoy user Glyph
//
// Name: Zooming Grid Distortion
// Description: Simple but fun to watch.
#define TIMESCALE .2
//Change this value to speed up (greater value) or slow down (lesser value) the visuals

float ar = iResolution.y/iResolution.x; // Bad practice?

float circle(vec2 uv, float r){
    return(step(length(uv),r));
}

vec2 push2D(vec2 uv, vec2 o, float r, float hv, float lv){
    vec2 ivec = o-uv;//Get vector from current coord to distortion origin
    
    //Return vector pushing away from origin scaled by the distance from the origin
    return(normalize(ivec)*clamp(smoothstep(1.0*r,0.0,length(ivec))*hv,lv,hv));
}

mat2 rotate2D(float a){
    //Standard rotation matrix
    return(mat2(-sin(a),cos(a),cos(a),sin(a)));
}

float rect(vec2 uv, float w, float h){
    return(step(abs(uv.x),w) * step(abs(uv.y),h));
}

float grid(vec2 uv, float density){
    vec2 fuv = uv + vec2(.25); // Offset grid to center at cross not cell
    
    // Return function exapanded for readability. Is treated as one line
    return(clamp(
        rect(fract(fuv*density) - vec2(.5),.005*density,1.0) // Vertical lines
        +
        rect(fract(fuv*density) - vec2(.5),1.0,.005*density) //Horiontal lines
        -
        circle(uv,.01) // Origin marker
        ,0.0,1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //Create square mapping with origin at image center
	vec2 uv = (fragCoord.xy / iResolution.xy - .5) * 2.0; uv = uv*vec2(1.0,ar);
    vec2 ouv = uv;
    float time = iGlobalTime * TIMESCALE;

    uv = (uv*1.5)*(1.0/(time*.2+1.0)); //Zoom in overtime
    
    float frq = texture2D(iChannel0,vec2(length(uv),.75)).x*.05*(1.0/(time*.1+1.0)) + 1.0;
    float mid = texture2D(iChannel0,vec2(length(ouv),.25)).x;
    
    
    vec3 col = vec3(0.05,mid*.3*length(ouv),mid*.45);
    //Feed the grid function a uv coord distorted by push2D
    col += grid((uv + push2D(uv, vec2(0.0), .8, .1*time*frq, 0.0)) * rotate2D(time), 10.0) * vec3(1.0,.2,.2); 
    
	fragColor = vec4(col,1.0);
}