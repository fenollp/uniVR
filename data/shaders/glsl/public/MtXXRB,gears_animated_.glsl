// Shader downloaded from https://www.shadertoy.com/view/MtXXRB
// written by shadertoy user athlete
//
// Name: Gears Animated 
// Description: Inspired by the tutorial by iq: https://www.youtube.com/watch?v=0ifChJ0nJfM
const float PI = 3.1415;
const float PIOVER180 = PI/180.0;

const int numRects = 17;
const float radius = 0.4;

//naive rect 
//#define Rect(p) max(abs(p).x,abs(p).y)>.0385 ? 1. : 0.

//anti aliased rect, thanks @FabriceNeyret2
#define Rect(p) smoothstep(.035,.0385,max(abs(p).x,abs(p).y))

//rotation, takes angle in degree
vec2 Rot(vec2 p, float angle)
{
	mat2 rotMatrix = mat2(cos(angle*PIOVER180), sin(angle*PIOVER180), //first column
                          -sin(angle*PIOVER180), cos(angle*PIOVER180)); //second column
    vec2 result = p * rotMatrix;

   	return result;
}

float DrawGear(vec2 p, float radius)
{   
    float A=1.0; // alpha mask
    
    //draw teeth of gear in a circle and angled  
    for(int i=0; i<numRects; i++)
    {
    	vec2 rec = p;
        rec = Rot(rec, float(i)*360.0/float(numRects));
        
   	 	rec.y -= 0.4;
        A *= Rect(rec);
    }
    
    //Draw Circle and subtract 2nd circle in the middle
    float l = length(p);
   
    return max(A*smoothstep(radius, radius+5e-3, l), 
                 smoothstep(radius/10.+1e-3, radius/10., l)
               );
} 

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //current pixel position stored in p
	vec2 p = fragCoord / iResolution.y; //keeps the aspect ratio!
    
    //move scene
    p -= vec2(0.715, 0.37);
    
    //scale
    p *= 1.25;
    
    //start with background color
    fragColor = smoothstep(vec4(0,.2,.1,1),vec4(.8,.8,1,1), p.y+vec4(.5,.4,.2,0));
    
    //backup current position
    vec2 q = p;
    
    //animate
    p = Rot(p, iGlobalTime*10.0);    
    q -= vec2(0.605, 0.60);
    q = Rot(q, -iGlobalTime*10.0 - 5.0); //rotate in opposite direction
    
    float G1 = DrawGear(p, radius);
    float G2 = DrawGear(q, radius);

    //fragColor *= min(G1, G2);
    fragColor *= G1 * G2;
}