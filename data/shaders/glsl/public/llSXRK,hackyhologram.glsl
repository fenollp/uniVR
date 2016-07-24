// Shader downloaded from https://www.shadertoy.com/view/llSXRK
// written by shadertoy user PumpkinPaul
//
// Name: HackyHologram
// Description: An hacky attempt at some sort of hologram shader
const float blurSize = 1.0/512.0;
const float intensity = 0.35;


//textures:
vec3 tx1(vec2 uv)
{
	return texture2D(iChannel1,uv).rgb;
}

vec3 tx1(float u)
{
	return texture2D(iChannel1,vec2(u,0.0)).rgb;
} 

//geometry:
float sph(vec2 pos, vec2 xy, float radius)
{
	return 1.0 / (length(xy - pos) / radius);
}

//math:
float sum(vec3 c)
{
	return (c.x + c.y + c.z);
}

float rand(float v)// 0 .. 1
{
	return sum(tx1(v)) * 0.6666666666;
}

float noise(vec2 p)
{
	float sample = texture2D(iChannel1,vec2(1.,2.*cos(iGlobalTime))*iGlobalTime*8. + p*1.).x;
	sample *= sample;
	return sample;
}

float onOff(float a, float b, float c)
{
	return step(c, sin(iGlobalTime + a*cos(iGlobalTime*b)));
}

vec4 getVideo(vec2 uv)
{
	vec2 look = uv;
	float window = 1./(1.+20.*(look.y-mod(iGlobalTime/4.,1.))*(look.y-mod(iGlobalTime/4.,1.)));
	look.x = look.x + sin(look.y*10. + iGlobalTime)/100.*onOff(4.,4.,.3)*(1.+cos(iGlobalTime*80.))*window;
	float vShift = 0.4*onOff(2.,3.,.9)*(sin(iGlobalTime)*sin(iGlobalTime*20.) + (0.5 + 0.1*sin(iGlobalTime*200.)*cos(iGlobalTime)));
	look.y = mod(look.y + vShift, 1.);
	vec4 video = vec4(texture2D(iChannel0,look));
        
	return video;
}

vec4 getVideoBlur(vec2 uv)
{
	vec2 look = uv;
	float window = 1./(1.+20.*(look.y-mod(iGlobalTime/4.,1.))*(look.y-mod(iGlobalTime/4.,1.)));
	look.x = look.x + sin(look.y*10. + iGlobalTime)/100.*onOff(4.,4.,.3)*(1.+cos(iGlobalTime*80.))*window;
	float vShift = 0.4*onOff(2.,3.,.9)*(sin(iGlobalTime)*sin(iGlobalTime*20.) + (0.5 + 0.1*sin(iGlobalTime*200.)*cos(iGlobalTime)));
	look.y = mod(look.y + vShift, 1.);
    
    //hack in blur    
    vec4 video = vec4(0);
    video += (texture2D(iChannel0, look + blurSize * vec2(-4.0, 0.0)) * 0.05);
    video += (texture2D(iChannel0, look + blurSize * vec2(-3.0, 0.0)) * 0.09);
    video += (texture2D(iChannel0, look + blurSize * vec2(-2.0, 0.0)) * 0.12);
    video += (texture2D(iChannel0, look + blurSize * vec2(-1.0, 0.0)) * 0.15);
    video += (texture2D(iChannel0, look) * 0.16);
    video += (texture2D(iChannel0, look + blurSize * vec2(1.0, 0.0)) * 0.15);
    video += (texture2D(iChannel0, look + blurSize * vec2(2.0, 0.0)) * 0.12);
    video += (texture2D(iChannel0, look + blurSize * vec2(3.0, 0.0)) * 0.09);
    video += (texture2D(iChannel0, look + blurSize * vec2(4.0, 0.0)) * 0.05);
    
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, -4.0)) * 0.05);
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, -3.0)) * 0.09);
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, -2.0)) * 0.12);
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, -1.0)) * 0.15);
    video += (texture2D(iChannel0, look) * 0.16);
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, 1.0)) * 0.15);
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, 2.0)) * 0.12);
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, 3.0)) * 0.09);
    video += (texture2D(iChannel0, look + blurSize * vec2(0.0, 4.0)) * 0.05);
    
	return video;
}

vec4 getVideoBlurLod(vec2 uv, float lod)
{
	vec2 look = uv;
	float window = 1./(1.+20.*(look.y-mod(iGlobalTime/4.,1.))*(look.y-mod(iGlobalTime/4.,1.)));
	look.x = look.x + sin(look.y*10. + iGlobalTime)/100.*onOff(4.,4.,.3)*(1.+cos(iGlobalTime*80.))*window;
	float vShift = 0.4*onOff(2.,3.,.9)*(sin(iGlobalTime)*sin(iGlobalTime*20.) + (0.5 + 0.1*sin(iGlobalTime*200.)*cos(iGlobalTime)));
	look.y = mod(look.y + vShift, 1.);
	vec4 video = vec4(texture2D(iChannel0,look, lod));
        
	return video;
}

void mainImage( out vec4 color, vec2 uv )
{  
    uv /= iResolution.xy;
		
   	if ( abs(uv.x-.45) > .15 || abs(uv.y-.5) > .3 ) 
        return; //hack to trim viewport 
    
	uv.y  = 1.0 - uv.y;
    uv.x *= 0.5;
    
    //color = getVideoBlurLod(uv, 2.0);
    color = getVideo(uv);

    float t = iGlobalTime;
    float strength = 64.0;
    float x = (uv.x + 4.0) * (uv.y + 4.0) * t * 10.0;
    float grain = 1.0 - (mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01) - 0.005) * strength;
    float random = rand(iGlobalTime);
    float flicker = max(1., random * 1.5);
    float scanlines = 0.85 * clamp(sin(uv.y * 400.0), 0.25, 1.0) * tx1(uv.y * sin(t * 0.2) * 0.1).r * 3.0;
    
    vec4 greyscale = vec4(dot(color, vec4(0.3, 0.59, 0.11, 0)));
    vec4 bluetint  = vec4(0.3, 0.5, 0.8, 1);  
    
    color  = greyscale;
    
    float shadowspeed = 0.2;
    float shadowrange = 0.35;
    float shadowcount = 5.0;
    
   	float shadow = 1.0 - shadowrange + (shadowrange * sin((uv.y + (iGlobalTime * shadowspeed)) * shadowcount));
	color *= shadow;
    
    float highlightspeed = 0.2;
    float highlightrange = 0.35;
    float highlightcount = 5.0;
    float highlight = 1.0 - highlightrange + (highlightrange * sin((uv.y + (iGlobalTime * -highlightspeed)) * highlightcount));
	color += highlight;
    
    
    color *= grain* flicker * scanlines * bluetint;
}