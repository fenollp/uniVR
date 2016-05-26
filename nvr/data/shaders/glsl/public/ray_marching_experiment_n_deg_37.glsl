// Shader downloaded from https://www.shadertoy.com/view/MsyGDz
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment n&deg;37
// Description: Ray Marching Experiment n&deg;37
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const vec2 vSteps = vec2(1.0,1.0);

/////////////////////////
// IQ Storage : https://www.shadertoy.com/view/MddGzf
float isInside( vec2 p, vec2 c ) {vec2 d = abs(p-0.5-c) - 0.5; return -max(d.x,d.y); }
float isInside( vec2 p, vec4 c ) {vec2 d = abs(p-0.5-c.xy-c.zw*0.5) - 0.5*c.zw - 0.5; return -max(d.x,d.y); }
vec4 loadValue( in vec2 re ){return texture2D( iChannel2, (0.5+re) / iChannelResolution[2].xy, -100.0 );}
void storeValue( in vec2 re, in vec4 va, inout vec4 fragColor, in vec2 fragCoord ){fragColor = ( isInside(fragCoord,re) > 0.0 ) ? va : fragColor;}
void storeValue( in vec4 re, in vec4 va, inout vec4 fragColor, in vec2 fragCoord ){fragColor = ( isInside(fragCoord,re) > 0.0 ) ? va : fragColor;}

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

#define y(a) sign(mod(floor(a), 2.) *.5 - .1)
#define pi 3.14159

vec3 effect(vec2 g) 
{
    vec2 
        s = sign(mod(floor(g), 2.) - .2),
        c, u;
    
    float 
        w = s.x * s.y * iDate.w * 5.,
        k = 1.57079;
    
    vec3 f = vec3(0);
    
    for (float i=0.;i<4.;i++)
    {
        c = sin(i * k + vec2(k,0));
        
        u = fract(mat2(c, -c.y, c.x) * g);
        
        f += step(
            min(max(1.5 * cos(atan(u.x, u.y) * 8. + w + k) + 6., 5.), 7.), 
            length(u) * 12.3) / 5.;
        
        w *=-1.;
    }
    return f;
}

vec4 displacement(vec3 p)
{
    vec2 g = p.xz * 0.7;
    vec3 col = 1.-effect(g);
    vec3 tex = texture2D(iChannel1, g).rgb;
    col = (col.r<0.2)?col * tex:col;
    float dist = dot(col,vec3(0.05));
    return vec4(dist,col);
}

vec4 map(vec3 p)
{
    vec4 disp = displacement(p);
    return vec4(length(p) - 4. - disp.x, disp.yzw);
}

///////////////////////////////////////////
//FROM IQ Shader https://www.shadertoy.com/view/Xds3zN
float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<16; i++ )
    {
		float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.01, 0., 0. );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

///////////////////////////////////////////
float march(vec3 ro, vec3 rd, float rmPrec, float maxd, float mapPrec, float maxStep)
{
   	float s = rmPrec;
    float d = 0.;
    for(float i=0.;i<250.;i++)
    {      
        if (i > maxStep) break;
        if (s<rmPrec||s>maxd) break;
        s = map(ro+rd*d).x*mapPrec;
        d += s;
    }
    return d;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 f, in vec2 g )
{
    vec4 varSteps = loadValue(vSteps); //(x:steps/y:rmPrec/z:maxd/w:mapPrec)
    
    float time = iGlobalTime*0.25;
    float cam_a = time; // angle z
    
    float cam_e = 5.52; // elevation
    float cam_d = 1.88; // distance to origin axis
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.7; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
    
    vec2 s = iResolution.xy;
    vec2 uv = (g+g-s)/s.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = march(ro, rd, varSteps.y, varSteps.z, varSteps.w, varSteps.x);
    
    if (d<varSteps.z)
    {
        vec2 e = vec2(-1., 1.)*0.005; 
    	vec3 p = ro+rd*d;
        vec3 n = calcNormal(p);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 refrRay = refract(rd, n, refr_a);
        
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        col = cubeRefl + cubeRefr + pow(b, 15.);
        
       	// lighting        
        float occ = calcAO( p, n );
		vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
		float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, lig ), 0.0, 1.0 );
        float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, reflRay.y );
        float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
		float spe = pow(clamp( dot( reflRay, lig ), 0.0, 1.0 ),16.0);
        
        dif *= softshadow( p, lig, 0.02, 2.5 );
       	dom *= softshadow( p, reflRay, 0.02, 2.5 );

		vec3 brdf = vec3(0.0);
        brdf += 1.20*dif*vec3(1.00,0.90,0.60);
		brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
        brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
        brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
		brdf += 0.02;
		col = col*brdf;

    	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d*d ) );
        
       	col = mix(col, map(p).yzw, 0.5);
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
    col = WriteValueToScreenAtPos(g, iFrameRate, vec2(150,2), col, vec2(12.0, 15.0), 1., 2., vec3(0.9));
    col = WriteValueToScreenAtPos(g, varSteps.x, vec2(15,2), col, vec2(12.0, 15.0), 1., 2., vec3(0.9));
    col = WriteValueToScreenAtPos(g, varSteps.y, vec2(15,20), col, vec2(12.0, 15.0), 1., 5., vec3(0.9));
    col = WriteValueToScreenAtPos(g, varSteps.z, vec2(15,38), col, vec2(12.0, 15.0), 1., 2., vec3(0.9));
    col = WriteValueToScreenAtPos(g, varSteps.w, vec2(15,56), col, vec2(12.0, 15.0), 1., 2., vec3(0.9));
    
	f.rgb = col;
}