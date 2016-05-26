// Shader downloaded from https://www.shadertoy.com/view/XlXSz2
// written by shadertoy user patriciogv
//
// Name: Digits
// Description: Example of http://patriciogonzalezvivo.com/2015/thebookofshaders/10/
// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

float random(in float x){ return fract(sin(x)*43758.5453); }
float random(in vec2 st){ return fract(sin(dot(st.xy ,vec2(12.9898,78.233))) * 43758.5453); }

float bin(vec2 ipos, float n){
    float remain = mod(n,33554432.);
    for(float i = 0.0; i < 25.0; i++){
        if ( floor(i/3.) == ipos.y && mod(i,3.) == ipos.x ) {
            return step(1.0,mod(remain,2.));
        }
        remain = ceil(remain/2.);
    }
    return 0.0;
}

float char(vec2 st, float n){
    st.x = st.x*2.-0.5;
    st.y = st.y*1.2-0.1;

    vec2 grid = vec2(3.,5.);

    vec2 ipos = floor(st*grid);
    vec2 fpos = fract(st*grid);

    n = floor(mod(n,10.));
    float digit = 0.0;
    if (n < 1. ) { digit = 31600.; } 
    else if (n < 2. ) { digit = 9363.0; } 
    else if (n < 3. ) { digit = 31184.0; } 
    else if (n < 4. ) { digit = 31208.0; } 
    else if (n < 5. ) { digit = 23525.0; } 
    else if (n < 6. ) { digit = 29672.0; } 
    else if (n < 7. ) { digit = 29680.0; } 
    else if (n < 8. ) { digit = 31013.0; } 
    else if (n < 9. ) { digit = 31728.0; } 
    else if (n < 10. ) { digit = 31717.0; }
    float pct = bin(ipos, digit);

    vec2 borders = vec2(1.);
    // borders *= step(0.01,fpos.x) * step(0.01,fpos.y);   // inner
    borders *= step(0.0,st)*step(0.0,1.-st);            // outer

    return step(.5,1.0-pct) * borders.x * borders.y;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 st = fragCoord.xy / iResolution.xy;
    st.x *= iResolution.x/iResolution.y;

    float rows = 24.0;
    vec2 ipos = floor(st*rows);
    vec2 fpos = fract(st*rows);

    ipos += vec2(0.,floor(iGlobalTime*20.*random(ipos.x+1.)));
    float pct = random(ipos);
    vec3 color = vec3(char(fpos,321.*pct));
    color = mix(color,vec3(color.r,0.,0.),step(.99,pct));

    fragColor = vec4( color , 1.0);
}