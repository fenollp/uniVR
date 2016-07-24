// Shader downloaded from https://www.shadertoy.com/view/ltlXRX
// written by shadertoy user janneasdf
//
// Name: Grid thing
// Description: 3D raymarching some cubes to create a grid
const float PI = 3.1415;

const float CamSpeed = 1.0;
const vec3 CubeColor = vec3(0.99, 0.1, 0.05) * 0.9;
const vec3 BackgroundColor = vec3(0.0, 0.0, 0.0);
const float CubeFatness = 0.2;
const float CubeDist = 3.0;
const float RotationFactor = 0.1;

float map(vec3 p);

vec3 approxNormal(vec3 pos)
{
    float epsilon = 0.001;
	vec2 t = vec2(0.0, epsilon);
    vec3 n = vec3(map(pos + t.yxx) - map(pos - t.yxx),
           	  map(pos + t.xyx) - map(pos - t.xyx),
              map(pos + t.xxy) - map(pos - t.xxy));
    return normalize(n);
}

float sdBox(vec3 p, vec3 boxDims)
{
  vec3 d = abs(p) - boxDims;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float map(vec3 p)
{
    float d = 99999.0;

    float c = cos(RotationFactor * p.z);
    float s = sin(RotationFactor * p.z);
    mat2 m = mat2(c, -s, s, c);
    p = vec3(m * p.xy, p.z);

    p = mod(p, CubeDist) - 0.5 * CubeDist;
    d = min(d, sdBox(p, vec3(0.5 * CubeDist, CubeFatness, CubeFatness)));
    d = min(d, sdBox(p, vec3(CubeFatness, 0.5 * CubeDist, CubeFatness)));
    d = min(d, sdBox(p, vec3(CubeFatness, CubeFatness, 0.5 * CubeDist)));

    return d;
}

vec3 getColor(vec3 rayPos, vec3 rayDir)
{
    vec3 color = BackgroundColor;

    float total_dist = 0.0;
    float d;
    int iters = 0;
    for (int i = 0; i < 128; ++i)
    {
    	++iters;
    	d = map(rayPos);
        rayPos += d * rayDir;
        total_dist += d;
        if (d < 0.0001)
        {
        	break;
        }
    }
    
    if (d < 0.001)
    {
    	float iter_factor = float(iters) / 128.0;
    	color = CubeColor * vec3(1.0 - iter_factor);
    	float bg_mix_factor = max(0.0, total_dist / 100.0);
    	color = mix(color, BackgroundColor, bg_mix_factor);
        color = vec3(1.0) - color * 18.0;
    }

    return color;
}

vec3 camRail(float t)
{
	return vec3(0.0, 0.0, t);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float aspect = iResolution.x / iResolution.y;
    
    // Make uv go [-0.5, 0.5] and scale uv.x according to aspect ratio
    uv -= .5;
    uv.x = aspect * uv.x;
    
    // Initialize camera stuff
    vec3 camPos = camRail(CamSpeed * iGlobalTime);
    vec3 camTarget = camRail(CamSpeed * iGlobalTime + 0.1);
    vec3 camUp = vec3(0., 1., 0.);
    vec3 camDir = normalize(camTarget - camPos);
    vec3 camRight = normalize(cross(camUp, camDir));
    camUp = normalize(cross(camDir, camRight));
    
    vec3 rayPos = camPos;
    vec3 rayDir = normalize(camDir + uv.x * camRight + uv.y * camUp);
    
    // Raymarch scene to get pixel color
    vec3 color = getColor(rayPos, rayDir);
    
    // Set pixel color
	fragColor = vec4(color, 1.0);
}
