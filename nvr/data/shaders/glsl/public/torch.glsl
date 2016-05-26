// Shader downloaded from https://www.shadertoy.com/view/lsKGzt
// written by shadertoy user 834144373
//
// Name: Torch
// Description: Hopeful...
bool Is(vec2 uv,lowp vec2 A,lowp vec2 B,lowp vec2 C){
    lowp vec3 AB,BC,AC;
    return dot(cross(AB = vec3(B-A,0.),vec3(uv-A,0.)),cross(AB, AC = vec3(C-A,0.)))>0. && dot(cross(BC = vec3(C-B,0.),vec3(uv-B,0.)),cross(BC,-AB))>0. && dot(cross(-AC,vec3(uv-C,0.)),-cross(AC,BC))>0.; 
}

void mainImage( out vec4 f, in vec2 u )
{
    vec2 uv = ( u*2.- iResolution.xy)/iResolution.y;
	vec2 uv2 = uv;
	uv.x = abs(uv.x);
	if(Is(uv,vec2(0.,-0.035),vec2(0.2,-0.18),vec2(0.5,0.43)) || Is(uv,vec2(0.),vec2(0.16,1.5),vec2(0.1,0.)) || Is(uv2,vec2(0.,0.587),vec2(-0.1,0.55),vec2(0.,0.64))){
		f = pow(vec4( uv+0.7,1.,1.0 )/1.23,vec4(1.3));
    }else{
        f = vec4(1.-length(uv+vec2(0.,-1.4))/2.4);
        f *= vec4(0.1,0.2,0.25,0.)*(1.7+2.+1.4*sin(iGlobalTime));
        f = pow(f,vec4(1.));
    }
}