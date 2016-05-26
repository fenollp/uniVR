// Shader downloaded from https://www.shadertoy.com/view/4tsGWs
// written by shadertoy user Fred1024
//
// Name: sinMountains
// Description: Been playing with raymarch algorithms :)
// ~ sinMountains ~
// Frederic Heintz
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define FOV_DEGRE 60.0
#define E 0.15
#define LIGHT_RANGE 3000.0

vec3 camPos;
int scapeType;

float mapY( in vec3 pos )
{
    if(scapeType == 1)
    {
	    pos.x = floor(pos.x / 10.0) * 10.0;
    }
    float y = sin( (pos.x + iGlobalTime * 5.0) * 0.1) * sin( (pos.z + iGlobalTime * 3.0) * 0.1) * 30.0;
    y += (sin( (pos.x + iGlobalTime * 10.0) * 0.05) * sin( (pos.z - iGlobalTime * 7.0) * 0.05) * 30.0);
    y += sin( (pos.x + iGlobalTime * 8.0) * 0.025) * sin( (pos.z + iGlobalTime * 12.0) * 0.025) * 30.0;

    if(scapeType == 2)
    {
	   	y = floor(y / 10.0) * 10.0;
    }
    float q = length(pos.xz - camPos.xz) * 2.0;
    return y * (0.2 + q * q * 0.0000015);
}

vec3 mapNormal( in vec3 pos )
{
	float yl = mapY( pos + vec3(-E, 0.0, 0.0));
	float yr = mapY( pos + vec3(E, 0.0, 0.0));
	float yt = mapY( pos + vec3(0.0, 0.0, -E));
	float yb = mapY( pos + vec3(0.0, 0.0, E));
    vec3 vx = normalize(vec3(E, yr - yl, 0.0));
    vec3 vz = normalize(vec3(0.0, yt - yb, -E));
    vec3 norm = normalize(cross( vx, vz ));
	return norm;
}

// the higher we get in the map the further we go
bool rayMarchFirstHit( in vec3 ray, inout float delta, inout vec3 ptr)
{
	for( int i = 0; i < 90; i++)
	{
		ptr += (delta * ray);
        float dy = ptr.y - mapY(ptr);
		if(dy <= 0.0)
		{
			ptr -= (delta * ray);
            return true;
        }
        delta = clamp(dy, 0.1, 9.0);
    }
    return false;
}

// refine with smaller and smaller steps
void rayMarchRefine( in vec3 ray, in float delta, inout vec3 ptr)
{
	for( int i = 0; i < 20; i++)
	{
		ptr += (delta * ray);

		if(ptr.y < mapY(ptr))
		{
			ptr -= (delta * ray);
            delta *= 0.5;
        }
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float localTime = mod((iGlobalTime + (fragCoord.x / iResolution.x) * 8.0), 40.0);
    
    if(abs(mod(localTime, 20.0)) < 0.01)	scapeType = 0;
    else if(localTime <= 20.0)				scapeType = 1;
    else									scapeType = 2;

    vec3 lightPos = vec3(sin(iGlobalTime * 0.08) * 700.0, 150.0 - sin(iGlobalTime * 0.25) * 30.0, cos(iGlobalTime * 0.08) * 100.0);

    // Camera setup
    float height = 20.0 + (iMouse.y / iResolution.y) * 100.0;
    camPos = mix(vec3(0.4, height, 0.3), lightPos, 0.3);
    camPos.y = height;
    
    vec3 camTgt = vec3(lightPos.x, lightPos.y * 0.2, lightPos.z);

    // A view matrix
    vec3 dir = normalize(camTgt - camPos);					// z dir
    vec3 side = normalize(cross(dir, vec3(0.0, 1.0, 0.0)));	// side
    vec3 up = normalize(cross(side, dir));					// up
    mat3 viewMatrix = mat3(side.x, up.x, dir.x, side.y, up.y, dir.y, side.z, up.z, dir.z);
    
    // Ray setup
    float tangF = tan(radians(FOV_DEGRE));
    float ratio = iResolution.y / iResolution.x;
    float rX = (((fragCoord.x / iResolution.x) * 2.0) - 1.0) * tangF;
    float rY = (((fragCoord.y / iResolution.y) * 2.0) - 1.0) * tangF * ratio;
    vec3 ray = normalize(vec3(rX, rY, 1.0));
    
    // apply camera trans to ray
    ray = ray * viewMatrix;

	// sky
    vec3 lightDir = (lightPos - camPos);
    float lightDist = length(lightDir);
   	lightDir = normalize(lightDir);
    float skyDot = clamp(dot(lightDir, ray), 0.0, 1.0);
    vec3 colorSky = mix(vec3(0.5, 0.5, 1.0), vec3(0.0, 0.0, 1.0), clamp(ray.y, 0.0, 1.0));
    colorSky += mix(vec3(0.0, 0.0, 0.0), vec3(0.5, 0.5, 1.0), vec3(pow(skyDot, 30.0) * 0.8, pow(skyDot, 15.0) * 0.6, pow(skyDot, 20.0) * 0.75));

    vec3 color = colorSky;
        
	vec3 ptr = camPos;
    float delta = 2.0;
	if(scapeType == 0)
    {
        color = vec3(1.0, 1.0, 1.0);
    }
    else if( rayMarchFirstHit( ray, delta, ptr ) == true)
    {
        rayMarchRefine( ray, delta * 0.5, ptr );

        vec3 norm = mapNormal(ptr);
        // surface color
        if( abs(norm.z) > 0.8)          color = vec3(1.0, 0.04, 0.0);
        else if( abs(norm.y) < 0.8)     color = mix(vec3(0.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), clamp((ptr.y + 25.0) * 0.05, 0.0, 1.0));
        else if( abs(norm.y) < 0.82)    color = vec3(1.0, 1.0, 0.0);
        else            				color = mix(vec3(0.5, 0.5, 1.0), vec3(1.0, 0.5, 0.0), clamp((ptr.y + 16.0) * 0.025, 0.0, 1.0));

        // shading
	    float lightDot = clamp(dot(lightDir, norm), 0.0, 1.0);

	    float spec = 0.0;
		float lightI = 0.0;
        if(lightDot >= 0.0 && lightDist < LIGHT_RANGE)
	    {
        	lightI = lightDot * pow(1.0 - (lightDist / LIGHT_RANGE), 2.0) * 1.6;
	    	spec = clamp(dot(ray, normalize(lightDir - norm)), 0.0, 1.0);
	    	spec = pow(spec, 200.0) * 1.0;
        }
        color = ( (color * 0.15) + (color * lightI) + spec );
        
        // mix with sky in the distance
        vec3 hitDir = (ptr - camPos);
        float hitDist = length(hitDir);
        float q = min(1.0, hitDist * hitDist * 0.0000017);
        color = mix( color, colorSky, q );
    }

    // show light
    lightDir = normalize(lightDir);
    float lightQ = max( 0.0, dot(ray, lightDir));
    color.xyz += vec3(pow(lightQ, 600.0 + sin(iGlobalTime * 50.0) * 20.0));

    // Gamma
    color = pow(color, vec3(0.4545));

    color = clamp(color, 0.0, 1.0);
    
    fragColor = vec4(color, 1.0);
}

