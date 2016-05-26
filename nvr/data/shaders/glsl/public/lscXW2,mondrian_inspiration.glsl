// Shader downloaded from https://www.shadertoy.com/view/lscXW2
// written by shadertoy user blbenoit
//
// Name: Mondrian inspiration
// Description: Mondrian inspiration for learning shapes with Book of shaders by patriciogonzalezvivo
#define red    vec3(1.0, 0.0, 0.0);
#define yellow vec3(1.0, 1.0, 0.0);
#define blue   vec3(0.0, 0.0, 1.0);
#define white  vec3(1.0, 1.0, 1.0);

// Draw a rectangle
vec3 rect(in vec2 _lb, in vec2 _rt, in vec2 _uv) {
    //            (left , bottom) *  (right , top)
    vec2 borders = step(_lb, _uv) * step(_uv, _rt);
    return vec3(borders.x*borders.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = vec3(0.0);

    // Left column
    color  = rect(vec2(0.02, 0.9) , vec2(0.4, 0.98) , uv) * red;
    color += rect(vec2(0.02, 0.4) , vec2(0.4, 0.88) , uv) * red;
    color += rect(vec2(0.02, 0.02), vec2(0.4, 0.38) , uv) * white;
    // Big white rectangle
    color += rect(vec2(0.42, 0.6) , vec2(0.98, 0.98), uv) * white;
    // Middle column
    color += rect(vec2(0.42, 0.3) , vec2(0.7, 0.58) , uv) * yellow;
    color += rect(vec2(0.42, 0.02), vec2(0.7, 0.28) , uv) * white;
    // Right column
    color += rect(vec2(0.72, 0.2) , vec2(0.98, 0.58), uv) * white;
    color += rect(vec2(0.72, 0.02), vec2(0.98, 0.18), uv) * blue;
    
	fragColor = vec4( color,1.0);
}  