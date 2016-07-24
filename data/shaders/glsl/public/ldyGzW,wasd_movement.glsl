// Shader downloaded from https://www.shadertoy.com/view/ldyGzW
// written by shadertoy user TekF
//
// Name: WASD movement
// Description: Basic FPS style WASD controls. I figure I'm going to want this for a lot of my shaders, and I thought other folks would too. Apologies for the ugly scene, that wasn't really the focus. :)
//    Press F to fly, Space to jump (when not flying).
// Ben Quantock 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec4 pattern( in vec3 p )
{
    vec4 o;
    o.a = 1.0;
    o.rgb = texture2D( iChannel2, (p.xz + p.xy)/11.0 ).rgb;
    o *= texture2D( iChannel1, (p.xz + p.xy)/7.0 ).r;
	return o;
}

float scene( in vec3 p )
{
    // simple scene
    
    float f = p.y - (-2.0);
    
    f = min( f, length(fract(p.xz/20.0+.4)-.5)*20.0-.8 );
    f = min( f, length(fract(p.xz/31.0)-.5)*30.0-1.8 );
    f = max( f, p.y - 2.0 );
    
    f -= .2*pattern(p).a;
    
    return f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // read camera position & orientation
    
    vec4 camPos = texture2D( iChannel0, vec2(.5,.5)/iResolution.xy, -100.0 );
    vec4 camRot = texture2D( iChannel0, vec2(1.5,.5)/iResolution.xy, -100.0 )*6.28318530718;

    // cast a ray from the camera
    
    vec3 ray = normalize( vec3( (fragCoord.xy-iResolution.xy*.5)/iResolution.x, 1.0 ) );
    
    ray.zy = ray.zy*cos(camRot.x) + sin(camRot.x)*vec2(1,-1)*ray.yz;
    ray.xz = ray.xz*cos(camRot.y) + sin(camRot.y)*vec2(1,-1)*ray.zx;

    vec3 p = camPos.xyz;
    
    float h = 1.0;
    for ( int i=0; i < 100; i++ )
    {
        if ( h < .001 )
            break;
        h = scene(p);
        p += ray*h;
    }
    
    
    // sample scene colour

    vec3 col;
	if ( h < .001 )
    {
        col = pattern(p).rgb;
        
        // vague lighting trick
        float light = max( .0, scene(p + normalize(vec3(3,2,1))*.1) )/.1;
        light = min( light, max (.0, scene(p + normalize(vec3(3,2,1))*2.) )/2. ); // vague shadows
		col *= light*.9+.1;
    }
    else
    {
       	col =( ray.y < .0 ) ?  vec3(.1) : vec3(.3,.5,.9);
        
        p += ray*(p.y+2.0)/max(-ray.y,.01);
    }
    
    col = mix( vec3(.3,.5,.9), col, exp2(-length(p-camPos.xyz)/1000.0) );

    fragColor = vec4(pow(col,vec3(1.0/2.2)),1.0);
}