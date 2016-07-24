// Shader downloaded from https://www.shadertoy.com/view/MlSSWV
// written by shadertoy user yibojiang
//
// Name: Lovely Stars
// Description: lovely star inspired by Little Prince
#define pi 3.14159
const float indent = 0.06;
float angular=5.;

float hash( float n )
{
	return fract( (1.0 + cos(n)) * 415.92653);
}

float noise2d( in vec2 x )
{
    float xhash = hash( x.x * 37.0 );
    float yhash = hash( x.y * 57.0 );
    return fract( xhash + yhash );
}

//steal from https://www.shadertoy.com/view/4tfGWr
float drawStar(vec2 o,float size,float startAngle){
    vec2 q=o;
    q*=normalize(iResolution).xy;
//    float startAngle = -iGlobalTime / size*0.001;
   //float startAngle=size*1000.;
   
    mat4 RotationMatrix = mat4( cos( startAngle ), -sin( startAngle ), 0.0, 0.0,
			    sin( startAngle ),  cos( startAngle ), 0.0, 0.0,
			             0.0,           0.0, 1.0, 0.0,
				     0.0,           0.0, 0.0, 1.0 );    
	q = (RotationMatrix * vec4(q, 0.0, 1.0)).xy;
    
	float angle=atan( q.y,q.x )/(2.*pi);
	

    float segment = angle * angular;
    
    
    float segmentI = floor(segment);
    float segmentF = fract(segment);
        
    angle = (segmentI + 0.5) / angular;
    
    if (segmentF > 0.5) {

        angle -= indent;
    } else
    {

        angle += indent;
    }
    angle *= 2.0 * pi;

    vec2 outline;
	outline.y = sin(angle);
    outline.x = cos(angle);
    
	float dist = abs(dot(outline, q));
    
    float ss=size*(1.+0.2*sin(iGlobalTime*hash(size)*20. ) );
    float r=angular*ss;
	
    
    
    float star=smoothstep( r, r+0.005, dist );
    
    
    return star;
}

float drawFlare(vec2 o,float size){
    o*=normalize(iResolution).xy;
    float flare=smoothstep(0.0,size,length(o) );
    return flare;
}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    

    vec3 color=mix(vec3(0.), vec3(0.1,0.2,0.4), uv.y );
    float fThreshhold = 0.995;
    float StarVal = noise2d( uv );
    if ( StarVal >= fThreshhold )
    {
        StarVal = pow( (StarVal - fThreshhold)/(1.0 - fThreshhold), 6.0 );

		color += vec3( StarVal );
    }

    for (int ii=0;ii<100;ii++){
   		float i=float(ii);
		float t0=i*0.1;
        
        if (iGlobalTime>t0){
            float t=mod(iGlobalTime-t0,5.5) ;
	        float size=1.+3.0*hash(i*10.);// sin(1.*t+(hash(i*10.)-0.5)*pi ) ;
			//size=mix(4.0,0.0,t/5.5);
  //          size=0.;
            
            vec2 pos=uv-vec2( 0.5+0.25*(hash(i)-0.5)*t ,
                  		0.0+(0.5 +0.5*hash(i+1.) )*t- .2*t*t ) ;
			
            color+=mix(vec3(0.05,0.05,0.),vec3(.0),drawFlare(pos,0.05*size) );
            
    		color=mix( vec3(0.9+hash(i),0.9,0.0),color ,
                  drawStar(pos,0.0005*size, pi*hash(i+1.) ) );    
            
        }
    }
    /*
    color=mix( vec3(0.9,0.9,0.0),color ,drawStar(uv-vec2(0.2 ,0.7),0.0005 ) );
    color=mix( vec3(0.9,0.9,0.0),color ,drawStar(uv-vec2(0.3 ,0.65),0.001 ) );    
    color=mix( vec3(0.9,0.7,0.0),color ,drawStar(uv-vec2(0.4 ,0.75),0.0015 ) );
    color=mix( vec3(0.9,0.7,0.0),color ,drawStar(uv-vec2(0.5 ,0.5),0.001 ) );
    color=mix( vec3(0.9,0.8,0.0),color ,drawStar(uv-vec2(0.6 ,0.66),0.002 ) );
    color=mix( vec3(0.9,0.9,0.0),color ,drawStar(uv-vec2(0.7 ,0.55),0.0012 ) );
    color=mix( vec3(0.9,0.9,0.0),color ,drawStar(uv-vec2(0.8 ,0.65),0.0008 ) );
*/
    fragColor = vec4( color,1.0);
	//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}