// Shader downloaded from https://www.shadertoy.com/view/MdK3Rt
// written by shadertoy user guachito
//
// Name: Rainbow Mouse Cursor
// Description: You can change the dot by changing the dotHeight / dotWdth (it will get multiplied by 2 so careful) and the color&lt;br/&gt;by tinkering with the values in fragColor.&lt;br/&gt;This is my first shader so feedback is appreciated &lt;img src=&quot;/img/emoticonHappy.png&quot;/&gt;
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(0);
    float correct;
    vec2 point;
    float dotWdth;
    float dotHeight;
    dotHeight = 20.0;
    dotWdth = 20.0;
    point = vec2(iMouse.x,iMouse.y);
    if (fragCoord.x <= point.x + dotWdth && fragCoord.x >= point.x - dotWdth) { 
        if (fragCoord.y <= point.y + dotHeight && fragCoord.y >= point.y - dotHeight) { correct = 1.0;}}
    if (correct == 1.0) { 	fragColor = vec4(sin(point.x / point.y),0.5*sin(point.x / point.y),0.7*sin(iGlobalTime),1.0); }
}