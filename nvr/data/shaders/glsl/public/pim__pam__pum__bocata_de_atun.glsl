// Shader downloaded from https://www.shadertoy.com/view/MdcSD8
// written by shadertoy user hecLu
//
// Name: pim, pam, pum, bocata de atun
// Description: Up, down, right and left to move the cursor. Space to pick tuna. Press 'r' to reset the level.
//    Orange=1 
//    Pink=2
//    Green=3 
//    Red=5
//    Shiny=10
//    Sometimes there are bonus points
//    Practica 2 PGATR - Juego en un shader.
//    Autores:
//    Lucia Cubel
//    Hector Suarez
/*****************************************************************************************
*Shader realizado para la asignatura Procesadores Graficos y Aplicaciones en Tiempo Real
*
* Autores:
* Lucía Cubel
* Héctor Suárez
*
*This is the link to the presentation
*https://www.youtube.com/watch?v=8QX9XaFZ2bE
*See and enjoy
*
*PD: there will be improvements in the game
******************************************************************************************/

#define PI 3.14159265359
const float KEY_SP    = 32.5/256.0;
const vec2 posCuadrado  = vec2(0.0,0.0);
const vec2 dirTiempo  = vec2(1.0,0.0);
const vec2 dirPuntuacion  = vec2(6.0,0.0);
///////////////////////////////////////////////////////////////////////////////////////
//Obtenido de un shader de iq (https://www.shadertoy.com/view/MddGzf)
float SampleDigit(const in float n, const in vec2 vUV)
{
    if( abs(vUV.x-0.5)>0.5 || abs(vUV.y-0.5)>0.5 ) return 0.0;

    // digit data by P_Malin (https://www.shadertoy.com/view/4sf3RN)
    float data = 0.0;
         if(n < 0.5) data = 7.0 + 5.0*16.0 + 5.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    else if(n < 1.5) data = 2.0 + 2.0*16.0 + 2.0*256.0 + 2.0*4096.0 + 2.0*65536.0;
    else if(n < 2.5) data = 7.0 + 1.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 3.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 4.5) data = 4.0 + 7.0*16.0 + 5.0*256.0 + 1.0*4096.0 + 1.0*65536.0;
    else if(n < 5.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
    else if(n < 6.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
    else if(n < 7.5) data = 4.0 + 4.0*16.0 + 4.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 8.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    else if(n < 9.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    
    vec2 vPixel = floor(vUV * vec2(4.0, 5.0));
    float fIndex = vPixel.x + (vPixel.y * 4.0);
    
    return mod(floor(data / pow(2.0, fIndex)), 2.0);
}
float PrintInt( in vec2 uv, in float value )
{
    float res = 0.0;
    float maxDigits = 1.0+ceil(.01+log2(value)/log2(10.0));
    float digitID = floor(uv.x);
    if( digitID>0.0 && digitID<maxDigits )
    {
        float digitVa = mod( floor( value/pow(10.0,maxDigits-1.0-digitID) ), 10.0 );
        res = SampleDigit( digitVa, vec2(fract(uv.x), uv.y) );
    }

    return res;
}
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
//Funciones para crear ruido de worley
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 );
}
//Funcion que crea un efecto de plasma azul
vec3 getColor(){
	vec2 p = vec2(gl_FragCoord.xy / iResolution.xy);
	vec2 r =  3.0*vec2(gl_FragCoord.xy + 0.5*iResolution.xy)/iResolution.y;
	float t = iGlobalTime;
    r = r * 8.0;
	
    float v1 = sin(r.x +t);
    float v2 = sin(r.y +t);
    float v3 = sin(r.x+r.y +t);
    float v4 = sin(sqrt(r.x*r.x+r.y*r.y) +1.7*t);
	float v = v1+v2+v3+v4;
	
	vec3 ret;
	ret = vec3(sin((v+0.5)*PI)*0.0, sin(v)*0.3+0.5, 0.8);
		
	
	ret = 0.5 + 0.5*ret;
	//ret=vec3(1.0);
	return ret;
}
//Worley+plasma azul
vec3 water(){
	vec2 pos = gl_FragCoord.xy / iResolution.yy;
	pos += vec2(sin(pos.x * 12.0 + iGlobalTime) * 0.017 + sin(pos.y * 27.0 + 2.0 * iGlobalTime) * 0.015);

	float numTiles = 10.0;
	
	vec2 curretTile = floor(pos * numTiles);
	pos = fract(pos * numTiles) + 1.0;
	
	float minDist = 2.0;
	
	for(float y = -1.0; y < 2.0; y++) {

		for(float x = -1.0; x < 2.0; x++) {
			float po = rand( vec2(curretTile.x + x, curretTile.y + y) );
            //Animacion basada en un shader de iq (https://www.shadertoy.com/view/ldl3W8)
            //con nuestro pequeño toque personal
			po=0.5 + 0.4*cos( iGlobalTime + 6.2831*po );
			vec2 point = vec2( (1.0 + x) + po , (1.0 + y) + (1.0 - po) );
			
			float dist = distance(pos, point);
			float cond=float(minDist > dist);
			minDist =minDist*(1.0-cond)+dist*cond;
		}

	}
	vec3 color=mix(getColor()*0.4,getColor(),smoothstep(0.0,1.0,clamp(minDist*0.9,0.0,1.0)));
	return color;
}
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
//Metodos para colorear atunes
void triangulo(vec2 r,vec2 centro,float factorD,float xMax,inout vec3 pixel,vec3 colorTri){
	vec2 punto=vec2(r.x-centro.x,abs(r.y-centro.y));
	float pinta=step(punto.x,xMax)*step(punto.y,(xMax/factorD));
	float valorX=xMax-(factorD*punto.y);
	if(valorX>=punto.x&&punto.x>=0.0){
		pixel=(pixel*abs(pinta-1.0))+(colorTri*pinta);
	}
}
vec3 pintarPezI(vec2 posCuadrado,vec2 posActual,vec3 colorFrag,vec3 colorPez){
    vec2 aux=abs(posActual-posCuadrado);
    float y1=-20.0+0.01*aux.x+0.01*aux.x*aux.x;
    float y2=-y1;
    //El cuerpo del pez esta formado por la interseccion de do parabolas
    float cond=float((aux.y>=y1) && (aux.y<=y2));
    vec3 colorF=colorPez*cond+colorFrag*(1.0-cond);
    //La cola es la mitad de un rombo(un triangulo)
    triangulo(posCuadrado,posActual+vec2(-43.9,0.0),0.5,13.0,colorF,colorPez);
    return colorF;
    
}
vec3 pintarPezD(vec2 posCuadrado,vec2 posActual,vec3 colorFrag,vec3 colorPez){
    vec2 aux=abs(posActual-posCuadrado);
    aux=-aux;
    float y1=-20.0+0.01*aux.x+0.01*aux.x*aux.x;
    float y2=-y1;
    float cond=float((aux.y>=y1) && (aux.y<=y2));
    vec3 colorF=colorPez*cond+colorFrag*(1.0-cond);
    triangulo(-posCuadrado,-posActual+vec2(-45.0,0.0),0.5,13.0,colorF,colorPez);
    return colorF;
    
}
vec3 pintarPezUp(vec2 posCuadrado,vec2 posActual,vec3 colorFrag,vec3 colorPez){
    vec2 aux=abs(posActual-posCuadrado);
    float y=aux.x;
    aux.x=aux.y;
    aux.y=y;
    float y1=-20.0+0.01*aux.x+0.01*aux.x*aux.x;
    float y2=-y1;
    float cond=float((aux.y>=y1) && (aux.y<=y2));
    vec3 colorF=colorPez*cond+colorFrag*(1.0-cond);
    triangulo(-vec2(posCuadrado.y,posCuadrado.x),-vec2(posActual.y,posActual.x)+vec2(-43.9,0.0),0.5,13.0,colorF,colorPez);
    return colorF;
    
}
vec3 pintarPezAbajo(vec2 posCuadrado,vec2 posActual,vec3 colorFrag,vec3 colorPez){
    vec2 aux=abs(posActual-posCuadrado);
    float y=aux.x;   
    aux.x=aux.y;
    aux.y=y;
    float y1=-20.0+0.01*aux.x+0.01*aux.x*aux.x;
    float y2=-y1;
    float cond=float((aux.y>=y1) && (aux.y<=y2));
    vec3 colorF=colorPez*cond+colorFrag*(1.0-cond);
     triangulo(vec2(posCuadrado.y,posCuadrado.x),vec2(posActual.y,posActual.x)+vec2(-43.9,0.0),0.5,13.0,colorF,colorPez);
    return colorF;
    
}
/////////////////////////////////////////////////////////////////////////////////////

//Funcion que pinta y anima los 12 atunes que saldran en la pantalla
vec3 atunes(vec3 color, vec2 fragCoord){
    vec2 pintarPez[4];
    pintarPez[0]=vec2(2.0,0.0);
    pintarPez[1]=vec2(3.0,0.0);
    pintarPez[2]=vec2(4.0,0.0);
    pintarPez[3]=vec2(5.0,0.0);
    vec3 estadoPez[4];
    estadoPez[0]=texture2D( iChannel0, (pintarPez[0]+0.5)/iChannelResolution[0].xy ).xyz;
    estadoPez[1]=texture2D( iChannel0, (pintarPez[1]+0.5)/iChannelResolution[0].xy ).xyz;
    estadoPez[2]=texture2D( iChannel0, (pintarPez[2]+0.5)/iChannelResolution[0].xy ).xyz;
    estadoPez[3]=texture2D( iChannel0, (pintarPez[3]+0.5)/iChannelResolution[0].xy ).xyz;
    vec3 colorPez=vec3(1.0,0.5,0.0)+vec3(0.2);
    float t=iGlobalTime;
    ////////////////////////////////////////////////////////////////////////////////
    //Atunes de la derecha
    float momento=mod(t*120.0,(iResolution.x+600.0));
    float x=iResolution.x+43.17-momento;
    float y=iResolution.y*0.3;
    /*x=iResolution.x*0.5;
    y=iResolution.y*0.5;*/
    if(estadoPez[0].x>0.0){
    	color=pintarPezI(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*200.0,(iResolution.x+800.0));
    x=iResolution.x+43.17-momento;
    y=iResolution.y*0.6+sin(x*0.02)*80.0;
    colorPez=vec3(1.0,0.5,0.8)+vec3(0.1);
    if(estadoPez[0].y>0.0){
    	color=pintarPezI(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*80.0,(iResolution.x+400.0));
    x=iResolution.x+43.17-momento;
    y=iResolution.y*0.9+tan(x*0.02)*180.0;
    colorPez=vec3(0.0,1.0,0.2)+vec3(0.1);
    if(estadoPez[0].z>0.0){
    	color=pintarPezI(vec2(x,y),fragCoord,color,colorPez);
    }
    ////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////
    //Atunes de la izquierda
    momento=mod(t*250.0,(iResolution.x+4000.0));
    x=-43.17+momento;
    y=iResolution.y*0.1+cos(x*0.01)*120.0;
    colorPez=vec3(1.0,0.5,0.8)+vec3(0.1);
    if(estadoPez[1].x>0.0){
    	color=pintarPezD(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*250.0,(iResolution.x*3.0));
    x=-43.17+momento;
    y=iResolution.y*0.4+atan((x-250.0)*0.01)*60.0;
    colorPez=vec3(1.0,0.5,0.8)+vec3(0.1);
    if(estadoPez[1].y>0.0){
    	color=pintarPezD(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*800.0,(iResolution.x+20000.0));
    x=-43.17+momento;
    y=iResolution.y*0.7;
    colorPez=vec3(1.0,0.0,0.0)+vec3(0.1);
    if(estadoPez[1].z>0.0){
    	color=pintarPezD(vec2(x,y),fragCoord,color,colorPez);
    }
    ////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////
    //Atunes hacia abajo
    momento=mod(t*150.0,(iResolution.y*2.5));
    y=-43.17+momento;
    x=iResolution.x*0.1+momento*0.8;
    colorPez=vec3(1.0,0.5,0.0)+vec3(0.2);
    if(estadoPez[2].x>0.0){
    	color=pintarPezUp(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*100.0,(iResolution.y+600.0));
    y=-43.17+momento;
    x=iResolution.x*0.5+cos(y*0.1)*90.0;
    colorPez=vec3(0.0,1.0,0.2)+vec3(0.1);
    if(estadoPez[2].y>0.0){
    	color=pintarPezUp(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*100.0,(iResolution.y*4.0));
    y=-43.17+momento*momento*0.2;
    x=iResolution.x*0.9;
    colorPez=texture2D(iChannel2,vec2(x,y)).xyz+vec3(0.5);
    if(estadoPez[2].z>0.0){
    	color=pintarPezUp(vec2(x,y),fragCoord,color,colorPez);
    }
    ////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////
    //Atunes hacia arriba
    momento=mod(t*100.0,(iResolution.y*5.0));
    y=iResolution.y+43.17-momento;
    x=iResolution.x*0.235+cos(y*0.01)*690.0;
    colorPez=vec3(1.0,0.0,0.0)+vec3(0.1);
    if(estadoPez[3].x>0.0){
    	color=pintarPezAbajo(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*1500.0,(iResolution.y*50.0));
    y=iResolution.y+43.17-momento;
    x=iResolution.x*0.32154;
    colorPez=texture2D(iChannel2,vec2(x,y)).xyz+vec3(0.5);
    if(estadoPez[3].y>0.0){
    	color=pintarPezAbajo(vec2(x,y),fragCoord,color,colorPez);
    }
    momento=mod(t*200.0,(iResolution.y*8.0));
    y=iResolution.y+43.17-momento;
    x=iResolution.x*0.715-momento*1.5;
    colorPez=vec3(1.0,0.5,0.0)+vec3(0.2);
    if(estadoPez[3].z>0.0){
    	color=pintarPezAbajo(vec2(x,y),fragCoord,color,colorPez);
    }
    ////////////////////////////////////////////////////////////////////////////////

    return color;
}

//Funcion que pinta el cursor (caña de pescar)
vec3 pintarCuadrado(vec2 posCuadrado,vec2 posActual,float ancho,float largo,vec3 colorFrag){
    vec2 aux=abs(posActual-posCuadrado);
    float cond=float((aux.y<=largo) && (aux.x<=ancho));
    vec3 colorC=vec3(0.9,0.0,0.2); 
    return colorC*cond+colorFrag*(1.0-cond);
    
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    //Pintamos un lecho de piedras
    vec3 color=texture2D(iChannel1,fragCoord/iResolution.xy).xyz;
    //Cargamos el estado
    vec2 posCuadrado = texture2D( iChannel0, (posCuadrado+0.5)/iChannelResolution[0].xy ).xy;
    float tiempo= texture2D( iChannel0, (dirTiempo+0.5)/iChannelResolution[0].xy ).x;
    //Si el tiempo no se ha acabado seguimos pintando atunes y animando atunes
    if(tiempo>0.0){
    	color=atunes(color,fragCoord);
    }
    float puntos=texture2D( iChannel0, (dirPuntuacion+0.5)/iChannelResolution[0].xy ).x;
    float f = PrintInt( (((-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y)-vec2(-1.5,0.8))*10.0, puntos);
    vec3 color2=water();
    //Creamos la excena final
    color=mix(color,color2,0.6);
    color=pintarCuadrado(posCuadrado,fragCoord,5.0,5.0,color);
    //Pintamos la puntuacion
    color = mix( color, vec3(1.0,1.0,1.0), f );
    f = PrintInt( (((-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y)+vec2(-1.3,-0.8))*10.0, tiempo);
	color = mix( color, vec3(0.8), f );
    fragColor = vec4(color,1.0);
}