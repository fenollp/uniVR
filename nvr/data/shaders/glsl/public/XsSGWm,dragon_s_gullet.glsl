// Shader downloaded from https://www.shadertoy.com/view/XsSGWm
// written by shadertoy user RavenWorks
//
// Name: Dragon's Gullet
// Description: based on Noben's art: [url]http://forum.altermeta.net/index.php/topic,2381.msg29005.html[/url]
//    thanks to [url]http://iquilezles.org/www/articles/distfunctions/distfunctions.htm[/url]
const float PI=3.14159265;

float obj_spiral( vec3 p ){
	
	const float flattenAmt = 2.0;
	const float torusRadius = 3.5;
	float spacingScale = (1.3*flattenAmt) + sin(iGlobalTime*1.8)*0.1;//kinda breaks the math, but close enough for fog
	float spiralPeriod = torusRadius*spacingScale;
	
	p.y *= flattenAmt;
	
	p.x += sin(iGlobalTime*2.0+p.y*0.4)*0.5;
	p.z += cos(iGlobalTime*2.0+p.y*0.4)*0.5;
	float ang = -atan(p.x,p.z);
	float dist = p.x*p.x+p.z*p.z;//maybe faster to use length() even though sqrt isn't necessary?
	
	p.y -= dist*0.1;
	
	// this is super artifacty, but that actually suits the look...!
	float periodX = 6.0;
	float periodZ = 6.0;
	float distX = 0.05;
	float distZ = 0.05;
	float inX = p.x + cos(dist)*(0.5+cos(ang*2.0+iGlobalTime*3.0)*1.0);
	float inZ = p.z + sin(dist)*(0.5+sin(ang*2.0+iGlobalTime*3.0)*1.0);
	p.y += cos(inZ*periodZ)*distZ + sin(inX*periodX)*distX;
	// only modifying the y seems to look good enough by itself
	
	
	
	
	
	
	p.y += p.x*(1.2+sin(iGlobalTime*1.5+p.y*0.3)*0.2);
	p.y += ang/(PI*2.0)*spiralPeriod;
	float spiralDist = -ang+PI+floor((p.y/spiralPeriod))*PI*2.0;
	p.y = mod(p.y, spiralPeriod)-spiralPeriod*0.5;
	
	vec2 q = vec2((length(p.xz))-torusRadius,p.y);
	
	
	
	float wobbleC = 
		    iGlobalTime*3.5+spiralDist*1.5  +
		sin(iGlobalTime*4.0+spiralDist*1.8) + 
		sin(iGlobalTime*1.5+spiralDist*0.3) *
		sin(iGlobalTime*7.5+spiralDist*5.9);
	float ringRadius = 1.5 + sin(wobbleC)*0.2;//sin(iGlobalTime+p.y)*0.2;
	
	return length(q)-ringRadius;
	
}

const float wallDist = 15.0;
const float wallThickness = 1.5;
const float wallRepeatX = PI/5.0;
const float wallRepeatY = 12.0;
const float archThickness = 3.6;
const float archThicknessHalf = archThickness*0.5;

float obj_cylinder(vec3 p){
	
	vec2 d = vec2(
		abs(p.z-wallDist)-wallThickness,
		archThickness-abs(p.y+archThicknessHalf)
	);
	
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
	
}

float obj_roundholes(vec3 p){
	return length(vec2(p.x*17.2,p.y-archThicknessHalf))-archThickness;
}

float obj_columnHalf(vec3 p,float side){
	return length(vec2((p.x+wallRepeatX*side*0.5)*18.2,p.z-wallDist))-0.7;
}
float obj_columns(vec3 p){
	return min(obj_columnHalf(p,1.0),obj_columnHalf(p,-1.0));
	// yuck. too lazy to redo the mod though,
	// and this is a quick enough calculation that who cares!
}

float opS( float d1, float d2 ){
    return max(-d1,d2);
}

float obj_room(vec3 worldP){
	
	float worldWithinY = (worldP.y/wallRepeatY) + 0.5;
	float withinY = (fract( worldWithinY ) - 0.5)*wallRepeatY;
	float stepY = floor( worldWithinY );
	
	float rotOff = mod(stepY,2.0)*wallRepeatX*0.5;
	
	float worldRotX = atan(worldP.z,worldP.x);
	
	vec3 p = vec3(
		mod(worldRotX+rotOff+wallRepeatX*0.5,wallRepeatX)-wallRepeatX*0.5,
		withinY,
		length(worldP.xz)
	);
	// converting to cylindrical space makes everything bow outwards a little,
	// but saves trouble in determining where things go...
	// (though it does make it messy to squish the X back into world space..
	//  I could probably fix that but whatever)
	
	vec2 uv = vec2(worldRotX/PI*1.0,worldP.y*0.025-p.z*0.0125);
	float bumpAmt = texture2D(iChannel0, uv).g * -0.1;
	return min(obj_columns(p),opS(obj_roundholes(p),obj_cylinder(p))) + bumpAmt;
	
}

float wallWave(vec3 p){
	float rotX = atan(p.z,p.x);
	float wavePower = 2.0+sin(iGlobalTime*2.0+rotX*4.0)*1.5;
	float waveAmt = sin(p.y+sin(iGlobalTime*1.0)*1.5+sin(iGlobalTime*2.0+rotX*8.0+sin(rotX)*4.0)+rotX*2.0);
	return pow((waveAmt+1.0)*0.5,wavePower)*0.22;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 vPos = fragCoord.xy/iResolution.xy - 0.5;
	
	// Camera up vector.
	vec3 vuv=vec3(0,1,0); 
	// Camera pos
	float rotAng = (iMouse.x/iResolution.x)*PI*2.0 + iGlobalTime*0.3;
	const float cameraDist = 11.0;
	vec3 prp = vec3(cos(rotAng)*cameraDist,((iMouse.y/iResolution.y)-0.5)*5.0,sin(rotAng)*cameraDist);
	// Camera lookat
	vec3 vrp=vec3(0,0,0);
	
	// light
	vec3 L = normalize(vec3(1.0,-4.0,0.0));
	
	// Camera setup.
	vec3 vpn=normalize(vrp-prp);
	vec3 u=normalize(cross(vuv,vpn));
	vec3 v=cross(vpn,u);
	vec3 vcv=(prp+vpn);
	vec3 scrCoord=vcv+vPos.x*u*iResolution.x/iResolution.y+vPos.y*v;
	vec3 scp=normalize(scrCoord-prp);
	
	// Raymarching.
	const vec3 e=vec3(0.02,0,0);
	const float maxd=40.0; //Max depth
	vec3 c,p,N;
	float sA,sP;
	float f, d;
	
	// march to bg
	vec3 bgColor=vec3(0,0,0);
 	f=1.0;
	d=0.1;
 	for(int i=0;i<32;i++){
		if ((abs(d) < .001) || (f > maxd)) break;
		f+=d;
		p=prp+scp*f;
		d = obj_room(p);
	}
	
	const vec3 rockC = vec3(0.05,0.1,0.3);
	const vec3 glowC = vec3(1.0,0.25,0.5);
	
	if (f < maxd){
		vec3 n = vec3(d-obj_room(p-e.xyy),
					  d-obj_room(p-e.yxy),
					  d-obj_room(p-e.yyx));
		N = normalize(n);
		
		float diffuse=max(dot(N,L),0.0);
		vec3 H = normalize(L-scp);
		float specular = max(dot(H,N),0.0);
		bgColor= (diffuse*0.9+0.1)*rockC + pow(specular,16.0)*0.25 + specular*wallWave(p)*glowC;
	}
	
	// march to flame
	const float sparkleSpecAmt = 0.7;
	const vec3 pinkFlame = vec3(1.0,0.25,0.5)*sparkleSpecAmt;
	const vec3 yellowFlame = vec3(1.0,0.8,0.38)*sparkleSpecAmt - pinkFlame;
	const float sparklePinkSpecPower = 4.0;
	const float sparkleYellowSpecPower = 64.0;
	
	vec3 flameColor=vec3(0,0,0);
	float fogAccumulation = 0.0;
	float curWithinSpd = 0.0;
	f=1.0;
	d=0.1;
	const int countAmt = 256;
	vec3 firstCrossP;
	vec3 secondCrossP;
	float firstCrossD;
	float secondCrossD;
	bool wasOutside = true;
	int crosses = 0;
 	for(int i=0;i<countAmt;i++){
		if (f > maxd) {
			//flameColor = vec3(0.0,0.0,1.0);
			break;
		}
		
		if (d < 0.01) {
			f+=0.1;
			curWithinSpd += 0.0001;
			fogAccumulation += curWithinSpd;
			if (wasOutside) {
				crosses++;
				if (crosses == 1) {
					firstCrossP = p;
					firstCrossD = d;
				} else {
					secondCrossP = p;
					secondCrossD = d;
				}
			}
			wasOutside = false;
		} else {
			curWithinSpd = 0.0;
			f+=d*0.5;//this isn't completely thought-out, but it does the job..
			// a smaller number would have even less artifacts,
			// but I actually like the look of the smaller artifacts so let's keep them!
			wasOutside = true;
		}
		p=prp+scp*f;
		d = obj_spiral(p);
		
		//if (i==countAmt-1) flameColor = vec3(1.0,0.0,0.0);
	}
	flameColor += vec3(0.2,1.0,0.8)*min(fogAccumulation,0.05)*3.0;
	
	if (crosses >= 1) {
		vec3 n = vec3(firstCrossD-obj_spiral(firstCrossP-e.xyy),
					  firstCrossD-obj_spiral(firstCrossP-e.yxy),
					  firstCrossD-obj_spiral(firstCrossP-e.yyx));
		N = normalize(n);
		float b=max(dot(N,normalize(-scp)),0.0);
		flameColor += pow(b,sparklePinkSpecPower)*pinkFlame;
		flameColor += pow(b,sparkleYellowSpecPower)*yellowFlame;
	}
	
	if (crosses >= 2) {
		vec3 n = vec3(secondCrossD-obj_spiral(secondCrossP-e.xyy),
					  secondCrossD-obj_spiral(secondCrossP-e.yxy),
					  secondCrossD-obj_spiral(secondCrossP-e.yyx));
		N = normalize(n);
		float b=max(dot(N,normalize(-scp)),0.0);
		flameColor += pow(b,sparklePinkSpecPower)*pinkFlame;
		flameColor += pow(b,sparkleYellowSpecPower)*yellowFlame;
	}
	
	fragColor = vec4((bgColor+flameColor),1.0);
}