// Shader downloaded from https://www.shadertoy.com/view/ltjGDG
// written by shadertoy user ddddddddd
//
// Name: Simple Sphere Texture Map
// Description: For reference. Please mess around with the code and do whatever you want with it.
// simple sphere cheat map.
// dean alex



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
    
    
    
    //----- get coordinates of texture -----
    float dx = tx - Px;
    float dy = ty - Py;
    float dis = sqrt( dx*dx + dy*dy );
    
    if( dis > radius ){ // piexl is outside boundary of sphere. stop here
        fragColor = vec4(0.0,0.0,0.0,1.0);
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
    dismf = dismf * dismf * dismf * dismf * dismf * dismf;
    tex.rgb += dismf;
        
    fragColor = tex;
}
