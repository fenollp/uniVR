// Shader downloaded from https://www.shadertoy.com/view/XtXGRM
// written by shadertoy user 4rknova
//
// Name: Value to Bit Array
// Description: A simple utility to visualize the bit array for a literal. All 32 bits are shown, however only the first 24 are usable in practice, the remaining 8 have a darker shade. You can use the mouse to generate a random pattern by holding down the left button.
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Change the following value to test your pattern.
#define VAL 3445.

#define BG vec3(.0, .2, .4567)
#define C0 vec3(.3, .1, .1)
#define C1 vec3(.1, .9, .1)
#define CL vec3(0)
#define CM vec3(1)

float val = VAL;
float z   = 20.;

float df_line(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa,ba) / dot(ba,ba), 0., 1.);	
	return length(pa - ba * h);
}

float df_circ(in vec2 p, in vec2 c, in float r)
{
    return abs(r - length(p - c));
}

float sharpen(in float d, in float w)
{
    float e = 1. / min(iResolution.y , iResolution.x);
    return 1. - smoothstep(-e, e, d - w);
}

void rect(in vec4 _p, in vec3 _c, in vec2 fragCoord, inout vec4 fragColor)
{
	vec2 p = fragCoord.xy;
    if((_p.x<p.x&&p.x<_p.x+_p.z&&_p.y<p.y&&p.y<_p.y+_p.w))fragColor=vec4(_c,0.);
}

// Print Utility by FMS_Cat
// https://www.shadertoy.com/view/4ts3R8
void print(in float _i, in vec2 _f,vec2 _p, in vec3 _c, in vec2 fragCoord, inout vec4 fragColor)
{
    bool n=(_i<0.)?true:false;
    _i=abs(_i);
    if(fragCoord.x<_p.x-5.-(max(ceil(log(_i)/log(10.)),_f.x)+(n?1.:0.))*30.||_p.x+6.+_f.y*30.<fragCoord.x||fragCoord.y<_p.y||_p.y+31.<fragCoord.y)return;
    
    if(0.<_f.y){rect(vec4(_p.x-5.,_p.y,11.,11.), vec3(1.), fragCoord, fragColor);rect(vec4(_p.x-4.,_p.y+1.,9.,9.), _c, fragCoord, fragColor);}
    
    float c=-_f.y,m=0.;
    for(int i=0;i<16;i++)
    {
        float x,y=_p.y;
        if(0.<=c){x=_p.x-35.-30.*c;}
        else{x=_p.x-25.-30.*c;}
        if(int(_f.x)<=int(c)&&_i/pow(10.,c)<1.&&0.<c)
        {
            if(n){rect(vec4(x,y+10.,31.,11.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+11.,29.,9.),_c, fragCoord, fragColor);}
            break;
        }
        float l=fract(_i/pow(10.,c+1.));
        if(l<.1){rect(vec4(x,y,31.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,29.),_c, fragCoord, fragColor);rect(vec4(x+15.,y+10.,1.,11.),vec3(1.), fragCoord, fragColor);}
        else if(l<.2){rect(vec4(x+5.,y,21.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x,y,31.,11.),vec3(1.), fragCoord, fragColor);rect(vec4(x,y+20.,6.,11.),vec3(1.), fragCoord, fragColor);rect(vec4(x+6.,y+1.,19.,29.),_c, fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,9.),_c, fragCoord, fragColor);rect(vec4(x+1.,y+21.,5.,9.),_c, fragCoord, fragColor);}
        else if(l<.3){rect(vec4(x,y,31.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,29.),_c, fragCoord, fragColor);rect(vec4(x+15.,y+10.,15.,1.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+20.,15.,1.),vec3(1.), fragCoord, fragColor);}
        else if(l<.4){rect(vec4(x,y,31.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,29.),_c, fragCoord, fragColor);rect(vec4(x+1.,y+10.,15.,1.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+20.,15.,1.),vec3(1.), fragCoord, fragColor);}
        else if(l<.5){rect(vec4(x,y+5.,15.,26.),vec3(1.), fragCoord, fragColor);rect(vec4(x+15.,y,16.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+6.,14.,24.),_c, fragCoord, fragColor);rect(vec4(x+16.,y+1.,14.,29.),_c, fragCoord, fragColor);rect(vec4(x+15.,y+6.,1.,10.),_c, fragCoord, fragColor);}
        else if(l<.6){rect(vec4(x,y,31.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,29.),_c, fragCoord, fragColor);rect(vec4(x+1.,y+10.,15.,1.),vec3(1.), fragCoord, fragColor);rect(vec4(x+15.,y+20.,15.,1.),vec3(1.), fragCoord, fragColor);}
        else if(l<.7){rect(vec4(x,y,31.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,29.),_c, fragCoord, fragColor);rect(vec4(x+10.,y+10.,11.,1.),vec3(1.), fragCoord, fragColor);rect(vec4(x+10.,y+20.,20.,1.),vec3(1.), fragCoord, fragColor);}
        else if(l<.8){rect(vec4(x,y+10.,15.,21.),vec3(1.), fragCoord, fragColor);rect(vec4(x+15.,y,16.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+11.,14.,19.),_c, fragCoord, fragColor);rect(vec4(x+16.,y+1.,14.,29.),_c, fragCoord, fragColor);rect(vec4(x+15.,y+20.,1.,10.),_c, fragCoord, fragColor);}
        else if(l<.9){rect(vec4(x,y,31.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,29.),_c, fragCoord, fragColor);rect(vec4(x+10.,y+10.,11.,1.),vec3(1.), fragCoord, fragColor);rect(vec4(x+10.,y+20.,11.,1.),vec3(1.), fragCoord, fragColor);}
        else{rect(vec4(x,y,31.,31.),vec3(1.), fragCoord, fragColor);rect(vec4(x+1.,y+1.,29.,29.),_c, fragCoord, fragColor);rect(vec4(x+1.,y+10.,20.,1.),vec3(1.), fragCoord, fragColor);rect(vec4(x+10.,y+20.,11.,1.),vec3(1.), fragCoord, fragColor);}
        c+=1.;
    }
}

void draw_bg(in vec2 p, inout vec4 fragColor)
{
    fragColor = vec4(mod(p.x + p.y, 2.) * .05 + BG, 1);
}

void draw_text(in vec2 p, in vec2 fragCoord, inout vec4 fragColor)
{
    print(val, vec2(1), vec2(iResolution.x - 50.,10.), vec3(0), fragCoord, fragColor);
}

void draw_01x32(in vec2 p, in vec2 uv, inout vec4 fragColor)
{
    vec2 o = vec2(2., floor(z - 2.));
	p -= o;
    vec2 c = uv * z - o;

    { // Cell frame        
	    float w = 0.25;
		float l = sharpen(df_line(c, vec2( 0,1), vec2(32,1)), w)
	            + sharpen(df_line(c, vec2( 0,0), vec2(32,0)), w)
	        	+ sharpen(df_line(c, vec2( 0,1), vec2( 0,0)), w)
	        	+ sharpen(df_line(c, vec2(32,1), vec2(32,0)), w);
    
	    if (l > 0.) fragColor = vec4(CL, 1);
    }
    
    { // Cells        
    	if (p.x >= 0. && p.y == 0. &&  p.x <= 31.) {
    		float bit = 0.;
        	bit = mod(val / pow(2., 31. - p.x), 2.);
            float mut = 31. - p.x > 23. ? .4 : 1.;
    		fragColor = vec4((floor(bit) > 0. ? C1 : C0) * mut, 1);
		}
    }
    
    { // Cell lines
    
    	float l = 0.;
    	float w = 0.06;
	    
	    for (int i = 0; i < 32; ++i) {
	        l += sharpen(df_line(c, vec2(i,1), vec2(i,0)), w);
	    }
    
	    if (l > 0.) fragColor = vec4(CL, 1);
    }
}

void draw_04x08(in vec2 p, in vec2 uv, inout vec4 fragColor)
{
    vec2 o = vec2(2., floor(z - 15.));
    p -= o;
    vec2 c = uv * z - o;

    { // Cell frame
	    float w = 0.25;
		float l = sharpen(df_line(c, vec2( 0, 0), vec2( 4, 0)), w)
	            + sharpen(df_line(c, vec2( 0, 8), vec2( 0, 0)), w)
            	+ sharpen(df_line(c, vec2( 4, 8), vec2( 4, 0)), w)
            	+ sharpen(df_line(c, vec2( 0, 8), vec2( 4, 8)), w);
    
	    if (l > 0.) fragColor = vec4(CL, 1);
    }
    
    { // Cells
    	if (   p.x >= 0. && p.y >= 0.
	        && p.x <= 3. && p.y <= 7.) {
	    	float bit = 0.;
	        float idx = p.y * 4. + 3. - p.x;
	        bit = mod(val / pow(2., idx), 2.);
            float mut = idx > 23. ? .4 : 1.;
	    	fragColor = vec4((floor(bit) > 0. ? C1 : C0) * mut, 1);
		}
    }
}

void handle_mouse(in vec2 p, inout vec4 fragColor)
{
    if (iMouse.z > 0.) {
        val = ceil(iMouse.x / iResolution.x * 4096.) *
              ceil(iMouse.y / iResolution.y * 4096.);
        
		float w = 0.001;
        float a = sin(10.*iGlobalTime);
		float l =
            sharpen(df_circ(p, iMouse.xy / iResolution.xy * vec2(iResolution.x / iResolution.y, 1.), 
                    .025 + a * .005), w);
   		if (l > 0.) fragColor = vec4(mix(CM, BG, a), 1);
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy
            * vec2(iResolution.x / iResolution.y, 1.);

    vec2  o1 = vec2(2., floor(z - 2.));
    vec2  p = floor(uv * z);
    
    draw_bg(p, fragColor);
    handle_mouse(uv, fragColor);
    draw_01x32(p, uv, fragColor);    
    draw_04x08(p, uv, fragColor);    
    draw_text(uv, fragCoord, fragColor);
}