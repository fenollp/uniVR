// Shader downloaded from https://www.shadertoy.com/view/lsVGz1
// written by shadertoy user kurtoon
//
// Name: BCH colorspace
// Description: A GLSL implementation of BCH colorspace as described by Bezryadin and Bourov:
//    [url]http://www.slideserve.com/orien/color-coordinate-systems-for-accurate-color-image-editing-software[/url]
//    
/* 	BCH Colorspace
	Kurt Kaminski, 2015

	Described by Bezryadin and Bourov:
	http://www.slideserve.com/orien/color-coordinate-systems-for-accurate-color-image-editing-software

	mouse x wipes between BCH and HSV visualizations
		left = BCH		
        right = HSV
*/

///////////////////////////////////////////////////////////////////////
// H S V
///////////////////////////////////////////////////////////////////////

// RGB 2 HSV
vec3 rgb2HSV(vec3 _col){
  vec3 hsv;
  float mini = 0.0;
  float maxi = 0.0;
  if (_col.r < _col.g) mini = _col.r;
    else mini = _col.g;
  if (_col.b < mini) mini = _col.b;
  if (_col.r > _col.g) maxi = _col.r;
    else maxi = _col.g;
  if (_col.b > maxi) maxi = _col.b;
  hsv.z = maxi; //VALUE
  float delta = maxi - mini; //delta
  if (maxi > 0.0) hsv.y = delta / maxi; //SATURATION
    else hsv.y = 0.0;
  if (_col.r >= maxi) hsv.x = (_col.g - _col.b) / delta;
  else if (_col.g >= maxi) hsv.x = 2.0 + (_col.b - _col.r)/delta;
  else hsv.x = 4.0 + (_col.r - _col.g) / delta;
  hsv.x *= 60.0;
  if (hsv.x < 0.0) hsv.x += 360.0;
  return hsv;
}

// HSV 2 RGB
vec3 hsv2RGB(vec3 _hsv){
  float hh, p, q, t, ff;
  int i;
  vec3 rgb;
  if(_hsv.y <= 0.0){
    rgb.r = _hsv.z;
    rgb.g = _hsv.z;
    rgb.b = _hsv.z;
    return rgb;
  }
  hh = _hsv.x;
  if(hh >= 360.) hh = (hh/360.);
  hh /= 60.0;
  i = int(hh);
  ff = hh - float(i);
  p = _hsv.z * (1.0 - _hsv.y);
  q = _hsv.z * (1.0 - (_hsv.y * ff));
  t = _hsv.z * (1.0 - (_hsv.y * (1.0 - ff)));

  if (i == 0){
      rgb.r = _hsv.z;
      rgb.g = t;
      rgb.b = p;
      return rgb;
    }
  else if (i == 1){
      rgb.r = q;
      rgb.g = _hsv.z;
      rgb.b = p;
      return rgb;
    }
  else if (i == 2){
      rgb.r = p;
      rgb.g = _hsv.z;
      rgb.b = t;
      return rgb;
    }
  else if (i == 3){
      rgb.r = p;
      rgb.g = q;
      rgb.b = _hsv.z;
      return rgb;
    }
  else if (i == 4){
      rgb.r = t;
      rgb.g = p;
      rgb.b = _hsv.z;
      return rgb;
    }
  else if (i == 5){
      rgb.r = _hsv.z;
      rgb.g = p;
      rgb.b = q;
      return rgb;
    }
  else {
      rgb.r = _hsv.z;
      rgb.g = p;
      rgb.b = q;
    return rgb;
  }
}


///////////////////////////////////////////////////////////////////////
// B C H
///////////////////////////////////////////////////////////////////////

vec3 rgb2DEF(vec3 _col){
  mat3 XYZ; // Adobe RGB (1998)
  XYZ[0] = vec3(0.5767309, 0.1855540, 0.1881852);
  XYZ[1] = vec3(0.2973769, 0.6273491, 0.0752741);
  XYZ[2] = vec3(0.0270343, 0.0706872, 0.9911085); 
  mat3 DEF;
  DEF[0] = vec3(0.2053, 0.7125, 0.4670);
  DEF[1] = vec3(1.8537, -1.2797, -0.4429);
  DEF[2] = vec3(-0.3655, 1.0120, -0.6104);

  vec3 xyz = _col.rgb * XYZ;
  vec3 def = xyz * DEF;
  return def;
}

vec3 def2RGB(vec3 _def){
  mat3 XYZ; 
  XYZ[0] = vec3(0.6712, 0.4955, 0.1540);
  XYZ[1] = vec3(0.7061, 0.0248, 0.5223);
  XYZ[2] = vec3(0.7689, -0.2556, -0.8645); 
  mat3 RGB; // Adobe RGB (1998)
  RGB[0] = vec3(2.0413690, -0.5649464, -0.3446944);
  RGB[1] = vec3(-0.9692660, 1.8760108, 0.0415560);
  RGB[2] = vec3(0.0134474, -0.1183897, 1.0154096);

  vec3 xyz = _def * XYZ;
  vec3 rgb = xyz * RGB;
  return rgb;
}
float getB(vec3 _def){
    float b = sqrt((_def.r*_def.r) + (_def.g*_def.g) + (_def.b*_def.b));
    return b;
}
float getC(vec3 _def){
    vec3 def_D = vec3(1.,0.,0.);
    float C = atan(length(cross(_def,def_D)), dot(_def,def_D));
    return C;
}
float getH(vec3 _def){
    vec3 def_E_axis = vec3(0.,1.,0.);
    float H = atan(_def.z, _def.y) - atan(def_E_axis.z, def_E_axis.y) ;
    return H;
}
// RGB 2 BCH
vec3 rgb2BCH(vec3 _col){
  vec3 DEF = rgb2DEF(_col);
  float B = getB(DEF);
  float C = getC(DEF);
  float H = getH(DEF);
  return vec3(B,C,H);
}
// BCH 2 RGB
vec3 bch2RGB(vec3 _bch){
  vec3 def;
  def.x = _bch.x * cos(_bch.y);
  def.y = _bch.x * sin(_bch.y) * cos(_bch.z);
  def.z = _bch.x * sin(_bch.y) * sin(_bch.z);
  vec3 rgb = def2RGB(def);
  return rgb;
}

// BRIGHTNESS
vec3 Brightness(vec3 _col, float _f){
  vec3 BCH = rgb2BCH(_col);
  vec3 b3 = vec3(BCH.x,BCH.x,BCH.x);
  float x = pow((_f + 1.)/2.,2.);
  x = _f;
  _col = _col + (b3 * x)/3.;
  return _col;
}

// CONTRAST
// simple contrast
// needs neighboring brightness values for higher accuracy
vec3 Contrast(vec3 _col, float _f){
  vec3 def = rgb2DEF(_col);
  float B = getB(def);
  float C = getC(def);
  float H = getH(def);
  
  B = B * pow(B*(1.-C), _f);

  def.x = B * cos(C);
  def.y = B * sin(C) * cos(H);
  def.z = B * sin(C) * sin(H);

  _col.rgb = def2RGB(def);
  return _col;
}

vec3 Hue(vec3 _col, float _f){
  vec3 BCH = rgb2BCH(_col);
  BCH.z += _f * 3.1459 * 2.;
  BCH = bch2RGB(BCH);
  return BCH;
}

vec3 Saturation(vec3 _col, float _f){
  vec3 BCH = rgb2BCH(_col);
  BCH.y *= (_f + 1.);
  BCH = bch2RGB(BCH);
  return BCH;
}

///////////////////////////////////////////////////////////////////////
// M A I N
///////////////////////////////////////////////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 bch;
    bch.x = 1.0;
    bch.y = 1.0;
    bch.z = uv.x*3.1459*2.0;
    
    vec3 hsv;
    hsv.x = uv.x*360.0;
    hsv.y = 1.0;
    hsv.z = 1.0;

    vec3 rgb;
    if (iMouse.x < fragCoord.x)
        rgb = bch2RGB(bch);
    else 
        rgb = hsv2RGB(hsv);
    
	fragColor = vec4(rgb,1.0);
}