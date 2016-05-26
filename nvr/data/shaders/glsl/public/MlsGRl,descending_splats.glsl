// Shader downloaded from https://www.shadertoy.com/view/MlsGRl
// written by shadertoy user eiffie
//
// Name: Descending Splats
// Description: Choose a few random splats and reposition them in front of the ray using gradient descent. The idea seems sound - the implementation not so much.
//Descending Splats by eiffie

//more splats will give better coverage near intersections
#define SPLATS 10
//more "gradient descent" steps fill in the surfaces
#define DESCENT 10

//total map calls = SPLATS x DESCENT x 3

//if you want to watch the descent
#define WATCH

float SphereD(vec3 po, vec3 rd){
	float b=dot(po,rd);
	return sqrt(abs(dot(po,po)-b*b));
}

vec3 sphere( in vec2 t )
{
     vec2 q = vec2( t.x*3.1416, acos(t.y) );
     return vec3( cos(q.x)*sin(q.y), t.y, sin(q.x)*sin(q.y) );
}
vec3 cylinder( in vec2 t )
{
    float q = t.x*3.1416;
    return vec3( 0.5*cos(q), t.y, 0.5*sin(q) );
}
vec3 quad( in vec2 t )
{
    return vec3( t.x, 0.0, t.y );
}

float DE(in vec2 t, in vec3 ro, in vec3 rd){
	vec3 s=sphere(t),c=cylinder(t)+vec3(2.0,0.0,0.0),q=2.0*quad(t)+vec3(0.75,-1.0,0.0);
	return min(SphereD(s-ro,rd),min(SphereD(c-ro,rd),SphereD(q-ro,rd)));
}
vec2 rnd2(vec2 c){
	return vec2(fract(sin(c.x+c.y+c.x*c.y)*415.231),fract(sin(c.x-c.y-c.x*c.x+c.y*c.y)*113.2537))*2.0-1.0;
}

mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec3 ro=vec3(sin(iGlobalTime)*5.0,1.0+sin(iGlobalTime*0.7)*0.75,cos(iGlobalTime)*5.0);
	vec3 rd=lookat(vec3(1.0,0.0,0.0)-ro)*normalize(vec3((2.0*fragCoord.xy-iResolution.xy)/iResolution.y,2.0));
	//ro=eye;rd=normalize(dir);
	float d=100.0;
  for(int j=0;j<SPLATS;j++){
      float fj=float(j);
	vec2 t=rnd2(fragCoord.xy+vec2(fj,fj*3.1))*0.8,dt=rnd2(fragCoord.yx+vec2(fj*1.3,fj*5.1))*0.05,ff=vec2(0.43);
#ifdef WATCH
	t=rnd2(vec2(fj,fj*3.1))*0.8;dt=rnd2(vec2(fj*1.3,fj*5.1))*0.05;ff=vec2(0.43);
#endif

	/*float d1=DE(t,ro,rd),d2;
	for(int i=0;i<DESCENT;i++){
		t.x+=dt.x;
		t.x=clamp(t.x,-1.0,1.0);
		d2=DE(t,ro,rd);
		d=min(d,d2);
		float g=clamp(dt.x/(d1-d2),-1.0,1.0);
		dt.x=ff.x*g*d2;
		d1=d2;
		t.y+=dt.y;
		t.y=clamp(t.y,-1.0,1.0);
		d2=DE(t,ro,rd);
		d=min(d,d2);
		g=clamp(dt.y/(d1-d2),-1.0,1.0);
		dt.y=ff.y*g*d2;
		d1=d2;
	}*/
      for(int i=0;i<DESCENT;i++){//a more legit descent but uses more DE checks
            float d1=DE(t,ro,rd);
            d=min(d,d1);
            vec2 d2=vec2(DE(t+vec2(dt.x,0.0),ro,rd),DE(t+vec2(0.0,dt.y),ro,rd));
            dt=ff*log(d2+1.0)*clamp(dt/(vec2(d1)-d2),-1.0,1.0);
            t=clamp(t+dt,-1.0,1.0);
      }
  }
	d=smoothstep(0.0,0.1,d);
	vec3 col=vec3(sqrt(d),d*d,d);
	fragColor = vec4(col,1.0);
}
