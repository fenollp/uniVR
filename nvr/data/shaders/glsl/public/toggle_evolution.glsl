// Shader downloaded from https://www.shadertoy.com/view/ldGGRG
// written by shadertoy user eiffie
//
// Name: toggle evolution
// Description: Experimenting with bergi's Interactive Evolutionary Framework but probably a bad example since there is no smooth transition between types. They are hypercomplex fractals Z=Z*Z+C where each has its own multiplication table.
//toggle evolution by eiffie (a kind of failed use bergi's interactive evolution)

//framework taken from interactive evolution by bergi https://www.shadertoy.com/view/XdyGWw

/*  Interactive Evolutionary Framework

    (c) 0x7e Stefan Berke
   	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

	Version 0.1
*/

//#define SHOW_MORE_TYPES
#define AA 0						// anti-aliasing > 1
const int NUM_PARAM_ROWS = 1;		// Number of rows of parameters for one 'tile'
const int NUM_TILES = 4;			// Number of 'tiles' per screen height

int cur_tile; // (initialized in main)

// returns the parameters for the current 'tile' 
vec4 parameter(in int column, in int row) 
{ 
    vec2 uv = (vec2(column, row + cur_tile * NUM_PARAM_ROWS)+.5) / iResolution.xy;
    return (texture2D(iChannel0, uv) - .5) * 4.;
    // some slight varying in time
    //    + 0.006 * sin(float(column) + iGlobalTime) * vec4(1., -1., -1., 1.);
    //    ;    
}
// wrapper, if you don't use rows
vec4 parameter(in int column) { return parameter(column, 0); }

// 8<---------8<---------8<--------8<--
// plug in your favorite algorithm here
// and use the parameter function above

//here is eiffie stuff (hypercomplex fractals with the signs coming from parameters)
vec4 p1,p2,p3;//the parameters
float DE(vec3 z0){
	vec4 Z=vec4(z0,0.0),C = Z;
	float dr = 1.0,r = length(Z);
	if(p3.z<0.0){Z.xyzw=Z.wzyx;C.xyzw=C.wzyx;}
	if(p3.w<0.0){Z.ywxz=Z.wyzx;C.ywxz=C.wyzx;}
	for (int n = 0; n < 6; n++) {
		if(r>2.0)break;
		dr = dr * r * 2.0 + 1.0;
		vec4 zz=Z*Z,zs=2.0*Z*Z.yzwx;//like a mandelbrot Z=Z*Z+C in 4D
		vec2 zss=2.0*Z.xy*Z.zw;
#ifdef SHOW_MORE_TYPES
        vec4 p4=parameter(3);
        if(p4.w<-0.5){
        	if(p4.x<0.0){vec2 t=zz.zw;zz.zw=zs.zw;zs.zw=t;}
        	if(p4.y<0.0){vec2 t=zz.xy;zz.xy=zs.xy;zs.xy=t;}
        	if(p4.z<0.0){vec2 t=zz.xz;zz.xz=zss;zss=t;}
        }
#endif
		Z=vec4(dot(p1,zz),dot(p2.xz,zs.xz),dot(p3.xy,zss),dot(p2.yw,zs.yw))+C;//just applying the signs
		r = length(Z);
	}
	return 0.5 * log(r) * r / dr;
}

float rand(vec2 c){return fract(sin(dot(c*423.143,vec2(13.235,121.23)))*2342.45);}
/* uv is in [-1, 1] */
vec3 theImage(in vec2 uv)
{
	uv=-uv.yx;//may favorite fractal was on its side
	p1=sign(parameter(0));p2=sign(parameter(1));p3=sign(parameter(2));//just toggle switches
	vec3 ro=vec3(0.0,0.0,-4.0),rd=normalize(vec3(uv,2.0));
	float tim=iGlobalTime*0.2+float(cur_tile);
	mat2 mx=mat2(cos(tim),-sin(tim),sin(tim),cos(tim));
	ro.xz=ro.xz*mx*mx;rd.xz=rd.xz*mx*mx;
	ro.xy=ro.xy*mx;rd.xy=rd.xy*mx;
	float t=2.0+DE(ro+rd*2.0)*0.1,d,od=1.0,px=0.002;
	vec4 e=vec4(0.0);
	for(int i=0;i<64;i++){
		t+=d=DE(ro+rd*t);
		if(d<px*t && e.w==0.0)e=vec4(t-d,e.xyz);
		od=d;
		if(d<0.00001 || t>6.0)break;
	}
	vec3 col=vec3(1.0),L=normalize(vec3(0.4,-0.7,-0.6));L.xz=L.xz*mx*mx;L.xy=L.xy*mx;
	for(int i=0;i<4;i++){//I can't make these little bugs look good
		if(e.x==0.0)break;
		vec3 so=ro+rd*e.x;
		vec2 v=vec2(0.01,0.0);
		vec3 N=normalize(vec3(DE(so+v.xyy)-DE(so-v.xyy),DE(so+v.yxy)-DE(so-v.yxy),DE(so+v.yyx)-DE(so-v.yyx)));
		if(N!=N)N=-rd;
		float dif=0.1+0.6*dot(N,L);
		col=mix(vec3(dif),col,clamp(DE(so)/(px*e.x),0.0,1.0));
		e=e.yzwx;
	}
	return col.rgb;
}

// 8<---------8<---------8<--------8<--

#define BLUR 0.1
float segment(vec2 uv){//from Andre https://www.shadertoy.com/view/Xsy3zG
	uv = abs(uv);return (1.0-smoothstep(0.07-BLUR,0.07+BLUR,uv.x)) * (1.0-smoothstep(0.46-BLUR,0.46+BLUR,uv.y+uv.x)) ;//* (1.25 - length(uv*vec2(3.8,1.3)))
	//uv = abs(uv);return (1.0-smoothstep(udef[6]-udef[8],udef[6]+udef[8],uv.x)) * (1.0-smoothstep(udef[7]-udef[8],udef[7]+udef[8],uv.y+uv.x)) ;//* (1.25 - length(uv*vec2(3.8,1.3)))
}
float sevenSegment(vec2 uv,int num){
	uv=(uv-0.5)*vec2(1.5,2.2);
	float seg=0.0;if(num>=2 && num!=7 || num==-2)seg+=segment(uv.yx);
	if (num==0 || (uv.y<0.?((num==2)==(uv.x<0.) || num==6 || num==8):(uv.x>0.?(num!=5 && num!=6):(num>=4 && num!=7) )))seg += segment(abs(uv)-0.5); 
	if (num>=0 && num!=1 && num!=4 && (num!=7 || uv.y>0.))seg += segment(vec2(abs(uv.y)-1.0,uv.x)); 
	return seg;
}
//prints a "num" filling the "rect" with "spaces" # of digits including minus sign
float formatNum(vec2 uv, vec2 rect, float num, int spaces){//only good up to 6 spaces!
	uv/=rect;if(uv.x<0.0 || uv.y<0.0 || uv.x>1.0 || uv.y>1.0)return 0.0;
	uv.x*=float(spaces);
	float place=floor(uv.x);
	if(num<0.0){if(place==0.0)return segment((uv.yx-0.5)*vec2(2.2,1.5));else {num=-num;place-=1.0;uv.x-=1.0;spaces-=1;}}
	float decpnt=floor(max(log(num)/log(10.0),0.0));//how many digits before the decimal place
	if(decpnt==0.0 && num<1.0){place+=1.0;uv.x+=1.0;spaces+=1;}
	float period=(decpnt==float(spaces-1)?0.0:1.0-smoothstep(0.06-BLUR/2.,0.06+BLUR/2.,length(uv-vec2(decpnt+1.0,0.1))));
	uv.x=fract(uv.x);
	num+=0.000001*pow(10.,decpnt);
	num /= pow(10.,decpnt-place);
	num = mod(floor(num),10.0);
	return period+sevenSegment(uv,int(num));
}

//x=sel_tile, y=last mouse z
vec4 state(){
    float maxRow=floor(float(NUM_PARAM_ROWS*NUM_TILES*NUM_TILES)*iResolution.x/iResolution.y)+float(NUM_PARAM_ROWS*NUM_TILES);
    return texture2D(iChannel0,vec2(0.5,maxRow+0.5)/iResolution.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    
    // reset dot
    if (uv.x < 0.05 && uv.y >= 0.95)
    {
        fragColor = vec4(1., 0., 0., 1.);
    }
    else
    { 
        int sel_tile=int(state().x+0.1);
        
        // determine the rendered tile index
        cur_tile = int(uv.y * float(NUM_TILES))
                 + int(uv.x * float(NUM_TILES)) * NUM_TILES;

        // get per-tile uv
        float width = iResolution.y / float(NUM_TILES);
        vec2 tileuv = vec2(mod(fragCoord.x, width), mod(fragCoord.y, width)) 
                        / iResolution.y * float(NUM_TILES) * 2.  - 1.;

        if(iMouse.z>0.0){//left mouse down so show full view
			tileuv=(uv-0.5)*2.0;cur_tile=sel_tile;
		}
#if AA <= 1
		vec3 col = theImage(tileuv);
#else
        vec2 sc = vec2(2.) / width / float(AA);
        vec3 col = vec3(0.);
        for (int j=0; j<AA; ++j)
        for (int i=0; i<AA; ++i)
        {
            col += theImage(tileuv + sc * vec2(float(i), float(j)));
        }
        col /= float(AA * AA);
#endif
        
        // vignette
        col *= 1. - pow(max(abs(tileuv.x), abs(tileuv.y)), 20.);
        col=clamp(col,0.0,1.0);
        if(iMouse.z>0.0){//left mouse down - print params
			uv.x-=1.1;uv.y-=0.9;
			vec2 rc=vec2(0.1,0.05);
			float f=0.0;
			for(int i=0;i<4;i++){//this doesn't need to be a loop fragCoord.y tells you which to print
				f+=formatNum(uv, rc, p1.x, 4);uv.y+=0.06;
				f+=formatNum(uv, rc, p2.x, 4);uv.y+=0.06;
				f+=formatNum(uv, rc, p3.x, 4);uv.y+=0.06;
				p1=p1.yzwx;p2=p2.yzwx;p3=p3.yzwx;
			}
			col+=vec3(f);
		}
        fragColor = vec4(col, 1.);
    }

    //fragColor = texture2D(iChannel0, uv);
}