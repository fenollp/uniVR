// Shader downloaded from https://www.shadertoy.com/view/Mdt3Ds
// written by shadertoy user 834144373
//
// Name: PhotoShop (cc0)
// Description: PhotoShop：
//    move your mouse,and move to it on the right  side,will opear a color aera,and you can draw on the left side with you select color,and you can change the brush size :)
//    
lowp vec2 uv;
vec2 mouse;
vec4 col,m_col;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float udBox(vec2 p,vec2 s)
{
    return length(max(abs(p)-s,0.));
}
bool Is_Side(lowp vec2 A,lowp vec2 B,lowp vec2 C){
    lowp vec3 AB;
    lowp vec3 BC;
    lowp vec3 AC;
    return dot(cross(AB = vec3(B-A,0.),vec3(uv-A,0.)),cross(AB, AC = vec3(C-A,0.)))>0. 
        && dot(cross(BC = vec3(C-B,0.),vec3(uv-B,0.)),cross(BC,-AB))>0. 
        && dot(cross(-AC,vec3(uv-C,0.)),cross(-AC,-BC))>0.; 
}
void mainImage( out lowp vec4 o, in vec2 u )
{
    uv = u/iResolution.xy;
    mouse = iMouse.xy/iResolution.xy;
	vec3 c0 = texture2D(iChannel2,u/iResolution.xy).rgb/1.1;
    //vec3 c1 = texture2D(iChannel3,u/iResolution.xy).rgb;
    vec3 cc = texture2D(iChannel3,vec2(uv.x,uv.y)).rgb;
    o.rgb = c0.rgb;
    
    if(Is_Side(vec2(0.6,0.),vec2(0.79,0.),vec2(0.79,0.073))){
    	o.r = 1.;
    }
		float m_slide = texture2D(iChannel0,vec2(1.)).r;
    float d = udBox(uv-vec2(clamp(m_slide,0.6,0.777),0.),vec2(0.01,0.08));
    if(d < 0.001){
    	o.g = 1.;
    }
    	vec2 m_sphere = texture2D(iChannel0,vec2(1.,0.)).rg;
    if(uv.x > 0.8){
        o.rgb = cc;
        float d = length((uv- vec2(clamp(m_sphere.x,0.82,1.),m_sphere.y))*vec2(iResolution.x/iResolution.y,1.));
        if(d<0.01 && d>0.0045){
            o.rgb = 1.-o.rgb;
        }
    }
    //else if(uv.x > 0.812){o.rgb = vec3(.1,sin(iGlobalTime),1.);}
	//o.rgb = cc;	

}



