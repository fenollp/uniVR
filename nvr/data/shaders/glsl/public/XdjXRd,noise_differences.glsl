// Shader downloaded from https://www.shadertoy.com/view/XdjXRd
// written by shadertoy user BeRo
//
// Name: noise differences
// Description: try noiseA, noiseB and noiseC with real non-ANGLE OpenGL and you will notice some differences or no any differences, depending on your used GPU and/or graphics driver version
      

float noiseA(in vec2 p){ // The reference function                
  vec2 f = fract(p);
  f = (f*f)*(3.0-(2.0*f));
  p = floor(p); 
  vec4 b = vec4(12.34, 56.78, 1.0, 0.0);
  vec4 r = fract(sin(vec4(dot(p.xy + b.ww, b.xy), dot(p.xy + b.zw, b.xy), dot(p.xy + b.wz, b.xy), dot(p.xy + b.zz, b.xy))) * 12345.6789);     
  return mix(mix(r.x,r.y,f.x),mix(r.z,r.w,f.x),f.y);	
}

float noiseB(in vec2 p){ // With manual by-hand dot products                
  vec2 f = fract(p);
  f = (f*f)*(3.0-(2.0*f));
  p = floor(p); 
  vec4 b = vec4(12.34, 56.78, 1.0, 0.0);
  vec2 pa = p.xy + b.ww;
  vec2 pb = p.xy + b.zw;
  vec2 pc = p.xy + b.wz;
  vec2 pd = p.xy + b.zz;
  vec4 r = fract(sin(vec4((pa.x * b.x) + (pa.y * b.y), (pb.x * b.x) + (pb.y * b.y), (pc.x * b.x) + (pc.y * b.y), (pd.x * b.x) + (pd.y * b.y))) * 12345.6789);     
  return mix(mix(r.x,r.y,f.x),mix(r.z,r.w,f.x),f.y);	
}           

float noiseC(in vec2 p){ // With a mat4 term optimized (hint: mat4 * vec4 != vec4 * mat4)               
  vec2 f = fract(p);
  f = (f*f)*(3.0-(2.0*f));
  vec4 r = fract(sin((floor(p.xyxy) + vec4(0.0, 0.0, 1.0, 1.0)) * mat4(12.34, 56.78, 0.0, 0.0, 0.0, 56.78, 12.34, 0.0, 12.34, 0.0, 0.0, 56.78, 0.0, 0.0, 12.34, 56.78)) * 12345.6789);     
  return mix(mix(r.x,r.y,f.x),mix(r.z,r.w,f.x),f.y);	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = fragCoord.xy / iResolution.xy;
  fragColor = vec4(noiseA(uv * 16.0)); // CHANGE HERE noiseA with noiseB or noiseC
}