// Shader downloaded from https://www.shadertoy.com/view/XtfSz2
// written by shadertoy user patriciogv
//
// Name: Random Defrag
// Description: From http://patriciogonzalezvivo.com/2015/thebookofshaders/10/
// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

float random (in float x) { return fract(sin(x)*1e4); }
float random (in vec2 _st) { return fract(sin(dot(_st.xy, vec2(12.9898,78.233)))* 43758.5453123);}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 st = fragCoord.xy / iResolution.xy;
    st.x *= iResolution.x/iResolution.y;

    // Grid
    vec2 grid = vec2(50.0,30.);
    st *= grid;

    vec2 ipos = floor(st);  // integer
    
    vec2 vel = floor(vec2(iGlobalTime*10.)); // time
    vel *= vec2(-1.,0.); // direction

    vel *= (step(1., mod(ipos.y,2.0))-0.5)*2.; // Oposite directions
    vel *= random(ipos.y); // random speed
    
    // 100%
    float totalCells = grid.x*grid.y;
    float t = mod(iGlobalTime*max(grid.x,grid.y)+floor(1.0+iGlobalTime*iMouse.y),totalCells);
    vec2 head = vec2(mod(t,grid.x), floor(t/grid.x));

    vec2 offset = vec2(0.1,0.);

    vec3 color = vec3(1.0);
    color *= step(grid.y-head.y,ipos.y);                                // Y
    color += (1.0-step(head.x,ipos.x))*step(grid.y-head.y,ipos.y+1.);   // X
    color = clamp(color,vec3(0.),vec3(1.));

    // Assign a random value base on the integer coord
    color.r *= random(floor(st+vel+offset));
    color.g *= random(floor(st+vel));
    color.b *= random(floor(st+vel-offset));

    color = smoothstep(0.,.5+iMouse.x/iResolution.x*.5,color*color); // smooth
    color = step(0.5+iMouse.x/iResolution.x*0.5,color); // threshold

    //  Margin
    color *= step(.1,fract(st.x+vel.x))*step(.1,fract(st.y+vel.y));
	fragColor = vec4(color,1.0);
}