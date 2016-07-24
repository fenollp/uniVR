// Shader downloaded from https://www.shadertoy.com/view/Xt2SDc
// written by shadertoy user 834144373
//
// Name: Everything Glowing II
// Description: the tutorial for young coder and students to easy undersand.
//    here you see a good effect : http://www.glslsandbox.com/e#28742.0
//    move the mouse to change the color
//Everythng Glowing.glsl
//License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//Created by 834144373  2015/11/8
///////////////////////////////////////////////////////////////////////////////////////
vec3 roty(vec3 p,float angle){
  float s = sin(angle),c = cos(angle);
    mat3 rot = mat3(
      c, 0.,-s,
        0.,1., 0.,
        s, 0., c
    );
    return p*rot; 
}
///////////////////////////////////
//raymaching step I for normal obj
///////////////////////////////////
float obj(vec3 pos){
    pos -= vec3(0.,-.6,0.);
    //here you can see "inigo quilez's particles about the distance field function" who's id named "iq"....
    float res =  length(max(abs(pos)-vec3(0.8,0.2,0.35),0.0))-0.1;
	res = min(res,length(abs(pos-vec3(0.,0.7,0.))-vec3(0.7,0.4,0.4))-.3);
    return res;
}

//raymarching step I
//find object
float disobj(vec3 pointpos,vec3 dir){
    float dd = 1.;
    float d = 0.;
    for(int i = 0;i<45;++i){
      vec3 sphere = pointpos + dd*dir;
          d = obj(sphere);
      dd += d;
	if(d<0.02)break;
    }
    return dd;
}

//////raymarching step II for detail obj
/////////////////////////////////////////////////////////////
//Inspired form guil https://www.shadertoy.com/view/MtX3Ws
//and I changed something
float objdetal(in vec3 p) {
  	float res = 0.;
    vec3 c = p;
  	for (int i = 0; i < 10; ++i) {
        p =1.7*abs(p)/dot(p,p) -0.8;
        p=p.zxy;
        res += exp(-20. * abs(dot(p,c)));        
  }
  return res/2.;
}
////////////////////////////////////////////////////
//raymarching step II 
//raymarching  inside of the objects
//and sample the "density"="min distance" with the raymarching
vec4 objdensity(vec3 pointpos,vec3 dir,float finaldis){
  vec4 color=vec4(0.);
    float den = 0.;
    vec3 sphere = pointpos + finaldis*dir;
    float dd = 0.;
    for(int j = 0;j<45;++j){
        vec4 col;
        col.a = objdetal(sphere);
        float c = col.a/200.;
        col.rgb = vec3(c,c,c*c);
        col.rgb *= col.a;
        col.rgb *= float(j)/20.;
        dd = 0.01*exp(-2.*col.a);
        sphere += dd*dir;
        color += col*0.8;
        if(color.a/200.>.9 || dd>200.)break;
    }
    return color*4.5;
}
/////////////////////////////////////////
/////////////////////////////////////////
#define time iGlobalTime*0.3
void mainImage(out vec4 color,in vec2 PixelUV)
{
    vec2 uv = (PixelUV.xy / iResolution.xy-0.5)*2.;
         uv.x *= iResolution.x/iResolution.y;
    vec2 Mo = iMouse.xy/iResolution.xy;
		 Mo = (vec2(1.-Mo.x,Mo.y)-0.5)*2.2;
    ///////////////////
    vec3 dir = normalize(vec3(uv,2.));
         dir = roty(dir,time);
    ///////////////////
    vec3 campos = vec3(0.,0.,-2.8);
         campos = roty(campos,time);
    //raymarching step I
    float finaldis = disobj(campos,dir);
    vec4 col = vec4(0.061,0.06,0.061,1.);
    if(finaldis < 20.){
        //raymarching step II
        //raymarching in raymarching, no raymarching and raymarching
        col = objdensity(campos,dir,finaldis);
        col += 0.6*col*vec4(0.7+Mo.x,0.8+Mo.y,0.5,1.);
    }
    color = vec4(col.rgb,1.0);
}