// Shader downloaded from https://www.shadertoy.com/view/4lsSzX
// written by shadertoy user Flyguy
//
// Name: Distance Field Text
// Description: Distance field based text with an 80's scifi like style. This is based on some shaders I posted on GLSL Sandbox a few days ago.
//#define SHOW_DISTANCE

#define BACK_COL_TOP vec3(1,0,1)
#define BACK_COL_BOTTOM vec3(0,0,1)

#define TEXT_COL1_TOP vec3(0.05, 0.05, 0.40)
#define TEXT_COL1_BOTTOM vec3(0.60, 0.90, 1.00)
#define TEXT_COL2_TOP vec3(0.10, 0.10, 0.00)
#define TEXT_COL2_BOTTOM vec3(1.90, 1.30, 1.00)

//--- Primiives ---
float dfSemiArc(float rma, float rmi, vec2 uv)
{
	return max(abs(length(uv) - rma) - rmi, uv.x-0.0);
}

//p0 = bottom left, clockwise winding
float dfQuad(vec2 p0, vec2 p1, vec2 p2, vec2 p3, vec2 uv)
{
	vec2 s0n = normalize((p1 - p0).yx * vec2(-1,1));
	vec2 s1n = normalize((p2 - p1).yx * vec2(-1,1));
	vec2 s2n = normalize((p3 - p2).yx * vec2(-1,1));
	vec2 s3n = normalize((p0 - p3).yx * vec2(-1,1));
	
	return max(max(dot(uv-p0,s0n),dot(uv-p1,s1n)), max(dot(uv-p2,s2n),dot(uv-p3,s3n)));
}

float dfRect(vec2 size, vec2 uv)
{
	return max(max(-uv.x,uv.x - size.x),max(-uv.y,uv.y - size.y));
}
//-----------------

//--- Letters ---
void S(inout float df, vec2 uv)
{
	df = min(df, dfSemiArc(0.25, 0.125, uv - vec2(-0.250,0.250)));
	df = min(df, dfSemiArc(0.25, 0.125, (uv - vec2(-0.125,-0.25)) * vec2(-1)));
	df = min(df, dfRect(vec2(0.125, 0.250), uv - vec2(-0.250,-0.125)));
	df = min(df, dfQuad(vec2(-0.625,-0.625), vec2(-0.500,-0.375), vec2(-0.125,-0.375), vec2(-0.125,-0.625), uv));	
	df = min(df, dfQuad(vec2(-0.250,0.375), vec2(-0.250,0.625), vec2(0.250,0.625), vec2(0.125,0.375), uv));
}

void H(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.250, 1.250), uv - vec2(-0.625,-0.625)));
    df = min(df, dfRect(vec2(0.250, 1.250), uv - vec2(-0.000,-0.625)));
	df = min(df, dfQuad(vec2(-0.375,-0.125), vec2(-0.375,0.125), vec2(0.000, 0.125), vec2(-0.125,-0.125), uv));	
}

void A(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.250, 0.825), uv - vec2(-0.625,-0.625)));
    df = min(df, dfRect(vec2(0.250, 0.825), uv - vec2(-0.000,-0.625)));
	df = min(df, dfQuad(vec2(-0.375,-0.125), vec2(-0.375,0.125), vec2(0.000, 0.125), vec2(-0.125,-0.125), uv));	
    df = min(df, dfSemiArc(0.3125, 0.125, (uv.yx - vec2(0.1875,-0.1875)) * -1.0));
}

void D(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.250, 1.25), uv - vec2(-0.625,-0.625)));
    df = min(df, dfSemiArc(0.5, 0.125, (uv.xy * vec2(-1,1) - vec2(0.375,-0.00))));
}

void E(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.250, 1.250), uv - vec2(-0.625,-0.625)));    
    df = min(df, dfQuad(vec2(-0.375,-0.625), vec2(-0.375,-0.375), vec2(0.250, -0.375), vec2( 0.125,-0.625), uv));	
    df = min(df, dfQuad(vec2(-0.375,0.375), vec2(-0.375,0.625), vec2(0.250, 0.625), vec2(0.125, 0.375), uv));	   
    df = min(df, dfQuad(vec2(-0.375,-0.125), vec2(-0.375,0.125), vec2(0.000, 0.125), vec2(-0.125,-0.125), uv));	
}

void R(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.250, 1.250), uv - vec2(-0.625,-0.625)));
    df = min(df, dfSemiArc(0.25, 0.125, (uv.xy * vec2(-1,1) - vec2(0.125,0.25))));    
    df = min(df, dfRect(vec2(0.25, 0.250), uv - vec2(-0.375,0.375)));
    df = min(df, dfQuad(vec2(-0.375,-0.125), vec2(-0.250,0.125), vec2(0.000, 0.125), vec2(-0.125,-0.125), uv));	
    df = min(df, dfQuad(vec2(-0.375,-0.125), vec2(-0.1,-0.125), vec2(0.250,-0.625), vec2(-0.025,-0.625), uv));	

}

void T(inout float df, vec2 uv)
{
    df = min(df, dfRect(vec2(0.250, 1.0), uv - vec2(-0.3125,-0.625))); 
	df = min(df, dfQuad(vec2(-0.625, 0.375), vec2(-0.625,0.625), vec2(0.250, 0.625), vec2(0.125, 0.375), uv));	
}

void O(inout float df, vec2 uv)
{
    df = min(df, dfRect(vec2(0.25, 0.375), uv - vec2( 0.000,-0.1875)));  
    df = min(df, dfRect(vec2(0.25, 0.375), uv - vec2(-0.625,-0.1875)));  
    df = min(df, dfSemiArc(0.3125, 0.125, (uv.yx - vec2(0.1875,-0.1875)) * -1.0));
    df = min(df, dfSemiArc(0.3125, 0.125, (uv.yx - vec2(-0.1875,-0.1875)) ));
}

void Y(inout float df, vec2 uv)
{
    df = min(df, dfRect(vec2(0.25, 0.25), uv - vec2( 0.000,0.375)));  
    df = min(df, dfRect(vec2(0.25, 0.25), uv - vec2(-0.625,0.375)));  
    df = min(df, dfSemiArc(0.3125, 0.125, (uv.yx - vec2(0.375,-0.1875)) ));
    df = min(df, dfRect(vec2(0.250, 0.75), uv - vec2(-0.3125,-0.625))); 
}

//---------------

//--- Gradient Stuff ---
//returns 0-1 when xn is between x0-x1
float linstep(float x0, float x1, float xn)
{
	return (xn - x0) / (x1 - x0);
}

vec3 retrograd(float x0, float x1, float m, vec2 uv)
{
	float mid = x0+(x1 - x0) * m;

	vec3 grad1 = mix(TEXT_COL1_BOTTOM, TEXT_COL1_TOP, linstep(mid, x1, uv.y));
    vec3 grad2 = mix(TEXT_COL2_BOTTOM, TEXT_COL2_TOP, linstep(x0, mid, uv.y));

	return mix(grad2, grad1, smoothstep(mid, mid + 0.04, uv.y));
}
//----------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 aspect = iResolution.xy/iResolution.y;
	vec2 uv = ( fragCoord.xy / iResolution.y );
	
	uv = (uv - aspect/2.0)*8.0;
	
    //Text distance field
	float dist = 1e6;
	
	vec2 chSpace = vec2(1.125,1.500);
	
	vec2 chuv = uv;
	chuv.x += (chSpace.x * 9.0) / 2.0 - 0.75;
		
	S(dist, chuv); chuv.x -= chSpace.x;
	H(dist, chuv); chuv.x -= chSpace.x;
	A(dist, chuv); chuv.x -= chSpace.x;
	D(dist, chuv); chuv.x -= chSpace.x;
    E(dist, chuv); chuv.x -= chSpace.x;
    R(dist, chuv); chuv.x -= chSpace.x;
	T(dist, chuv); chuv.x -= chSpace.x;
    O(dist, chuv); chuv.x -= chSpace.x;
    Y(dist, chuv); chuv.x -= chSpace.x;
    
    dist /= 2.0;
    
    //Colors and mixing mask
	float mask = smoothstep(4.0 / iResolution.y, 0.00, dist);
    
	vec3 textcol = retrograd(-0.75, 0.50, 0.40 + pow(abs(dist), 0.25) * 0.08, uv);
	
	vec3 backcol = mix(BACK_COL_BOTTOM, BACK_COL_TOP, (uv.y/4.0)+0.5) * smoothstep(0.02, 0.025, dist);
	
    //Grid Stuff
	vec2 gdef = vec2(uv.x / abs(uv.y), 1.0 / (uv.y));
	gdef.y = clamp(gdef.y,-1e2, 1e2);
	
	vec2 gpos = vec2(0.0,-iGlobalTime);
	
	gdef += gpos;
	
	vec2 grep = mod(gdef*vec2(1.0,2.0), vec2(1.0));
	
	float grid = max(abs(grep.x - 0.5),abs(grep.y - 0.5));
	
	float gs = length(gdef-gpos)*0.01;
	
	backcol *= mix(smoothstep(0.46-gs,0.48+gs,grid), 1.0, step(0.0,uv.y))*0.75+0.25;
	
    //Mixing text with background
	vec3 color = mix(backcol,textcol,mask);
	
    #ifdef SHOW_DISTANCE
    color = vec3(sin(dist*48.0));
    #endif
    
	fragColor = vec4( vec3( color ), 1.0 );
}