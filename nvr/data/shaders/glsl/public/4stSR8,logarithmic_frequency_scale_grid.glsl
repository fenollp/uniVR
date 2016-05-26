// Shader downloaded from https://www.shadertoy.com/view/4stSR8
// written by shadertoy user BeRo
//
// Name: Logarithmic frequency scale grid
// Description: The logarithmic frequency scale grid from the GLSL-based spectrum analyzer in my CreamTracker 64k softsynth tracker

// The logarithmic frequency scale grid from the GLSL-based spectrum analyzer in my CreamTracker 64k softsynth tracker

// Copyright (C) 2016 by Benjamin 'BeRo' Rosseaux
// Because the german law knows no public domain in the usual sense,
// this code is licensed under the CC0 license 
// http://creativecommons.org/publicdomain/zero/1.0/

// But please give credits, if you're using it.

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 onePixel = vec2(1.0) / iResolution.xy;
  float c = 0.;
  const float ln10 = 2.3025850929; // log(10.0);
  const float minFrequency = 10.0;
  const float maxFrequency = 22050.0;
  float lowLog = log(minFrequency) / ln10;
  float highLog = log(maxFrequency) / ln10;
  float scale = 1.0 / (highLog - lowLog); 
  float frequencyHz = exp(((uv.x / scale) + lowLog) * ln10);
  float currentMajorDecade = exp(floor(log(frequencyHz) / ln10) * ln10);	
  float nearestMajorDecade = exp(floor((log(frequencyHz) / ln10) + 0.5) * ln10);	
  float nearestMinorDecade = floor((frequencyHz / currentMajorDecade) + 0.5) * currentMajorDecade;	
  float nearestSubMinorDecade = floor((frequencyHz / (currentMajorDecade * 0.1)) + 0.5) * (currentMajorDecade * 0.1);	
  float ignoreFirstAndLastXFactor = step(onePixel.x, uv.x) * (1.0 - step(1.0 - onePixel.x, uv.x));  
  c = mix(c, 0.0625, smoothstep(onePixel.x, 0.0, abs((((log(nearestSubMinorDecade) / ln10) - lowLog) * scale) - uv.x)) * ignoreFirstAndLastXFactor);
  c = mix(c, 0.25, smoothstep(onePixel.x, 0.0, abs((((log(nearestMinorDecade) / ln10) - lowLog) * scale) - uv.x)) * ignoreFirstAndLastXFactor);
  c = mix(c, 1.0, smoothstep(onePixel.x, 0.0, abs((((log(nearestMajorDecade) / ln10) - lowLog) * scale) - uv.x)) * ignoreFirstAndLastXFactor);
  fragColor = vec4(c);
}