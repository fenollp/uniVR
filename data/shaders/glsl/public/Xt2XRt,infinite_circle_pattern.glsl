// Shader downloaded from https://www.shadertoy.com/view/Xt2XRt
// written by shadertoy user erkaman
//
// Name: infinite circle pattern
// Description: a simple circle pattern.
// Created by Eric Arnebäck - erkaman/2015
// This work is licensed under a 
// Creative Commons Attribution 4.0 International License

/*
This simple shader draws a circular pattern.
*/

#define R 0.1
#define r 0.00005


float rand(float co){
    return fract(sin(dot(vec2(co ,co ) ,vec2(12.9898,78.233))) * 43758.5453);
}

int rand_range_int(float seed, float low, float high) {
	return int(low + (high - low) * rand(seed));
}

// set union.
float un(float c1, float c2) {
    return min(c1,c2);
    
}

float circleNE(vec2 q, vec2 pos ) {
    vec2 p = q - pos;
    
    if(p.x > 0.0 && p.y > 0.0) {
        return pow(R - sqrt(p.x*p.x + p.y*p.y ), 2.0) - r;
    } else {
        return 10.0;
    }
}

float circleNW(vec2 q, vec2 pos ) {
    vec2 p = q - pos;
    
    if(p.x < 0.0 && p.y > 0.0) {
        return pow(R - sqrt(p.x*p.x + p.y*p.y ), 2.0) - r;
    } else {
        return 10.0;
    }
}

float circleSW(vec2 q, vec2 pos ) {
    vec2 p = q - pos;
    
    if(p.x < 0.0 && p.y < 0.0) {
        return pow(R - sqrt(p.x*p.x + p.y*p.y ), 2.0) - r;
    } else {
        return 10.0;
    }
}

float circleSE(vec2 q, vec2 pos ) {
    vec2 p = q - pos;
    
    if(p.x > 0.0 && p.y < 0.0) {
        return pow(R - sqrt(p.x*p.x + p.y*p.y ), 2.0) - r;
    } else {
        return 10.0;
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;
    
    // make all coordinates positive. This simplifies things a lot. 
    p += vec2(0.5);
    
   
    p += iGlobalTime * vec2(0.2) + 0.45*sin(1.0*iGlobalTime) * vec2(-0.2, 0.2);

    
    p.x *= iResolution.x/iResolution.y;
  
    vec3 col = vec3(0.0,0.0,0.0); // black background color. 

    vec2 q = p - vec2(0.5,0.5);
   
    float c1;
    float c2;
    
    
    // the pattern is created by first laying out lots of 
    // 2D toruses in a grid formation, thus creating a very regular
    // pattern. 
    // Segments are then  randomly  removed from the toruses to create the
    // pattern seen on the screen.
    
    vec2 grid = vec2( int(q.x/(2.0*(R+r))),int(q.y/(2.0*(R+r))));
    
    
    vec2 cp = vec2(grid*(2.0*(R+r)) + (R+r));   //  vec2(-0.2,0.0);
     
    c1 = 1.0;
    
    // every torus consists of four segments.
    // NE = North east
    // NW = North west
    // SW = south west
    // SE = south east.
    c2 = circleNE(q, cp);
    c1 = un(c1, c2);
           
    c2 = circleNW(q, cp);             
    c1 = un(c1, c2);
       
    c2 = circleSW(q, cp);           
    c1 = un(c1, c2);   
    
    c2 = circleSE(q, cp);            
    c1 = un(c1, c2);
      
    
    if(mod(grid.x, 
           float(rand_range_int((grid.x+grid.y)*2.32, 1.0, 4.0))) != 0.0 ) {
    
    c2 = circleSW(q, cp +vec2(R,R));             
    c1 = un(c1, c2);
    }
    
    if(mod(grid.x+grid.y, 
           float(rand_range_int((grid.x+grid.y)*2.32, 5.0, 10.0))) != 0.0 ) {
    
    c2 = circleNW(q, cp +vec2(R,-R));            
    c1 = un(c1, c2); 
    }

    
    if(mod(grid.y, 
           float(rand_range_int((grid.x+grid.y)*32.113212, 3.0, 8.0))) != 0.0 ) {
    
    c2 = circleNE(q, cp +vec2(-R,-R));            
    c1 = un(c1, c2);
    }
        
    
    if(mod(grid.y+grid.x, 
           float(rand_range_int((grid.x+grid.y)*131.113212, 1.0, 4.0))) != 0.0 ) {
    
    c2 = circleSE(q, cp +vec2(-R,R));            
    c1 = un(c1, c2);
    }

   
    float res = smoothstep(0.00009, 0.0,c1  );
   
    // noise texture over torus. 
    col += texture2D(iChannel0, p * 0.9).rrr * res;
    
    
    fragColor = vec4(col,1.0);
    
}