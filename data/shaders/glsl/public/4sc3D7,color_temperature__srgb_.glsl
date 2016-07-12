// Shader downloaded from https://www.shadertoy.com/view/4sc3D7
// written by shadertoy user BeRo
//
// Name: Color temperature (sRGB)
// Description: Color temperature
// Color temperature (sRGB) stuff
// Copyright (C) 2014 by Benjamin 'BeRo' Rosseaux
// Because the german law knows no public domain in the usual sense,
// this code is licensed under the CC0 license 
// http://creativecommons.org/publicdomain/zero/1.0/

#define WithQuickAndDirtyLuminancePreservation        

const float LuminancePreservationFactor = 1.0;

const float PI2 = 6.2831853071;

// Valid from 1000 to 40000 K (and additionally 0 for pure full white)
vec3 colorTemperatureToRGB(const in float temperature){
  // Values from: http://blenderartists.org/forum/showthread.php?270332-OSL-Goodness&p=2268693&viewfull=1#post2268693   
  mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
	                                      vec3(0.0, 1669.5803561666639, 2575.2827530017594),
	                                      vec3(1.0, 1.3302673723350029, 1.8993753891711275)) : 
	 								 mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
   	                                      vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
	                                      vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275)); 
  return mix(clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)), vec3(1.0), smoothstep(1000.0, 0.0, temperature));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float temperature = (iMouse.z > 0.0) ? mix(1000.0, 40000.0, iMouse.x / iResolution.x) : 6550.0; // mix(1000.0, 15000.0, (sin(iGlobalTime * (PI2 / 10.0)) * 0.5) + 0.5);
    float temperatureStrength = (iMouse.z > 0.0) ? (1.0 - clamp((iMouse.y / iResolution.y) * (1.0 / 0.9), 0.0, 1.0)) : 1.0;
    if(uv.y > 0.1){        
      vec3 inColor = texture2D(iChannel0, uv).xyz;    
      vec3 outColor = mix(inColor, inColor * colorTemperatureToRGB(temperature), temperatureStrength); 
#ifdef WithQuickAndDirtyLuminancePreservation        
      outColor *= mix(1.0, dot(inColor, vec3(0.2126, 0.7152, 0.0722)) / max(dot(outColor, vec3(0.2126, 0.7152, 0.0722)), 1e-5), LuminancePreservationFactor);  
#endif
      fragColor = vec4(outColor, 1.0);
    }else{
      vec2 f = vec2(1.5) / iResolution.xy;   
	  fragColor = vec4(mix(colorTemperatureToRGB(mix(1000.0, 40000.0, uv.x)), vec3(0.0), min(min(smoothstep(uv.x - f.x, uv.x, (temperature - 1000.0) / 39000.0),
                                                                                                 smoothstep(uv.x + f.x, uv.x, (temperature - 1000.0) / 39000.0)),
                                                                                             1.0 - min(smoothstep(0.04 - f.y, 0.04, uv.y),
                                                                                                       smoothstep(0.06 + f.y, 0.06, uv.y)))),
                                                                                         1.0);
    }   
}