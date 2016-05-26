// Shader downloaded from https://www.shadertoy.com/view/lsXGzM
// written by shadertoy user weyland
//
// Name: Auralights
// Description: Very simple and fast shader I did for an android app
float speed=4.;

float blob(float x,float y,float fx,float fy){
   float xx = x+sin(iGlobalTime*fx/speed)*.7;
   float yy = y+cos(iGlobalTime*fy/speed)*.7;

   return 20.0/sqrt(xx*xx+yy*yy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
   vec2 position = ( fragCoord.xy / iResolution.xy )-0.5;

   float x = position.x*2.0;
   float y = position.y*2.0;

   float a = blob(x,y,3.3,3.2) + blob(x,y,3.9,3.0);
   float b = blob(x,y,3.2,2.9) + blob(x,y,2.7,2.7);
   float c = blob(x,y,2.4,3.3) + blob(x,y,2.8,2.3);
   
   vec3 d = vec3(a,b,c)/60.0;
   
   fragColor = vec4(d.x,d.y,d.z,1.0);
}