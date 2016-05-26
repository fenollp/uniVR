// Shader downloaded from https://www.shadertoy.com/view/lddXRN
// written by shadertoy user paniq
//
// Name: JFA: ID diagram
// Description: bulding a brush ID voronoi diagram from a seed of brush ids. This can be used to build a 3D distance field for an arbitrary number of implicit primitives. The brush ids can be seeded multiple times, and the seed position can be arbitrary.
// presentation

float sdBox( vec2 p, vec2 b )
{
  vec2 d = abs(p) - b;
  return min(max(d.x,d.y),0.0) +
         length(max(d,0.0));
}

struct Brush {
    vec2 p;
    vec2 s;
    float a;
};
    
#define NUMBRUSHES 5
Brush brushes[NUMBRUSHES];
void initdata(float t) {
    brushes[0] = Brush(vec2(0.5), vec2(0.0), 0.0);
	brushes[1] = Brush(vec2(0.0), vec2(1.0,0.1), t);
    brushes[2] = Brush(vec2(0.5,0.2), vec2(0.05,0.1), 0.5);
    brushes[3] = Brush(vec2(-0.6,-0.4), vec2(0.01), 0.2);
    brushes[4] = Brush(vec2(0.1,0.0), vec2(sin(t)*0.5+0.5)*0.3, 0.1);
}
Brush getbrush(int i) {
    if (i == 1) return brushes[1];
    if (i == 2) return brushes[2];
    if (i == 3) return brushes[3];
    if (i == 4) return brushes[4];
    return brushes[0];
}

float brushdist(Brush brush, vec2 p) {
    p -= brush.p;
    vec2 cs = vec2(sin(-brush.a),cos(-brush.a));
    p = vec2(
        dot(p, vec2(cs.y, -cs.x)),
        dot(p, cs)
        );
    return sdBox(p, brush.s);
}

vec4 load0(ivec2 p) {
    vec2 uv = (vec2(p)-0.5) / iChannelResolution[0].xy;
    return texture2D(iChannel0, uv);
}

vec4 load1(ivec2 p) {
    vec2 uv = (vec2(p)-0.5) / iChannelResolution[1].xy;
    return texture2D(iChannel1, uv);
}

// from https://www.shadertoy.com/view/4djSRW
#define HASHSCALE3 vec3(.1031, .1030, .0973)
//  3 out, 1 in...
vec3 hash31(float p)
{
   p *= 3.1459;
   vec3 p3 = fract(vec3(p) * HASHSCALE3);
   p3 += dot(p3, p3.yzx+19.19);
   return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    int frame = int(mod(iGlobalTime,15.0));
    initdata(iGlobalTime - mod(iGlobalTime,15.0));
    vec2 aspect = vec2(iResolution.x / iResolution.y,1.0); 
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = (uv * 2.0 - 1.0) * aspect;    
    
    int id = int(load1(ivec2(fragCoord + 0.5)).x);
    float d = 0.0;
    if (id != 0) {
        Brush brush = getbrush(id);
        d = brushdist(brush, uv);
    }
    
    vec3 col;
    col = hash31(float(id)) * 0.5;
    col += 0.5*(sin(d*40.0)*0.5+0.5);
    if (d < 0.0) {
        col += 0.5;
    }
    /*
    if (frame < 12) {
        col = hash31(float(id)) * 0.5;
    } else {
        col = hash31(float(id));
    }
	*/
    
	fragColor = vec4(col, 1.0);
}