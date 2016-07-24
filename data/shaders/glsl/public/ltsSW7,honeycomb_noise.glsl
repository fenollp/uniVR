// Shader downloaded from https://www.shadertoy.com/view/ltsSW7
// written by shadertoy user foxes
//
// Name: Honeycomb noise
// Description: an example of a Honeycomb noise, generator without sin for realization on CPU, move the mouse up and down to zoom, left and right to mix several layers.


float hash(float x){ return fract(fract(x*0.31830988618379067153776752674503)*fract(x*0.15915494309189533576888376337251)*265871.1723); }

float hash2(vec2 x) { return hash(dot(mod(x,100.0),vec2(127.1,311.7))); }

//float hash(float x) { return 0.0; }
//float hash2(vec2 x) { return 0.0; }

//float hash3(vec2 x,float anum) { return hash(dot(vec3(x,anum)+anum*0.001,vec3(127.1,311.7,0.0000001))); }

/*float noiseHoneycomb(vec2 i) {
    vec2 c3;
    i.x*=1.1547005383792515290182975610039;
    c3.x=ceil(i.x);
    vec2 b=vec2(i.y+i.x*0.5,i.y-i.x*0.5);
    c3.y=ceil(b.x)+ceil(b.y);
    vec3 o=fract(vec3(i.x,b.xy));
    
    vec4 s;
    vec3 m1=vec3(hash3(c3+vec2(1.0,0.0),anim),hash3(c3+vec2(-1.0,-1.0),anim),hash3(c3+vec2(-1.0,1.0),anim));
    vec3 m2=vec3(hash3(c3,anim),hash3(c3+vec2(0.0,1.0),anim),hash3(c3+vec2(0.0,-1.0),anim));
    vec3 m3=vec3(hash3(c3+vec2(-1.0,0.0),anim),hash3(c3+vec2(1.0,1.0),anim),hash3(c3+vec2(1.0,-1.0),anim));
    vec3 m4=vec3(m2.x,m2.z,m2.y);
    
    vec3 w1=vec3(o.x,(1.0-o.y),o.z);
    vec3 w2=vec3((1.0-o.x),o.y,(1.0-o.z));

    vec2 d=fract(c3*0.5)*2.0;
    
    s=fract(vec4(dot(m1,w1),dot(m2,w2),dot(m3,w2),dot(m4,w1)));
      
    return fract(mix(mix(s.z,s.w,d.x),mix(s.x,s.y,d.x),d.y));
}*/

float noiseHoneycomb(vec2 i) {
    vec2 c3;
    i.x*=1.1547005383792515290182975610039;
    c3.x=ceil(i.x);
    vec2 b=vec2(i.y+i.x*0.5,i.y-i.x*0.5);
    c3.y=ceil(b.x)+ceil(b.y);
    vec3 o=fract(vec3(i.x,b.xy));
    
    vec4 s;
    vec3 m1=vec3(hash2(c3+vec2(1.0,0.0)),hash2(c3+vec2(-1.0,-1.0)),hash2(c3+vec2(-1.0,1.0)));
    vec3 m2=vec3(hash2(c3),hash2(c3+vec2(0.0,1.0)),hash2(c3+vec2(0.0,-1.0)));
    vec3 m3=vec3(hash2(c3+vec2(-1.0,0.0)),hash2(c3+vec2(1.0,1.0)),hash2(c3+vec2(1.0,-1.0)));
    vec3 m4=vec3(m2.x,m2.z,m2.y);
    
    vec3 w1=vec3(o.x,(1.0-o.y),o.z);
    vec3 w2=vec3((1.0-o.x),o.y,(1.0-o.z));

    vec2 d=fract(c3*0.5)*2.0;
    
    s=fract(vec4(dot(m1,w1),dot(m2,w2),dot(m3,w2),dot(m4,w1)));
      
    return fract(mix(mix(s.z,s.w,d.x),mix(s.x,s.y,d.x),d.y));//hash2(c3);
}

void mainImage(out vec4 o, vec2 uv)
{
	uv=uv/iResolution.y/.1;
    
    float mx = iMouse.x>0.0?iMouse.x/iResolution.x:0.5;
    float my = iMouse.y>0.0?iMouse.y/iResolution.y:0.5;
    
    float time=iGlobalTime*5.0;
    
    vec2 i=(uv-vec2(9.0,5.0))*my*10.0+vec2(time,time*0.5);
    
    if (uv.x<mx*17.8)
        o.xyz=vec3(noiseHoneycomb(i));
    if (uv.x>=mx*17.8) {
        o.xyz=vec3(noiseHoneycomb(i)*0.3+noiseHoneycomb(i*6.0)*0.25+noiseHoneycomb(i*16.0)*0.2+noiseHoneycomb(i*32.0)*0.2);
        o.xyz=o.xyz*0.7+noiseHoneycomb(i*0.25)*0.2;
    }
}
