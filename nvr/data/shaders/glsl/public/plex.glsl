// Shader downloaded from https://www.shadertoy.com/view/4sGXDW
// written by shadertoy user GonzaloQuero
//
// Name: Plex
// Description: Plexus-like shader. Movement of the vertices is based on the frequencies of the music.
#define PNUM 32
#define PRADIUS 0.005
#define LINEWIDTH 0.003
#define LINEFADEDISTANCE 0.05
#define LINECOLOR vec4(0.4, 0.4, 1.0, 1.0) * 4.0

float getFreq(int i) {
    vec2 uv = vec2(float(i) / float(PNUM), 0.25);
    float freq = texture2D(iChannel0, uv).x;
    return freq * 0.6;
}

vec2 makePoint(int i)
{
   	vec2 uv =  vec2(float(i) / 64.0, 0.3);
    vec2 movement = texture2D(iChannel1, uv).xy;
    movement *= vec2(2.0, 1.5);
    movement += vec2(-0.5, -0.5);
    movement *= 2.0 * texture2D(iChannel1, uv * sin(0.01 * iGlobalTime)).xy;
  	return movement;
}

void getPoints(out vec2[PNUM] p)
{
    // First sample the sound texture.
    for(int i = 0; i < PNUM; i++)
    {
         p[i] = makePoint(i);
    }
    
    // Then sample the noise texture to help with cache locality.
    for(int i = 0; i < PNUM; i++)
    {
        float freqx = getFreq(i);
        float freqy = getFreq(PNUM - 1 - i);
        p[i] = p[i]  + vec2(freqx, freqy);
    }
}

float DistToLine(vec2 pt1, vec2 pt2, vec2 testPt)
{
  	vec2 lineDir = pt2 - pt1;
  	vec2 perpDir = vec2(lineDir.y, -lineDir.x);
  	vec2 dirToPt1 = pt1 - testPt;
    
    float a = abs(distance(pt1, testPt));
    float b = abs(distance(pt2, testPt));
    float c = abs(distance(pt1, pt2));
    
    float agtc = sign(a - c);
    float bgtc = sign(b - c);
    
    // a >= c || b >= c
    float comp = clamp(max(agtc, bgtc), 0.0, 1.0);
     
  	return mix(abs(dot(normalize(perpDir), dirToPt1)), 1000.0, comp);
}

float inLine(vec2 testPoint, vec2 iPoint, vec2 jPoint)
{
  return LINEWIDTH - DistToLine(iPoint, jPoint, testPoint);
}

vec4 drawLines(vec2[PNUM] points, vec2 uv)
{
 	vec4 ret = vec4(0.0);
    
    for(int i = 0; i < PNUM; i++)
    {
        vec2 iPoint = points[i];
        
     	for(int j = 0; j < PNUM; j++)
        {
            vec2 jPoint = points[j];
            
            float lineDist = inLine(uv, iPoint, jPoint);
            float lineMix = clamp(lineDist, 0.0, 1.0) / LINEWIDTH;

            float fade = pow(LINEFADEDISTANCE / distance(iPoint, jPoint), 2.0);
            vec4 possibleColor = LINECOLOR * clamp(fade, 0.0, 1.0);   
            possibleColor = mix(vec4(0.0), possibleColor, lineMix);
            ret = max(ret, possibleColor);
        }
    }
    
    return ret;
}

vec4 getFragColor(vec2[PNUM] points, vec2 uv)
{
    vec4 ret = drawLines(points, uv);    
    return ret;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 points[PNUM];
    getPoints(points);
    
    float x = fragCoord.x * (iResolution.x / iResolution.y) / iResolution.x;
    float y = fragCoord.y / iResolution.y;
    vec2 uv = vec2(x, y);
    
	fragColor = getFragColor(points, uv);
}