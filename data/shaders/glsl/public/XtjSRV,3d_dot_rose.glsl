// Shader downloaded from https://www.shadertoy.com/view/XtjSRV
// written by shadertoy user yasuo
//
// Name: 3D Dot Rose
// Description: It's just my drawing stuff.
#define NEAR 0.01
#define FAR 128.
#define ITER 128
float tt;
float atime;
const float PI = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;

mat4 matRotateX(float rad)
{
    return mat4(1,       0,        0,0,
                0,cos(rad),-sin(rad),0,
                0,sin(rad), cos(rad),0,
                0,       0,        0,1);
}

mat4 matRotateY(float rad)
{
    return mat4( cos(rad),0,-sin(rad),0,
                0,       1,        0,0,
                sin(rad),0, cos(rad),0,
                0,       0,        0,1);
}

mat4 matRotateZ(float rad)
{
    return mat4(cos(rad),-sin(rad),0,0,
                sin(rad), cos(rad),0,0,
                0,        0,1,0,
                0,        0,0,1);
}

mat3 mat3RotateX(float rad)
{
    return mat3(1,       0,        0,
                0,cos(rad),-sin(rad),
                0,sin(rad), cos(rad));
}

// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
vec4 combine(vec4 val1, vec4 val2 )
{
    if ( val1.w < val2.w ) return val1;
    return val2;
}

// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdBox( vec3 p, vec3 b )
{
    vec3 d = abs(p) - b;
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdCone( vec3 p, float r, float h )
{
    vec2 c = normalize( vec2( h, r ) );
    float q = length(p.xy);
    return max( dot(c,vec2(q,p.z)), -(p.z + h) );
}

float cubicInOut(float t) {
    return t < 0.5
        ? 4.0 * t * t * t
        : 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
}

float perlin(vec3 p) {
    vec3 i = floor(p);
    vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
    vec3 f = cos((p-i)*PI)*(-.5)+.5;
    a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
    a.xy = mix(a.xz, a.yw, f.y);
    return mix(a.x, a.y, f.z);
}

vec4 map( vec3 pos, mat4 m)
{
    vec4 q = vec4(pos+vec3(0,0,-50.0),1.0)*m;

    float t = floor(iGlobalTime);
    float f = fract(iGlobalTime);
    t += cubicInOut(2. - exp(-f*5.));
    atime = t*0.2;

    float deg = atime*50.0;
    float deg2 = -1.0*atime*50.0+30.0;
    float deg3 = atime*50.0+60.0;
    float deg4 = -1.0*atime*50.0+90.0;
    float deg5 = atime*50.0+120.0;
    float deg6 = -1.0*atime*50.0+150.0;
    float deg7 = atime*50.0+180.0;
    float deg8 = -1.0*atime*50.0+210.0;
    float deg9 = atime*50.0+240.0;
    float deg10 = -1.0*atime*50.0+280.0;

    vec4 newP = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg*DEG_TO_RAD)*matRotateY(deg*DEG_TO_RAD)*matRotateZ(deg*DEG_TO_RAD);
    vec4 newP2 = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg2*DEG_TO_RAD)*matRotateY(deg2*DEG_TO_RAD)*matRotateZ(deg2*DEG_TO_RAD);
    vec4 newP3 = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg3*DEG_TO_RAD)*matRotateY(deg3*DEG_TO_RAD)*matRotateZ(deg3*DEG_TO_RAD);
    vec4 newP4 = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg4*DEG_TO_RAD)*matRotateY(deg4*DEG_TO_RAD)*matRotateZ(deg4*DEG_TO_RAD);
    vec4 newP5 = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg5*DEG_TO_RAD)*matRotateY(deg5*DEG_TO_RAD)*matRotateZ(deg5*DEG_TO_RAD);
    vec4 newP6 = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg6*DEG_TO_RAD)*matRotateY(deg6*DEG_TO_RAD)*matRotateZ(deg6*DEG_TO_RAD);
    vec4 newP7 = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg7*DEG_TO_RAD)*matRotateY(deg7*DEG_TO_RAD)*matRotateZ(deg7*DEG_TO_RAD);
    vec4 newP8 = vec4(q.xyz + vec3( 0, 0, 0 ),1.0)*matRotateX(deg8*DEG_TO_RAD)*matRotateY(deg8*DEG_TO_RAD)*matRotateZ(deg8*DEG_TO_RAD);
    vec4 newP9 = vec4(q.xyz + vec3( 5.0, 10.0, 0 ),1.0)*matRotateX(90.0*DEG_TO_RAD)*matRotateY(-40.0*DEG_TO_RAD);
    vec4 newP10 = vec4(q.xyz + vec3( -7.0, 15.0, 0 ),1.0)*matRotateX(90.0*DEG_TO_RAD)*matRotateY(45.0*DEG_TO_RAD);

    float glow = 0.0;
    vec3 p = pos;
    float grid = max(0.0, max((mod((p.x+p.y+p.z*50.0)-atime*0.01, 50.0)-40.0), 0.0) );

    float size1 = 7.2;
    float size2 = 7.2;
    float size3 = 7.2;
    float size4 = 7.2;
    float size5 = 7.2;
    float size6 = 7.2;
    float size7 = 7.2;

    vec3 roseCl = vec3(0.35,0.0,0.0)+vec3(grid,0.0,0.0);
    vec3 scale1 = vec3(abs(sin(atime)*size1),size1,abs(sin(atime)*size1));
    vec3 scale2 = vec3(size2,abs(sin(atime)*size2),size2);
    vec3 scale3 = vec3(size3,size3,abs(sin(atime)*size3));
    vec3 scale4 = vec3(size4,abs(sin(atime)*size4),size4);
    vec3 scale5 = vec3(abs(sin(atime)*size5),size5,size5);
    vec3 scale6 = vec3(abs(sin(atime)*size6),abs(sin(atime)*size6),size6);
    vec3 scale7 = vec3(size7,abs(sin(atime)*size7),size7);

    float noise = perlin(pos * 0.5) * 0.2;
    vec4 val1 = vec4(roseCl,sdBox(newP.xyz,scale1 ) + noise);
    vec4 val2 = vec4(roseCl,sdBox(newP2.xyz,scale2 ) + noise);
    vec4 val3 = vec4(roseCl,sdBox(newP3.xyz,scale3 ) + noise);
    vec4 val4 = vec4(roseCl,sdBox(newP4.xyz,scale4 ) + noise);
    vec4 val5 = vec4(roseCl,sdBox(newP5.xyz,scale5 ) + noise);
    vec4 val6 = vec4(roseCl,sdBox(newP6.xyz,scale6 ) + noise);
    vec4 val7 = vec4(roseCl,sdBox(newP7.xyz,scale7 ) + noise);

    vec4 val8 = vec4(vec3(0.0,0.1,0.0)+vec3(0.0,grid,0.0),sdBox(q.xyz + vec3( 0, 16.0, 0 ),vec3(1.0,10.0,1.0) ) + noise);
    vec4 val9 = vec4(vec3(0.0,0.1,0.0)+vec3(0.0,grid,0.0),sdCone(newP9.xyz,1.0,7.0 ) + noise);
    vec4 val10 = vec4(vec3(0.0,0.1,0.0+vec3(0.0,grid*-1.0,0.0)),sdCone(newP10.xyz,1.0,9.0 ) + noise);

    vec4 val11 = combine ( val1, val2 );
    vec4 val12 = combine ( val3, val4 );
    vec4 val13 = combine ( val5, val6 );
    vec4 val14 = combine ( val7, val8 );
    vec4 val15 = combine ( val9, val10 );
    vec4 val16 = combine ( val11, val12 );
    vec4 val17 = combine ( val13, val14 );
    vec4 val18 = combine ( val15, val16 );
    vec4 val19 = combine ( val17, val18 );

    return val19;
}

vec2 rot(vec2 p, float a) {
    return vec2(
        cos(a) * p.x - sin(a) * p.y,
        sin(a) * p.x + cos(a) * p.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 position = ( fragCoord.xy / iResolution.xy );
    position -= .5;
    position = floor(position*150.0)/150.0;
    vec3 dir = vec3( position, 1.0 );

    float aspect = iResolution.x / iResolution.y;
    dir = normalize(vec3(position * vec2(aspect, 1.0), 1.0));
    dir.yz = rot(dir.yz, 0.2);

    vec3 pos = vec3(0.0, 5.0, 15.0);
    mat4 m = matRotateY(iGlobalTime*0.5);

    vec4 result;
    int march = 0;

    for (int i =0; i < ITER; i++)
    {
        result = map(pos, m);
        march = i;
        if (result.w < NEAR || result.w > FAR) break;
        pos += result.w * dir;
    }

    vec3 col = map(pos, m).xyz;
    vec4 bgCol;
    if ( pos.z> 100. )
    {
        // bg
        position.y /= 1.5;
        vec3 pw	= vec3(position.y - position.x, position.y + position.x, -(position.y * 2.));
        pw		*= .8;

        float t = atime*-7.0;
        float tau = (8. * atan(1.));
        vec2 m = vec2((t-1.5) / tau, (t - .5) / tau);

        vec3 r = vec3(m.x, tau/2., m.y);

        mat3 rm3 = mat3RotateX(r.z*5.);
        pw *= tau/1.;

        float s = 1./0.7;
        vec3 d = vec3(pw);

        float w  = 0.0001/iResolution.x;
        vec3 color = vec3(0);

        pw = abs(pw)-s;
        pw *= rm3;

        color += float(pw.z*0.5<w);
        float temp = length(vec2(position.xy))+0.5;

        col = vec3(vec3(vec3(.2,.0,.0)/vec3(temp)))+vec3(color.y*0.1,0,0.);
    }
    else
    {
        // shade
        vec3 lightPos = vec3(20.0, 20.0, 20.0 );
        vec3 light2Pos = normalize( lightPos - pos);
        vec3 eps = vec3( .1, .01, .0 );
        vec3 n = vec3( result.w - map( pos - eps.xyy, m ).w,
                      result.w - map( pos - eps.yxy, m ).w,
                      result.w - map( pos - eps.yyx, m ).w );
        n = normalize(n);

        float lambert = max(.0, dot( n, light2Pos));
        col *= vec3(lambert);

        col += vec3(result.xyz);
    }
	float cline = mod(fragCoord.y, 4.0) < 2.0 ? 0.5 : 1.0;
    fragColor = vec4( col, 1.0)*cline;

}