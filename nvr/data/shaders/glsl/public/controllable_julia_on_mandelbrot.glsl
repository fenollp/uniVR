// Shader downloaded from https://www.shadertoy.com/view/MtjSRw
// written by shadertoy user roombarampage
//
// Name: controllable Julia on Mandelbrot
// Description: inspired by ichko's Mandelbrot Set &amp; Julia... https://www.shadertoy.com/view/4tjSRw
//    
//    instructions: click and move the mouse around the screen to display the julia set for that location.
//    
//    background video: https://www.youtube.com/watch?v=oCkQ7WK7vuY
/*
  programmer: jonathan potter
  github: https://github.com/jonathan-potter
  repo: https://github.com/jonathan-potter/shadertoy-fractal
*/

const int MAX_ITERATIONS = 256;

struct complex { 
  float real;
  float imaginary;
};

int fractal(complex c, complex z) {
  for (int iteration = 0; iteration < MAX_ITERATIONS; iteration++) {

    // z <- z^2 + c
    float real = z.real * z.real - z.imaginary * z.imaginary + c.real;
    float imaginary = 2.0 * z.real * z.imaginary + c.imaginary;

    z.real = real;
    z.imaginary = imaginary;

    if (z.real * z.real + z.imaginary * z.imaginary > 4.0) {
      return iteration;
    }
  }

  return 0;
}

int mandelbrot(vec2 coordinate) {
  complex c = complex(coordinate.x, coordinate.y);
  complex z = complex(0.0, 0.0);

  return fractal(c, z);
}

int julia(vec2 coordinate, vec2 offset) {
  complex c = complex(offset.x, offset.y);
  complex z = complex(coordinate.x, coordinate.y);

  return fractal(c, z);
}

vec2 fragCoordToXY(vec2 fragCoord) {
  vec2 relativePosition = fragCoord.xy / iResolution.xy;
  float aspectRatio = iResolution.x / iResolution.y;

  vec2 cartesianPosition = (relativePosition - 0.5) * 4.0;
  cartesianPosition.x *= aspectRatio;

  return cartesianPosition;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 coordinate    = fragCoordToXY(fragCoord);
  vec2 clickPosition = fragCoordToXY(vec2(iMouse.x, iMouse.y));

  int juliaValue = julia(coordinate, clickPosition);
  int mandelbrotValue = mandelbrot(coordinate);
    
  float clickPoint;  
  if(length(clickPosition - coordinate) < 0.05){
    clickPoint = 1.0;
  } else {
    clickPoint = 0.0;
  }
    
  float juliaColor      = 5.0 * float(juliaValue) / float(MAX_ITERATIONS);
  float mandelbrotColor = 5.0 * float(mandelbrotValue) / float(MAX_ITERATIONS);

  float color = mandelbrotColor + juliaColor;
  fragColor = vec4(color, color, color + clickPoint, 1.0);
}
