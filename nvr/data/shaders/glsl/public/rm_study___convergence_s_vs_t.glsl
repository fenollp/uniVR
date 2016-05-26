// Shader downloaded from https://www.shadertoy.com/view/XdcXDS
// written by shadertoy user aiekick
//
// Name: RM Study : Convergence S vs T
// Description: clcik with mouse to see in yellow the var S and in violet the var T. (x axis is the iteration, y axis is the value)
//    the label in top left is the iteration before break
//    the two curve has not the same scaled
//    
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

const vec2 ballParams = vec2(4.78, 4.5);

#define break_condition 0.01*log(t*t/s/1e4)
#define curve1_var s
#define curve2_var log(t*t/s)

#define MAX_DISTANCE 20.
/////////////////////////
// GLSL Number Printing - @P_Malin (CCO 1.0)=> https://www.shadertoy.com/view/4sBSWW
float DigitBin(const in int x){
    if(x==0) return 480599.0; if(x==1) return 139810.0; if(x==2) return 476951.0; if(x==3) return 476999.0;	if(x==4) return 350020.0; 
    if(x==5) return 464711.0; if(x==6) return 464727.0; if(x==7) return 476228.0; if(x==8) return 481111.0; if(x==9) return 481095.0; 
    return 0.0;}
float PrintValue(vec2 fragCoord, const in vec2 vPixelCoords, const in vec2 vFontSize, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces){
    vec2 vStringCharCoords = (fragCoord.xy - vPixelCoords) / vFontSize;
    if ((vStringCharCoords.y < 0.0) || (vStringCharCoords.y >= 1.0)) return 0.0;
	float fLog10Value = log2(abs(fValue)) / log2(10.0);
	float fBiggestIndex = max(floor(fLog10Value), 0.0);
	float fDigitIndex = fMaxDigits - floor(vStringCharCoords.x);
	float fCharBin = 0.0;
	if(fDigitIndex > (-fDecimalPlaces - 1.01)) {
		if(fDigitIndex > fBiggestIndex) {
            if((fValue < 0.0) && (fDigitIndex < (fBiggestIndex+1.5))) fCharBin = 1792.0;} 
        else {		
			if(fDigitIndex == -1.0) {
				if(fDecimalPlaces > 0.0) fCharBin = 2.0;} 
            else {
				if(fDigitIndex < 0.0) fDigitIndex += 1.0;
				float fDigitValue = (abs(fValue / (pow(10.0, fDigitIndex))));
                float kFix = 0.0001;
                fCharBin = DigitBin(int(floor(mod(kFix+fDigitValue, 10.0))));} } }
    return floor(mod((fCharBin / pow(2.0, floor(fract(vStringCharCoords.x) * 4.0) + (floor(vStringCharCoords.y * 5.0) * 4.0))), 2.0));}
vec3 WriteValueToScreenAtPos(vec2 fragCoord, float vValue, vec2 vPixelCoord, vec3 vColour, vec2 vFontSize, float vDigits, float vDecimalPlaces, vec3 vColor){
    float num = PrintValue(fragCoord, vPixelCoord, vFontSize, vValue, vDigits, vDecimalPlaces);
    return mix( vColour, vColor, num);}

/////////////////////////////////////////////////////////////////

vec4 displ(vec3 p)
{
    vec2 g = p.xz;
    vec3 col =  texture2D(iChannel0, g+iGlobalTime*0.1).rgb;
   	col = clamp(col, 0., 1.);
    float dist = dot(col,vec3(0.11));
    return vec4(dist,col);
}

float df(vec3 p)
{
    vec4 disp1 = displ(p*0.07); // 0.1 ca merde 0.11 ca marche....
    float m = length(p);
    float me = m - ballParams.x + disp1.x;
    float mi = m - ballParams.y - disp1.x;
    return max(-mi, me);
}

vec3 nor( vec3 pos, float prec )
{
	vec3 eps = vec3( prec, 0., 0. );
	vec3 nor = vec3(
	    df(pos+eps.xyy) - df(pos-eps.xyy),
	    df(pos+eps.yxy) - df(pos-eps.yxy),
	    df(pos+eps.yyx) - df(pos-eps.yyx) );
	return normalize(nor);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 si = iResolution.xy;
	vec2 uvn = fragCoord/si*vec2(1.,20.);
	vec2 g = fragCoord;
    if (iMouse.z > 0.)
		g = iMouse.xy;
	
	vec2 uv = (g+g-si)/min(si.x, si.y);
	float d = 1.88;
	float a = iGlobalTime;
	float e = 10.52;
    vec3 ro = vec3(cos(a)*d,e, sin(a)*d);

    vec3 cu = vec3(0,1,0);
    vec3 co = vec3(0);
	
	float fov = 0.5;
	vec3 z = normalize(co - ro);
	vec3 x = normalize(cross(cu, z));
	vec3 y = normalize(cross(z, x));
	vec3 rd = normalize(z + fov * uv.x * x + fov * uv.y * y);
	
	float s = 1., so = 1.;;
	float t = 0.0;
	vec3 p = ro;
	
	float c = 0.;
	vec3 curve0 = vec3(0);
	vec3 curve1 = vec3(0);
    vec3 curve2 = vec3(0);
    float outStep = 0.;
	for (float i=0.; i< 950.; i++)
	{
		if (iMouse.z > 0. && abs(fragCoord.x - i) < 1.)
		{
			curve0 += 0.048 * vec3(1,1,0) / length(uvn.y - curve1_var);
			curve1 += 0.048 * vec3(0.48,0,0.48) / length(uvn.y - curve2_var);
            if(t>MAX_DISTANCE)
            	curve2 += 0.2 * vec3(0,0,1) / uvn.x;
            else if(s < break_condition)
            	curve2 += 0.2 * vec3(1,0,1) / uvn.x;
        }
		if (s < break_condition || t > MAX_DISTANCE ) break;
		s = df(p);
        s *= (s>so?2.:1.);so=s; // Enhanced Sphere Tracing => lgdv.cs.fau.de/get/2234 
		t += s * 0.2;
		p = ro + rd * t;
		outStep++;
	}
	if (iMouse.z > 0.)
    {	
        fragColor = vec4(curve0 + curve1 + curve2,1);
    	fragColor.rgb = WriteValueToScreenAtPos(fragCoord, outStep, vec2(20,si.y-20.), 
                                                fragColor.rgb, vec2(12.0, 15.0), 1., 0., vec3(0.9));
    }
	else
		fragColor = vec4(nor(p,s), 1);
		
		
	
}
