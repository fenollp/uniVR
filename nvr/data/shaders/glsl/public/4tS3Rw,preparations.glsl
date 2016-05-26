// Shader downloaded from https://www.shadertoy.com/view/4tS3Rw
// written by shadertoy user movAX13h
//
// Name: Preparations
// Description: An army is moving east. 
//    Mixture of a 3D scene with 2D sprites.
// Preparations, fragment shader by movAX13h, March 2015
// 3D scene, animated 2D sprites

#define time iGlobalTime

//----------------------------------------------------

#define MAX_SLICES 10
#define MAX_COLORS 5
#define MAX_FRAMES 3

struct Frame
{
	int s[MAX_SLICES];  // slices
	vec3 c[MAX_COLORS]; // colors
};

Frame iAnt[MAX_FRAMES];
Frame iAnt2[MAX_FRAMES];
	
void loadSprites()
{
	iAnt[0].c[0]=vec3(0.0); iAnt[0].c[1]=vec3(0.289,0.258,0.223); iAnt[0].c[2]=vec3(0.387,0.387,0.387); iAnt[0].c[3]=vec3(0.191,0.160,0.129);	
	iAnt[0].s[0]=6295616; iAnt[0].s[1]=4525316; iAnt[0].s[2]=7668992; iAnt[0].s[3]=12852484; iAnt[0].s[4]=7407888; iAnt[0].s[5]=6310160; iAnt[0].s[6]=1024; 
	iAnt[1].s[0]=6291520; iAnt[1].s[1]=4545792; iAnt[1].s[2]=7685376; iAnt[1].s[3]=12848385; iAnt[1].s[4]=7407888; iAnt[1].s[5]=6359312; iAnt[1].s[6]=1028;
	iAnt[2].s[0]=6291520; iAnt[2].s[1]=4525312; iAnt[2].s[2]=7607556; iAnt[2].s[3]=12864784; iAnt[2].s[4]=7407888; iAnt[2].s[5]=6297860; iAnt[2].s[6]=1024; 

	iAnt2[0].c[0]=vec3(0.0); iAnt2[0].c[1]=vec3(0.289,0.258,0.223); iAnt2[0].c[2]=vec3(0.258,0.223,0.191); iAnt2[0].c[3]=vec3(0.387,0.387,0.387); iAnt2[0].c[4]=vec3(0.191,0.160,0.129);	
	iAnt2[0].s[0]=0; iAnt2[0].s[1]=6292544; iAnt2[0].s[2]=6592011; iAnt2[0].s[3]=8983056; iAnt2[0].s[4]=18452; iAnt2[0].s[5]=657698; iAnt2[0].s[6]=4325408; iAnt2[0].s[7]=10240; iAnt2[0].s[8]=1056; iAnt2[0].s[9]=160; 
	iAnt2[1].s[0]=0; iAnt2[1].s[1]=6292544; iAnt2[1].s[2]=6590987; iAnt2[1].s[3]=8983056; iAnt2[1].s[4]=18452; iAnt2[1].s[5]=4327696; iAnt2[1].s[6]=1114144; iAnt2[1].s[7]=8208; iAnt2[1].s[8]=65680; iAnt2[1].s[9]=128; 
	iAnt2[2].s[0]=0; iAnt2[2].s[1]=6292544; iAnt2[2].s[2]=6590987; iAnt2[2].s[3]=8983056; iAnt2[2].s[4]=18452; iAnt2[2].s[5]=1181856; iAnt2[2].s[6]=4194336; iAnt2[2].s[7]=2176; iAnt2[2].s[8]=1280; iAnt2[2].s[9]=34;
}

// constant array index workaround --
Frame frame(Frame frames[MAX_FRAMES], int id) 
{
	for(int i = 0; i < MAX_FRAMES; i++)	{ if (i == id) return frames[i]; }
	return frames[1];
}

float slice(int id, in Frame f) 
{
	for(int i = 0; i < MAX_SLICES; i++)	{ if (i == id) return float(f.s[i]); }
	return 0.0;	
}

vec3 color(int id, in Frame f) 
{
	for(int i = 0; i < MAX_COLORS; i++) { if (i == id) return f.c[i]; }
	return vec3(0.0);
}
// --

int sprite(vec2 p, in Frame f, vec2 size, in int pxPerInt, in int bitsPerPx)
{
	int d = 0; p = floor(p);
	p.x = size.x - p.x - 1.0; // correction
	if (clamp(p.x, 0.0, size.x-1.0) == p.x && clamp(p.y, 0.0, size.y-1.0) == p.y)
	{
		float k = p.x + size.x*p.y, s = floor(k / float(pxPerInt)), n = slice(int(s), f);
		k = floor((k - s*float(pxPerInt))*float(bitsPerPx));
		if (int(mod(n/(exp2(k)),2.0)) == 1) d += 1;
		if (bitsPerPx > 1 && int(mod(n/(exp2(k+1.0)),2.0)) == 1) d += 2;
		if (bitsPerPx > 2 && int(mod(n/(exp2(k+2.0)),2.0)) == 1) d += 4;
	}
	return d;
}

void antV(inout vec3 col, vec2 p)
{
	p.y = mod(p.y, 20.0);
	
	float f = floor(iGlobalTime * 18.0);
	
	if (p.x <= 0.0)
	{
		p.x -= step(p.x, 0.0);
		p.x = abs(p.x);	
		f++;
	}
	
	f = floor(mod(f, 3.0));
	
	int i = sprite(p, frame(iAnt, int(f)), vec2(6.0, 13.0), 12, 2);
	col = mix(col, color(i, iAnt[0]), min(0.8, float(i)));
    
    col = mix(col, vec3(0.0), 0.5*smoothstep(5.0, 0.0, length(vec2(1.0, 0.6)*p-vec2(2.0, 7.0)))); // shadow
}

void antH(inout vec3 col, vec2 p)
{
	float id = floor(p.x / 20.0);
	p.x = mod(p.x, 20.0);
	
	float f = -floor(iGlobalTime * 13.0) + id;
	f = floor(mod(f, 3.0));
	
	int i = sprite(p, frame(iAnt2, int(f)), vec2(13.0, 6.0), 8, 3);
	col = mix(col, color(i, iAnt2[0]), min(0.7, float(i)));
    
    col = mix(col, vec3(0.0), 0.4*smoothstep(5.0, 0.0, length(vec2(0.6, 1.0)*p-vec2(6.0, 5.0)))); // shadow
}

//----------------------------------------------------


float rand(float n)
{
    return fract(sin(n * 0.84949385) * 43758.5453123);
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 floorTex(vec2 uv)
{
	return texture2D(iChannel0, uv * 0.4).b * vec3(0.6, 0.4, 0.2);
}

float height(vec2 p)
{
    float r = length(p);
    return 0.25*r + 0.14*cos(5.0*r);
}

vec4 scene(vec3 p)
{
	// plane
	vec3 ft = floorTex(p.xz);
	float d = abs(p.y - 0.08 + height(p.xz) + 0.3 - 0.1*smoothstep(0.0, 0.5, ft.b));
	vec3 col = ft*2.4 - 0.5*abs(sin(p.x));
	return vec4(col, d);
}
	
vec3 normal(vec3 p)
{
	float c = scene(p).w;
	vec2 h = vec2(0.01, 0.0);
	return normalize(vec3(scene(p + h.xyy).w - c, 
						  scene(p + h.yxy).w - c, 
		                  scene(p + h.yyx).w - c));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
    vec2 pos = (fragCoord.xy*2.0 - iResolution.xy) / iResolution.y;
    float focus = 3.14;
    float far = 6.5;
	float dist = 0.0;
	
    float a = 0.8*sin(0.2*time);
	
    vec3 cp;
    int at;
    float ad;
    
	vec3 ct = vec3(0.0, -0.2, 0.0);
    float t = mod(time, 15.0);

    if (t < 5.0)
    {
        cp = vec3(1.8, 0.7, -1.8);
        at = 0;
        ad = 1.0;
    }
    else if (t < 10.0)
    {
        cp = vec3(2.2, 2.7, 0.2);
        at = 1;
        ad = 1.0;
    }
    else
    {
        cp = vec3(2.2, 1.7, 2.2);
        at = 2;
        ad = -1.0;
		ct = vec3(1.0, -0.2, 0.0);
    }
    
	
    #if 0
	if (iMouse.z > 0.0)
	{
		float d = (iResolution.y-iMouse.y)*0.01+0.5;
		cp = vec3(sin(iMouse.x*0.01)*d, 1.4*sin(2.8+iMouse.y*0.001)*d, cos(iMouse.x*0.01)*d);
	}
    #endif
	
	vec3 cd = normalize(ct-cp);
	vec3 cu  = vec3(0.0, 1.0, 0.0);
	vec3 cs = cross(cd, cu);
	vec3 dir = normalize(cs*pos.x + cu*pos.y + cd*focus);
	vec3 ray = cp;
	bool hit = true;
	vec3 col = vec3(0.0);
	vec4 s;
    
    for(int i=0; i < 80; i++) 
	{
        s = scene(ray);
        s.w *= 0.2;
        dist += s.w;
        ray += dir * s.w;

        col = s.rgb;
		
        if(dist > far) 
		{
			dist = far;
            hit = false;
			break;
		}
    }
	
    float b = 1.0 - dist/far;
	col = b * s.rgb;

    if (!hit)
    {
        dir.y *= 0.5;
        vec3 q = 0.9*textureCube(iChannel2, dir).rgb;
        q.b *= smoothstep(0.5, 0.7, q.g);
    	col = q;
    }
 	
    // ants
    loadSprites();
    vec2 p;
    float id;
   	p.x = fragCoord.x - iResolution.x * 0.5;    
    
    if (at == 0)
    {
	    p.y = fragCoord.y - iResolution.y * (0.44 - 0.37*height(vec2(3.0*p.x/iResolution.x, 0.0)));
        float ax = ad*time*50.0-p.x;
        id = floor(ax / 20.0);
        p.y += 40.0*rand(id);
        antH(col, vec2(ad*ax, -p.y));
    }
    else if (at == 1)
    {
        p.y = fragCoord.y - iResolution.y * 0.48;
        p *= 0.7+0.5*fragCoord.y/iResolution.y;
        float ay = time*60.0-p.y;
        id = floor(ay / 20.0);
        float r = rand(id);
        p.x += -10.0 + 80.0*r - 0.4*p.y;
        p.x += 20.0*r*sin(time*r+r*123.3844);
	   	antV(col, vec2(p.x, ay));
    } 
    else
    {
	    p.y = fragCoord.y - iResolution.y * (0.6 - 0.3*height(vec2(1.0+3.0*p.x/iResolution.x, 0.0)));
        float ax = ad*time*50.0-p.x;
        id = floor(ax / 20.0);
        p.y += 40.0*rand(id);
        antH(col, vec2(ad*ax, -p.y));
    }
    
    // color correction & post processing
	col = clamp(col, vec3(0.0), vec3(1.0));
	col = pow(col, vec3(2.2, 2.4, 2.5)) * 3.5;
	col = pow(col, vec3(1.0 / 2.5));    
	col -= smoothstep(0.4, 1.0, abs(pos.y));
    col *= 1.0 - 0.2*rand(pos);
    col *= min(1.0, abs(2.6*sin(3.1415*time/5.0))); // blend
    
	fragColor = vec4(col, 1.0);
}
