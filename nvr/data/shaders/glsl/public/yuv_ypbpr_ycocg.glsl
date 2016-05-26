// Shader downloaded from https://www.shadertoy.com/view/4dcSRN
// written by shadertoy user paniq
//
// Name: YUV YPbPr YCoCg
// Description: reference implementation for YUV colorspaces. cylinder demos the YCoCg color space, with chroma radius clamped to bicone of safe values in RGB cube. Drag mouse to see slices.
// undefine to see full mapped range
#define CLAMP_BICONE

// define for chroma normalization (when biconic clamping is disabled)
//#define NORM_CHROMA

//----------------------------------------------------------------------------

// YUV, generic conversion
// ranges: Y=0..1, U=-uvmax.x..uvmax.x, V=-uvmax.x..uvmax.x

vec3 yuv_rgb (vec3 yuv, vec2 wbwr, vec2 uvmax) {
    vec2 br = yuv.x + yuv.yz * (1.0 - wbwr) / uvmax;
	float g = (yuv.x - dot(wbwr, br)) / (1.0 - wbwr.x - wbwr.y);
	return vec3(br.y, g, br.x);
}

vec3 rgb_yuv (vec3 rgb, vec2 wbwr, vec2 uvmax) {
	float y = wbwr.y*rgb.r + (1.0 - wbwr.x - wbwr.y)*rgb.g + wbwr.x*rgb.b;
    return vec3(y, uvmax * (rgb.br - y) / (1.0 - wbwr));
}

//----------------------------------------------------------------------------

// YUV, HDTV, gamma compressed, ITU-R BT.709
// ranges: Y=0..1, U=-0.436..0.436, V=-0.615..0.615

vec3 yuv_rgb (vec3 yuv) {
    return yuv_rgb(yuv, vec2(0.0722, 0.2126), vec2(0.436, 0.615));
}

vec3 rgb_yuv (vec3 rgb) {
    return rgb_yuv(rgb, vec2(0.0722, 0.2126), vec2(0.436, 0.615));
}

//----------------------------------------------------------------------------

// Y*b*r, generic conversion
// ranges: Y=0..1, b=-0.5..0.5, r=-0.5..0.5

vec3 ypbpr_rgb (vec3 ybr, vec2 kbkr) {
    return yuv_rgb(ybr, kbkr, vec2(0.5));
}
    
vec3 rgb_ypbpr (vec3 rgb, vec2 kbkr) {
    return rgb_yuv(rgb, kbkr, vec2(0.5));
}

//----------------------------------------------------------------------------

// YPbPr, analog, gamma compressed, HDTV
// ranges: Y=0..1, b=-0.5..0.5, r=-0.5..0.5

// YPbPr to RGB, after ITU-R BT.709
vec3 ypbpr_rgb (vec3 ypbpr) {
    return ypbpr_rgb(ypbpr, vec2(0.0722, 0.2126));
}

// RGB to YPbPr, after ITU-R BT.709
vec3 rgb_ypbpr (vec3 rgb) {
    return rgb_ypbpr(rgb, vec2(0.0722, 0.2126));
}

//----------------------------------------------------------------------------

// YPbPr, analog, gamma compressed, VGA, TV
// ranges: Y=0..1, b=-0.5..0.5, r=-0.5..0.5

// YPbPr to RGB, after ITU-R BT.601
vec3 ypbpr_rgb_bt601 (vec3 ypbpr) {
    return ypbpr_rgb(ypbpr, vec2(0.114, 0.299));
}

// RGB to YPbPr, after ITU-R BT.601
vec3 rgb_ypbpr_bt601 (vec3 rgb) {
    return rgb_ypbpr(rgb, vec2(0.114, 0.299));
}

//----------------------------------------------------------------------------

// in the original implementation, the factors and offsets are
// ypbpr * (219, 224, 224) + (16, 128, 128)

// YPbPr to YCbCr (analog to digital)
vec3 ypbpr_ycbcr (vec3 ypbpr) {
	return ypbpr * vec3(0.85546875,0.875,0.875) + vec3(0.0625, 0.5, 0.5);
}

// YCbCr to YPbPr (digital to analog)
vec3 ycbcr_ypbpr (vec3 ycbcr) {
	return (ycbcr - vec3(0.0625, 0.5, 0.5)) / vec3(0.85546875,0.875,0.875);
}

//----------------------------------------------------------------------------

// YCbCr, digital, gamma compressed
// ranges: Y=0..1, b=0..1, r=0..1

// YCbCr to RGB (generic)
vec3 ycbcr_rgb(vec3 ycbcr, vec2 kbkr) {
    return ypbpr_rgb(ycbcr_ypbpr(ycbcr), kbkr);
}
// RGB to YCbCr (generic)
vec3 rgb_ycbcr(vec3 rgb, vec2 kbkr) {
    return ypbpr_ycbcr(rgb_ypbpr(rgb, kbkr));
}
// YCbCr to RGB
vec3 ycbcr_rgb(vec3 ycbcr) {
    return ypbpr_rgb(ycbcr_ypbpr(ycbcr));
}
// RGB to YCbCr
vec3 rgb_ycbcr(vec3 rgb) {
    return ypbpr_ycbcr(rgb_ypbpr(rgb));
}

//----------------------------------------------------------------------------

// ITU-R BT.2020:
// YcCbcCrc, linear
// ranges: Y=0..1, b=-0.5..0.5, r=-0.5..0.5

// YcCbcCrc to RGB
vec3 yccbccrc_rgb(vec3 yccbccrc) {
	return ypbpr_rgb(yccbccrc, vec2(0.0593, 0.2627));
}

// RGB to YcCbcCrc
vec3 rgb_yccbccrc(vec3 rgb) {
	return rgb_ypbpr(rgb, vec2(0.0593, 0.2627));
}

//----------------------------------------------------------------------------

// YCoCg
// ranges: Y=0..1, Co=-0.5..0.5, Cg=-0.5..0.5

vec3 ycocg_rgb (vec3 ycocg) {
    vec2 br = vec2(-ycocg.y,ycocg.y) - ycocg.z;
    return ycocg.x + vec3(br.y, ycocg.z, br.x);
}

vec3 rgb_ycocg (vec3 rgb) {
    float tmp = 0.5*(rgb.r + rgb.b);
    float y = rgb.g + tmp;
    float Cg = rgb.g - tmp;
    float Co = rgb.r - rgb.b;
    return vec3(y, Co, Cg) * 0.5;
}

//----------------------------------------------------------------------------

vec3 yccbccrc_norm(vec3 ypbpr) {
    vec3 p = yccbccrc_rgb(ypbpr);
   	vec3 ro = yccbccrc_rgb(vec3(ypbpr.x, 0.0, 0.0));
    vec3 rd = normalize(p - ro);
    vec3 m = 1./rd;
    vec3 b = 0.5*abs(m)-m*(ro - 0.5);
    float tF = min(min(b.x,b.y),b.z);
    p = ro + rd * tF * max(abs(ypbpr.y),abs(ypbpr.z)) * 2.0;
	return rgb_yccbccrc(p); 
}

vec3 ycocg_norm(vec3 ycocg) {
    vec3 p = ycocg_rgb(ycocg);
   	vec3 ro = ycocg_rgb(vec3(ycocg.x, 0.0, 0.0));
    vec3 rd = normalize(p - ro);
    vec3 m = 1./rd;
    vec3 b = 0.5*abs(m)-m*(ro - 0.5);
    float tF = min(min(b.x,b.y),b.z);
    p = ro + rd * tF * max(abs(ycocg.y),abs(ycocg.z)) * 2.0;
	return rgb_ycocg(p); 
}

//----------------------------------------------------------------------------

float linear_srgb(float x) {
    return mix(1.055*pow(x, 1./2.4) - 0.055, 12.92*x, step(x,0.0031308));
}
vec3 linear_srgb(vec3 x) {
    return mix(1.055*pow(x, vec3(1./2.4)) - 0.055, 12.92*x, step(x,vec3(0.0031308)));
}

float srgb_linear(float x) {
    return mix(pow((x + 0.055)/1.055,2.4), x / 12.92, step(x,0.04045));
}
vec3 srgb_linear(vec3 x) {
    return mix(pow((x + 0.055)/1.055,vec3(2.4)), x / 12.92, step(x,vec3(0.04045)));
}

//----------------------------------------------------------------------------

// from https://www.shadertoy.com/view/4s23DR
bool cylinder(vec3 org, vec3 dir, out float near, out float far)
{
	// quadratic x^2 + y^2 = 0.5^2 => (org.x + t*dir.x)^2 + (org.y + t*dir.y)^2 = 0.5
	float a = dot(dir.xy, dir.xy);
	float b = dot(org.xy, dir.xy);
	float c = dot(org.xy, org.xy) - 0.25;

	float delta = b * b - a * c;
	if( delta < 0.0 )
		return false;

	// 2 roots
	float deltasqrt = sqrt(delta);
	float arcp = 1.0 / a;
	near = (-b - deltasqrt) * arcp;
	far = (-b + deltasqrt) * arcp;
	
	// order roots
	float temp = min(far, near);
	far = max(far, near);
	near = temp;

	float znear = org.z + near * dir.z;
	float zfar = org.z + far * dir.z;

	// top, bottom
	vec2 zcap = vec2(0.5, -0.5);
	vec2 cap = (zcap - org.z) / dir.z;

	if ( znear < zcap.y )
		near = cap.y;
	else if ( znear > zcap.x )
		near = cap.x;

	if ( zfar < zcap.y )
		far = cap.y;
	else if ( zfar > zcap.x )
		far = cap.x;
	
	return far > 0.0 && far > near;
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

bool huecylinder(vec3 ro, vec3 rd, vec3 p, float cap, float rscale, out vec3 uv) {
    ro = ro.xzy;
    rd = rd.xzy;
    cap = max(cap, 0.0001);
    ro -= p;
    ro.z += 0.5;
    ro.z /= cap;
    rd.z /= cap;
    ro.z -= 0.5;
    
    float near, far;
    if (cylinder(ro, rd, near, far)) {
        vec3 p = ro + rd * near;
        
        uv.x = (p.z + 0.5) * cap;
        uv.x = srgb_linear(uv.x);
        uv.yz = p.xy * rscale;
#ifdef CLAMP_BICONE
        float r = (1.0-abs(uv.x-0.5)*2.0) * 0.7071;
        //float r = (1.0-abs(uv.x-0.5)*2.0) * 0.53235;
        uv.yz *= r;
#else
        //uv.yz *= 1.1681404025202;
#endif
        uv = clamp(uv, vec3(0.0,-0.5,-0.5), vec3(1.0,0.5,0.5));
        
        return true;
    }    
    return false;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 ms = iMouse.xy / iResolution.xy;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pd = uv * 2.0 - 1.0;
    pd.x *= iResolution.x / iResolution.y;
    
    float a = iGlobalTime * 0.5;
    vec3 ro = vec3(cos(a), 1.0, sin(a)) * 3.0;
    mat3 m = calcLookAtMatrix(ro, vec3(0.0), 0.0);
    vec3 rd = normalize(m * vec3(pd.xy,5.0));
    
    float cap = (iMouse.z > 0.5)?clamp(ms.y*2.0-0.5,0.0,1.0):(sin(iGlobalTime)*0.5+0.5);
    float rscale = 1.0; //(iMouse.z > 0.5)?ms.x*2.0:1.0;
    
    vec3 color = vec3(0.0);
    float near, far;
    vec3 yuv;
    if (huecylinder(ro, rd, vec3(0.0, 0.0, 0.0), cap, rscale, yuv)) {
        vec3 p = ro + rd * near;
#ifdef NORM_CHROMA
        yuv = ycocg_norm(yuv);
#endif
        color = ycocg_rgb(yuv);
        vec3 c = abs(color - 0.5);
        if (max(c.r,max(c.g,c.b)) > 0.501)
            color = vec3(0.5);
    }
 
#if 0
    for (int i = 0; i < 10; ++i) {
    	color = rgb_ycocg(color);
    	color = ycocg_rgb(color);
    }
#endif
    
    color = linear_srgb(color);
    
	fragColor = vec4(color,1.0);
}