// Shader downloaded from https://www.shadertoy.com/view/XljXzt
// written by shadertoy user fernandoanton
//
// Name: TazonCircles
// Description: Circulos para tazon
#define RADIO 0.4
#define RADIO_2 0.16

#define CENTER_X 0.3
#define CENTER_Y 0.2

#define COLOR_R 1.0
#define COLOR_G 0.5
#define COLOR_B 0.5

#define SPEED 0.4
#define MOVE_RADIO 0.3

#define SPEED_2 0.6
#define MOVE_RADIO_2 0.6


#define PI 3.14159265359
#define TWOPI 6.28318530718

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float CenterX = CENTER_X + MOVE_RADIO*cos(SPEED*PI*iGlobalTime) + MOVE_RADIO_2*sin(SPEED_2*PI*iGlobalTime);
	float CenterY = CENTER_Y + MOVE_RADIO*sin(SPEED*PI*iGlobalTime) + MOVE_RADIO_2*cos(SPEED_2*PI*iGlobalTime);
	vec3 Color = vec3(0);
	// Convertimos las coordenadas del pixel X,Y con el que estamos trabajando (fragCoord)
	// R valdra un valor entre (-iResolution.X/2 .. +iResolution.X/2 , -iResolution.Y/2 .. +iResolution.Y/2)
	// Es una sentencia vectorial - R es un vector bidimensional y la operacion trabaja sobre las dos componentes
	// La sintaxis es igual que la de R o la de Matlab
	vec2 R = vec2( fragCoord.xy - 0.5*iResolution.xy );
	// Ahora normalizamos R
	// R valdra un valor entre (-AspectRatio .. +AspectRatio , -1 .. +1)
	// Donde AspectRatio es iResolution.X / iResolution.Y - es decir, ajustamos por la pantalla que no es cuadrada
	R = 2.0 * R.xy / iResolution.y;
	// Procesamos el pixel. Se trata de saber si esta o no dentro de la circunferencia
	float DistanceX2 = (R.x - CenterX) * (R.x - CenterX);
	float DistanceY2 = (R.y - CenterY) * (R.y - CenterY);
	float Distance2 = DistanceX2+DistanceY2;
	if (Distance2<RADIO_2) Color=vec3(COLOR_R,COLOR_G,COLOR_B);
	fragColor=vec4(Color,1.0);
}
