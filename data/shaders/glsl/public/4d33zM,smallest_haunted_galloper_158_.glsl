// Shader downloaded from https://www.shadertoy.com/view/4d33zM
// written by shadertoy user 834144373
//
// Name: Smallest Haunted Galloper(158)
// Description: Can you compress it or make it smallest?Ok let us challenge it! The smallest is winner. Codegolf.
//    Rules : you can change all the code and the scale and position,but make it similar to the original appearance.:)

void mainImage( out vec4 o, vec2 i ) {
    i.x*=.8;
    float L=length(i=i/iResolution.xy*.5-.25);
    
    o = texture2D(iChannel0,.75 + 3.*i - i/L/.89 -.6*iDate.wx);
    o += o -= sqrt(L)*(o+.7); 
}

//the newsmallest version is 154 chars now!
//And the version and the shader is belong to coyote! Cheers!:)
//-----------------------------------------------------
/*
void mainImage( out vec4 o, vec2 i ) {
    i.x*=.8;
    float L=length(i=i/iResolution.xy*.5-.25);
    
    o = texture2D(iChannel0,.75 + 3.*i-i/L-.6*iDate.wx); 
    o += o -= sqrt(L)*(o+.7); 
}
*/
//------------------------------------------------------

/*
//the newsmallest version is 170 chars !
void mainImage( out vec4 o, vec2 i ) {
    i.x*=.8;
    float L=length(i=i/iResolution.xy*.5-.25);
    
    //to reduce 1 char to 171 by coyote
    o = texture2D(iChannel0,.8 - smoothstep(.3,0.,L)*i/L-.6*iDate.wx-i); //coyote
    o += o -= sqrt(L)*(o+.7);   //coyote
    ***
		o = 2.*texture2D(iChannel0,.75 - i/L * smoothstep(.3,0.,L)-.6*iDate.wx-i);//-4 chars to 174 by FabriceNeyret2
		o -= sqrt(L)*(o+1.4);// by FabriceNeyret2
    ***
}
*/


/*
    //the new smallest is 172 chars
    void mainImage( out vec4 o, vec2 i ) {

        //i/=iResolution.xy/.5; 
        i.x*=.8;

        float L=length(i=i/iResolution.xy*.5-.25); //-2 to 172 by coyote.

        //float L=length(i-=.25);    //-1 by coyote again.

        o = 2.*texture2D(iChannel0,.75 - i/L * smoothstep(.3,0.,L)-.6*iDate.wx-i);//-4 chars to 174 by FabriceNeyret2
        //o = 2.*texture2D(iChannel0,.75-i/L * smoothstep(.2,-.1,L-.1)-.6*iDate.wx-i);//178 by coyote
     **    
        float L=length(i-.25);
        o = 2.*texture2D(iChannel0,( .25-i)/L * smoothstep(.2,-.1,L-.1)-.6*iDate.wx-i);
     **    
        o -= sqrt(L)*(o+1.4);// by FabriceNeyret2

    }
*/


//another 179 chars version by FabriceNeyret2
/*
void mainImage( out vec4 o, vec2 i ) {
    
    i /= iResolution.xy*2.;

    float  L= length(i-.25);

    i += (i-.25)/L * smoothstep(.2,-.1,L-.1);
    i.x += .6*iDate.w;
	
    o = 2.*texture2D(iChannel0,-i); o -= sqrt(L)*(o+1.4);
}
*/

//the new 183 chars version!
/*
void mainImage( out vec4 o, vec2 i ) {
    
    i/=iResolution.xy/.5;
    i.x*=.8;

    float L=length(i-.25);
	
    
    i += (i-.25)/L * smoothstep(.2,-.1,L-.1)+.6*iDate.wx; //coyote to 183 chars
    
    //i += (i-.25)/L * smoothstep(.2,-.1,L-.1);
    //i.x += .6*iDate.w;//FabriceNeyret2
    //i.x += .6*iGlobalTime; 
	
    o = 2.*texture2D(iChannel0,-i); o -= sqrt(L)*(o+1.4); //FabriceNeyret2 to 187 chars
    //o = 2.*mix(texture2D(iChannel0,-i),vec4(-.7),sqrt(L)); //FabriceNeyret2
    //o = mix(texture2D(iChannel0,-i),vec4(-.7),sqrt(L));
    //o += o;
}
*/

//the 197 chars version from coyote.
/*
void mainImage( out vec4 o, vec2 i ) {
    
    i/=iResolution.xy/.5;
    i.x*=.8;

    float L=length(i-.25);

    i += (i-.25)/L * smoothstep(.2,-.1,L-.1);
    i.x += .6*iGlobalTime;

    o = mix(texture2D(iChannel0,-i),vec4(-.7),sqrt(L));
    
    o += o;
}
*/

//here is the origin version by 834144373
//https://www.shadertoy.com/view/ltlXzj
/*
//#define lig iMouse.y/iResolution.y;
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv1 = fragCoord.xy / iResolution.xy ;
    uv1 *= 0.5;uv1.x *= .8;
    vec2 uv2 = uv1 - 0.5*0.5;
	
    float d2 = length(uv2);
    vec2 dir = normalize(uv2);
    
    uv1 += dir*smoothstep(.2,-0.1,d2-0.1);
    uv1.x += 0.6*iGlobalTime;
    
	vec3 col = texture2D(iChannel0,uv1).xyz;
    col = mix(col,vec3(-0.7),sqrt(d2));
    
    col -= pow(col,vec3(4.));
    col *=2.;
    //here you can use this lig
    //col *=1.+lig;
	fragColor = vec4(col,1.0);
}


*/
