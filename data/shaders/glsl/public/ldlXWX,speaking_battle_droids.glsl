// Shader downloaded from https://www.shadertoy.com/view/ldlXWX
// written by shadertoy user Dave_Hoskins
//
// Name: Speaking Battle Droids
// Description: Speech synthesis in Shadertoy!
// Battle Droids saying, "Errr, I think we have a problem!"
// By David Hoskins. Aug.'14.
// Uses sinusoidal speech construction.

// https://www.shadertoy.com/view/ldlXWX

// Note, on the fourth droid, you can hear the formants scaled down,
// this reveals the original actor's voice ( well, near enough :] ).

//==============================================================================

#define TAU  6.2831
const vec2 randValues = vec2(0.006, 0.003);
const vec2 INV_SCALE  = 1.0 / vec2(509.0, 509.0*450.0/800.0);
vec3 col = vec3(1.0);
vec2 uv;
vec2 fcoord;

//==============================================================================

#define MOD2 vec2(443.8975,397.2973)
float Hash(float p)
{
	vec2 p2 = fract(vec2(p) * MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y)-.5;
}


//==============================================================================
vec2 Hash2( vec2 x )
{
	float n = dot(x,vec2(1.12313,113.94871)) + iGlobalTime;
    return fract(sin(n)*vec2(3758.5233,2578.1459))-.5;
}

//==============================================================================
vec2 unpackCoord(float f) 
{
    vec2 ret = vec2(mod(f, 512.0),floor(f / 512.0)) * INV_SCALE;
    return ret;
}

//==============================================================================
vec2 unpackColour(float f) 
{
    return vec2(mod (f, 256.0),floor(f / 256.0)) / 256.0;
}

//==============================================================================
void Tri(float pA, float pB, float pC, float pCol1, float pCol2)
{
	vec2 pos = uv;
	vec2 a = unpackCoord(pA);
	vec2 b = unpackCoord(pB);
	vec2 c = unpackCoord(pC);
	pos += Hash2(fcoord) * randValues.x - randValues.y;

	// Triangle test...
	vec2 as = pos-a;
	vec2 bs = pos-b;
	if  ( (b.x-a.x)*as.y-(b.y-a.y)*as.x > 0.0 &&
		  (a.x-c.x)*as.y-(a.y-c.y)*as.x > 0.0 &&
    	  (c.x-b.x)*bs.y-(c.y-b.y)*bs.x > 0.0)
	{
		vec2 c1 = unpackColour(pCol1);
		vec2 c2 = unpackColour(pCol2);
		col = mix (col, vec3(c1.x, c1.y, c2.x), c2.y); 
	}
}

//==============================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fcoord = fragCoord;
	uv = fragCoord.xy / iResolution.xy;
    vec2 aspect = vec2(1.0, iResolution.y / iResolution.x);
    
    float t = iGlobalTime;
    
    // Move around...
    t = mod(t, 6.0);
    uv.x += -smoothstep(1.0, .0, t) + smoothstep(4.0, 5.0, t);
    uv.y += abs(sin(t*TAU*2.0) * (smoothstep(1.0, .0, t) + smoothstep(4.0, 5.0, t)) * .2);
    float tilt = smoothstep(1.0, 1.5, t) * smoothstep(4.5, 3.5, t) * .1;
    float shake = smoothstep(1.5, 3.0, t) * smoothstep(3.4, 3.0, t) * .3;
    mat2 mat = mat2( cos(tilt), sin(tilt),-sin(tilt), cos(tilt));
    uv = (mat * (uv*aspect-vec2(1.75,.0) + vec2(1.75,.0))) / aspect;
    uv.y += sin(t*24.0) * .01  * shake - tilt;
    uv.y += cos(t*3.0) * .02  * shake;
	
	// Packed data parameters:
	// Tri( X1/Y1, X2/Y2, X3/y3, RG, BA)
	Tri(98094., 99008.,58567., 257., 14868.);
	Tri(28833., 53424.,63129., 256., 15105.);
	Tri(95493., 18203.,62768., 7217., 15107.);
	Tri(436., 12211.,-170., 3095., 15107.);
	Tri(82630., 107354.,96944., 2., 15107.);
	Tri(36620., 108944.,125326., 46074., 9353.);
	Tri(72041., 108781.,64818., 8., 15110.);
	Tri(141596., 31881.,25234., 43005., 13831.);
	Tri(29463., -227.,-187., 12587., 15108.);
	Tri(49858., 65160.,54910., 1026., 15105.);
	Tri(131830., 72846.,40084., 23937., 14342.);
	Tri(127793., 21592.,8305., 557., 14850.);
	Tri(105147., 77581.,77180., 12436., 12288.);
	Tri(14620., 96016.,101124., 513., 15105.);
	Tri(63055., 142319.,65611., 65019., 15094.);
	Tri(145282., 61327.,33687., 1286., 15108.);
	Tri(83763., 56630.,48972., 2712., 15107.);
	Tri(127770., 79559.,62684., 60665., 14586.);
	Tri(-227., -196.,119123., 30164., 14848.);
	Tri(107269., 109765.,62832., 8214., 11008.);
	Tri(29615., 356.,-94., 1553., 15105.);
	Tri(47807., 73465.,87204., 30656., 14879.);
	Tri(69885., 21080.,8306., 18255., 11012.);
	Tri(92393., 22104.,8814., 11., 15105.);
	Tri(127230., -226.,98147., 24206., 15106.);
	Tri(113963., 26772.,115020., 548., 13062.);
	Tri(129788., 125672.,83317., 7715., 14593.);
	Tri(86294., 110276.,45679., 15495., 13071.);
	Tri(80161., 111282.,22875., 65022., 15358.);
	Tri(117125., 66446.,57236., 1., 15105.);
	Tri(24367., 7526.,80674., 64253., 15102.);
	Tri(37581., 101231.,69905., 64254., 15084.);
	Tri(4563., 16872.,3866., 65277., 15357.);
	Tri(27238., 21646.,54997., 64509., 15350.);
	Tri(81563., 19030.,8313., 1550., 15105.);
	Tri(14267., 25018.,-154., 258., 15105.);
	Tri(-139., 416.,24472., 2., 15105.);
	Tri(59257., 81743.,51053., 257., 15105.);
	Tri(45229., 70799.,32355., 2056., 15104.);
	Tri(124133., -200.,84793., 19604., 15105.);
	Tri(28767., 76985.,73360., 6941., 15110.);
	Tri(47943., 60234.,59187., 13., 15104.);
	Tri(14940., 117590.,139015., 28553., 12032.);
	Tri(-187., 119556.,-226., 570., 15106.);
	Tri(118494., 17727.,55607., 20609., 14849.);
	Tri(144280., 48692.,55387., 65021., 15358.);
	Tri(66413., 130864.,97474., 11923., 14850.);
	Tri(123715., 66885.,80753., 21649., 13319.);
	Tri(130332., 115401.,97478., 65008., 15286.);
	Tri(23583., 145258.,18949., 63995., 13817.);
	Tri(48492., 113500.,128816., 15228., 14850.);
	Tri(125161., 86796.,68442., 516., 14593.);
	Tri(91951., 128241.,60684., 258., 15110.);
	Tri(84858., 134398.,110275., 13174., 8960.);
	Tri(74547., 66244.,49332., 65021., 15353.);
	Tri(130801., 93526.,97122., 542., 15105.);
	Tri(127367., 120705.,97668., 1544., 15109.);
	Tri(138131., 22601.,134560., 65022., 7931.);
	Tri(48334., 64752.,81126., 5426., 13313.);
	Tri(88364., 92506.,106405., 64251., 15097.);
	Tri(128234., 101559.,34403., 3., 15104.);
	Tri(83627., 117033.,126752., 65017., 15354.);
	Tri(128090., 131659.,14542., 65015., 14078.);
	Tri(42933., 57253.,-108., 65278., 15100.);
	Tri(112380., 74396.,94941., 1542., 15105.);
	Tri(72850., 52957.,92923., 65018., 14585.);
	Tri(23703., 63728.,24724., 3359., 12889.);
	Tri(97928., 95367.,115199., 65278., 14833.);
	Tri(-141., 488.,30115., 621., 15106.);
	Tri(-44., 15294.,16264., 18025., 14593.);
	Tri(-23., 22468.,27560., 565., 15104.);
	Tri(72054., 86846.,50036., 3137., 13826.);
	Tri(73001., 48961.,99156., 513., 15106.);
	Tri(42691., 45199.,22674., 48629., 15174.);
	Tri(39240., 130840.,130302., 778., 15106.);
	Tri(52083., 60259.,24804., 65275., 8186.);
	Tri(68301., 57508.,61142., 15301., 14593.);
	Tri(47475., 100191.,93505., 4., 15106.);
	Tri(126230., 142023.,129198., 65277., 15354.);
	Tri(18201., -227.,48952., 17520., 13321.);
	Tri(69897., 68441.,99173., 574., 15104.);
	Tri(59666., 13083.,105313., 2368., 15105.);
	Tri(25743., 35987.,15978., 65228., 15353.);
	Tri(146757., 138042.,45875., 63206., 9447.);
	Tri(32865., 8303.,16012., 303., 15105.);
	Tri(29346., 112329.,31328., 23194., 14867.);
	Tri(108822., 79495.,101630., 64762., 14842.);
	Tri(130888., 11920.,72436., 65022., 15358.);
	Tri(82589., 47218.,105194., 1025., 15110.);
	Tri(112483., 118092.,42227., 65022., 10967.);
	Tri(84298., 89967.,106397., 65278., 15354.);
	Tri(108382., 52588.,56188., 10825., 14337.);
	Tri(92925., 28439.,45333., 65278., 15356.);
	Tri(-93., 9619.,-164., 257., 15104.);
	Tri(55515., 103782.,146903., 63484., 7918.);
	Tri(141172., 113312.,122103., 63996., 10493.);
	Tri(22924., 27583.,52154., 65277., 15101.);
	Tri(95438., 86205.,80598., 518., 15105.);
	Tri(121771., 141735.,138858., 65277., 15357.);
	Tri(30815., 9833.,79088., 8807., 14851.);
	Tri(16549., 10921.,119603., 65273., 15353.);
	Tri(21958., 22947.,5604., 53220., 15047.);
	Tri(23487., 71997.,32121., 65277., 15358.);
	Tri(130821., 125157.,16465., 33158., 15191.);
	Tri(57194., 106705.,48501., 65021., 13043.);
	Tri(93073., 62868.,418., 516., 15106.);
	Tri(49462., 2430.,58218., 65022., 15355.);
	Tri(-210., 32043.,140549., 65278., 15352.);
	Tri(16343., 30061.,1508., 63486., 13754.);
	Tri(21216., 54423.,53372., 64762., 14582.);
	Tri(106175., 132366.,124129., 256., 15107.);
	Tri(10857., 44657.,21594., 514., 15104.);
	Tri(74467., 99150.,93432., 6973., 15108.);
	Tri(84145., 79178.,88430., 514., 15105.);
	Tri(48334., 34408.,35507., 34975., 15189.);
	Tri(49317., 95406.,41580., 528., 15104.);
	Tri(26543., 53559.,-189., 65021., 15357.);
	Tri(57711., 47494.,67471., 65018., 15102.);
	Tri(53619., 50473.,9143., 65021., 15357.);
	Tri(101210., 134927.,105758., 9811., 13568.);
	Tri(120517., 101669.,93109., 64766., 8163.);
	Tri(61200., 26394.,61204., 2., 15105.);
	Tri(125237., 118998.,51064., 20., 7937.);
	Tri(18202., 36650.,60706., 53245., 11332.);
	Tri(8861., 13876.,7293., 65273., 15358.);
	Tri(33621., 41799.,49335., 62691., 8183.);
	Tri(55705., 127368.,118143., 33., 15105.);
	Tri(89927., 98122.,139508., 65277., 15314.);
	Tri(58127., 72033.,108791., 537., 15106.);
	Tri(54562., -204.,86306., 512., 15110.);
	Tri(133413., 124638.,80537., 2594., 15104.);
	Tri(18584., 101151.,107299., 65278., 15358.);
	Tri(142647., 35020.,144711., 61949., 12790.);
	Tri(106178., 88844.,122638., 55037., 14237.);
	Tri(23455., 87442.,18328., 512., 15105.);
	Tri(6051., 139656.,35225., 3., 15108.);
	Tri(18843., 134531.,29077., 1280., 15104.);
	Tri(131459., 141657.,41850., 65021., 15358.);
	Tri(10347., 107713.,24152., 0., 15104.);
	Tri(128759., 128307.,131342., 531., 15105.);
	Tri(111333., 31018.,40232., 57340., 7837.);
	Tri(102131., 113947.,121102., 64506., 15353.);
	Tri(22970., 6544.,-61., 64766., 15358.);
	Tri(99729., 126336.,28055., 0., 15104.);
	Tri(120533., 56442.,131886., 7238., 12290.);
	Tri(39586., 68345.,102126., 24206., 15119.);
	Tri(116552., 66608.,58913., 65021., 8439.);
	Tri(81624., 92393.,120535., 35014., 9531.);
	Tri(105142., 130804.,134893., 65276., 15358.);
	Tri(76046., 68397.,83756., 59388., 15255.);
	Tri(124228., 97095.,107869., 19338., 13312.);
	Tri(92490., 125228.,91434., 65021., 15344.);
	Tri(15475., 101665.,144160., 62461., 15311.);
	Tri(63792., 25892.,37713., 65277., 14589.);
	Tri(87347., 86329.,119777., 64510., 14068.);
	Tri(54888., 24730.,47817., 65276., 8153.);
	Tri(68749., 60592.,67766., 55663., 9203.);
	Tri(136147., 146750.,123968., 65277., 15357.);
	Tri(80661., 21588.,9334., 590., 7683.);
	Tri(62612., 50365.,66283., 65018., 15341.);
	Tri(66445., 1437.,61843., 513., 15106.);
	Tri(1147., 16011.,51865., 61689., 12286.);
	Tri(123766., 132073.,146474., 65273., 15358.);
	Tri(53110., 74613.,67939., 40668., 15143.);
	Tri(38697., 80155.,56601., 65021., 15305.);
	Tri(80070., 96949.,54910., 48886., 14681.);
	Tri(22939., 134536.,146816., 65021., 15357.);
	Tri(72859., 22637.,67754., 812., 15104.);
	Tri(103614., 82077.,62086., 2058., 15105.);
	Tri(50693., 4807.,32909., 64510., 9981.);
	Tri(16516., 30884.,47789., 4924., 12546.);
	Tri(96985., 102651.,113953., 258., 15106.);
	Tri(124289., 28568.,124295., 2., 15106.);
	Tri(53371., 131780.,3652., 61436., 14334.);
	Tri(125241., 120042.,79614., 61950., 10215.);
	Tri(-187., 62768.,284., 13165., 15105.);
	Tri(85251., 71942.,73508., 2., 15105.);
	Tri(67902., 69471.,108877., 257., 15104.);
	Tri(69870., 118071.,63684., 65277., 15355.);
	Tri(142248., 136061.,80599., 64252., 8186.);
	Tri(-212., 1841.,111893., 62974., 15351.);
	Tri(76883., 4639.,2656., 65021., 15358.);
	Tri(25691., 55495.,123618., 13708., 7682.);
	Tri(85000., 40206.,94310., 64765., 7934.);
	Tri(126264., 130841.,49483., 33716., 7939.);
	Tri(111868., 83142.,83662., 518., 12289.);
	Tri(139146., 6552.,2466., 281., 11010.);
	Tri(102664., 72359.,60139., 47358., 15218.);
	Tri(28597., -139.,-17., 54524., 8720.);
	Tri(146905., 128625.,131455., 65021., 15358.);
	Tri(50070., 88975.,120197., 65277., 15357.);
	Tri(30307., 16510.,18057., 2., 15106.);
	Tri(42704., 76381.,19200., 65277., 15340.);
	Tri(86176., 21592.,107271., 306., 11008.);
	Tri(84065., 38912.,13917., 65021., 15358.);
	Tri(25697., 44224.,57986., 41438., 14936.);
	Tri(11861., 40040.,60928., 65021., 15357.);
	Tri(133450., 80020.,56028., 62973., 9168.);
	Tri(370., -101.,22938., 258., 15106.);
	Tri(9828., 81971.,17925., 65278., 15358.);
	Tri(102159., 94380.,87305., 59642., 15308.);
	Tri(69527., 112523.,52118., 512., 14848.);
	Tri(93359., 25711.,17053., 65275., 7897.);
	Tri(117837., 143833.,146536., 65278., 15358.);

    col = col * smoothstep(60.0, 58.0, iGlobalTime);
    fragColor = vec4(min(col*1.1, 1.0), 1.0 );
}
//==============================================================================