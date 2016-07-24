// Shader downloaded from https://www.shadertoy.com/view/MdVGDh
// written by shadertoy user eiffie
//
// Name: My SOund VisUalization
// Description: sometimes my imagination is lacking
//Too Tey. Bee Yen by Villainous Willis is used CC

void mainImage(out vec4 O, in vec2 U){
    O=texture2D(iChannel0,U/iResolution.xy);
    if(U.y>0.85){
        O=O*0.5+texture2D(iChannel0,(U+vec2(1.0))/iResolution.xy)*0.5;
    }
}