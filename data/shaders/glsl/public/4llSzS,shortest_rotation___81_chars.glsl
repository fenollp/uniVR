// Shader downloaded from https://www.shadertoy.com/view/4llSzS
// written by shadertoy user FabriceNeyret2
//
// Name: shortest rotation - 81 chars
// Description: f.x--, sin(a+f*1.6) = (-cos(a),sin(a),sin(a),cos(a))
// 81
void mainImage( out vec4 f, vec2 i ) {
    f.x--;	f.xy =  (i-2e2) * mat2(sin(iDate.w+f*1.6)) ;
}


/* // 87
void mainImage( inout vec4 f, vec2 i ) {
	f.xy =  (i-2e2) * mat2(sin(iDate.w+vec4(1,2,0,1)*1.6)) ;
}
	

// f.x=2.; f.xy =  (i-2e2) * mat2(sin(iDate.w+f.wxyw*1.6)) ;  // also 87

*/





/* // 91
void mainImage( out vec4 f, vec2 i ) {
    i -= 2e2;
	i *= mat2(sin(iDate.w+vec4(1,2,0,1)*1.6)); 
 // i = sin(atan(i.y,i.x)+iDate.w+vec2(0,1.6)); // *length(i);
	f = i.xyyx;
}
*/