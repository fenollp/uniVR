// Shader downloaded from https://www.shadertoy.com/view/lsdXRn
// written by shadertoy user BeRo
//
// Name: Color grading
// Description: My color grading code from my 64k intros.

// http://creativecommons.org/publicdomain/zero/1.0/

struct ColorGradingPreset {
  vec3 gain;
  vec3 gamma;
  vec3 lift;
  vec3 presaturation;
  vec3 colorTemperatureStrength;
  float colorTemperature; // in K
  float colorTemperatureBrightnessNormalization;  
};

vec3 colorTemperatureToRGB(const in float temperature){
  mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                                          vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                                          vec3(1.0, 1.3302673723350029, 1.8993753891711275)) :
                                     mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                                          vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                                          vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));
  return clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0));
}

vec3 colorGradingProcess(const in ColorGradingPreset p, in vec3 c){
  float originalBrightness = dot(c, vec3(0.2126, 0.7152, 0.0722));
  c = mix(c, c * colorTemperatureToRGB(p.colorTemperature), p.colorTemperatureStrength);
  float newBrightness = dot(c, vec3(0.2126, 0.7152, 0.0722));
  c *= mix(1.0, (newBrightness > 1e-6) ? (originalBrightness / newBrightness) : 1.0, p.colorTemperatureBrightnessNormalization);
  c = mix(vec3(dot(c, vec3(0.2126, 0.7152, 0.0722))), c, p.presaturation);
  return pow((p.gain * 2.0) * (c + (((p.lift * 2.0) - vec3(1.0)) * (vec3(1.0) - c))), vec3(0.5) / p.gamma);
}

ColorGradingPreset colorGradingPresetLerp(const in ColorGradingPreset a, const in ColorGradingPreset b, const in float t){
  return ColorGradingPreset(mix(a.gain, b.gain, t),
                            mix(a.gamma, b.gamma, t),
                            mix(a.lift, b.lift, t),
                            mix(a.presaturation, b.presaturation, t),
                            mix(a.colorTemperatureStrength, b.colorTemperatureStrength, t),
                            mix(a.colorTemperature, b.colorTemperature, t),
                            mix(a.colorTemperatureBrightnessNormalization, b.colorTemperatureBrightnessNormalization, t));
}

ColorGradingPreset ColorGradingPreset1 = ColorGradingPreset(
  vec3(0.5),   // Gain
  vec3(0.5),   // Gamma
  vec3(0.5),   // Lift
  vec3(1.0),   // Presaturation
  vec3(0.0),   // Color temperature strength
  6500.0,      // Color temperature (in K)
  0.0          // Color temperature brightness normalization factor 
);

ColorGradingPreset ColorGradingPreset2 = ColorGradingPreset(
  vec3(0.5),   // Gain
  vec3(0.5),   // Gamma
  vec3(0.5),   // Lift
  vec3(1.0),   // Presaturation
  vec3(1.0),   // Color temperature strength
  3500.0,      // Color temperature (in K)
  1.0          // Color temperature brightness normalization factor 
);

ColorGradingPreset ColorGradingPreset3 = ColorGradingPreset(
  vec3(0.51, 0.55, 0.53), // Gain
  vec3(0.45, 0.57, 0.55), // Gamma
  vec3(0.5,  0.4,  0.6),  // Lift
  vec3(1.0,  0.9,  0.8),  // Presaturation
  vec3(1.0,  1.0,  1.0),  // Color temperature strength
  6500.0,                 // Color temperature (in K)
  0.0                     // Color temperature brightness normalization factor 
);


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 c = texture2D(iChannel0, uv).xyz;
    c = colorGradingProcess(colorGradingPresetLerp(ColorGradingPreset1, 
                                                   colorGradingPresetLerp(ColorGradingPreset2, 
                                                                          ColorGradingPreset3, 
                                                                          (sin(iGlobalTime * 6.28318 * 0.25) * 0.5) + 0.5), 
                                                   (sin(iGlobalTime * 6.28318) * 0.5) + 0.5), c);
	fragColor = vec4(c, 1.0);
}