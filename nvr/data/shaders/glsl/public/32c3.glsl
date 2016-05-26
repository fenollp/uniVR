// Shader downloaded from https://www.shadertoy.com/view/lddGRB
// written by shadertoy user NinjaKoala
//
// Name: 32C3
// Description: Based on  https://www.shadertoy.com/view/XsX3zf by tayholliday
float det(vec2 a, vec2 b) { return a.x*b.y-b.x*a.y; }

vec2 closestPointInSegment( vec2 a, vec2 b )
{
  vec2 ba = b - a;
  return a + ba*clamp( -dot(a,ba)/dot(ba,ba), 0.0, 1.0 );
}

// From: http://research.microsoft.com/en-us/um/people/hoppe/ravg.pdf
vec2 get_distance_vector(vec2 b0, vec2 b1, vec2 b2) {
	
  float a=det(b0,b2), b=2.0*det(b1,b0), d=2.0*det(b2,b1); // 𝛼,𝛽,𝛿(𝑝)

  /*
	if bezier curve is to straight, use distance to line
	attention! constant depends on coordinate scale ( and number of bezier lines ???)
	if constant is too low, the bezier line will become too thin if bezier curve becomes straight
	if constant is too big, it will make bezier become straight too soon
	*/
  //if( abs(2.0*a+b+d) < .01 ) return closestPointInSegment(b0,b2);
	
  float f=b*d-a*a; // 𝑓(𝑝)
  vec2 d21=b2-b1, d10=b1-b0, d20=b2-b0;
  vec2 gf=2.0*(b*d21+d*d10+a*d20);
  gf=vec2(gf.y,-gf.x); // ∇𝑓(𝑝)
  vec2 pp=-f*gf/dot(gf,gf); // 𝑝′
  vec2 d0p=b0-pp; // 𝑝′ to origin
  float ap=det(d0p,d20), bp=2.0*det(d10,d0p); // 𝛼,𝛽(𝑝′)
  // (note that 2*ap+bp+dp=2*a+b+d=4*area(b0,b1,b2))
  float t=clamp((ap+bp)/(2.0*a+b+d), 0.0 ,1.0); // 𝑡̅
  return mix(mix(b0,b1,t),mix(b1,b2,t),t); // 𝑣𝑖= 𝑏(𝑡̅)

}

float approx_distance(vec2 p, vec2 b0, vec2 b1, vec2 b2) {
  return length(get_distance_vector(b0-p, b1-p, b2-p));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv=gl_FragCoord.xy/iResolution.xy;
	uv-=.5;
	uv.x*=iResolution.x/iResolution.y;

	vec2 mouse=iMouse.xy/iResolution.xy;
	mouse-=.5;
	mouse.x*=iResolution.x/iResolution.y;

    
  float d = 1e38;
	d=min(d,approx_distance(uv,vec2(-0.811198, -0.186198),vec2(-0.746094, -0.166667),vec2(-0.524740, -0.200521)));
	d=min(d,approx_distance(uv,vec2(-0.524740, -0.200521),vec2(-0.305990, -0.230469),vec2(-0.248698, -0.187500)));
	
	//3
	if(all(lessThan(abs(uv-vec2(-0.305990, 0.014323)),vec2(.14,.23)))){
		d=min(d,approx_distance(uv,vec2(-0.248698, -0.187500),vec2(-0.174479, -0.134115),vec2(-0.187500, -0.031250)));
		d=min(d,approx_distance(uv,vec2(-0.187500, -0.031250),vec2(-0.201823, 0.009115),vec2(-0.226562, 0.019531)));
		d=min(d,approx_distance(uv,vec2(-0.226562, 0.019531),vec2(-0.225260, 0.032552),vec2(-0.204427, 0.044271)));
		d=min(d,approx_distance(uv,vec2(-0.204427, 0.044271),vec2(-0.157552, 0.093750),vec2(-0.197917, 0.166667)));
		d=min(d,approx_distance(uv,vec2(-0.197917, 0.166667),vec2(-0.247396, 0.236979),vec2(-0.326823, 0.225260)));
		d=min(d,approx_distance(uv,vec2(-0.326823, 0.225260),vec2(-0.415365, 0.203125),vec2(-0.424479, 0.118490)));
		d=min(d,approx_distance(uv,vec2(-0.424479, 0.118490),vec2(-0.391927, 0.105469),vec2(-0.361979, 0.115885)));
		d=min(d,approx_distance(uv,vec2(-0.361979, 0.115885),vec2(-0.358073, 0.169271),vec2(-0.308594, 0.173177)));
		d=min(d,approx_distance(uv,vec2(-0.308594, 0.173177),vec2(-0.252604, 0.166667),vec2(-0.248698, 0.117188)));
		d=min(d,approx_distance(uv,vec2(-0.248698, 0.117188),vec2(-0.253906, 0.059896),vec2(-0.346354, 0.054688)));
		d=min(d,approx_distance(uv,vec2(-0.346354, 0.054688),vec2(-0.346354, 0.022135),vec2(-0.339844, -0.007812)));
		d=min(d,approx_distance(uv,vec2(-0.339844, -0.007812),vec2(-0.285156, -0.014323),vec2(-0.259115, -0.033854)));
		d=min(d,approx_distance(uv,vec2(-0.259115, -0.033854),vec2(-0.217448, -0.078125),vec2(-0.269531, -0.136719)));
		d=min(d,approx_distance(uv,vec2(-0.269531, -0.136719),vec2(-0.339844, -0.173177),vec2(-0.367187, -0.108073)));
		d=min(d,approx_distance(uv,vec2(-0.367187, -0.108073),vec2(-0.395833, -0.097656),vec2(-0.430990, -0.105469)));
		d=min(d,approx_distance(uv,vec2(-0.430990, -0.105469),vec2(-0.408854, -0.200521),vec2(-0.305990, -0.205729)));
	}
	d=min(d,approx_distance(uv,vec2(-0.268229, -0.134115),vec2(-0.248698, -0.252604),vec2(-0.138021, -0.200521)));
	//2
	if(all(lessThan(abs(uv-vec2(-0.016927, 0.013021)),vec2(.13,.23)))){
		d=min(d,approx_distance(uv,vec2(-0.138021, -0.200521),vec2(-0.097656, -0.156250),vec2(-0.049479, -0.143229)));
		d=min(d,approx_distance(uv,vec2(-0.049479, -0.143229),vec2(0.024740, -0.136719),vec2(0.100260, -0.143229)));
		d=min(d,approx_distance(uv,vec2(0.100260, -0.143229),vec2(0.108073, -0.190104),vec2(0.102865, -0.207031)));
		d=min(d,approx_distance(uv,vec2(0.102865, -0.207031),vec2(-0.053385, -0.207031),vec2(-0.138021, -0.201823)));
		d=min(d,approx_distance(uv,vec2(0.102865, -0.207031),vec2(-0.053385, -0.207031),vec2(-0.138021, -0.201823)));
		d=min(d,approx_distance(uv,vec2(-0.138021, -0.201823),vec2(-0.141927, -0.160156),vec2(-0.136719, -0.139323)));
		d=min(d,approx_distance(uv,vec2(-0.136719, -0.139323),vec2(-0.080729, -0.071615),vec2(-0.044271, -0.035156)));
		d=min(d,approx_distance(uv,vec2(-0.044271, -0.035156),vec2(0.026042, 0.031250),vec2(0.045573, 0.082031)));
		d=min(d,approx_distance(uv,vec2(0.045573, 0.082031),vec2(0.050781, 0.148438),vec2(-0.010417, 0.171875)));
		d=min(d,approx_distance(uv,vec2(-0.010417, 0.171875),vec2(-0.059896, 0.175781),vec2(-0.072917, 0.105469)));
		d=min(d,approx_distance(uv,vec2(-0.072917, 0.105469),vec2(-0.101562, 0.096354),vec2(-0.128906, 0.104167)));
		d=min(d,approx_distance(uv,vec2(-0.128906, 0.104167),vec2(-0.122396, 0.235677),vec2(-0.016927, 0.233073)));
		d=min(d,approx_distance(uv,vec2(-0.016927, 0.233073),vec2(0.082031, 0.218750),vec2(0.100260, 0.134115)));
		d=min(d,approx_distance(uv,vec2(0.100260, 0.134115),vec2(0.108073, 0.075521),vec2(0.088542, 0.055990)));
		d=min(d,approx_distance(uv,vec2(0.102865, 0.102865),vec2(0.115885, 0.040365),vec2(-0.078125, -0.151042)));
		d=min(d,approx_distance(uv,vec2(-0.045573, -0.143229),vec2(0.079427, -0.171875),vec2(0.101562, -0.197917)));
	}

	d=min(d,approx_distance(uv,vec2(0.102865, 0.102865),vec2(0.119792, 0.091146),vec2(0.148438, 0.054688)));
	d=min(d,approx_distance(uv,vec2(0.029948, -0.036458),vec2(0.054688, -0.088542),vec2(0.102865, -0.052083)));
	d=min(d,approx_distance(uv,vec2(0.102865, -0.052083),vec2(0.127604, -0.036458),vec2(0.149740, -0.042969)));

	//C
	if(all(lessThan(abs(uv-vec2(0.307292, 0.006510)),vec2(.17,.225)))){
		d=min(d,approx_distance(uv,vec2(0.147135, 0.055990),vec2(0.197917, 0.015625),vec2(0.210938, 0.046875)));
		d=min(d,approx_distance(uv,vec2(0.148438, 0.058594),vec2(0.136719, -0.161458),vec2(0.242188, -0.199219)));
		d=min(d,approx_distance(uv,vec2(0.242188, -0.199219),vec2(0.407552, -0.234375),vec2(0.444010, -0.087240)));
		d=min(d,approx_distance(uv,vec2(0.444010, -0.087240),vec2(0.399740, -0.071615),vec2(0.388021, -0.075521)));
		d=min(d,approx_distance(uv,vec2(0.388021, -0.075521),vec2(0.296875, -0.225260),vec2(0.212240, -0.072917)));
		d=min(d,approx_distance(uv,vec2(0.212240, -0.072917),vec2(0.204427, -0.041667),vec2(0.209635, 0.048177)));
		d=min(d,approx_distance(uv,vec2(0.209635, 0.048177),vec2(0.220052, 0.170573),vec2(0.298177, 0.173177)));
		d=min(d,approx_distance(uv,vec2(0.298177, 0.173177),vec2(0.373698, 0.161458),vec2(0.373698, 0.089844)));
		d=min(d,approx_distance(uv,vec2(0.373698, 0.089844),vec2(0.401042, 0.085938),vec2(0.449219, 0.089844)));
		d=min(d,approx_distance(uv,vec2(0.449219, 0.089844),vec2(0.463542, 0.210938),vec2(0.300781, 0.222656)));
		d=min(d,approx_distance(uv,vec2(0.300781, 0.222656),vec2(0.170573, 0.223958),vec2(0.149740, 0.058594)));
		d=min(d,approx_distance(uv,vec2(0.450521, 0.092448),vec2(0.483073, 0.059896),vec2(0.453125, 0.052083)));
		d=min(d,approx_distance(uv,vec2(0.453125, 0.052083),vec2(0.429688, 0.042969),vec2(0.451823, 0.089844)));
		d=min(d,approx_distance(uv,vec2(0.386719, -0.178385),vec2(0.399740, -0.127604),vec2(0.442708, -0.087240)));
	}

	d=min(d,approx_distance(uv,vec2(0.207031, -0.040365),vec2(0.195312, -0.217448),vec2(0.316406, -0.238281)));
	d=min(d,approx_distance(uv,vec2(0.316406, -0.238281),vec2(0.393229, -0.227865),vec2(0.441406, -0.184896)));
	d=min(d,approx_distance(uv,vec2(0.441406, -0.184896),vec2(0.471354, -0.186198),vec2(0.509115, -0.191406)));
	d=min(d,approx_distance(uv,vec2(0.442708, -0.087240),vec2(0.473958, -0.079427),vec2(0.506510, -0.041667)));

	//3
	if(all(lessThan(abs(uv-vec2(0.630208, 0.013021)),vec2(.14,.23)))){
		d=min(d,approx_distance(uv,vec2(0.509115, -0.191406),vec2(0.574219, -0.160156),vec2(0.697917, -0.123698)));
		d=min(d,approx_distance(uv,vec2(0.506510, -0.041667),vec2(0.533854, 0.069010),vec2(0.653646, 0.046875)));
		d=min(d,approx_distance(uv,vec2(0.653646, 0.046875),vec2(0.725260, 0.118490),vec2(0.647135, 0.167969)));
		d=min(d,approx_distance(uv,vec2(0.647135, 0.167969),vec2(0.585938, 0.179688),vec2(0.570312, 0.109375)));
		d=min(d,approx_distance(uv,vec2(0.570312, 0.109375),vec2(0.535156, 0.106771),vec2(0.505208, 0.114583)));
		d=min(d,approx_distance(uv,vec2(0.505208, 0.114583),vec2(0.518229, 0.238281),vec2(0.623698, 0.233073)));
		d=min(d,approx_distance(uv,vec2(0.623698, 0.233073),vec2(0.673177, 0.227865),vec2(0.710938, 0.192708)));
		d=min(d,approx_distance(uv,vec2(0.710938, 0.192708),vec2(0.782552, 0.087240),vec2(0.708333, 0.016927)));
		d=min(d,approx_distance(uv,vec2(0.708333, 0.016927),vec2(0.770833, -0.044271),vec2(0.748698, -0.122396)));
		d=min(d,approx_distance(uv,vec2(0.748698, -0.122396),vec2(0.718750, -0.196615),vec2(0.635417, -0.210938)));
		d=min(d,approx_distance(uv,vec2(0.635417, -0.210938),vec2(0.546875, -0.205729),vec2(0.511719, -0.104167)));
		d=min(d,approx_distance(uv,vec2(0.511719, -0.104167),vec2(0.515625, -0.088542),vec2(0.563802, -0.097656)));
		d=min(d,approx_distance(uv,vec2(0.563802, -0.097656),vec2(0.630208, -0.190104),vec2(0.686198, -0.100260)));
		d=min(d,approx_distance(uv,vec2(0.686198, -0.100260),vec2(0.708333, -0.019531),vec2(0.608073, -0.013021)));
		d=min(d,approx_distance(uv,vec2(0.608073, -0.013021),vec2(0.610677, 0.019531),vec2(0.600260, 0.049479)));
		d=min(d,approx_distance(uv,vec2(0.683594, -0.040365),vec2(0.704427, -0.036458),vec2(0.743490, -0.033854)));
		d=min(d,approx_distance(uv,vec2(0.697917, -0.122396),vec2(0.722656, -0.118490),vec2(0.747396, -0.121094)));
	}
	float thickness = 1./800.;

	float a;
	if(d<thickness){
		a=1.;
	}
	else{
  	a = 1. - smoothstep(d,thickness, 3.*thickness);
	}

	fragColor = vec4(a);
}
