// Shader downloaded from https://www.shadertoy.com/view/Ms2XRt
// written by shadertoy user BeRo
//
// Name: Wavelength color conversion
// Description: Various color wavelengths to XYZ and *RGB conversion functions
// Various color wavelengths to XYZ and *RGB conversion functions
// Copyright (C) 2014 by Benjamin 'BeRo' Rosseauc
// Because the german law knows no public domain in the usual sense,
// this code is licensed under the CC0 license 
// http://creativecommons.org/publicdomain/zero/1.0/

const float PI = 3.1415926535897932384626433832795;

vec3 wl2rgbTannenbaum(float w){
  vec3 r;
  if(w < 350.0){
    r = vec3(0.5, 0.0, 1.0);
  }else if((w >= 350.0) && (w < 440.0)){
    r = vec3((440.0 - w) / 90.0, 0.0, 1.0);
  }else if((w >= 440.0) && (w <= 490.0)){
    r = vec3(0.0, (w - 440.0) / 50.0, 1.0);
  }else if((w >= 490.0) && (w < 510.0)){
    r = vec3(0.0, 1.0, (-(w - 510.0)) / 20.0);
  }else if ((w >= 510.0) && (w < 580.0)){
    r = vec3((w - 510.0) / 70.0, 1.0, 0.0);
  }else if((w >= 580.0) && (w < 645.0)){
    r = vec3(1.0, (-(w - 645.0)) / 65.0, 0.0);
  }else{    
    r = vec3(1.0, 0.0, 0.0);
  }
  if(w < 350.0){
    r *= 0.3;
  }else if((w >= 350.0) && (w < 420.0)){
    r *= 0.3 + (0.7 * ((w - 350.0) / 70.0));
  }else if((w >= 420.0) && (w <= 700.0)){
    r *= 1.0;
  }else if((w > 700.0) && (w <= 780.0)){
    r *= 0.3 + (0.7 * ((780.0 - w) / 80.0));
  }else{
    r *= 0.3;
  }
  return r;
}


vec3 wl2xyzCIE1931(const in float w){
  // based on the informations from http://jcgt.org/published/0002/02/01/paper.pdf
  vec4 t = vec4((w - 446.8) / 19.44, (w - 595.8) / 33.33, (log(w) - log(556.3)) / 0.075, (log(w) - log(449.8)) / 0.051);  
  t = vec4(0.366, 1.065, 1.014, 1.839) * exp((-0.5) * (t * t));
  return vec3(t.x + t.y, t.zw);
}

vec3 wl2xyzCIE1931Approximation(const in float w){
  // based on the informations from http://jcgt.org/published/0002/02/01/paper.pdf
  vec3 xc = vec3((w - 442.0) *((w < 442.0) ? 0.0624 :0.0374), (w - 599.8) * ((w < 599.8) ? 0.0264 :0.0323), (w - 501.1) *((w < 501.1) ? 0.0490 :0.0382));
  vec2 yc = vec2((w - 568.8) * ((w < 568.8) ? 0.0213 : 0.0247), (w - 530.9) * ((w < 530.9) ? 0.0613 : 0.0322));
  vec2 zc = vec2((w - 437.0) * ((w < 437.0) ? 0.0845 : 0.0278), (w - 459.0) * ((w < 459.0) ? 0.0385 : 0.0725));
  xc *= xc;  
  yc *= yc;  
  zc *= zc;  
  return vec3(dot(vec3(0.362, 1.056, -0.065) * exp((-0.5) * xc), vec3(1.0)), dot(vec2(0.821, 0.286) * exp((-0.5) * yc), vec2(1.0)), dot(vec2(1.217, 0.681) * exp((-0.5) * zc), vec2(1.0)));
}

    
vec3 wl2xyzCIE1964(const in float w){
  // based on the informations from http://jcgt.org/published/0002/02/01/paper.pdf
  vec4 t = vec4(log((w + 570.1) / 1014.0), log((1338.0 - w) / 743.5), (w - 556.1) / 46.14, log((w - 265.8) / 180.4));  
  t = vec4(0.398, 1.132, 1.011, 2.060) * exp(vec4(-1250.0, -234.0, -0.5, -32.0) * (t * t));
  return vec3(t.x + t.y, t.zw);
}

// based from the informations from CIE RGB http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html 
const mat3 SRGB2XYZ = mat3(0.4124564, 0.3575761, 0.1804375,
                           0.2126729, 0.7151522, 0.0721750,
                           0.0193339, 0.1191920, 0.9503041);

// based from the informations from CIE RGB http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html 
const mat3 XYZ2SRGB = mat3(3.2404542, -1.5371385, -0.4985314,
                           -0.9692660, 1.8760108, 0.0415560,
                           0.0556434, -0.2040259, 1.0572252);

// based from the informations from CIE RGB http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html 
const mat3 CIERGB2XYZ = mat3(0.4887180, 0.3106803, 0.2006017,
                             0.1762044, 0.8129847, 0.0108109,
                             0.0000000, 0.0102048, 0.9897952);

// based from the informations from CIE RGB http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html 
const mat3 XYZ2CIERGB = mat3(2.3706743, -0.9000405, -0.4706338,
                             -0.5138850, 1.4253036,  0.0885814,
                             0.0052982, -0.0146949, 1.0093968);
                           
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord.xy / iResolution.xy;
	//fragColor = vec4(wl2xyzCIE1931(uv.x * 1000.0) * XYZ2CIERGB, 1.0);
	//fragColor = vec4(wl2xyzCIE1931Approximation(uv.x * 1000.0) * XYZ2SRGB, 1.0);
    float t = iGlobalTime; 
	fragColor = vec4(mix(mix(mix(wl2xyzCIE1931Approximation(uv.x * 1000.0) * XYZ2SRGB,
                                    wl2xyzCIE1931(uv.x * 1000.0) * XYZ2SRGB,
                                   (sin(t * (4.0 * PI)) * 0.5) + 0.5),
                                wl2xyzCIE1964(uv.x * 1000.0) * XYZ2SRGB,
                                (sin(t * (2.0 * PI)) * 0.5) + 0.5),
                            wl2rgbTannenbaum(uv.x * 1000.0), 
                            (sin(t * PI) * 0.5) + 0.5), 1.0);
}