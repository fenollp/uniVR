// Shader downloaded from https://www.shadertoy.com/view/lstSRM
// written by shadertoy user ciberxtrem
//
// Name: Ball Runner
// Description: Press WASD keys to move the ball and take a walk :).
//    
//    Quaternion reference:
//    http://blog.molecular-matters.com/2013/05/24/a-faster-quaternion-vector-multiplication/
//    http://mollyrocket.com/forums/molly_forum_833.html
// Memory Props
vec2 mPos     = vec2(1., 0.);
vec2 mCamPos  = vec2(2., 0.);
vec2 mQuat    = vec2(4., 0.);

vec3 gBallPos;
vec3 gCamPos;
vec4 gBallQuat;

float gBallRadius = 1.0;

float gSoundWave;

float hash(float x) { return fract(sin(x)*4.86); }

vec4 Load(in sampler2D sampler, vec2 samplerRes, in vec2 valueCoord)
{
    return texture2D(sampler, (valueCoord + 0.5)/samplerRes);
}

vec3 Rotate(vec4 q, vec3 v)
{
    vec3 t = 2.*cross(q.xyz, v);
    return v + q.w*t + cross(q.xyz, t);
}

vec2 MapBall(in vec3 p, out vec3 coord)
{
    coord = p - gBallPos - vec3(0., 1., 0.);
    coord = Rotate(gBallQuat, coord);
    float d = length(coord)-gBallRadius;
    return vec2(d, 1.0);
}

vec2 MapTerrain(in vec3 p)
{
    float h = -1.;
    h += sin(p.x*0.15)*1.5;
    h += sin(1.8*p.x*0.1)*0.2;
    
    h += cos(0.6+p.z*0.1)*1.0;
    h += sin(0.+p.z*0.16)*0.25;
    
    float d = p.y-h;
    return vec2(d, 2.0);
}

vec2 Map(in vec3 p, out vec3 coord)
{
    vec2 res = MapTerrain(p);
    vec2 res2 = MapBall(p, coord);
    if(res2.x < res.x) { res = res2; }
    return res;
}

vec2 Intersect(vec3 ro, vec3 rd, float dmin, float dmax, out vec3 coord)
{
    float k = dmin;
    vec2 res = vec2(dmax);
    for(int i=0; i<160; ++i)
    {
        vec2 tmp = Map(ro + rd*k, coord);
        k += tmp.x;
        if(tmp.x<0.01)
        {
            res = vec2(k, tmp.y); break;
        }
    }
    return res;
}

vec3 CalcNormal(vec3 p)
{
    vec3 coord;
    vec2 ep = vec2(1e-3, 0.);
    float c = Map(p, coord).x;
    return normalize( vec3(
        Map(p+ep.xyy, coord).x - c,
        Map(p+ep.yxy, coord).x - c,
        Map(p+ep.yyx, coord).x - c
    ) );
}

vec3 Shade(vec3 color, vec3 n, vec3 v, vec3 l)
{
    float diff = 0.05+0.95*pow(max(dot(n, -v), 0.), 2.0);
    vec3 refl = reflect(v, n);
    float spec = pow(max(dot(refl, l), 0.), 25.);
    return color * diff + spec*vec3(1.0);
}

vec3 GetColor(float id, vec3 p, vec3 coord, vec3 rd, inout vec3 n)
{
    if(id < 1.5) 
    {
        return textureCube(iChannel1, normalize(coord)).xyz+coord*0.25; 
    }
    else 
    { 
        return vec3(0.384, 0.666, 0.917);
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-iResolution.xy*0.5) / iResolution.y;
    
    gSoundWave = texture2D(iChannel2, vec2(0.15, 0.2)).x;
    
    gBallPos  = Load(iChannel0, iChannelResolution[0].xy, mPos).xyz;
    gBallPos.y = -MapTerrain(vec3(gBallPos.x, 0., gBallPos.z)).x;
    gCamPos  = Load(iChannel0, iChannelResolution[0].xy, mCamPos).xyz;
    gBallQuat = Load(iChannel0, iChannelResolution[0].xy, mQuat);
    
    vec3 target = gBallPos;
    vec3 ro = gCamPos;
    
	vec3 front = normalize(target+vec3(0., 4.0, 0.)-ro);
    vec3 right = cross(vec3(0., 1, 0.), front);
    vec3 up = cross(front, right);
    vec3 rd = normalize(front + 35.*(3.14159/180.)*(right*uv.x + up*uv.y));
    
    vec3 l = normalize(vec3(-0.1, 0.5, -0.1));
    vec3 coord;
    vec3 color = vec3(0.03);
    float w = 1.;
    for(int i=0; i<2; ++i)
    {
        vec2 res = Intersect(ro, rd, 0.1, 100., coord);
        
        if(res.x < 100.)
        {
            vec3 p = ro + res.x * rd;
            vec3 n = CalcNormal(p);
            vec3 tmpColor = GetColor(res.y, p, coord, rd, n);
            color += Shade(tmpColor, n, rd, l)*w;
            
            if(res.y < 1.5) {break;}
            else
            {
                rd = reflect(rd, n); rd.y *= 0.8;
                ro = p;
                w *= 0.25;
            }
        }
        else
        {
            vec3 tmpColor = vec3(0.541, 0.388, 0.298);
            color += mix(vec3(0.835, 0.823, 0.647), color, smoothstep(0., 1., pow(abs(rd.y+0.02)*4., 0.5)))*0.2*w;
            
            vec3 farPos = rd * 4./rd.z;
            vec2 uv = farPos.xy*vec2(0.5, 1.)*0.40-vec2(-0.50, -0.40);
            vec3 texColor = texture2D(iChannel3, uv).rgb;
            
            for(int i=0; i<25; ++i)
            {
                if(float(i) > floor(+26.*fract(0.01+ gSoundWave+0.*iGlobalTime*0.25))) break;
                    
                float d = abs(uv.y-1.00+hash(float(2+i)*7.625)*0.5+sin(gBallPos.x*0.5+hash(float(i)) + (hash(float(i))*2.-1.)*iGlobalTime*1.0 +uv.x*10.+0.7)*0.05);
                color += w*mix(vec3(hash(float(i)), hash(float(i+4)), hash(float(i+9)))*0.5, vec3(0.), smoothstep(0., 1., pow(d/0.15, 0.2+gSoundWave*0.5+0.020*hash(float(i)))));
            }
            break;
        }
    }
	fragColor = vec4(pow(color, vec3(1./2.2)),1.0);
}