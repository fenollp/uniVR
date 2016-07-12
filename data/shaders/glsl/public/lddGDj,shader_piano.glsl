// Shader downloaded from https://www.shadertoy.com/view/lddGDj
// written by shadertoy user NinjaKoala
//
// Name: Shader Piano
// Description: Shader Piano
//    My original plan was to make it functional with GPU sound, but i then realized it wasn't possible because i don't have access to the Render buffers in the sound shader :(
float border=2./iResolution.x;

void black_key_render(vec4 color1, vec4 color2, vec2 uv, float pos, float pitch_offset, float curr_pitch, inout vec4 color){

	float mod_x=mod(uv.x+4.*59./725.,413./725.);
	float div_x=floor((uv.x+4.*59./725.)/(413./725.));

	vec4 col;
	if(curr_pitch == pitch_offset+div_x*12.){
		col=color1;
	}
	else{
		col=color2;
	}
	color=mix(color,col,smoothstep(-border,0.,5./29.-abs(uv.y-.25+5./29.))*smoothstep(-border,0.,127./5800.-abs(mod_x-pos/5800.)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv=fragCoord.xy/iResolution.xy;
	uv-=.5;
    uv.y*=iResolution.y/iResolution.x;

	vec4 black=vec4(0,0,0,1);
	vec4 white=vec4(1,1,1,1);
	vec4 grey=vec4(.5,.5,.5,1);
	vec4 green=vec4(0,1,0,1);
	vec4 color=white;

	//white key location:
	float key_loc = floor(725./59.*(uv.x+531./1450.));
    

	//key_loc=-46.; //bad location ;) triggers weird bug
	//float pitch=-79.; //corresponding pitch

	//white key pitch:
	float pitch=float((2*int(key_loc) - int(floor((float(key_loc)+.5)/3.5))));

	//float mouse_pitch=floor(mod(iGlobalTime*1.,22.))-3.;
    float mouse_pitch = texture2D(iChannel0,vec2(0)).r;

	if(mouse_pitch==pitch){
		color=green;
	}
	
	//white key horizontal border
	color=mix(black,color,smoothstep(0.,border,abs(mod(uv.x,59./725.)-59./1450.)));
	
	//black keys
	
	black_key_render(green, black, uv, 183., 1., mouse_pitch, color);
	black_key_render(green, black, uv, 743., 3., mouse_pitch, color);
	black_key_render(green, black, uv, 1577., 6., mouse_pitch, color);
	black_key_render(green, black, uv, 2115., 8., mouse_pitch, color);
	black_key_render(green, black, uv, 2653., 10., mouse_pitch, color);
	

	//vertical border
	color=mix(white,color,step(0.,.25 - abs(uv.y)));
	color=mix(black,color,smoothstep(0.,border,abs(.25-abs(uv.y))));

	fragColor=color;
}
