// Shader downloaded from https://www.shadertoy.com/view/4tfSz2
// written by shadertoy user patriciogv
//
// Name: NumeredGrid
// Description: Example from http://patriciogonzalezvivo.com/2015/thebookofshaders/10/
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

float grid(vec2 st, float res){
    vec2 grid = fract(st*res);
    return 1.-(step(res,grid.x) * step(res,grid.y));
}

float box(in vec2 st, in vec2 size){
    size = vec2(0.5) - size*0.5;
    vec2 uv = smoothstep(size,
                        size+vec2(0.001),
                        st);
    uv *= smoothstep(size,
                    size+vec2(0.001),
                    vec2(1.0)-st);
    return uv.x*uv.y;
}

float cross(in vec2 st, vec2 size){
    return  clamp(box(st, vec2(size.x*0.5,size.y*0.125)) +
            box(st, vec2(size.y*0.125,size.x*0.5)),0.,1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 st = fragCoord.xy / iResolution.xy;
    st.x *= iResolution.x/iResolution.y;
    st *= 0.7;

    vec3 color = vec3(0.0);
    
    // Grid
    vec2 grid_st = st*300.;
    color += vec3(0.5,0.,0.)*grid(grid_st,0.01);
    color += vec3(0.2,0.,0.)*grid(grid_st,0.02);
    color += vec3(0.2)*grid(grid_st,0.1);

    // Crosses
    vec2 crosses_st = st + .5;
    crosses_st *= 3.;
    vec2 crosses_st_f = fract(crosses_st);
    color *= 1.-cross(crosses_st_f,vec2(.3,.3));
    color += vec3(.9)*cross(crosses_st_f,vec2(.2,.2));

    // Digits
    vec2 digits_st = mod(st*60.,20.);
    vec2 digits_st_i = floor(digits_st);
    if (digits_st_i.y == 1. &&
        digits_st_i.x > 0. && digits_st_i.x < 6. ) {
        vec2 digits_st_f = fract(digits_st);
        float pct = random(digits_st_i+floor(crosses_st)+floor(iGlobalTime*20.));
        color += vec3(char(digits_st_f,100.*pct));
    } else if (digits_st_i.y == 2. &&
        digits_st_i.x > 0. && digits_st_i.x < 8. ) {
        vec2 digits_st_f = fract(digits_st);
        float pct = random(digits_st_i+floor(crosses_st)+floor(iGlobalTime*20.));
        color += vec3(char(digits_st_f,100.*pct));
    }
    
    // Digits
    vec2 blocks_st = floor(st*3.);
    float t = iGlobalTime*.8+random(blocks_st);
    float time_i = floor(t);
    float time_f = fract(t);
    color.rgb += step(0.9,random(blocks_st+time_i))*(1.0-time_f);
    
	fragColor = vec4(color,1.0);
}