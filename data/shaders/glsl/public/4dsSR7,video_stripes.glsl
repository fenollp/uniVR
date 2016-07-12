// Shader downloaded from https://www.shadertoy.com/view/4dsSR7
// written by shadertoy user FabriceNeyret2
//
// Name: video stripes
// Description: .
#define PI 3.14159265359
float t = iGlobalTime;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 txt = texture2D(iChannel0,vec2(uv.x,uv.y)).rgb;
	vec3 col = txt/length(txt); // chrominance
	t = t/4.;
#define N 14.
	int MODE = int(mod(t,N));

	float lum = (txt.r+txt.g+txt.b)/3.,
		  rg = atan(txt.r,txt.g);
	
	if (MODE==0) { 					// inverse lum and chrominance
		lum *= 2.*PI; rg = rg*2./PI;
		col = vec3(rg*(.5+.5*cos(lum)),rg*.1, rg*(.5+.5*sin(lum)));
	}
	else 	if ((MODE==1)||(MODE==2)||(MODE==3))    // iso-lums
		col = vec3(.5-.5*cos(t+2.*PI*mod(t,N)*lum)); 
	else 	if ((MODE==4)||(MODE==5)||(MODE==6))
		col *= vec3(.5-.5*cos(t+2.*PI*mod(t,N)*lum));  // iso-lums * chrominance
	else if ((MODE==7)||(MODE==8)) { // diag or invdiag strip depending on dominant color
		lum = floor(10.*lum)/10.;
		float diag1 = sin(2.*PI*(fragCoord.x+fragCoord.y)*lum/2.),
			  diag2 = sin(2.*PI*(fragCoord.x-fragCoord.y)*lum/2.);
		if (MODE==7)
	    	col = (txt.g>txt.r) ? vec3(diag1) : vec3(diag2);
		else 
	    	col = (txt.g>txt.r) ? vec3(0.,diag1,0.) : vec3(diag2,0.,0.);
	}
	else if ((MODE==9)||(MODE==10)) { // combine stripes dir from R and G
		float a = 2.*rg;  	a = floor(10.*a/PI)*PI/10.;
		float b = lum*PI;  	b = floor(10.*b/PI)*PI/10.;
		vec2 dirA = vec2(cos(a),sin(a)); 
		vec2 dirB = vec2(cos(b),sin(b)); 
		a = 2.*PI*dot(dirA,fragCoord.xy); a = .5-.5*cos(a);
		b = 2.*PI*dot(dirB,fragCoord.xy); b = .5-.5*cos(b);
		col = (MODE==9) ? vec3(a-b) : col=vec3(a,b,0.);
	}
	else if ((MODE==11)||(MODE==12)) { // stripes dir + length = lum,chromin. or reverse
		float a,b;
		if (MODE==11) {
			a = 2.*rg;  	a = floor(10.*a/PI)*PI/10. +PI/2.;  
			b = lum;		b = floor(10.*b)/10.;
		} else {
			a = lum*PI;  	a = floor(10.*a/PI)*PI/10.;// +PI/2.;  
			b = 1.-rg;		b = floor(10.*b)/10.;
		}
		vec2 dir = vec2(cos(a),sin(a)); 
		a = 2.*PI*dot(dir,fragCoord.xy);
		col = vec3(.5-.5*cos(.5*b*a))*vec3(txt/length(txt));
	}
	else if (MODE==13) {
		lum = floor(8.*lum)/7.; 
		col *= lum; 
	}
	
	fragColor = vec4(col,1.0);
}