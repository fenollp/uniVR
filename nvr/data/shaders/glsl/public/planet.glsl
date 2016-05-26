// Shader downloaded from https://www.shadertoy.com/view/4sf3Rn
// written by shadertoy user iq
//
// Name: Planet
// Description: A planet rotating
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 doit( in vec2 pix )
{
    vec2 p = -1.0 + 2.0*pix;
    p.x *= iResolution.x/iResolution.y;

    vec3 ro = vec3( 0.0, 0.0, 2.5 );
    vec3 rd = normalize( vec3( p, -2.0 ) );

    vec3 col = vec3(0.1);

    // intersect sphere
    float b = dot(ro,rd);
    float c = dot(ro,ro) - 1.0;
    float h = b*b - c;
    if( h>0.0 )
    {
        float t = -b - sqrt(h);
        vec3 pos = ro + t*rd;
        vec3 nor = pos;

        // texture mapping
        vec2 uv;
        uv.x = atan(nor.x,nor.z)/6.2831 - 0.03*iGlobalTime - iMouse.x/iResolution.x;
        uv.y = acos(nor.y)/3.1416;
		uv.y *= 0.5;
        col = texture2D( iChannel0, uv ).xyz;

		float o = smoothstep( 0.3,0.4,col.x);
		col = mix( vec3(0.2,0.3,0.4), col, o );
	
        // lighting
        col *= 0.1 + 0.9*max(nor.x*2.0+nor.z,0.0);
    }
	else
	{
		c = dot(ro,ro) - 10.0;
		h = b*b - c;
        float t = -b - sqrt(h);
        vec3 pos = ro + t*rd;
        vec3 nor = pos;

        vec2 uv;
        uv.x = 16.0*atan(nor.x,nor.z)/6.2831 - 0.05*iGlobalTime - iMouse.x/iResolution.x;
        uv.y = 2.0*acos(nor.y)/3.1416;
        col = texture2D( iChannel0, uv, 1.0 ).xyz;
		col = col*col; col = col*col; col = col*col;
        col *= 0.7;
        vec3 sta = texture2D( iChannel0, 0.5*uv, 5.0 ).xyz;
		sta = sta*sta;
		col += sta*0.1;

	}
	
    col = 0.5*(col+sqrt(col));
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // render this with four sampels per pixel
    vec3 col0 = doit( (fragCoord.xy+vec2(0.0,0.0) )/iResolution.xy );
    vec3 col1 = doit( (fragCoord.xy+vec2(0.5,0.0) )/iResolution.xy );
    vec3 col2 = doit( (fragCoord.xy+vec2(0.0,0.5) )/iResolution.xy );
    vec3 col3 = doit( (fragCoord.xy+vec2(0.5,0.5) )/iResolution.xy );
    vec3 col = 0.25*(col0 + col1 + col2 + col3);

    fragColor = vec4(col,1.0);
}