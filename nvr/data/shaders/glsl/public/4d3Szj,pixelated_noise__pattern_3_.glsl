// Shader downloaded from https://www.shadertoy.com/view/4d3Szj
// written by shadertoy user udart
//
// Name: Pixelated noise (pattern 3)
// Description: Adapted from https://www.shadertoy.com/view/ldS3RR#. Small fix to make it work on video. Changed the effect a bit to fit the video better
float time;

vec4 a1(float n, vec2 p) {
	vec4 ccc=vec4(0.0,0.0,0.0,0.0);
	p=mod(p/n, 1.0) ;
	ccc=texture2D(iChannel1,p).rgba;	
	return ccc;
}

vec4 a2(float n, vec2 p) {
	vec4 ccc=vec4(0.0,0.0,0.0,0.0);
	p=mod(p/n, 1.0) ;
	ccc=texture2D(iChannel2,p).rgba;	
	return ccc;
}

vec4 a3(float n, vec2 p) {
	vec4 ccc=vec4(0.0,0.0,0.0,0.0);
	p=mod(p/n, 1.0) ;
	ccc=texture2D(iChannel3,p).rgba;	
	return ccc;
}


float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	int n;
	float gray; 
	vec3 col;
	vec4 a,b,c,d=vec4(1.0);
	vec2 uv = fragCoord.xy;
 	
	col = texture2D(iChannel0, floor(uv.xy/5.0)*5.0/iResolution.xy).rgb;		
	gray = (col.r*0.2126)+ (col.g*0.7152)+ (col.b*0.0722);        
	if(gray>0.3){
						
		a=a1(20.0,uv.xy);
		a.r =col.r-a.r;
		a.g =col.g-a.g;
		a.b =col.b-a.b;	
		
	}
	
	col = texture2D(iChannel0, floor(uv/10.0)*10.0/iResolution.xy).rgb;		
	gray = (col.r*0.2126)+ (col.g*0.7152)+ (col.b*0.0722);        
	if(gray>0.4){
		
		a=a2(10.0,uv);
		a.r =col.r-a.r;
		a.g =col.g-a.g;
		a.b =col.b-a.b;			
	}
	
	
	col = texture2D(iChannel0, floor(uv/20.0)*20.0/iResolution.xy).rgb;		
	gray = (col.r*0.2126)+ (col.g*0.7152)+ (col.b*0.0722);        
	if(gray>0.6){
		time=gray*rand(floor(uv/20.0)*20.0/iResolution.xy);		
		
		if(time<0.33){
			a=a1(5.0,uv);
		}else if(time<0.66){
			a=a2(10.0,uv);
		}else if(time<0.99){
			a=a3(20.0,uv);
		}	
		
		a.r =col.r-a.r;
		a.g =col.g-a.g;
		a.b =col.b-a.b;						
	}

	fragColor = a*2.8;
}