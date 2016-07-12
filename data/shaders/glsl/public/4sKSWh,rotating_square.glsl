// Shader downloaded from https://www.shadertoy.com/view/4sKSWh
// written by shadertoy user FurryLiso
//
// Name: Rotating_square
// Description: /
#define RotatingMat(Angle) mat2(cos(Angle),sin(Angle),-sin(Angle),cos(Angle))
const float Pi = 3.1415;
const float RotatingSpeed = 100.0;

struct Square
{
    vec2 A;
    vec2 B;
    vec2 C;
    vec2 D;
    vec4 ColorSquare;
};
    
vec4 RGBA(int R, int G, int B, int A)
{
    return vec4(float(R), float(G), float(B), float(A)) / 255.0;
}

Square SetSquare(float Width, vec4 Color)
{
    vec2 A = vec2(iResolution.x / 2.0 - Width, iResolution.y / 2.0 - Width);
    vec2 B = vec2(iResolution.x / 2.0 - Width, iResolution.y / 2.0 + Width);
    vec2 C = vec2(iResolution.x / 2.0 + Width, iResolution.y / 2.0 + Width);
    vec2 D = vec2(iResolution.x / 2.0 + Width, iResolution.y / 2.0 - Width);
    return Square(A, B, C, D, Color);
}

bool PointInSquare(vec2 Point, Square S)
{
    float A1 = (S.A.x - Point.x) * (S.B.y - S.A.y) - (S.B.x - S.A.x) * (S.A.y - Point.y);
    float B1 = (S.B.x - Point.x) * (S.D.y - S.B.y) - (S.D.x - S.B.x) * (S.B.y - Point.y);
    float C1 = (S.D.x - Point.x) * (S.A.y - S.D.y) - (S.A.x - S.D.x) * (S.D.y - Point.y);
    
    float A2 = (S.B.x - Point.x) * (S.C.y - S.B.y) - (S.C.x - S.B.x) * (S.B.y - Point.y);
    float B2 = (S.C.x - Point.x) * (S.D.y - S.C.y) - (S.D.x - S.C.x) * (S.C.y - Point.y);
    float C2 = (S.D.x - Point.x) * (S.B.y - S.D.y) - (S.B.x - S.D.x) * (S.D.y - Point.y);
    
    return ((A1 >= 0.0 && B1 >= 0.0 && C1 >= 0.0) || (A1 <= 0.0 && B1 <= 0.0 && C1 <= 0.0))
         ||((A2 >= 0.0 && B2 >= 0.0 && C2 >= 0.0) || (A2 <= 0.0 && B2 <= 0.0 && C2 <= 0.0));
}

vec4 DrawSquare(vec2 Pixel, Square S)
{
    if(PointInSquare(Pixel, S))
    	return S.ColorSquare;
    else
        return vec4(1.0);
}

Square RotateSquare(Square S, float Angle)
{
    Angle *= Pi / 180.0;
    
    vec2 A, B, C, D;
    vec2 Centr;
    
    Centr = iResolution.xy / 2.0;
    
    A = (S.A - Centr) * RotatingMat(Angle) + Centr;
    B = (S.B - Centr) * RotatingMat(Angle) + Centr;
    C = (S.C - Centr) * RotatingMat(Angle) + Centr;
    D = (S.D - Centr) * RotatingMat(Angle) + Centr;
    
	return Square(A, B, C, D, S.ColorSquare);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    Square S = SetSquare(50.0, RGBA(255, 100, 0, 255));
    S = RotateSquare(S, iGlobalTime * RotatingSpeed);
    fragColor = DrawSquare(fragCoord, S);
}