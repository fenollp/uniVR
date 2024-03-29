// Shader downloaded from https://www.shadertoy.com/view/4dlGW8
// written by shadertoy user Dave_Hoskins
//
// Name: Eye sketch
// Description: 'Sketching' using triangles. * SQUINT * :)
// Eye sketch - by Dave Hoskins 2013
// Made with Shadertoy

vec3 col = vec3(1.0); // Start white...
vec2 uv;
#define INV_SCALE 1.0/vec2(326.0, 183.0)
#define ADD_DITHER
vec2 coord;

#ifdef ADD_DITHER
vec2 randValues = vec2(0.03, 0.015);
vec2 Hash2( vec2 x )
{
	float n = dot(x,vec2(13.31510,113.00));
    return fract(sin(vec2(n))*vec2(43758.5453123,22578.1459123));
}
#endif


vec2 unpackCoord(float f) 
{
    return vec2((mod(f, 512.0)), floor(f / 512.0)) * INV_SCALE;
}

vec2 unpackColour(float f) 
{
    return vec2((mod (f, 256.0)), floor(f / 256.0)) / 255.0;
}

void Tri(float n, float pA, float pB, float pC, float pCol1)
{
	if (n > iGlobalTime*8.1) return;
	vec2 pos = uv;
	vec2 a = unpackCoord(pA);
	vec2 b = unpackCoord(pB);
	vec2 c = unpackCoord(pC);
#ifdef ADD_DITHER
	pos += Hash2(coord.xy) * randValues.x - randValues.y;
	pos = clamp(pos, vec2(0.0001), vec2(.996));
#endif
	// Triangle test...
	vec2 as = pos-a;
	vec2 bs = pos-b;
	if  ( (b.x-a.x)*as.y-(b.y-a.y)*as.x > 0.0 &&
		  (a.x-c.x)*as.y-(a.y-c.y)*as.x > 0.0 &&
    	  (c.x-b.x)*bs.y-(c.y-b.y)*bs.x > 0.0)
	{
		vec2 c1 = unpackColour(pCol1);
		col = mix (col, vec3(c1.x), c1.y * (texture2D( iChannel0, uv*3.5+a*14.4).x)*2.3); 
	}
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    coord =  fragCoord;
	uv = fragCoord.xy / iResolution.xy;
	Tri(0., 7795., 94023.,93878., 15116.);
	Tri(1., 55054., 77583.,48336., 14337.);
	Tri(2., 76615., 49691.,1248., 7969.);
	Tri(3., 77883., 327.,94022., 15116.);
	Tri(4., 54082., 80639.,198., 12328.);
	Tri(5., 67399., 75931.,42277., 15110.);
	Tri(6., 7795., 40773.,94023., 14848.);
	Tri(7., 35625., 0.,206., 8081.);
	Tri(8., 327., 5447.,91782., 14898.);
	Tri(9., 65263., 79872.,49895., 15358.);
	Tri(10., 92715., 7225.,45157., 10567.);
	Tri(11., 37481., 74244.,24075., 14118.);
	Tri(12., 64523., 17508.,76886., 14852.);
	Tri(13., 68719., 201.,92382., 14359.);
	Tri(14., 12392., 82944.,0., 9800.);
	Tri(15., 21595., 32358.,25146., 15207.);
	Tri(16., 73787., 63084.,77093., 15357.);
	Tri(17., 93918., 52039.,94023., 15106.);
	Tri(18., 43179., 44253.,72946., 15357.);
	Tri(19., 38004., 94016.,90732., 14723.);
	Tri(20., 41632., 27344.,71334., 14867.);
	Tri(21., 61952., 56525.,93756., 13164.);
	Tri(22., 15975., 70656.,31744., 8258.);
	Tri(23., 33287., 52300.,52268., 15105.);
	Tri(24., 41182., 79607.,77004., 11517.);
	Tri(25., 56009., 28892.,34588., 13569.);
	Tri(26., 26267., 7396.,78066., 15099.);
	Tri(27., 215., 45192.,137., 15106.);
	Tri(28., 92730., 7.,33367., 11004.);
	Tri(29., 71186., 29761.,84703., 12802.);
	Tri(30., 94023., 93804.,43846., 15107.);
	Tri(31., 48662., 27146.,53303., 14082.);
	Tri(32., 81570., 8304.,41163., 13572.);
	Tri(33., 65863., 71909.,326., 15105.);
	Tri(34., 46645., 40474.,30., 15357.);
	Tri(35., 35992., 215.,37191., 15023.);
	Tri(36., 61016., 36394.,15443., 11010.);
	Tri(37., 214., 27772.,152., 14597.);
	Tri(38., 48689., 42006.,47171., 15105.);
	Tri(39., 75323., 51924.,93782., 10053.);
	Tri(40., 59911., 55866.,73279., 15106.);
	Tri(41., 43011., 59471.,55815., 15101.);
	Tri(42., 66560., 78499.,93696., 15356.);
	Tri(43., 14367., 9924.,31749., 12684.);
	Tri(44., 93846., 81408.,34441., 13030.);
	Tri(45., 8492., 35650.,6241., 15061.);
	Tri(46., 124., 327.,87183., 15105.);
	Tri(47., 84157., 66164.,85241., 14367.);
	Tri(48., 24675., 173.,51507., 9771.);
	Tri(49., 67804., 204.,7479., 15101.);
	Tri(50., 43216., 28372.,44329., 14605.);
	Tri(51., 94023., 93946.,55073., 12548.);
	Tri(52., 93700., 30321.,93824., 15098.);
	Tri(53., 90294., 43704.,67297., 15203.);
	Tri(54., 93308., 82031.,210., 15174.);
	Tri(55., 72429., 62153.,70922., 15105.);
	Tri(56., 93867., 93713.,31343., 15100.);
	Tri(57., 67813., 45243.,276., 14077.);
	Tri(58., 71231., 29232.,48739., 15105.);
	Tri(59., 86104., 4762.,75885., 8794.);
	Tri(60., 17592., 68703.,6238., 14589.);
	Tri(61., 63692., 84137.,65149., 15185.);
	Tri(62., 4798., 325.,66823., 15254.);
	Tri(63., 727., 8400.,185., 15106.);
	Tri(64., 698., 285.,47943., 15355.);
	Tri(65., 32393., 71782.,83., 15357.);
	Tri(66., 56647., 50909.,24332., 14948.);
	Tri(67., 132., 234.,93826., 10500.);
	Tri(68., 25148., 43039.,26134., 15357.);
	Tri(69., 93381., 109.,219., 11029.);
	Tri(70., 33919., 93837.,93703., 15102.);
	Tri(71., 70785., 122.,93367., 15207.);
	Tri(72., 17116., 279.,40747., 15090.);
	Tri(73., 55067., 48838.,43710., 14818.);
	Tri(74., 59719., 93977.,93858., 15220.);
	Tri(75., 47288., 49360.,67286., 14849.);
	Tri(76., 93874., 93829.,8816., 13194.);
	Tri(77., 40131., 21193.,38215., 15254.);
	Tri(78., 44131., 53341.,32310., 15245.);
	Tri(79., 93776., 42496.,93904., 15334.);

	fragColor = vec4(col, 1.0 );
}
