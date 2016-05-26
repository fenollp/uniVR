// Shader downloaded from https://www.shadertoy.com/view/lsd3DS
// written by shadertoy user sqrt_1
//
// Name: Mandelbrot (simple zoom)
// Description: Mandelbrot test from the Humus mandelbrot demo (http://humus.name/index.php?page=3D&amp;ID=85).
//Mandelbrot demo ported from Humus demo (http://humus.name/index.php?page=3D&ID=85)

// Calculate the position in the Mandelbrot (typically passed as a shader constant)
vec3 CalcOffset()
{
  float time = iGlobalTime * 1000.;

  float tt = mod(time,8192.);  
  
  float targetIndex = mod(time / 8192., 5.);
  vec2 pos1 = vec2(0.30078125, 0.0234375); 
  vec2 pos2 = vec2(-0.82421875,0.18359375);   
    
  if(targetIndex > 1.)
  {
    pos1 = pos2;
    pos2 = vec2(+0.07031250, -0.62109375);      
  }
  if(targetIndex > 2.)
  {
    pos1 = pos2;      
    pos2 = vec2(-0.07421875, -0.66015625);            
  }
  if(targetIndex > 3.)
  {
    pos1 = pos2;      
    pos2 = vec2(-1.65625, 0.);                  
  }
  if(targetIndex > 4.)
  {
    pos1 = pos2;      
    pos2 = vec2(0.30078125, 0.0234375);                  
  }
    
  float t1 = tt * (1. / 8192.);
  float f = 4. * (t1 - t1 * t1);
  f *= f;
  f *= f;
  f *= f;
  f *= f;
  float s = t1;
  s = s * s * (3. - s - s);
  s = s * s * (3. - s - s);
  s = s * s * (3. - s - s);
  s = s * s * (3. - s - s);    
    
  return vec3(mix(pos1, pos2, s),
              f + (1. / 8192.));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec3 tex = CalcOffset();
  vec2 x = (fragCoord * (2./iResolution.y) - 1.)*tex.z + tex.xy;
  vec2 y=x;
  vec2 z=y;
    
  float lw = 255.;
  for(int w=0; w<255; w++)
  {
    if(y.x < 5.)
    {   
      y=x*x;
      x.y*=x.x*2.;
      x.x=y.x-y.y;
      x+=z;
      y.x+=y.y;

      lw-=1.;
    }
  }
  fragColor = sin(vec4(2.,3.5,5.,5.) + (lw/18. + log(y.x) / 28.)) / 2. + 0.5;
  fragColor.w=1.;
}


