// Shader downloaded from https://www.shadertoy.com/view/ltfGDj
// written by shadertoy user TekF
//
// Name: White Gold Blue Black
// Description: Demonstrating the optical illusion captured by accident in that notorious photograph:
//    http://www.bbc.co.uk/news/uk-scotland-highlands-islands-31656935
//    (The lack of) context is everything.
// Ben Quantock 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://creativecommons.org/licenses/by-nc-sa/3.0/

// Obviously in reality there's a lot of other effects at work,
// but for this I've just used exposure and white balance.


float DressDF( vec3 p )
{
    //return max( abs(p.y)-1.0, length(p.xz)-.5 ); // vaguely dress shaped
    
    return length( max(vec3(.0),abs(p)-vec3(0,.5,0)) )-.5 + sin(p.y*8.0)*.3/8.0 + sin(p.x*17.0+sin(p.y*8.0))*.2/17.0;
}


float RoomDF( vec3 p )
{
    p = abs(p-vec3(-1,1,-1)); // centre of the room
    const vec3 dim = vec3(3,2.2,3);
    
    vec3 i = dim-p; // interior
    vec3 o = -(i+.1); // exterior

    // front windows
    i.z += .2;

    float f = max(max(o.x,o.y),o.z);
    
    f = max( f, min(min(i.x,i.y),i.z) );
    
    return f;
}

float ObjectsDF( vec3 p )
{
    return length( abs(p-vec3(0,-.5,.3))-vec3(1,0,0) )-.3;
}

float DF( vec3 p )
{
    return min( min( DressDF(p), RoomDF(p)), ObjectsDF(p) );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 iHalfRes = iResolution.xy/2.0;

//    float whiteBalance = mix( .30, .70, sin(iGlobalTime)*.5+.5 );
//    float exposure = exp2( sin(iGlobalTime/3.0)*2.0 );
    
    vec2 div = vec2(iHalfRes.x*(1.0+.5*sin(iGlobalTime*.5)),.0);
    if ( iMouse.z > .0 )
        div = iMouse.xy-vec2(.0,iHalfRes.y);

    float whiteBalance, exposure;
    if ( fragCoord.x < div.x )
    {
        // settings for a blue dress:
        whiteBalance = .2;
        exposure = 3.0;
    }
    else
    {
        // settings for a white dress:
        whiteBalance = .75;
        exposure = .5;
    }
    
    // make a shape to place the material on
    // so we can test lighting, volumetric mapping, etc
    vec3 ray = normalize(vec3(fragCoord.xy-iHalfRes,iHalfRes.y*3.0));
    
    vec2 r = vec2(0);
    r = mix( vec2(-.1,1), vec2(.5,-.5), smoothstep( -.8, .8, sin( iGlobalTime / vec2(2.3,3.1) ) ) );
    //if ( iMouse.z > .0 ) r += vec2(-2,3)*(iMouse.yx/iHalfRes.yx-1.0);
    
    vec2 c = cos(r);
    vec2 s = sin(r);
    
    ray.yz = ray.yz*c.x + vec2(-1,1)*ray.zy*s.x;
    ray.xz = ray.xz*c.y + vec2(1,-1)*ray.zx*s.y;

    vec3 p = vec3(-c.x*s.y,s.x,-c.x*c.y)*4.0;
    
    float h;
    for ( int i=0; i < 100; i++ )
    {
        h = DF(p);
        p += ray*h;
        if ( h < .0001 )
            break;
    }
    
    
   	vec3 col = 8.0*pow( textureCube( iChannel1, ray ).rgb, vec3(2.2) );

    vec3 albedo = col;
    if ( h < .1 )
    {
        if ( DressDF(p) < .01 )
        {
            // lilac and brown, similar to the actual colours in the dress *image*
            albedo = mix( vec3(.2,.4,1), vec3(.07,.07,.03), step(fract(p.y*1.7),.3) );

            // then compute what the albedo would have to be to look this way in the final image, given the current lighting/camera settings
            albedo /= exposure;
            albedo /= mix( vec3(2,1,0), vec3(0,1,2), whiteBalance-.05 );
        }
        else if ( ObjectsDF(p) < .01 )
        {
            vec3 blue = vec3(.2,.4,1)/(3.0*vec3(1.7,1,.3));
            vec3 white = vec3(.2,.4,1)/(.5*vec3(.6,1,1.4));
            albedo = (p.x > .0) ? blue : white;
        }
        else
        {
            if ( p.y <= -1.199 )
            {
                // floor
            	albedo = pow( texture2D( iChannel0, p.xz/2.0 ).rgb, vec3(2.2) );
			}
            else
            {
                albedo = vec3(1.3,1,.8);
            }
        }
        
        vec2 d = vec2(-1,1)*.0001;
        vec3 n = normalize(	DF(p+d.xxx)*d.xxx +
                           	DF(p+d.xyy)*d.xyy +
                           	DF(p+d.yxy)*d.yxy +
                           	DF(p+d.yyx)*d.yyx );
        
        vec3 light = vec3(.3);
        light += max(.0,dot(n,normalize(vec3(1,3,-1))))*1.0;
        light += max(.0,dot(n,normalize(vec3(1,2,3))))*2.0;
        
        col = albedo*light;
    }


    // fade out the camera effects periodically
    float fade = smoothstep( .7, .85, sin(iGlobalTime) );
//    if ( iMouse.z > .0 ) fade = iMouse.y/iResolution.y;
    
    exposure = mix( exposure, 1.0, fade );
    whiteBalance = mix( whiteBalance, .5, fade );
    
    
    // colour correction, similar to a camera
    // exposure
    col *= exposure;
    
    // white balance
    col *= mix( vec3(2,1,0), vec3(0,1,2), whiteBalance-.05 );
    
    /*if ( fragCoord.y < div.y )
    {
        // show actual colour
        col = albedo;
    }*/

    fragColor = vec4( pow(col,vec3(1.0/2.2)), 1 );
}