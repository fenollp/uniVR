// Shader downloaded from https://www.shadertoy.com/view/MdtXzs
// written by shadertoy user ddddddddd
//
// Name: Simple Sphere help
// Description: Just a reference for anyone that wants it.
//    Commented and labelled.
/*

"Simple Sphere"
by Dean Alex 2016, dean[at]neuroid co uk

A ball with a reflection and some lighting.
Not supposed to be anything fancy. Just a starting point for people to use to make other things.


To anyone who hates math, the only formulas needed are both from highschool -

- Pythagorus... a2 + b2 = c2 ...applied in three dimensions to define the surface of a sphere.
- Trigonometry... tan( theta ) = opposite / adjacent ...used to unwrap the angle into a uv.

*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    
    // shape and size of sphere,  this could be in a seperate function with position and radius as inputs, if you wanted multiple spheres
    float radius = 0.75;
    vec2 R = iResolution.xy;
    vec2 uv = (2. * fragCoord.xy -R ) / R.y / radius;
    
	
    // discard fragments outside the radius
    float mag = dot(uv,uv);
    if( mag > 1.0 ){ // 'discard' might go here in a normal fragment shader
    	fragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
        return;
    }
    
    
    // surface normal,   x2+y2+z2 = 1 ... therefore easy to get z
    vec3 norm = vec3( uv, sqrt( 1.0 - mag ));
    
    
    // uv texture of sphere,   tan(theta) = o/a ... basic trig to calculate the angle then wrap it to range 0-1)
    float s = atan( norm.z, norm.x ) / 6.283185307179586;
    float t = asin( norm.y ) / 3.14159265358979;
    fragColor = texture2D( iChannel0, vec2( s + iGlobalTime * 0.4, t + iGlobalTime * 0.03 ));
    
    
    
    // directional light
    vec3 lightDir = normalize( vec3( -1.6, -0.3, 1.0 )); // direction vector
    float mflight = max(dot( norm, lightDir), 0.0);
    fragColor.rgb *= mflight;
    

    // point light
    vec3 light1pos = vec3( 0.6, 0.5, 0.6 ); // position
    vec3 light1col = vec3( 1.0, 2.0, 3.0 ); // color. over blown

    float dis = 1.0 - length( norm - light1pos ) / 2.0;
    fragColor.rgb += light1col * pow( dis, 8.0); // specularity is given by index in power function - change this function to whetever you like. million ways of doing lighting.
}
