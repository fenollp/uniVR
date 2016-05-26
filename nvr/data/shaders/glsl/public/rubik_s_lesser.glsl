// Shader downloaded from https://www.shadertoy.com/view/XdV3W3
// written by shadertoy user eiffie
//
// Name: Rubik's Lesser
// Description: Like the cube but easier so to make it a challenge you are limited to 3 types of rotations - the top, middle and bottom. Use the mouse - you'll figure it out.
vec2 bx_cos(vec2 a){return clamp(abs(mod(a,8.0)-4.0)-2.0,-1.0,1.0);}
vec2 bx_cossin(float a){return bx_cos(vec2(a,a-2.0));}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = texture2D(iChannel0,fragCoord/iResolution.xy);
    if(fragColor.a<0.5){
        float h=1.0;
        for(float i=0.0;i<8.0;i+=1.0){
			vec2 v=bx_cossin(i); 
			vec4 c=texture2D(iChannel0,(fragCoord+v)/iResolution.xy); 
            if(c.a>0.5){
                float a=1.0/dot(v,v);h+=a;
                fragColor.rgb+=c.rgb*a;
            }
		}
		fragColor/=h;
    }
}