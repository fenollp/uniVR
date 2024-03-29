// Shader downloaded from https://www.shadertoy.com/view/ltfXD2
// written by shadertoy user Flyguy
//
// Name: 16 Segment Display
// Description: A 16 segment display with binary-packed characters. 
//    The segment layout was made in Blender and converted into glsl code using Processing.
/*
16 segment display

Segment bit positions:

  __2__ __1__
 |\    |    /|
 | \   |   / |
 3  11 10 9  0
 |   \ | /   |
 |    \|/    |
  _12__ __8__
 |           |
 |    /|\    |
 4   / | \   7
 | 13 14  15 |
 | /   |   \ |
  __5__|__6__

15                 0
 |                 |
 0000 0000 0000 0000

example: letter A

   12    8 7  4 3210
    |    | |  | ||||
 0001 0001 1001 1111

 binary to hex -> 0x119F
 
 float c_a = float(0x119F)
*/

float c_a = float(0x119F);
float c_b = float(0x927E);
float c_c = float(0x007E);
float c_d = float(0x44E7);
float c_e = float(0x107E);
float c_f = float(0x101E);
float c_g = float(0x807E);
float c_h = float(0x1199);
float c_i = float(0x4466);
float c_j = float(0x4436);
float c_k = float(0x9218);
float c_l = float(0x0078);
float c_m = float(0x0A99);
float c_n = float(0x8899);
float c_o = float(0x00FF);
float c_p = float(0x111F);
float c_q = float(0x80FF);
float c_r = float(0x911F);
float c_s = float(0x8866);
float c_t = float(0x4406);
float c_u = float(0x00F9);
float c_v = float(0x2218);
float c_w = float(0xA099);
float c_x = float(0xAA00);
float c_y = float(0x4A00);
float c_z = float(0x2266);

float c_com = float(0x2000);
float c_spc = 0.0;

float c_nl = -1.0;

//Distance to line p0,p1 at uv
float dseg(vec2 p0,vec2 p1,vec2 uv)
{
	vec2 dir = normalize(p1 - p0);
	uv = (uv - p0) * mat2(dir.x, dir.y,-dir.y, dir.x);
	return distance(uv, clamp(uv, vec2(0), vec2(distance(p0, p1), 0)));   
}

//Checks if bit 'b' is set in number 'n'
bool bit(float n, float b)
{
	return mod(floor(n / exp2(floor(b))), 2.0) != 0.0;
}

//Distance to the character defined in 'bits'
float dchar(float bits, vec2 uv)
{
	float d = 1e6;	

	float n = floor(bits);
	
	if(bits != 0.0)
	{
        //Segment layout and checking.
		d = bit(n,  0.0) ? min(d, dseg(vec2( 0.500,  0.063), vec2( 0.500,  0.937), uv)) : d;
		d = bit(n,  1.0) ? min(d, dseg(vec2( 0.438,  1.000), vec2( 0.063,  1.000), uv)) : d;
		d = bit(n,  2.0) ? min(d, dseg(vec2(-0.063,  1.000), vec2(-0.438,  1.000), uv)) : d;
		d = bit(n,  3.0) ? min(d, dseg(vec2(-0.500,  0.937), vec2(-0.500,  0.062), uv)) : d;
		d = bit(n,  4.0) ? min(d, dseg(vec2(-0.500, -0.063), vec2(-0.500, -0.938), uv)) : d;
		d = bit(n,  5.0) ? min(d, dseg(vec2(-0.438, -1.000), vec2(-0.063, -1.000), uv)) : d;
		d = bit(n,  6.0) ? min(d, dseg(vec2( 0.063, -1.000), vec2( 0.438, -1.000), uv)) : d;
		d = bit(n,  7.0) ? min(d, dseg(vec2( 0.500, -0.938), vec2( 0.500, -0.063), uv)) : d;
		d = bit(n,  8.0) ? min(d, dseg(vec2( 0.063,  0.000), vec2( 0.438, -0.000), uv)) : d;
		d = bit(n,  9.0) ? min(d, dseg(vec2( 0.063,  0.063), vec2( 0.438,  0.938), uv)) : d;
		d = bit(n, 10.0) ? min(d, dseg(vec2( 0.000,  0.063), vec2( 0.000,  0.937), uv)) : d;
		d = bit(n, 11.0) ? min(d, dseg(vec2(-0.063,  0.063), vec2(-0.438,  0.938), uv)) : d;
		d = bit(n, 12.0) ? min(d, dseg(vec2(-0.438,  0.000), vec2(-0.063, -0.000), uv)) : d;
		d = bit(n, 13.0) ? min(d, dseg(vec2(-0.063, -0.063), vec2(-0.438, -0.938), uv)) : d;
		d = bit(n, 14.0) ? min(d, dseg(vec2( 0.000, -0.938), vec2( 0.000, -0.063), uv)) : d;
		d = bit(n, 15.0) ? min(d, dseg(vec2( 0.063, -0.063), vec2( 0.438, -0.938), uv)) : d;
	}
	
	return d;
}

const int NUM_CHARS = 16;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = ( fragCoord / iResolution.y ) * 8.0;
	
	float ch[NUM_CHARS];
	
	ch[ 0] = c_h;
	ch[ 1] = c_e;
	ch[ 2] = c_l;
	ch[ 3] = c_l;
	ch[ 4] = c_o;
    ch[ 5] = c_com;
	ch[ 6] = c_nl;
	ch[ 7] = c_s;
	ch[ 8] = c_h;
	ch[ 9] = c_a;
    ch[10] = c_d;
    ch[11] = c_e;
    ch[12] = c_r;
    ch[13] = c_t;
    ch[14] = c_o;
    ch[15] = c_y;
	
	//Printing and spacing
	vec2 ch_size = vec2(1.0, 2.0);
	vec2 ch_space = ch_size + vec2(0.25, 0.25);
	
    vec2 uvc = mod(uv, ch_space) - (ch_size / 2.0) - 0.125; //Per-character repeated uv space
    vec2 uvt = floor(uv / ch_space); //Character screen position
    
    float char = 0.0; //Character to print
    
	vec2 cursor = vec2(0.0,2.0); //Print position cursor
	
    float index = 0.0; //Character index (for animation)
    
	for(int i = 0;i < NUM_CHARS;i++)
	{
        if(uvt == cursor)
        {
            if(ch[i] >= 0.0) //Don't print control characters.
            {
				char = ch[i];
            }
            break;
        }
        
        if(ch[i] == c_nl) //Insert a new line after c_nl
        {
			cursor.y--;
            cursor.x = 0.0;
        }
        else
        {
        	index++; 
            cursor.x++; //Move cursor.
        }
	}
    
    //Glitch fade-in animation
	float anim_time = clamp(iGlobalTime * 0.3, 0.0, 1.0) * float(NUM_CHARS);
    
    char = mix(0.0, char, clamp(anim_time - index, 0.0, 1.0));
    
	float dist = dchar(char, uvc);
    
	//Shading
	vec3 color = vec3(0.0);
	
	color = mix(vec3(2.0, 0.8, 0.1), vec3(0.0, 0.0, 0.0), smoothstep(0.01, 0.04, dist) - (0.0001 / (dist * dist)));
	
	fragColor = vec4(color, 1.0);

}