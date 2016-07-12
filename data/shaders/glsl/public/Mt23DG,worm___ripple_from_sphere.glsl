// Shader downloaded from https://www.shadertoy.com/view/Mt23DG
// written by shadertoy user ddddddddd
//
// Name: Worm / Ripple from Sphere
// Description: modified from the Simple Sphere shader.
//    just playing around. not supposed to be anything precise.
// simple sphere cheat map.
// modified. playing around.
// dean alex

// USE MOUSE


float radius = 0.25;
float focal = 0.5;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    
    //----- setup -----
    float aspect = iResolution.x / iResolution.y;
    float Px = iMouse.x / iResolution.x * aspect;
    float Py = iMouse.y / iResolution.y;
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float tx = uv.s * aspect;
    float ty = uv.t;
    
    
    // play around with the 'center' of the sphere, proportionally with our uv position
    // time is one of the sine wave inputs (to make it ripple). the rest are just playing.
    // if x effects y, as y effects x, we get more interesting shapes
    Px = (tx + cos(iGlobalTime * 3.0 - ty)*0.25) * 0.6 + Px * 0.4;
    Py = Py * ty + (sin(Px * 15.0 + iGlobalTime * 3.0) * 0.15 + 0.4) * (1.0 - ty);
    
    
    
    
    //----- get coordinates of texture -----
    float dx = tx - Px;
    float dy = ty - Py;
    float dis = sqrt( dx*dx + dy*dy );
    
    if( dis > radius ){ // piexl is outside boundary of sphere
        fragColor = texture2D( iChannel0, vec2( tx * 2.0,ty*2.0 ) ) * 0.4;
        return;
    }
    
    
    // width of radius at y
    float rad_w = sqrt( radius*radius - dy*dy );
    float warp_x = dx / rad_w;
    
    // height of radius at x
    float rad_h = sqrt( radius*radius - dx*dx );
    float warp_y = dy / rad_h;
    
    // warp the values with a cos curve to approximate the angle of the edges
    warp_x = warp_x / (cos( dx * 3.14159265358979586 ));
    warp_y = warp_y / (cos( dy * 3.14159265358979586 ));
    
    
    
    //----- shading -----
    float dismf = dis / radius;
    dismf = 1.0 - dismf;
    
    
    vec4 tex = texture2D( iChannel0, vec2( warp_x * focal + Px, warp_y * focal + Py ) );
    tex.rgb *= (dismf * 0.9) + 0.1;
    
    // specular
    dismf = dismf * dismf * dismf * dismf;
    tex.rgb += dismf;
        
    fragColor = tex;
}
