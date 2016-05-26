// Shader downloaded from https://www.shadertoy.com/view/MtfXDN
// written by shadertoy user aiekick
//
// Name: Blob eat blob Reduced (251c)
// Description: Reduced version of [url=https://www.shadertoy.com/view/ldjSWD]Blob eat blob[/url]
//    
//    1092c to 258c

// 215 by coyote
#define k(o) 1. - dot(V=v-f.o,V)/dot(f,f)
void mainImage( out vec4 f, vec2 v ) {

    f = iResolution.xyzz;
    vec2 V = v - .5*f.xy; float r=length(V);
    r = abs(V.x/r - cos(r*.1 + iDate.w * 5.));    
    f = r<.5 ? f-f : r*.5*vec4( k(z)+k(zy), k(xy)+k(zy), k(xz), 1);
}

/* 227 by FabriceNeyret2
#define k(o) vec2(0, 1. - dot(V=v-f.o,V)/dot(f,f) ).

void mainImage( out vec4 f, vec2 v ) {

    f.xyz = iResolution; 
	vec2 V = v - .5*f.xy; float r=length(V);
    
   	r = abs(V.x/r - cos(r*.1 + iDate.w * 5.));    
    f = k(z)yxxy +	k(xz)xxyy + k(xy)xyxy + k(zy)yyxy;
    f *= r < .5 ? 0. : r*.5;
}
*/
    
/* 251 by 104
#define k(o) (1. - dot(d=v-f.o,d)/r) * vec2(0,1).
void mainImage( out vec4 f, vec2 v )
{
    f.xyz = iResolution; // iResolution.z = 0. for the moment :)
	vec2 V = v - (f.xy * .5),d;
    
    float r = dot(f, f);
    
    f = k(z)yxxy +	k(xz)xxyy + k(xy)xyxy + k(zy)yyxy;
	
   	r = abs(cos(atan(V.y, V.x)) - cos((length(V)*.1 + iDate.w * 5.)))*.5;
    
    f *= r < .25?0.:r;
}
*/

/* 258 by me
#define k(o) (1. - dot(d=v-R.o,d)/r) * c.
void mainImage( out vec4 f, vec2 v )
{
    vec3 R = iResolution; // iResolution.z = 0. for the moment :)
	vec2 V = v - (R.xy * .5),d,c=vec2(0,1);
    
    float r = dot(R, R);
    
    f = k(z)yxxy +	k(xz)xxyy + k(xy)xyxy + k(zy)yyxy;
	
    r = abs(cos(atan(V.y, V.x)) - cos((length(V)/10. + iDate.w * 5.)));

    f *= (r < .5)?0.:r*.5;
}
*/

/* 454c chars by me
void mainImage( out vec4 f, vec2 v )
{
    vec2 R = iResolution.xy,d,c=vec2(0,1);
	vec2 uv = v - (iResolution.xy * 0.5);
    
    float rem = abs(cos(atan(uv.y, uv.x)) - cos((length(uv) + iDate.w * 50.) / 10.));

	float tar = dot(R, R);//toal area

    vec4 res = (tar - dot(v, v)) / tar * vec4(1, 0, 0, 1);
    res += (tar - dot((d= v - vec2(R.x, 0)), d)) / tar * vec4(0, 0, 1, 1);
    res += (tar - dot((d= v -  R), d)) / tar * vec4(0, 1, 0, 1);
    res += (tar - dot((d= v - vec2(0, R.y)), d)) / tar * vec4(1, 1, 0, 1);

    f = res * 0.5;
    
	if (rem < 0.5) 
		f *= vec4(vec3(0), 1.0);
	else
		f *= vec4(vec3(rem), 1.0);
}
*/

/* original 1092 chars
#define alpha 0.0
#define beta 10.0

vec4 getCornerColors(vec2 coord)
{
    vec4 cornerColors[4];
	
    cornerColors[0] = vec4(1.0, 0, 0, 1.0);
    cornerColors[1] = vec4(0, 0, 1.0, 1.0);
    cornerColors[2] = vec4(0, 1.0, 0.0, 1.0);
    cornerColors[3] = vec4(1.0, 1.0, 0.0, 1.0);
        
    vec2 cornerCoords[4];
    cornerCoords[0] = vec2(0);
    cornerCoords[1] = vec2(1, 0);
    cornerCoords[2] = vec2(1);
    cornerCoords[3] = vec2(0, 1);

    
	vec4 result = vec4(0.0);

	float totalArea = dot(iResolution.xy, iResolution.xy);

	for(int i = 0; i < 4; i++)
	{
		vec2 cCoord = cornerCoords[i] * iResolution.xy;

		vec2 diff = coord - cCoord;

		float area = dot(diff, diff);

		result += ((totalArea - area) / totalArea) * cornerColors[i];
	}

	return result;
}

vec4 spiral4(vec2 coord)
{	
	float alpha_t = alpha - iGlobalTime * 50.0;

	float x = coord.x;
	float y = coord.y;

	float r = sqrt(dot(coord, coord));

	float phi = atan(y, x);

	float phi_r = (r - alpha_t) / beta;

	float r_phi = alpha_t + (beta * phi);

	float remainder = abs(cos(phi) - cos(phi_r));

	if (remainder < 0.5)
	{
		return vec4(vec3(0), 1.0);
	}
	else
	{
		return vec4(vec3(remainder), 1.0);
	}
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy - (iResolution.xy * 0.5);
	//fragColor = spiral4(uv) * vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
    fragColor = spiral4(uv) * (getCornerColors(fragCoord.xy) * 0.5);
}*/