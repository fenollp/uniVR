// Shader downloaded from https://www.shadertoy.com/view/4llXzS
// written by shadertoy user coyote
//
// Name: Halftweet Scissors
// Description:  
void mainImage(out vec4 o,vec2 i) {
    i-=i.yx*abs(tan(iDate.w));
    o=i.yxxy;
}