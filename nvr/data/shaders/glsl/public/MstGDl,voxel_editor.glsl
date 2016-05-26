// Shader downloaded from https://www.shadertoy.com/view/MstGDl
// written by shadertoy user elias
//
// Name: Voxel Editor
// Description: Mouse = rotate view
//    ESDF = Move
//    R = insert voxel
//    
//    See shader comments for more info.
/*

    One pixel stores 4 voxels.
    Each color channel holds three coordinates in the form of 0.XXYYZZ
    With 4x4 pixels we have a total of 64 voxels to play with. (change size below)

    I recommend pausing the shader for easier control.

*/

#define SIZE 4. // change in Buf A too

#define NCUBES (SIZE*SIZE*4.)
#define CSIZE (0.5/NCUBES)
#define T iGlobalTime
#define load(a,b) texture2D(b,(a+0.5)/iResolution.xy)

struct Ray    { vec3 o, d; };
struct Camera { vec3 p, d; };
struct Hit    { vec3 p, n; float t; int id; };
struct Plane  { vec3 n; float s; };

/* ===================== */
/* ====== Globals ====== */
/* ===================== */

Camera _cam = Camera(vec3(0,1,-1)*0.2, vec3(0,-1,1));

const int _numObjects = 3;
Hit _objects[_numObjects];

Hit _miss = Hit(vec3(0),vec3(0),-1e10,0);
Ray _r;

vec2 _uv;
vec3 _n;
vec3 _cursor;

float _tmin,_tmax;
int _ignore = -1;

/* =================== */
/* ====== Utils ====== */
/* =================== */

mat3 rotX(float a){float c=cos(a);float s=sin(a);return mat3(1,0,0,0,c,-s,0,s,c);}
mat3 rotY(float a){float c=cos(a);float s=sin(a);return mat3(c,0,-s,0,1,0,s,0,c);}

vec3 getCoords(float n)
{
	float x = floor(n*100.);
	float y = n*10000.;
	float z = fract(y)*100.;
	y = floor(y)-x*100.;

	return floor((vec3(x,y+NCUBES/2.,z)-NCUBES/2.)/NCUBES*NCUBES+0.5)/NCUBES+vec3(CSIZE);
}

/* ======================== */
/* ====== Raytracing ====== */
/* ======================== */

Ray lookAt(Camera cam, vec2 c)
{
    vec3 dir = normalize(cam.d);
    vec3 right = normalize(cross(dir,vec3(0,1,0)));
    vec3 up = cross(right, dir);
  
    return Ray(cam.p, normalize(right*c.x + up*c.y + dir));
}

Hit plane(Ray r, vec3 n, float s)
{
    float t = dot(n,n*s-r.o)/dot(n,r.d);
    return Hit(r.o+r.d*t,n,t,0);
}

void startObject(Ray r)
{
    _r = r;
    _tmax = -1e10;
    _tmin = 1e10;
}

void join(vec3 n, float s)
{    
    float t = (-dot(n,_r.o)+s)/dot(n,_r.d);

    if (dot(n,_r.d)<0.0)
    {
        if(_tmax < t)
        {
            _tmax = t;
            _n = n;
        }
    }
    else
    {
        _tmin = min(_tmin,t);
    }
}

Hit endObject()
{
    float t = _tmax < _tmin ? _tmax : -1e10;
    return Hit(_r.o+_r.d*t,_n,t,0);
}

Hit cube(Ray r, vec3 p, float d)
{
    r.o -= p;
    
    startObject(r);
    
    join(vec3( 0, 1, 0),d);
    join(vec3( 0,-1, 0),d);
    join(vec3( 1, 0, 0),d);
    join(vec3(-1, 0, 0),d);
    join(vec3( 0, 0, 1),d);
    join(vec3( 0, 0,-1),d);
    
    _r.o += p;
    
    return endObject();
}

bool compare(inout Hit a, Hit b)
{
    if (a.t < 0.0 || b.t > 0.0 && b.t < a.t)
    {
        a = b;
        return true;
    }
    
    return false;
}

Hit trace(Ray r)
{
    Hit h = _miss;
    
    for(float x = 0.; x < SIZE; x++)
    {
        for(float y = 0.; y < SIZE; y++)
        {
            vec4 n = texture2D(iChannel0, (vec2(x,y)+0.5)/iResolution.xy);

            if(n.x > 0.0) compare(h,cube(r,getCoords(n.x),CSIZE));
            if(n.y > 0.0) compare(h,cube(r,getCoords(n.y),CSIZE));
            if(n.z > 0.0) compare(h,cube(r,getCoords(n.z),CSIZE));
            if(n.w > 0.0) compare(h,cube(r,getCoords(n.w),CSIZE));
        }
    }
    
    _objects[0] = plane(r,vec3(0,1,0),0.0);
	_objects[1] = h;
    
    _objects[2] = _miss;
    
    if (_ignore != 2) { _objects[2] = cube(r,_cursor,CSIZE); }
    
    h = _objects[0];
    
    for (int i = 1; i < _numObjects; i++)
    {
        Hit t = _objects[i];
        
        if(compare(h,t) == true)
        {
            h.id = i;
        }
    }
    
    return h;
}

/* ======================= */
/* ====== Rendering ====== */
/* ======================= */

vec3 getColor(Hit h)
{
    if (h.t <= 0.0) { return vec3(0); }
    
    vec3 col = vec3(1);
    vec3 light = _cam.p; //vec3(0,1,0);
    
    for(int i = 0; i < 2; i++)
    {
        float diff = max(dot(h.n,normalize(light-h.p)),0.0);
        float spec = pow(max(dot(reflect(normalize(h.p-light),h.n),normalize(_cam.p)),0.0),100.0);
        float fog = min(0.9/exp(length(light-h.p)),1.);

        if (h.id == 0)
        {
            float s = CSIZE*4.;
            float l = length(max(abs(h.p.xz)-0.5,0.)) == 0.0 ? 1.0: 0.0;
            col *= l*fog;
            col -= floor(fract(h.p.x/s+.5*floor(fract(h.p.z/s)+.5))+.5)*0.05;
        }
        else if (h.id == 1)
        {
            col = mix(vec3(1,0.8,0.5),col*diff*fog,0.2);
        }
        
        if (h.id == 2)
        {
            _ignore = 2;
            h = trace(lookAt(_cam,_uv));
            _ignore = -1;
        }
        else
        {
            if (i==1)
            {
                col = mix(col,vec3(0,1,0),(sin(T*4.0)+1.0)/4.0+0.3);
            }
            
            break;
        }
    }
    
	return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    _uv = (2.*fragCoord.xy-iResolution.xy)/iResolution.xx;
    
    vec2 uvm = (2.*iMouse.xy-iResolution.xy)/iResolution.xx;
    vec2 rot = load(vec2(iResolution.x-1.,0),iChannel0).xy;
    vec3 pos = load(vec2(iResolution.x-4.,0),iChannel0).xyz*1e4;

    _cam.p += pos;
    _cam.d *= rotX(rot.x)*rotY(rot.y);

    _ignore = 2;
    Hit h = trace(lookAt(_cam,uvm));
    _cursor = floor(h.p*NCUBES+h.n*0.5)/NCUBES+vec3(CSIZE);
    _ignore = -1;

    
    fragColor = vec4(getColor(trace(lookAt(_cam,_uv))),1);
}