// Shader downloaded from https://www.shadertoy.com/view/4sB3zz
// written by shadertoy user hornet
//
// Name: Plotting Functions
// Description: Three ways to plot a highly oscillating function
//    - multisampling (xy)
//    - weighing by value-distance (y)
//    - na&iuml;ve single sample of value
//    
//    Originally inspired by http://blog.hvidtfeldts.net/index.php/2011/07/plotting-high-frequency-functions-using-a-gpu/
#ifdef GL_ES
precision highp float;
#endif
 
 
float aspect = iResolution.x / iResolution.y;
 
float function( float x ) {
  return sin(x*x*x)*sin(x);
//  return sin(x*x*x)*sin(x) + 0.1*sin(x*x);
//  return sin(x);
}
 
//note: does one sample per x, thresholds on distance in y
float discreteEval( vec2 uv ) {
  const float threshold = 0.015;
  float x = uv.x;
  float fx = function( x );
  float dist = abs( uv.y - fx );
  float hit = step( dist, threshold );
  return hit;
}
 
//note: samples graph by checking multiple samples being above / below function
//original from http://blog.hvidtfeldts.net/index.php/2011/07/plotting-high-frequency-functions-using-a-gpu/
float stochEval( vec2 uv ) {
  const int samples = 255; //note: on AMD requires 255+ samples, should be ~50
  const float fsamples = float(samples);
  vec2 maxdist = 0.075 * vec2( aspect, 1.0 );
  vec2 stepsize = maxdist / vec2(samples);
  float count = 0.0;
  vec2 initial_offset = - 0.5 * fsamples * stepsize;
  uv += initial_offset;
  for ( int ii = 0; ii<samples; ii++ ) {
    float i = float(ii);
    float fx = function( uv.x + i*stepsize.x );
    for ( int jj = 0; jj<samples; jj++ ) {
      float j = float(jj);
      float diff =  fx - float(uv.y + j*stepsize.y);
      count = count + step(0.0, diff) * 2.0 - 1.0;
    }
  }
  return 1.0 - abs( count ) / float(samples*samples);
}
 
//note: averages distances over multiple samples along x, result is identical to superEval
float distAvgEval( vec2 uv ) {
  const int samples = 55;
  const float fsamples = float(samples);
  vec2 maxdist = 0.075 * vec2( aspect, 1.0 );
  vec2 halfmaxdist = 0.5 * maxdist;
  float stepsize = maxdist.x / fsamples;
  float initial_offset_x = -0.5*fsamples * stepsize;
  uv.x += initial_offset_x;
  float hit = 0.0;
  for( int i=0; i<samples; ++i ) {
    float x = uv.x + stepsize * float(i);
    float y = uv.y;
    float fx = function( x );
    float dist = ( y - fx );
    float vt = clamp( dist / halfmaxdist.y -1.0, -1.0, 1.0 );
    hit += vt;
  }
  return 1.0 - abs(hit) / fsamples;
}
 
//note: does multiple thresholded samples
float proxyEval( vec2 uv ) {
  const int samples = 255; //note: on AMD requires 255+ samples, should be ~50
  const float fsamples = float(samples);
  vec2 maxdist = vec2(0.05) * vec2( aspect, 1.0 );
  vec2 halfmaxdist = vec2(0.5) * maxdist;
  float stepsize = maxdist.x / fsamples;
  float initial_offset_x = -0.5 * fsamples * stepsize;
  uv.x += initial_offset_x;
  float hit = 0.0;
  for( int i=0; i<samples; ++i ) {
    float x = uv.x + stepsize * float(i);
    float y = uv.y;
    float fx = function( x );
    float dist = abs( y - fx );
    hit += step( dist, halfmaxdist.y );
  }
  const float arbitraryFactor = 3.5; //note: to increase intensity
  const float arbitraryExp = 0.95;
  return arbitraryFactor * pow( hit / fsamples, arbitraryExp );
}
 
 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv_norm = fragCoord.xy / iResolution.xy;
	vec4 dim = vec4( -2.0 + sin(iGlobalTime), 12.0 + sin(iGlobalTime), -3.0, 3.0 );
	uv_norm = (uv_norm ) * ( dim.yw - dim.xz ) + dim.xz;
 
	//float hitStoch = stochEval( uv_norm - vec2(0,2) );
	float hitProximity = proxyEval( uv_norm - vec2(0,2) );
	float hitDistAvgStoch = distAvgEval( uv_norm - vec2(0,0) );
	float hitDiscr = discreteEval( uv_norm  + vec2(0,2) );
 
	vec3 g0 = vec3(0.0,0.8,0.2) * hitProximity;
	vec3 g1 = vec3(1.0,0.0,0.0) * hitDistAvgStoch;	
	vec3 g2 = vec3(0.0,0.5,1.0) * hitDiscr;
	
	fragColor = vec4( g0+g1+g2, 1.0 );
}
