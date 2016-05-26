// Shader downloaded from https://www.shadertoy.com/view/Xt2SRh
// written by shadertoy user yibojiang
//
// Name: Black Pearl
// Description: Practice ray tracing.
#define pi 3.1415926
#define intense 1.0
#define rotspeed 0.5
vec3 lightDir=vec3(0.0,-3.0,2.0);
vec3 ambCol=.5*vec3(0.1,0.1,0.1);
vec3 sphereCol=vec3(1.0,1.,1.0);
vec3 spherePos=vec3(0.0, 0.1,0.0 );

vec3 cylinderCol=vec3(0.1,0.1,0.1);
vec3 cylinderPos=vec3(0.3,0.1,0.1);
vec3 cylinderDir=normalize(vec3(0.1,0.0,-0.1) );
float cylinderHeight=0.1;
vec3 eye=vec3(0.,.3,-1.0) ;

vec2 noise(vec2 tc){
    return (2.*texture2D(iChannel1, tc).xy-1.).xy;
}

vec4 tex(vec2 tc){
 	return texture2D(iChannel0, tc,2.);
}

vec4 tex2(vec2 tc){
 	return texture2D(iChannel1, tc,2.);
}


vec4 texCube(vec3 tc){
 	return textureCube(iChannel2,tc);
}

float intersectCylinder(inout vec3 color,in vec3 col,in vec3 eye,in vec3 ray,in vec3 p,in vec3 ndir,in float radius,in float height){
	float k=0.;
    vec3 hit=vec3(0.);

    //radius=0.1*length(dot(ray,ndir) *ray);
    
    k=-dot(eye-p-height*ndir,ndir)/dot(ray,ndir);
    //k=(p.y+height-eye.y)/ray.y;
    hit=eye+k*ray;
    if (k>=0.){
        vec3 rr=hit-p-ndir*height;
        if ( length(rr)<  radius){
            vec3 normal=ndir;
            vec3 l=normalize(lightDir);
            vec3 v=normalize(ray);
            vec3 n=normalize(normal );
            vec3 r=reflect( v , n );
            vec3 refr=refract(v,n,1.1);
            float diffuse=max( dot (n , -l ),0. );
            float spec=3.* pow( max(dot(l,-r),0. ), 50. );
            vec3 cr=texCube(r).xyz;
            
            //col=mix(vec3(1.),vec3(0.) ,length(rr)/r );
            //vec3 c=mix(vec3(1.),vec3(0.) ,length(rr)/radius );
            vec3 c=vec3(1.)*step(length(rr/radius),0.8 );
            //c=vec3(0.9);
            color=intense*(c*diffuse + c*spec + ambCol );
			color=c;
	        return k;
        }
    }
    


    vec3 aa=ray- dot( ray , ndir ) * ndir ;
    float a=dot( aa  , aa   );
    vec3 deltaP = eye - p;
    float b= 2.0 * dot ( ray - dot( ray, ndir ) * ndir , deltaP - dot (deltaP , ndir) *ndir );
    vec3 cc=deltaP - dot( deltaP,ndir)*ndir;
    float c=dot(cc,cc)-radius*radius;
    float delta=b*b-4.0*a*c;

    if (delta>=0.){
        k=(-b-sqrt(delta) )/(2.0*a);
        if (k<0.){
         	k= (-b+sqrt(delta) )/(2.0*a);
        }
        
        if (k>=0.){
            vec3 hit=eye+k*ray;
            vec3 q=hit-p;
            float dotQ=dot(q,q);
            if ( dotQ<height*height+radius*radius && dotQ>=0. && dot(q,ndir)>0. ){
                vec3 q=hit-p;
                vec3 normal=q-dot(q,ndir)*q;
				vec3 l=normalize(lightDir);
                vec3 v=normalize(ray);
                vec3 n=normalize(normal );
                vec3 r=reflect( v , n );
                vec3 refr=refract(v,n,1.1);
                float diffuse=max( dot (n , -l ),0. );
                float spec=3.* pow( max(dot(l,-r),0. ), 50. );
                vec3 cr=texCube(r).xyz;
                color=intense*(col*diffuse + c*spec + ambCol );
                //color=vec3(n);
                return k;
           }
        }
        
    }
    
    
    k=-dot(eye-p,ndir)/dot(ray,ndir);
    hit=eye+k*ray;
    if (k>=0.){
        vec3 rr=hit-p;
        if ( length(rr)<  radius){
            vec3 normal=ndir;
            vec3 l=normalize(lightDir);
            vec3 v=normalize(ray);
            vec3 n=normalize(normal );
            vec3 r=reflect( v , n );
            vec3 refr=refract(v,n,1.1);
            float diffuse=max( dot (n , -l ),0. );
            float spec=3.* pow( max(dot(l,-r),0. ), 50. );
            vec3 cr=texCube(r).xyz;
            color=intense*(col*diffuse + c*spec + ambCol );
	        return k;
        }
    }
    
   

    return k;
}

float intersectSphere(inout vec3 color,in vec3 col,in vec3 eye,in vec3 ray,in vec3 p,in float r){
	float k=0.;
  	vec3 c=p-eye;
	float rc=dot(ray,c);

    float delta=rc*rc +r*r -dot(c,c );
    if (delta>=0.){
      	k=rc - sqrt(delta);
        if (k<0.){
         	k=rc + sqrt(delta);   
        }
        
        if (k>=0.){
           	vec3 hit=eye+k*ray;
            vec3 normal=hit-p;
            vec3 l=normalize(lightDir-p);
            vec3 v=normalize(ray);
            vec3 n=normalize(normal );
            
            vec3 r=reflect( v , n );
            vec3 refr=refract(v,n,1.1);

			
            float diffuse=max( dot (n , -l ),0. );
            float refrac= 1.0* max( dot(v,refr),0. );
            float spec=3.* pow( max(dot(l,-r),0. ), 50. );
            //float spec=2.* pow( max(dot(-h,n),0. ), 4. );
            float fre =1.7* pow(0.01+ clamp( dot(r,v),0.0,1.0), 3. );
			//float fre =1.0* pow(0.5+ clamp(dot(-refr,v),0.0,1.0), 1.0 );
	        vec3 frecol = texCube(r).rgb ;
            
            vec3 c=col;
            //c=tex2( vec2(normal.x,normal.y) ).xyz;
            //vec3 cr=texCube(r).xyz;

            vec3 crf=texCube(refr).xyz;
			
            //From Shane
            vec3 bgCol = color;
            color = intense*(frecol * fre+ c*spec + ambCol );
            float edge = smoothstep(0., .2, dot(-ray, n));
            color= mix(bgCol, color, edge);
            
			//color=intense*(frecol * fre+ c*spec  +  ambCol );	
            return k;
        }
        
    }

    
    return 0.;

}

float intersectPlane(inout vec3 color,in vec3 col,in vec3 eye,in vec3 ray,in vec3 p,in vec3 normal){
	float k=0.;
    k=-dot(eye,normal)/dot(ray,normal);
    if (k>0.){

        vec3 hit=eye+k*ray;
        
        vec3 n=normalize(normal);
        //vec3 n1=2.*texture2D(iChannel1, vec2( hit.x,hit.z),.9).xyz;
       // n=tex(1.0*vec2( hit.x,hit.z)).xyz;
        vec3 v=normalize(ray);
        vec3 l=normalize(lightDir);

        float fade=smoothstep(0.0,1.0, k/2.5 );
        vec3 c=vec3(0.);
        c=col*fade;
        //c=col;
        //c=1.0*tex(1.0*vec2( hit.x,hit.z)).xyz;
        //c=0.2*texCube( vec3(hit.x*1.,hit.z*1.,-1.0) ).xyz;
        float diffuse= max(dot(n , -l ),0. );
        vec3 r=reflect(v,n );
		

        //r=-l+v;
        float spec=1.* pow( max(dot(l,-r),1. ), 9. );

        vec3 refcol=vec3(0.);
        intersectSphere(refcol, sphereCol,hit ,r, spherePos,.1 );
       
        vec3 shadowCol=vec3(1.0);
        float shadow=1.0-intersectSphere(shadowCol, vec3(0.4),hit ,-l, spherePos,.1 );
        //shadowCol=clamp(shadowCol, vec3(0.),vec3(1.) );
        //shadowCol=clamp(sign(shadowCol-vec3(0.99)),vec3(0.),vec3(1.) );
        //color=(intense*(c* diffuse +intense*2.*ambCol*fade+ intense*0.2*refcol) )* shadowCol  ;
        color=intense*(c* diffuse + ambCol +0.0*spec*c + 0.2*refcol)*shadow ;
        //color=vec3(1.,1.,1.)*v;
        //color=refcol;
        return k;
     
    }
        
    return 0.;
}

mat3 rotate(float rx,float ry,float rz){
	mat3 rtx=mat3(
        1.,0.,0.,
        0.,cos(rx) , -sin(rx),
        0.,sin(rx),cos(rx) );  
    mat3 rtz=mat3( 
        cos(rz) , -sin(rz),0.,
        sin(rz),cos(rz),0.,
        0.,0.,1.);
    mat3 rty=mat3( 
        cos(ry),0. , sin(ry),
        0.0,1.0,0.0,
        -sin(ry),0.,cos(ry) );
    return rtx*rty*rtz;
}

mat4 move(float mx,float my,float mz){
    return mat4(
        1.,0.,0.,mx,
    	0.,1.,0.,my,
        0.,0.,1.,mz,
        0.,0.,0.,1.
    );  
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
    vec2 uv=p-vec2(0.5,0.5);
    

    uv.y*= iResolution.y/iResolution.x;
    vec2 q=uv;
    vec3 color=vec3(1.0);
    


    float ligthrt=iGlobalTime;
	ligthrt=0.;
	mat3 rtl=rotate(0.,ligthrt,0.);
    
    float rt=pi*.4-iGlobalTime*rotspeed;
	//rt=0.0;
    float rtx=abs(sin(iGlobalTime*rotspeed) );

    rtx=pi*.0;
    rtx=0.25;
    if (iMouse.z>0.){
    	rt=iMouse.x*0.01-pi*.5;
        //rtx=iMouse.y*0.01-pi*.5;
    }
    
	
    vec4 eyepos=vec4(eye.xyz,1.0);
    //eyepos*=move( 0.,sin(rtx),1.0-cos(rtx) );
    eyepos*=move( sin(-rt) ,0., 1.0-cos(-rt) );

	lightDir*=rtl;
    eye=eyepos.xyz;
    
    
    vec3 ray= normalize(vec3(q.x,q.y,1.3) );
    ray*=rotate(rtx,0.,0.);
    ray*=rotate(0.,rt,0.);
    

    
    //vec3 ww = ray;
    //vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    //vec3 vv = normalize( cross(uu,ww));
    //vec3 rd = normalize( q.x*uu + q.y*vv + 4.0*ww );
    //color = textureCube(iChannel2, rd).rgb;



    //spherePos=vec3(0.0, 0.1,0.0 );    
    //spherePos.x=0.+.2*cos(iGlobalTime*1.);
    //spherePos.z=1.0+.2*sin(iGlobalTime*1.);
    //spherePos.y=0.1+abs(0.1*sin(iGlobalTime*3.) );
    
    intersectPlane(color,vec3(.2),eye,ray,vec3(.0,0.0,.0), vec3(0.,1.0,0.) );    
    //intersectCylinder(color, cylinderCol  ,eye,ray, cylinderPos,cylinderDir,.1 ,cylinderHeight );
    intersectSphere(color, sphereCol ,eye ,ray, spherePos,.1 );
	fragColor = vec4(color,1.0);
}