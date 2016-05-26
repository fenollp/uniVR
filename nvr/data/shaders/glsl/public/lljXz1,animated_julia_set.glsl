// Shader downloaded from https://www.shadertoy.com/view/lljXz1
// written by shadertoy user roombarampage
//
// Name: Animated Julia Set
// Description: Julia Set animation
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

  return MAX_ITERATIONS;
}

int mandelbrot(float x, float y) {
  complex c = complex(x, y);
  complex z = complex(0.0, 0.0);

  return fractal(c, z);
}

int animatedJulia(float x, float y) {
  float animationOffset = 0.055 * cos(iGlobalTime * 2.0);

  complex c = complex(-0.795 + animationOffset, 0.2321);
  complex z = complex(x, y);

  return fractal(c, z);
}

vec2 fragCoordToXY(vec2 fragCoord) {
  vec2 relativePosition = fragCoord.xy / iResolution.xy;
  float aspectRatio = iResolution.x / iResolution.y;

  vec2 cartesianPosition = (relativePosition - 0.5) * 4.0 / (1.30 - cos(iGlobalTime * 1.0));
  cartesianPosition.x *= aspectRatio;

  return cartesianPosition;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 coordinate = fragCoordToXY(fragCoord);

  int crossoverIteration = animatedJulia(float(coordinate.x), float(coordinate.y));
    
  float color = 5.0 * float(crossoverIteration) / float(MAX_ITERATIONS);

  fragColor = vec4(color, color, color, 1.0);
}
