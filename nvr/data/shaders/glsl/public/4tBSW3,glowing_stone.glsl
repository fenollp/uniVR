// Shader downloaded from https://www.shadertoy.com/view/4tBSW3
// written by shadertoy user 834144373
//
// Name: Glowing Stone
// Description: move the mouse to change the color,choose the color which you like,but it's not perfect,
//    here you can get a good look:[url]http://www.glslsandbox.com/e#28740.0[/url]and[url]http://www.glslsandbox.com/e#28669.0[/url]
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//Created by 834144373  2015/11/5

float noise(vec3 p) //from Las of the "Mercury"
{
  vec3 i = floor(p);
  vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
  vec3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
  a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
  a.xy = mix(a.xz, a.yw, f.y);
  return mix(a.x, a.y, f.z);
}

#define time iGlobalTime*0.3
//..........................................................
vec3 roty(vec3 p,float angle){
  float s = sin(angle),c = cos(angle);
    mat3 rot = mat3(
      c, 0.,-s,
        0.,1., 0.,
        s, 0., c
    );
    return p*rot; 
}
//............................................................

///////////////////////////////////
//raymaching step I for normal obj
///////////////////////////////////
float obj(vec3 pos){
    pos -= vec3(0.,0.13,0.);
    float  n = noise(pos);
    // float res =  length(max(abs(pos)-vec3(0.8,0.4,0.4)-n,0.0))-0.1;
  
    float res = length(pos)-(1.- 0.3*n);
    return res;
}

//raymarching step I
//find object
float disobj(vec3 pointpos,vec3 dir){
    float dd = 1.;
    float d = 0.;
    for(int i = 0;i<30;++i){
      vec3 sphere = pointpos + dd*dir;
          d = obj(sphere);
      dd += d;
      if(d<0.02)break;
    }
    return dd;
}

//ramarching step for normal
/*
vec3 normal(vec3 surface){
  vec2 offset = vec2(0.01,0.);
    vec3 nDir = vec3(
      obj(surface+offset.xyy),
        obj(surface+offset.yxy),
        obj(surface+offset.yyx)
    ) - obj(surface);
    return normalize(nDir);
}
*/

//////raymarching step II for detail obj
/////////////////////////////////////////////////////////////
///////here is form guil https://www.shadertoy.com/view/MtX3Ws
//vec2 csqr( vec2 a )  { return vec2( a.x*a.x - a.y*a.y, 2.*a.x*a.y  ); }
float objdetal(in vec3 p) {
  	float res = 0.;
    vec3 c = p;
  	for (int i = 0; i < 10; ++i) {
        p =1.7*abs(p)/dot(p,p) -0.8;
        //p.yz= csqr(p.yz);
        p=p.zxy;
        res += exp(-20. * abs(dot(p,c)));        
  }
  return res/2.;
}
////////////////////////////////////////////////////
//raymarching step II 
vec4 objdensity(vec3 pointpos,vec3 dir,float finaldis){
  vec4 color;
    float den = 0.;
    vec3 sphere = pointpos + finaldis*dir;
    //vec3 nDir = normal(sphere);
    float dd = 0.;
    //if(dot(nDir,dir)<0.){
        for(int j = 0;j<45;++j){
            vec4 col;
            col.a = objdetal(sphere);
      
            //col.rgb = smoothstep(vec3(0.1,0.2,0.1),vec3(0.7,0.2,0.6),col.aaa);
            //col.rgb *= col.a;
            float c = col.a/200.;
            col.rgb = vec3(c,c,c*c);
            col.rgb *= col.a;
            col.rgb *= float(j)/20.;
            dd = 0.01*exp(-2.*col.a);
            //float dd = max(0.1,col.a);
            sphere += dd*dir;

            color += col*0.8;
            //if(color.a/200.>.9 || dd>200.)break;
        }
    //}
    return color*4.5;
}
/////////////////////////////////////////
/////////////////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = (fragCoord.xy / iResolution.xy-0.5)*2.;
  
    uv.x *= iResolution.x/iResolution.y;
    
    vec2 mouse = (iMouse.xy/iResolution.xy-0.5)*2.2;
    ///////////////////
    vec3 dir = normalize(vec3(uv,2.));
      dir = roty(dir,time);
    ///////////////////
    vec3 campos = vec3(0.,0.,-2.8);
      campos = roty(campos,time);
    //raymarching step I
    float finaldis = disobj(campos,dir);
    vec4 col = vec4(0.061,0.06,0.061,1.);
    if(finaldis < 40.){
      	//col.r = 1.;
        col = objdensity(campos,dir,finaldis);
        col += 0.6*col*vec4(0.7+mouse.x,0.8+mouse.y,0.5,1.);
    }
    
    fragColor = vec4(col.rgb,1.0);
}