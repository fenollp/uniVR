// Shader downloaded from https://www.shadertoy.com/view/4ls3zM
// written by shadertoy user dakrunch
//
// Name: Manta Ray
// Description: v2.0: 
//    Improving the distance functions (tail still todo)
//    Worked on the anatomy.
//    Added gills.
//    Need to work on tracing the wings more efficiently.
// version 2.0 = new anatomy, improved distance functions
// version 1.5 = trying to make the water surface and the sea floor more interesting
// version 1.3 = changed wing primitives and adding front flaps
// version 1.2 = working on improving the shape
// version 1.1 = multiple mantas. Added scattering attributes
// Version 1.0 = creation. Added a background. Single manta swim loop


const vec3 sun = vec3(-0.6, 0.4,-0.3);
float time = iGlobalTime+32.2;
vec3 lightDir = normalize(vec3(.1,.7, .2));
#define csb(f, con, sat, bri) mix(vec3(.5), mix(vec3(dot(vec3(.2125, .7154, .0721), f*bri)), f*bri, sat), con)
#define MATERIAL_DEBUG 2.0
#define MATERIAL_SKIN 1.0
#define MATERIAL_NONE 0.0

// Quality modifiers
#define SPACING 3.5
#define BBSIZE 1.75
#define MAXDIST 40.
#define MAXSTEPS 300
#define TRACEMULT .3

// debug
#define DEBUG 0

//--------------------------------------------------------------------------------------
// Utilities....
float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

vec3 Rotate_Y(vec3 v, float angle)
{
	vec3 vo = v; float cosa = cos(angle); float sina = sin(angle);
	v.x = cosa*vo.x - sina*vo.z;
	v.z = sina*vo.x + cosa*vo.z;
	return v;
}

// stolen from IQ.
float softMin(float a, float b, float k)
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

float sphere(vec3 p, float r)
{
    return length(p) - r;
}

float sdEllipsoid( in vec3 p, in vec3 r )
{
    // calculate deformed radius, not exact but decent estimate
    float smallestSize = min(min(r.x,r.y),r.z);
    vec3 deformedP = p/r;
    float d = length(deformedP) - 1.0;
    // renormalize - ish
   	return d * smallestSize;
}

float wings(in vec3 p) 
{   
    vec3 r = vec3(1.5, 0.15, 0.55);
    //vec3 r = vec3(1.0);
    float smallestSize = min(min(r.x,r.y),r.z);
    // scale and position
    vec3 dp = p/r;
    dp.z -= dp.x*dp.x*0.8; //bend backward
    dp.z -= (dp.x-0.6)*(dp.x-0.5);
    dp.y -= 0.6; // lift up
    // shape
    //float d = length(dp.zy);
    float d = (dp.y*dp.y + dp.z*dp.z);
    d += abs(dp.x);
    d -= 1.0; // radius
    
    return d * smallestSize;
}

float mantabody(in vec3 p)
{
    // body
    float d = sdEllipsoid(p, vec3(0.4,0.3,0.8));
    //float d = 10.;
    
    // wings
    if (p.z < 1.0 && p.z > -1.4 &&
       	p.y < 1.0 && p.y > -0.2) 
    {
    	d = softMin(d, wings(p), 0.4);
        //d = wings(p);
    }
    
    vec3 flapsP;
    vec3 flapsScale;
    
    // bottom flaps
    if (p.x < 1.0 && 
        p.z < -0.2 && p.z > -1.4 &&
       	p.y < 0.2 && p.y > -0.2) 
    {
        flapsP = p;
    	flapsP += vec3(-0.5-p.z*0.2,0.3-p.x*0.5,1.0-p.x*0.2);
	    flapsScale = vec3(.09,.08,.25);
    	d = softMin(d, sdEllipsoid(flapsP,flapsScale),0.2);
    }
    
    // dorsal fin
    if (p.x < 0.2 && 
        p.z > 0.3 && p.z < 1.0 &&
       	p.y > 0.1 && p.y < 0.5) 
    {
	    flapsP = p;
    	flapsP += vec3(0.,-0.15- 0.2*p.z,-0.7);
	    flapsScale = vec3(.03,.1,.2);
    	d = softMin(d, sdEllipsoid(flapsP,flapsScale),0.15);
    }
    
    //
    if (p.z>0.0) {    
	    float taild = length(p.xy);
    	d = softMin(d,taild,0.1);
        d = max(d, smoothstep(2.3,2.5,p.z));
    }
    
    
    return d;
}

float GetMantaScale(in float rowId, in float columnId)
{
	return 0.6 + 0.6*hash(7.*rowId + 11.* columnId);
}


float animatedManta(in vec3 p, in float rowId, in float columnId) 
{   
    float size = GetMantaScale(rowId, columnId);
    
    // animate
    float timeloop = time * 2.5 / (size-0.25) + // loop speed
        hash(rowId+3.*columnId) * 10.; // random offset
    p.y+= -sin(timeloop-0.5)*.25 * size;
    p.y+= sin(time*0.5 + hash(37.*rowId+11.*columnId)*17.) * 2.5;
    
 	vec3 mantap = p/size;
    mantap.x = abs(mantap.x);    
 
    float animation = sin(timeloop-3. - 1.3*mantap.z);
    float animationAmount = pow(mantap.x,1.5);
    animationAmount = min(animationAmount, 2.5); // cap max deformation to avoid alias on wings
    mantap.y += animation * (0.3*animationAmount + 0.15);
    
    float d = mantabody(mantap);
    
    return d*size;
}


//--------------------------------------------------------------------------------------
vec2 Scene(vec3 p, in int includeNeighbors, in int debug)
{
    p.z+= time;
	float mat = MATERIAL_SKIN;
    
    // Repeat
    vec3 loopP = p;
    loopP.x = mod(loopP.x+BBSIZE, SPACING)-BBSIZE;
    loopP.z = mod(loopP.z+BBSIZE, SPACING)-BBSIZE;

    //scramble
    float rowId = floor((p.x+ BBSIZE)/SPACING);
    float columnId = floor((p.z+ BBSIZE)/SPACING);
    
    float d = animatedManta(loopP, rowId, columnId);
    // careful about BB edges!
    if (includeNeighbors == 1) 
    {
        d = min(d, BBSIZE+0.1-abs(loopP.x));
        d = min(d, BBSIZE+0.1-abs(loopP.z));
    }
    
    
    if (debug == 1) 
    {
        float planeD = abs(p.y - 2.*sin(time));
        
        //if (planeD < d) {
            d = planeD;
            mat = MATERIAL_DEBUG;
        //}
    }

	return vec2(d, mat);
}

//--------------------------------------------------------------------------------------
vec4 Trace(vec3 rayOrigin, vec3 rayDirection, out float hit)
{
	const float minStep = 0.005;
    hit = 0.0;
	
    vec2 ret = vec2(0.0, 0.0);
    vec3 pos = rayOrigin;
	float dist = 0.0;
    for(int i=0; i < MAXSTEPS; i++){
		if (hit == 0.0 && dist < MAXDIST && pos.y<10.0 && pos.y > -10.0 )
        {
            pos = rayOrigin + dist * rayDirection;
            
            // ret.x: distance, ret.y: material type
            ret = Scene(pos, 1, DEBUG);
            
            if (ret.x < 0.01)
                hit = ret.y;

            // increment
            if (ret.y >= 2.0)
                dist += ret.x * 10.0;
            else 
            {
            	float increment = ret.x*TRACEMULT;
                increment = max(minStep, increment);
                dist += increment;
            }
        }
    }
    return vec4(pos, ret.y);
}

//--------------------------------------------------------------------------------------
vec3 GetNormal(vec3 p)
{
	vec3 eps = vec3(0.0001,0.0,0.0);
	return normalize(vec3(Scene(p+eps.xyy,0, 0).x-Scene(p-eps.xyy,0, 0).x,
						  Scene(p+eps.yxy,0, 0).x-Scene(p-eps.yxy,0, 0).x,
						  Scene(p+eps.yyx,0, 0).x-Scene(p-eps.yyx,0, 0).x ));
}

//--------------------------------------------------------------------------------------
vec3 GetColour(vec4 p, vec3 n, vec3 org, vec3 dir)
{
    vec3 localP = vec3(p) + vec3(0.,0.,time);
    vec3 loopP = localP;
    loopP.x = mod(loopP.x+BBSIZE, SPACING)-BBSIZE;
    loopP.z = mod(loopP.z+BBSIZE, SPACING)-BBSIZE; 

    //scramble
    float rowId = floor((localP.x+0.5*SPACING)/SPACING);
    float columnId = floor((localP.z+0.5*SPACING)/SPACING);
    float size = GetMantaScale(rowId, columnId);
    vec2 coord = loopP.xz;
    loopP/=size;
    
	vec3 colour = vec3(0.0);
	if (p.w < 1.5)
    {
		float v = clamp(-(n.y-.1)*6.2, 0.3, 1.0);
		v+=.35;
		colour = vec3(v*.8, v*.9, v*1.0);
	}
    
    vec3 colorUp = colour;
    if (n.y < 0.4) 
    {    
	    float stainsUp = texture2D(iChannel1, coord).x;
    	stainsUp *= stainsUp * 2.;
	    stainsUp = 1.-stainsUp;
		stainsUp += smoothstep(2.,-2.,loopP.z);
	    stainsUp = clamp(stainsUp, 0., 1.);
        
        float gillsV = loopP.z*60.;
        float gillsU = abs(loopP.x*0.7);
        float maskV = (loopP.z+0.1*size)*1.2;
        gillsV += gillsU*16.0; //bend
        float mask = 1.5-(10.0*gillsU*gillsU)-(10.0*maskV*maskV);
        mask *= min(gillsU*10., 1.0);
        mask = clamp(mask, 0.0, 1.0);
        float gills = 1.1 + sin(gillsV)*0.6;
        gills = clamp(gills, 0.1, 1.0);
        gills = mix(1.0, gills, mask);
        stainsUp *= gills;
        
    	colorUp *= stainsUp;
    }
    
    vec3 colorDown = colour;
    if (n.y > -0.4)
    {
    	float stainsDown = texture2D(iChannel1, coord*0.4).x;
	    stainsDown *= stainsDown;
	    stainsDown = clamp(stainsDown, 0., 1.);
        
    	colorDown *= vec3(stainsDown);
    }
    
    colour = mix(colorUp, colorDown, smoothstep(-0.4,0.4,n.y));   

    // Water caustics
    vec2 wat = p.xz*1.;
    wat +=  (texture2D(iChannel0, (wat*5.0+time*.04)*.1, 3.0).z -
             texture2D(iChannel0, wat*.3-time*.03, 2.0).y) * .4;
    float causticLight = texture2D(iChannel0, wat* .04, 0.0).x;
    causticLight = pow(max(0.0, causticLight-.2), 1.0) * 20. * smoothstep(-5.,3.,p.y);
    colour *= vec3(1.0) + vec3(causticLight*.5, causticLight, causticLight)*max(n.y, 0.0); 
    
    // shadow
    float diff = dot(n,lightDir);
    // light properties
    vec3 brightLight = vec3(0.7,0.7,0.8);
    vec3 shade = vec3(0.12,0.15,0.22);
    colour *= mix(shade,brightLight,max(diff*0.5+0.5,0.0));
    
    return colour;
}


//--------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 col;	
	vec2 uv = (fragCoord.xy / iResolution.xy) - vec2(.5);
	uv.x*=iResolution.x/iResolution.y;
	vec3 dir = normalize(vec3(uv, -1.0));
	
	//vec3 pos = vec3(1.3, sin(time+4.3)*.18-.05, sin(-time*.15)*5.0-1.35);
    vec3 pos = (sin(time*0.14)*2.+4.5)*vec3(sin(time*.5), 0.0, cos(time*.5));
    pos.z -= time;
    pos.y += 0.7 * sin(time * 0.2);
    float rot = -time*0.5;
	dir = Rotate_Y(dir, rot);

    // Sun...
	float i = max(0.0, 1./(length(sun-dir)+1.0));
	col = vec3(pow(i, 1.9), pow(i, 1.0), pow(i, .8)) * 1.3;
	
	// Water depth colour...
	col = mix(col, vec3(0.0, .25, .45), ((1.0-uv.y)*.45) * 1.8);
	
    float d;
	if (uv.y >= 0.0)
	{
		// Add water ripples...
        d = (3.0-pos.y) / -uv.y;
		
        vec2 wat = (dir * d).xz-pos.xz;
        d += 1.*sin(wat.x + time);
        wat = (dir * d).xz-pos.xz;
        wat = wat * 0.1 + 0.2* texture2D(iChannel0, wat, 0.0).xy;
        
		i = texture2D(iChannel3, wat, 0.0).x;
        
		col += vec3(i) * max(2./-d, 0.0);
	}
	else		
	{
		// Do floor stuff...
		d = (-3.0-pos.y) / uv.y;
		vec2 coord = pos.xz+(dir.xz * d);
		vec3 sand = texture2D(iChannel3, coord* .1).rgb * 1.5  + 
					texture2D(iChannel3, coord* .23).rgb;
        sand *= 0.5;
		
		float f = ((-uv.y-0.3 +sin(time*0.1)*0.2)*2.45) * .4;
		f = clamp(f, 0.0, 1.0);
		
		col = mix(col, sand, f);
	}

	float hit = 0.0;
	vec4 loc = Trace(pos, dir, hit);
    float material = loc.w;
	if (hit > 0.0)
	{
        if (material == MATERIAL_DEBUG) 
        {
            col = vec3(1.,0.,0.0);
            vec2 ret = Scene(loc.xyz, 0, 0);
            float d = ret.x;
            col = vec3(mod(d,1.0), mod(d*10.0,1.0), 0.0);
        } 
        else 
        {    
            vec3 norm = GetNormal(loc.xyz);
            vec3 foundColor = GetColour(loc, norm, pos, dir);
            vec3 backgroundColor = col;

            // total water reflection
            float facing = -dot(norm,dir);
            float upfacing = clamp(norm.y, 0.,1.);
            float fresnel = 1.0-facing;
            fresnel = clamp(pow(fresnel, 1.0), 0.0,1.0);
            foundColor = mix(foundColor, backgroundColor*2.0, 0.5 * (0.5 + upfacing*upfacing) * fresnel);

            // atmos
            float dis = length(pos-loc.xyz);
            float fogAmount = clamp(max((dis-.5),0.0)/MAXDIST, 0.0, 1.0);

            col = mix(foundColor, backgroundColor, fogAmount );
        }
	}
	
    // Contrast, saturation and brightness...
	col = csb(col, 1.1, 1.05, 1.22);
	fragColor = vec4(col, 10);
}
