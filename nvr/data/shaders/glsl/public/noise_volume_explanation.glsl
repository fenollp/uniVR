// Shader downloaded from https://www.shadertoy.com/view/Ms3SRr
// written by shadertoy user Bers
//
// Name: Noise Volume Explanation
// Description: An explanation about 3D noise created from a 2D texture. The difficulty is to allow the noise to be continuous along the 3rd axis.
// Author : Sébastien Bérubé
// (trilinearSampling/Noise function from : Inigo Quilez https://www.shadertoy.com/view/XslGRr)
// Created : Dec 2014
// Modified : Jan 2016
//
// This shader was created in order to understand and explain the noise stacking trick 
// used in many excellent volumetric shaders (Clouds, amongst many).
// It uses a single texture2D lookup (r+g channels) to generate 3D noise.
//
// Therefore, here goes the explaination:
//
// 		First, the sampled result is a trilinear interpolation.
//      (See images here : https://en.wikipedia.org/wiki/Trilinear_interpolation)
//      Since the texture2D() function takes care internally of the fractional interpolation
//      on the XZ texture plane, one only needs to interpolate between 2 XZ layers in order 
//      to add the 3rd (Y) dimension to the noise and produce a noise volume.
//
//      The tricky part here is the [37x17] offset. Why 37x17? If you change this number, you will
//      essentially get garbage (discontinuities) along the Y-axis. Why is that? Well, it is because
//      the RGB noise texture is "hacked" for this :). The 3 noise layers are NOT random, they only are
//      a tranlated version of each other. Indeed, the 37x17 is the exact translation to align
//      the red texture plane on the green texture plane. The B texture plane has a different offset
//      (I do not remember what it is, but the noise layering trick also works between any channel
//       when you plug in the exact offset across them. The 64x64 RBG noise textures are
//       also built that way)
//
//      So, now that we know the offset between noise layers, how does that helps in
//      contructing a noise volume? Well, it helps making the noise volume CONTINOUS across
//      sections on the Y-Axis. Indeed, when the fractionnal part of the Y-Axis coordinates
//		returns to zero (t.y), the translated XZ coordinates (by [37x17]) allow us to swap the 
//      R&G channels seamlessly, and continue interpolation along the Y Axis like if it was
//      a continuous noise volume.
//
//      And to finish, "t = t * t * (3.0 - 2.0 * t)" is simply an easing function
//      to convert from purely linear interpolation to a more rounded/organic transition.
//		The noise volume will still work if you remove this line, yet it will look
//      much less smooth.
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

float trilinearSampling(vec3 p)
{
    const float TEXTURE_RES = 256.0; //Texture resolution
    p *= TEXTURE_RES;   //Computation in pixel space (1 unit = 1 pixel)
    vec3 pixCoord = floor(p);//Pixel coord, integer [0,1,2,3...256...]
    vec3 t = p-pixCoord;     //Pixel interpolation position, linear [0-1]
    t = t * t * (3.0 - 2.0 * t); //interpolant easing function
    //noise volume stacking trick : g layer = r layer shifted by (37x17 pixels ->
    //this is no keypad smashing, but the actual translation embedded in the noise texture).
    vec2 layer_translation = -pixCoord.y*vec2(37.0,17.0)/TEXTURE_RES;
    vec2 layer1_layer2 = texture2D(iChannel0,layer_translation+(pixCoord.xz+t.xz+0.5)/TEXTURE_RES,-100.0).rg;
    return mix( layer1_layer2.x, layer1_layer2.y, t.y );
}

const float PI = 3.14159;
const float INFINITY = 200000.0;

//Utility function to compute the distance along a ray to reach a plane, in 3D.
//The value returned is the distance along ray (in "d" units) to the plane intersection.
//o = ray origin
//d = ray direction
//pn = plane normal
//pp = arbitrary point on the plane
float planeLineIntersect(vec3 o,vec3 d,vec3 pn,vec3 pp)
{
    //Note : The plane normal is the optimal direction for a ray to reach it.
    //The equation below can be conceptualized this way : "How far is the plane"/"approach rate".
    //No need to normalize pn, as dot product above and under cancel out and do not scale the result.
    return dot(pp-o,pn)/dot(d,pn);
}

float _sign(float x)
{
    if(x>0.)
        return 1.0;
    else
        return -1.0;
}

//A very basic rotation.
vec3 rotate(vec3 p, const float yaw, const float pitch)
{
    p.xz = vec2( p.x*cos(yaw)+p.z*sin(yaw),
                 p.z*cos(yaw)-p.x*sin(yaw));
    p.yz = vec2( p.y*cos(pitch)+p.z*sin(pitch),
                 p.z*cos(pitch)-p.y*sin(pitch));
    return p;
}

//This function returns the intersection point of a ray cast towards a plane.
//o = ray origin
//d = ray direction
//center : the plane center
//[yaw,pitch] = rad angles
//Size = plane size
//return value : distance along the ray to intersec the plane
float plane(vec3 o, vec3 d, vec3 center, vec2 yawPitch, vec2 size)
{
    //The plane is not really rotated nor translated. The ray being cast is, however, which yields
    //the same result.
    o = o-center;
    float yaw = yawPitch.x;
    float pitch = yawPitch.y;
    d = rotate(d,-yaw,-pitch);
    o = rotate(o,-yaw,-pitch);
    
    //t = distance along the ray to reach the plane.
    float t = planeLineIntersect(o,d,vec3(0,-_sign(d.y),0),vec3(0,0,0));
    
    //Intersection position : (o:start)+(t:step size)*(d:direction)
    vec3 p = o+t*d;
    
    if( abs(p.x) <= size.x && abs(p.z) <= size.y) //xz plane
    	return t;
    
    return INFINITY; //Did not cross the plane. Return infinity.
}

//A very unintersting animation. This is just to show the volumetric lookup values.
vec4 animatedNoisePlane(vec3 o, vec3 d, vec3 offset, float fTime)
{
    float planeAngle = -0.2;
    vec3 planePos = offset+vec3(0,0,-6);
    
    //Rotate layers from in time interval : [0-1]
    if(fTime<1.)
    {
    	planeAngle += fTime*PI;
    }
    //Move layers up and down between time : [1-2]
	else
    {
        planePos += vec3(0,0.5+0.5*sin(-PI/2.+fTime*2.*PI),0);
    }
    
    float t = plane(o,d,planePos,vec2(0.0,planeAngle),vec2(2));
    
    //Intersection position : (o:start)+(t:step size)*(d:direction)
    vec3 p = o+t*d;
    
    //Background
    if(t>=INFINITY || t<0.0 )
        return vec4(0);
    
    //Noise volume at position p (scaled at 1:100)
    return vec4(vec3(trilinearSampling(p*0.01)),0.25); //0.5 is alpha
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //Centered, scaled uv coordinates (x:[-0.5;0.5])
    vec2 uv = (fragCoord.xy-0.5*iResolution.xy) / iResolution.xx;
    
    //The 3 axis of the camera
    vec3 camR = vec3(1,0,0);
    vec3 camU = vec3(0,1,0);
    vec3 camD = vec3(0,0,-1);
    vec3 o = vec3(0,1,0);//Camera origin
    vec3 d = normalize(uv.x*camR+uv.y*camU+camD); //ray direction : use uv coordinate to cast the ray
    
    //Arbitrary time scale
    float fTime = fract(iGlobalTime*0.2)*2.0;
    
    //Accumulate the values for the 4 lookup planes.
    float fOffset = 0.0;
    vec4 cAccum = vec4(0);
    for(int i=0; i < 4; ++i)
    {
        fOffset += 0.5;
        vec4 c = animatedNoisePlane(o,d,vec3(0,fOffset,-fOffset),fTime);
        cAccum += (1.0-cAccum.w)*c*c.w;
    }
    
    fragColor = cAccum*1.5;
}