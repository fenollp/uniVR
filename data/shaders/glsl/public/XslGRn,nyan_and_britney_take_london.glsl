// Shader downloaded from https://www.shadertoy.com/view/XslGRn
// written by shadertoy user mtf
//
// Name: Nyan and Britney Take London
// Description: One of the more sophisticated demos out there
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

	vec2 uv    = -fragCoord.xy / iResolution.xy;
	vec2 uvCat =  fragCoord.xy / iResolution.xy;
	vec2 uvBrit = fragCoord.xy / iResolution.xy; 
	
	float run = .08 + (.32 * abs(sin(iGlobalTime)));
	run = floor(run * 30.0) / 30.0;
	
	uvCat = (uvCat - vec2(run,0.0)) / 
		    (vec2(1.02,0.9) - vec2(0.5,0.15));
	

	uvCat = clamp( uvCat, 0.0, 1.0 );
	
	// look where you're going kitty
	if( sin(2.0 * iGlobalTime) < 0.0){
		uvCat.x = 1.0 - uvCat.x;
	}
	
	float ofx = floor( mod( iGlobalTime * 12.0, 6.0 ) );
	float ww = 40.0 / 256.0;
	
	uvCat.x = (uvCat.x * ww) + (ofx * ww);
	uvCat.y = 1.0 - uvCat.y;
	
	uvBrit.y -= .4;
	
	vec4 fg   = texture2D( iChannel0, uvCat );
	
	float londonZoom = .4;
	float lz = londonZoom + (floor(sin(iGlobalTime/4.0)+1.0) * (1.0-londonZoom));
		
	vec4 bg   = texture2D( iChannel1, uv * vec2(lz) );
	vec4 brit = texture2D( iChannel2, uvBrit);
	
	float britMix = 0.6;
	float thresh = .3;
	if( brit[0] < thresh && 
	   	brit[1] > thresh && 
	    brit[2] < thresh ){
			britMix = 0.0;
	}
	
	float skyMix = 0.0;
	float skyThresh = .9;
	if( bg[0] > skyThresh &&
	    bg[1] > skyThresh &&
	    bg[2] > skyThresh &&
	    uv.y  < -.5
	  	){
			skyMix = 1.0;
	}
	
	//iq contact shadow from comments
	//16.2.13
	float occ = length( (uv - vec2(-0.25-run,-0.12))*vec2(2.0,6.0) ); 
	bg *= 0.3 + 0.7*smoothstep( 0.3, 0.9, occ );

	float rr = (sin(iGlobalTime) + 1.0)*.5;
	float gg = (sin(iGlobalTime  + 4.0)+1.0)*.5;
	float bb = (sin(iGlobalTime  + 3.0)+1.0)*.5;
	
	vec4 sky = vec4(rr, gg, bb, 1.0);
	vec4 col = mix(fg, bg, 1.0 - fg.w);
	vec4 britSky = mix(sky, brit, britMix);
	col = mix(col, britSky, skyMix);
	
	fragColor = col;

}