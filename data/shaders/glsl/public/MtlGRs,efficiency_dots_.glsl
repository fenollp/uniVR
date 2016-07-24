// Shader downloaded from https://www.shadertoy.com/view/MtlGRs
// written by shadertoy user Glyph
//
// Name: Efficiency Dots?
// Description: I was playing around with the Android app version of Shadertoy and I found that my initial attempts at creating this effect were extremely slow. This is my attempt to make it as optimized as possible. Please tell me if you have tips. 
vec4 finalcol;
vec2 manres = vec2(1080.0,1920.0);
uniform vec2 resolution;
const float dotw = 400.0;
const float dotwdmax = 30.0;
const float dotsep = 20.0;
float pi = 3.14159265;

float circle(vec2 origin,float radius,bool smooth){
    if(!smooth){
    return(step(length(origin),radius));
    }else{
        return(smoothstep(radius,0.0,length(origin)));
    }
}

bool square(vec2 origin,float width){
        return(origin.x < width && origin.x > -width && origin.y < width && origin.y > -width);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 mpoint = fragCoord.xy - iMouse.xy;
	float col = 0.0;
    
	for(float j=0.0;j < dotw;j+=dotsep){
		for(float i = 0.0; i< dotw; i+=dotsep){
        if(!square(mpoint,dotw/2.0 + dotwdmax/2.0)){
            break;
        }
		col =+ circle(vec2(mpoint.x +-(dotw)/2.0 +dotwdmax/4.0 + i,mpoint.y +(dotw)/2.0 -dotwdmax/4.0 -j),8.0*abs(sin(iGlobalTime))+2.0,sign(sin(iGlobalTime)) > 0.0);
    	if(col != 0.0){
     		break;   
    	}
	}
		if(col != 0.0 || !square(mpoint,240.0)){
     	break;
    	}
	}
    float sqc = 0.0;
    if(square(mpoint,dotw/2.0 + dotwdmax/2.0)){
      sqc = 1.0;   
    }
    
	finalcol = vec4(col*abs(sin(iGlobalTime)) + sqc*0.0,col * abs(cos(iGlobalTime)),abs(sin(iGlobalTime + pi/4.0)) * col,1.0);
    fragColor=finalcol;
}
    