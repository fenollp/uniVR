// Shader downloaded from https://www.shadertoy.com/view/lsVXWz
// written by shadertoy user juhler1
//
// Name: compressed 6400%
// Description: video resolution pixelated to 90x160 buffer A
//    and image blended
void mainImage( out vec4 oc, in vec2 fc )
{ vec2 g = fc.xy / iResolution.xy;
// set 90 160 size of buffer A
 float h=90.0;float w=160.0;int p=0;// change p=1 to see pixeulated buffer A
 float fw=(1.0/w);float fh=(1.0/h);
 float x=floor(g.x*w)/w; float y=floor(g.y*h)/h;
 float px=fract(g.x*w);float py=fract(g.y*h);
 float nx=1.0-px;float ny=1.0-py;
 // working with buffer A (1/16 of data) blending
   vec4 a = texture2D(iChannel1,vec2(x+(fw*0.5),y+(fh*1.5)))*nx*py;
   vec4 b = texture2D(iChannel1,vec2(x+(fw*0.5),y+(fh*0.5)))*nx*ny;
   vec4 c = texture2D(iChannel1,vec2(x+(fw*1.5),y+(fh*1.5)))*px*py;
   vec4 d = texture2D(iChannel1,vec2(x+(fw*1.5),y+(fh*0.5)))*px*ny;
 oc=a+b+c+d;
 if (p==1){oc= texture2D(iChannel1,vec2(x+(fw*0.5),y+(fh*0.5)));}
 }