float n(float g) { return g * .5 + .5; }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  vec2 p  = vec2(iResolution.x/iResolution.y, 1) * uv;
  float a = atan(p.y, p.x);
  float l = length(p);
  vec3  c = vec3(0);

  p = vec2(sin(a), cos(a))/l;

  for (int i = 0; i < 3; i++) {
    float mag = 0.0;
    float t = iGlobalTime;// + float(i) * 0.05;

    p.y += 0.425;

    mag += n(cos(p.y * 1.5 + t * 5.));
    mag += n(sin(p.x + t * 3.));
    mag += n(cos(p.x * p.y));
    mag *= 0.333;

    c[i] = mag;
  }

  fragColor = vec4(1.0 - pow(c, vec3(0.4545)), 1);
}
