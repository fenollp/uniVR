// Shader downloaded from https://www.shadertoy.com/view/MtBSRW
// written by shadertoy user capitanNeptune
//
// Name: Evolving Isles
// Description: First attemp in shader
// All noise and fbm from iq

#define time iGlobalTime*0.05

float noise3D(vec3 p)
{
	return fract(sin(dot(p ,vec3(12.9898,78.233,128.852))) * 43758.5453)*2.0-1.0;
}

float simplex3D(vec3 p)
{
	
	float f3 = 1.0/3.0;
	float s = (p.x+p.y+p.z)*f3;
	int i = int(floor(p.x+s));
	int j = int(floor(p.y+s));
	int k = int(floor(p.z+s));
	
	float g3 = 1.0/6.0;
	float t = float((i+j+k))*g3;
	float x0 = float(i)-t;
	float y0 = float(j)-t;
	float z0 = float(k)-t;
	x0 = p.x-x0;
	y0 = p.y-y0;
	z0 = p.z-z0;
	
	int i1,j1,k1;
	int i2,j2,k2;
	
	if(x0>=y0)
	{
		if		(y0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; } // X Y Z order
		else if	(x0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; } // X Z Y order
		else 			{ i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; } // Z X Z order
	}
	else 
	{ 
		if		(y0<z0) { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; } // Z Y X order
		else if	(x0<z0) { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; } // Y Z X order
		else 			{ i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; } // Y X Z order
	}
	
	float x1 = x0 - float(i1) + g3; 
	float y1 = y0 - float(j1) + g3;
	float z1 = z0 - float(k1) + g3;
	float x2 = x0 - float(i2) + 2.0*g3; 
	float y2 = y0 - float(j2) + 2.0*g3;
	float z2 = z0 - float(k2) + 2.0*g3;
	float x3 = x0 - 1.0 + 3.0*g3; 
	float y3 = y0 - 1.0 + 3.0*g3;
	float z3 = z0 - 1.0 + 3.0*g3;	
				 
	vec3 ijk0 = vec3(i,j,k);
	vec3 ijk1 = vec3(i+i1,j+j1,k+k1);	
	vec3 ijk2 = vec3(i+i2,j+j2,k+k2);
	vec3 ijk3 = vec3(i+1,j+1,k+1);	
            
	vec3 gr0 = normalize(vec3(noise3D(ijk0),noise3D(ijk0*2.01),noise3D(ijk0*2.02)));
	vec3 gr1 = normalize(vec3(noise3D(ijk1),noise3D(ijk1*2.01),noise3D(ijk1*2.02)));
	vec3 gr2 = normalize(vec3(noise3D(ijk2),noise3D(ijk2*2.01),noise3D(ijk2*2.02)));
	vec3 gr3 = normalize(vec3(noise3D(ijk3),noise3D(ijk3*2.01),noise3D(ijk3*2.02)));
	
	float n0 = 0.0;
	float n1 = 0.0;
	float n2 = 0.0;
	float n3 = 0.0;

	float t0 = 0.5 - x0*x0 - y0*y0 - z0*z0;
	if(t0>=0.0)
	{
		t0*=t0;
		n0 = t0 * t0 * dot(gr0, vec3(x0, y0, z0));
	}
	float t1 = 0.5 - x1*x1 - y1*y1 - z1*z1;
	if(t1>=0.0)
	{
		t1*=t1;
		n1 = t1 * t1 * dot(gr1, vec3(x1, y1, z1));
	}
	float t2 = 0.5 - x2*x2 - y2*y2 - z2*z2;
	if(t2>=0.0)
	{
		t2 *= t2;
		n2 = t2 * t2 * dot(gr2, vec3(x2, y2, z2));
	}
	float t3 = 0.5 - x3*x3 - y3*y3 - z3*z3;
	if(t3>=0.0)
	{
		t3 *= t3;
		n3 = t3 * t3 * dot(gr3, vec3(x3, y3, z3));
	}
	return 96.0*(n0+n1+n2+n3);
	
}

float fbm(vec3 p)
{
	float f;
    f  = 0.50000*(simplex3D( p )); p = p*2.01;
    f += 0.25000*(simplex3D( p )); p = p*2.02;
    f += 0.12500*(simplex3D( p )); p = p*2.03;
    f += 0.06250*(simplex3D( p )); p = p*2.04;
    f += 0.03125*(simplex3D( p )); p = p*2.05;
    f += 0.015625*(simplex3D( p ));
	return f;
}

//absolute value
float ridgedMultifractal(vec3 p)
{
	float f;
    f  = 0.50000*abs(simplex3D( p )); p = p*2.01;
    f += 0.25000*abs(simplex3D( p )); p = p*2.02;
    f += 0.12500*abs(simplex3D( p )); p = p*2.03;
    f += 0.06250*abs(simplex3D( p )); p = p*2.04;
    f += 0.03125*abs(simplex3D( p ));
	return f;
}

float inverseRidgedMultifractal(vec3 p)
{
	float f;
    f  = 0.50000*abs(simplex3D( p )); p = p*2.01;
    f += 0.25000*abs(simplex3D( p )); p = p*2.02;
    f += 0.12500*abs(simplex3D( p )); p = p*2.03;
    f += 0.06250*abs(simplex3D( p )); p = p*2.04;
    f += 0.03125*abs(simplex3D( p ));
	return 1.0-f;
}

float terrain( vec3 p )
{
    float terrain = 0.0;
    
    terrain += 0.95*fbm( p * vec3(1.0, 0.2, 0.2))*0.5+0.5; p = p*2.01;
    terrain += 0.05*inverseRidgedMultifractal( p );
    
    return terrain;
}

vec3 interpolateColors( float n , vec2 limits, vec3 startColor, vec3 endColor )
{
    float a = ((n-limits.x)/(limits.y-limits.x));
    float invn = 1.0 - a;
    return vec3(endColor.r * a + startColor.r * invn, 
                endColor.g * a + startColor.g * invn,
                endColor.b * a + startColor.b * invn);
}

vec3 colorize( float n )
{    
    if(n <= .60)		// static water
    {
        return interpolateColors(n, vec2(.0,.60), vec3(.06,.12,.24), vec3(.15,.23,.34));
    }
    else if(n <= .68)	// underwater sand
    {
        return interpolateColors(n, vec2(.60,.68), vec3(.15,.23,.34), vec3(.23,.34,.43));
    }
    else if(n <= .71)	// underwater coral rgb(30%, 56%, 55%)
    {
        return interpolateColors(n, vec2(.68,.71), vec3(.23,.34,.43), vec3(.30,.56,.55));
    }
    else if(n <= .712)	// beach rgb(70%, 56%, 42%)
    {
        return interpolateColors(n, vec2(.71,.712), vec3(.30,.56,.55), vec3(.87,.68,.39));
    }
    else if(n <= .725)	// beach2 rgb(87%, 68%, 39%)
    {
        return interpolateColors(n, vec2(.712,.725), vec3(.87,.68,.39), vec3(.27,.30,.15));
    }
    else if(n <= .80)	// grass
    {
        return interpolateColors(n, vec2(.725,.80), vec3(.27,.30,.15), vec3(.20,.25,.08));
    }
    else if(n <= .85)	// brown1
    {
        return interpolateColors(n, vec2(.80,.85), vec3(.20,.25,.08), vec3(.25,.25,.15));
    }
    else if(n <= .90)	// brown2
    {
        return interpolateColors(n, vec2(.85,.90), vec3(.25,.25,.15), vec3(.76,.68,.60));
    }
    else if(n <= .95)	// snow
    {
        return interpolateColors(n, vec2(.90,.95), vec3(.76,.68,.60), vec3(.85,.89,.85));
    }
    
    return vec3(n,n,n);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy*1.0-0.5;
    uv.x*=(iResolution.x/iResolution.y);
    float mx = iMouse.x>0.0?iMouse.x/iResolution.x:0.5;
    float my = iMouse.y>0.0?iMouse.y/iResolution.y:0.5;
	uv*=my*10.0;
    
    float n = 0.0;
    if(uv.x < (fragCoord.x / iResolution.x*1.0-0.5)*2.0)
    {
    	n = terrain(vec3(time, vec2(uv)));
    }
    else
    {
    	n = terrain(vec3(time, vec2(uv)));
    }
    
    float b = terrain(vec3(time, vec2(uv) - vec2(-.005, .005)));
    vec3 light = vec3(0.0,0.0,0.0);
    vec3 shadow = vec3(0.0,0.0,0.0);
    vec2 water_wind_direction = vec2(-time*0.5, time*0.2);
    
    //light
    if(b > n && n > 0.60)
    {
    	//shadow = interpolateColors(b, vec2(.6,1.0), vec3(.0), vec3(.15));
        //under the water
        if( n < 0.71)
        {
            float toadd = (b-n)*10.0;
            light = vec3(toadd);
            light = interpolateColors(n, vec2(0.60, 0.71), vec3(0.0), vec3(light));
        }
        else
        {
            float toadd = (b-n)*20.0;
       		light = vec3(toadd);
        }
    }
    //water  light
    else if(n < 0.71)
    {
        float b = inverseRidgedMultifractal(vec3((time+50.0)*0.5, water_wind_direction + uv - vec2(-.005, .005)));
        float v = inverseRidgedMultifractal(vec3((time+50.0)*0.5, water_wind_direction + uv));
        float toadd = (b-v)*0.5;
       	light += vec3(toadd);
    }
    //shadows
    b = terrain(vec3(time, vec2(uv)-vec2(.01, -.01)));
    
    if(b > n && n > 0.71)
    {
        float toadd = (b-n)*10.0;
       	shadow = vec3(toadd);
    }
    
    if(uv.x < (fragCoord.x / iResolution.x*1.0-0.5)*2.0)
    {
    	fragColor = vec4(colorize(n) + light - shadow, 1.0);
        //fragColor = vec4(n, n, n, 1.0);
    }
    else
    {
        fragColor = vec4(colorize(n) + light - shadow, 1.0);
    	//fragColor = vec4(n, n, n, 1.0);
    }
}