// Shader downloaded from https://www.shadertoy.com/view/4d33z4
// written by shadertoy user sagarpatel
//
// Name: My first ShaderToy: Learning SDF
// Description: Hacked on top of @cabbibo's awesome SDF tutorial ( https://www.shadertoy.com/view/Xl2XWt ) and uses funcs from IQ's SDF page (http://iquilezles.org/www/articles/distfunctions/distfunctions.htm)
//    Did the tut + this on the bus ride from Ha Long Bay to Hanoi
// @sagzorz
// My first shader on ShaderToy!



// The stuff below is pretty much all of the amazing @cabbibo's SDF tutorial 
// https://www.shadertoy.com/view/Xl2XWt

// I read thorugh it then looked at IQ's page on distance functions 
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

// got inspired and remixed stuff in really messy code
// my only excuse was that I was in a rush since I did the tutorial and my hack all in a bus ride
// from Ha Long Bay to Hanoi and batteries were starting to run out :/

/*

    CC0 1.0

	@vrtree
	who@tree.is
	http://tree.is
	
	
	I dont know if this is going to work, or be interesting, 
	or even understandable, But hey! Why not try!

	To start, get inspired by some MAGICAL creations made by raytracing:

	Volcanic by IQ
	https://www.shadertoy.com/view/XsX3RB

	Remnant X by Dave_Hoskins ( Audio Autoplay warnings )
	https://www.shadertoy.com/view/4sjSW1

	Cloud Ten by Nimitz
	https://www.shadertoy.com/view/XtS3DD

	Spectacles by MEEEEEE
    https://www.shadertoy.com/view/4lBXWt

	[2TC 15] Mystery Mountains by Dave_Hoskins
	https://www.shadertoy.com/view/llsGW7

	Raytracing graphics is kinda like baking cakes. 
	
	I want yall to first see how magical 
	the cake can be before trying to learn how to make it, because the thing we 
	make at first isn't going to be one of those crazy 10 story wedding cakes. its just
	going to be some burnt sugar bread. 
	
	Making art using code can be so fufilling, and so infinite, but to get there you 
	need to learn some techniques that might not seem that inspiring. To bake a cake,
	you first need to turn on an oven, and need to know what an oven even is. In this
	tutorial we are going to be learning how to make the oven, how to turn it on, 
	and how to mix ingredients. as you can see on our left, our cake isn't very pretty
	but it is a cake. and thats pretty crazy for just one tutorial!

	Once you have gone through this tutorial, you can see a 'minimized' version
	here: https://www.shadertoy.com/view/Xt2XDt

	where I've rewritten it using the varibles and functions that
	are used alot throughout shadertoy. The inspiration examples above
	probably seem completely insane, because of all the single letter variable
	names, but keep in mind, that they all start with most of the same ingredients 
	and overn that we will learn about right now!

	
	I've tried to break up the code into 'sections'
	which have the 'SECTION 'BLAH'' label above them. Not sure
	if thats gonna help or not, but please leave comments 
	if you think something works or doesn't work, slash you 
	have any questions!!!

	or contact me at @vrtree || @cabbibo


	Cheat sheet for vectors:

    x = left / right
	y = up / down
	z = forwards / backwards

	also, for vectors labeled 'color'

	x = red
	y = green
	z = blue



	//---------------------------------------------------
    // SECTION 'A' : ONE PROGRAM FOR EVERY PIXEL!
    //---------------------------------------------------

	The best metaphor that I can think of for raytracing is
	that the rectangle to our left is actually just a small window
	into a fantastic world. We need to describe that world, 
	so that we can see it. BUT HOW ?!?!?!

	What we are doing below is describing what color each pixel
	of the window is, however because of the way that shader 
	programs work, we need to give the same instruction to every
	single PIXEL ( or in shadertoy terms, FRAGMENT )
	in the window. This is where the term SIMD comes 
	from : Same Instruction Multiple Data 

	In this case, the same instruction is the program below,
	and the multiple data is the marvelous little piece of magic
	called 'fragCoord' which is just the position of the pixel in 
	window. lets rename some things to look prettier.

	
	//---------------------------------------------------
    // SECTION 'B' : BUILDING THE WINDOW
    //---------------------------------------------------

	If you think about what happens with an actual window, you 
	can begin to get an idea of how the magic of raytracing works
	basically a bunch of rays come from the sun ( and or other
	light sources ) , bounce around a bunch ( or a little ), and
	eventually make it through the window, and into our eyes.

	Now the number of rays are masssiveeee that come from the sun
	and alot of them that are bouncing around, will end up going 
	directions that aren't even close to the window, or maybe
	will hit the wall instead of the window. 

	We only care about the rays that go through the window 
	and make it to our eyeballs!

	This means that we can be a bit intelligent. Instead of 
	figuring out the rays that come from the sun and bounce around
	lets start with out eyes, and work backwards!!!!


	//---------------------------------------------------
    // SECTION 'C' : NAVIGATING THE WORLD
    //---------------------------------------------------

	After setting up all the neccesary ray information,
	we FINALLY get to start building the scene. Up to this point, 
	we've only built up the window, and the rays that go from our
	eyes through the window, but now we need to describe to the rays
    if they hit anything and what they hit!


	Now this part has some pretty scary code in it ( whenever I look
	at it at least, my eyes glaze over ), so feel free to skip over 
	the checkRayHit function. I tried to explain it as best as I could
	down below, and you might want to come back to it after going
	throught the rest of the tutorial, but the important thing to
	remember is the following:


	These 'rays' that we've been talking about will move through the
	scene along their direction. They do this iteratively, and at each
	step will basically ask the question :
	
	'HOW CLOSE AM I TO THINGS IN THE WORLD???'

	because well, rays are lonely, and want to be closer to things in
	the world. We provide them an answer to that question using our
	description of the world, and they use this information to tell
	them how much further along their path they should move. If the
	answer to the question is:
		
	'Lovely little ray, you are actually touching a thing in the world!'
	
	We know what that the ray hit something, and can begin with our next
	step!
	
	The tricky part about this is that we have to as accuratly as 
	possible provide them an answer to their question 'how close??!!'
	


	//--------------------------------------------------------------
    // SECTION 'D' : MAPPING THE WORLD , AKA 'SDFS ARE AWESOME!!!!'
    //--------------------------------------------------------------

	To answer the above concept, we are going to use this magical 
	concept called: 

	'Signed Distance Fields'
	-----------------------

	These things are the best, and very basically can be describe as 
	a function that takes in a position, and feeds back a value of
	how close you are to a thing. If the value of this distance is negative
	you are inside the thing, if it is positive, you are outside the thing
	and if its 0 you are at the surface of the thing! This positive or negative
	gives us the 'Signed' in 'Signed Distance Field'

	For a super intensive description of many of the SDFs out there
	check out Inigo Quilez's site:

	http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

	Also, if you want a deep dive into why these functions are the 
	ultimate magic, check out this crazy paper by the geniouses
	over at Media Molecule about their new game: 'DREAMS' 

    http://media.lolrus.mediamolecule.com/AlexEvans_SIGGRAPH-2015.pdf

	Needless to say, these lil puppies are super amazing, and are
	here to free us from the tyranny of polygons.


	---------

	We are going to put all of our SDFs into a single function called
	
	'mapTheWorld' 
	
	which will take in a position, and feed back two values.
	The first value is the Distance of Signed Distance Field, and the
	second value will tell us what we are closest too, so that if 
	we actually hit something, we can tell what it is. We will denote this
	by an 'ID' value.

	The hardest part for me to wrap my head around for this was the fact that
	these fields do not just describe where the surface of an object is,
	they actually describe how far you are from the object from ANYWHERE 
	in the world. 

	For example, if I was hitting a round ballon ( AKA a sphere :) ) 
	I wouldn't just know if I was on the surface of the ballon, I would have
	to know how close I was to the balloon from anywhere in space.

	Check out the 'TAG : BALLOON' in the mapTheWorld function for more detail :)

	I've also made a function for a box, that is slightly more complex, and to be
	honest, I don't exactly understand the math of it, but the beauty of programming
	is that someone else ( AKA Inigo ) does, and I can steal his knowledge, just by
	looking at the functions from his website!
	
	---------

	One of the magical properties of SDFs is how easily they can be combined 
	contorted, and manipulated. They are just these lil functions that take 
	in a position and give back a distance value, so we can do things like play with the
	input position, play with the output distance value, or just about anything
	else.

	We'll start by combining two SDFs by asking the simple question
	
	'Which thing am I closer to?'
	
	which is as simple as a '>' because we already know exactly how close we are 
	to each thing!

	check out 'TAG : WHICH AM I CLOSER TO?'  for more enough

	We use these function to create a map of the world for the rays to navigate,
	and than pass that map to the checkRayHit, which propates the rays throughout
	the world and tells us what they hit.

	Once they know that, we can FINALLY do our last step:


	//--------------------------------------------------------------
    // SECTION 'E' : COLORING THE WORLD!
    //--------------------------------------------------------------

	At the end of our checkRayHit function we return a vec2 with two values:
	.x is the distance that our ray traveled before hitting
	.y is the ID of the thing that we hit.

	if .y is less that 0.0 that means that our ray went as far as we allowed it
	to go without hitting anything. thats one lonely ray :(
	
	however, that doesn't mean that the ray didn't hit anything. It just meant 
	that it is part of the background. 
	
	Thanks little ray! 
	You told us important information about our scene, 
	and your hard work is helping to create the world!

	We can get reallly crazy with how we color the background of the scene,
	but for this tutorial lets just keep it black, because who doesn't love 
	the void.

	we will use the function 'doBackgroundColor' to accomplish this task!

	That tells us about the background, but what if .y is greater than 0.0?
	then we get to make some stuff in the scene!

	if the ID is equal to balloon id, then we 'doBalloonColor'
	and if the ID is equal to the box , then we 'doBoxColor'
	
	This is all that we need if we want to color simple solid objects,
	but what if we want to add some shading, by doing what we originally
	talked about, that is, following the ray to the sun?

	For this first tutorial, we will keep it to a very naive approach,
	but once you get the basics of sections A - D, we can get SUPER crazy
	with this 'color' the world section. 

	For example, we could reflect the
	ray off the surface, and than repeat the checkRayHit with this new information
	continuing to follow this ray through more and more of the world. we could 
	repeat this process again and again, and even though our gpu would hate us
	we could continue bouncing around until we got to a light source! 

	In a later tutorial we will do exactly this, but for now, 
	we are going to do 1 simple task:


	See how much the surface that we hit, faces the sun.


	to do that we need to do 2 things. 

	First, determine which way the surface faces
	Second, determine which way rays go from the surface to get to the sun

	1) To determine the way that the surface faces, we will use a function called
	'getNormalOfSurface' This function will either make 100% sense, or 0% sense
	depending on how often you have played with fields, but it made 0% sense to me
	for many years, so don't worry if you don't get it! Whats important is that
	it gives us the direction that the surface faces, which we call its 'Normal'
	You can think of it as a vector that is perpendicular to the surface at a specific point
	
	So that it is easier to understand what this value is, we are actually going to color our
	box based on this value. We will map the X value of the normal to red, the Y value of the 
	normal to green and the Z value of the normal to blue. You can see this more in the 
	'doBoxColor' function

	
	2) To get the direction the rays go to get to the sun, we just need to subtract the sun
	position from the position of where we hit. This will provide us a direction from the sun
	to the position. Look inside the doBalloonColor to see this calculation happen.
	this will give us the direction of the rays from the sun to the surface!


	Now that we have these 2 pieces of information, the last thing we need to do is see 
	how much the two vectors ( the normal and the light direction ) 'Face' each other. 
	
	that word 'Face', might not make much sense in this context, but think about it this way.

	If you have a table, and a light above the table, the top of the table will 'Face',
	the light, and the bottom of the table will 'Face' away from the light. The surface
	that 'Faces' the light will get hit by the rays from the light, while the surface
	that 'Faces' away from the light will be totally dark!

	so how do we get this 'Face' value ( pun intended :p ) ?

	There is a magical function called a 'dot product' which does exactly this. you 
	can read more here:

	https://en.wikipedia.org/wiki/Dot_product

	basically this function takes in 2 vectors, and feeds back a value from -1 -> 1.

	if the value is -1 , the two vectors face in exact opposite directions, and if
	the value is 1 , the two vectors face in exactly the same direction. if the value is
	0, than they are perpendicular!

	By using the dot product, we take get the ballon's 'Face' value and color it depending
	on this value!

	check out the doBallonColor to see all this craziness in action


	//--------------------------------------------------------------
    // SECTION 'F' : Wrapping up
    //--------------------------------------------------------------

	What a journey it has been. Remember back when we were talking about
	sending rays through the window? Remember them moving all through the 
	world trying to be closer to things?

	So much has happened, and at the end of that journey, we got a color for each ray!

	now all we need to do is output that color onto the screen , which is a single call,
	and we've made our world.


	I know this stuff might seem too dry or too complex at times, too confusing, 
	too frustrating, but I promise, if you stick with it, you'll soon be making some of the
	other magical structures you see throughout the rest of this site.

	I'll be trying to do some more of these tutorials, and you'll see that VERY
	quickly, you get from this hideous monstrosity to our left, to marvelous worlds
	filled with lights, colors, and love.

	Thanks for staying around, and please contact me:

	@vrtree , @cabbibo with questions, concerns , and improvments. Or just comment!



*/



//---------------------------------------------------
// SECTION 'B' : BUILDING THE WINDOW
//---------------------------------------------------

// Most of this is taken from many of the shaders
// that @iq have worked on. Make sure to check out
// more of his magic!!!


// This calculation basically gets a way for us to 
// transform the rays coming out of our eyes and going through the window.
// If it doesn't make sense, thats ok. It doesn't make sense to me either :)
// Whats important to remember is that this basically gives us a way to position
// our window. We could you it to make the window look north, south, east, west, up, down
// or ANYWHERE in between!
mat3 calculateEyeRayTransformationMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}







//--------------------------------------------------------------
// SECTION 'D' : MAPPING THE WORLD , AKA 'SDFS ARE AWESOME!!!!'
//--------------------------------------------------------------


//'TAG: BALLOON'
vec2 sdfBalloon( vec3 currentRayPosition ){
  
  float ballOrbitSpeed = 0.85;
  float ballOrbitRadius = 1.0;
  vec3 ballOrbitOffset = vec3(1.0,0,0);
    
  float balloonPosX = ballOrbitRadius * cos( ballOrbitSpeed * iGlobalTime);
  float balloonPosY = ballOrbitRadius * sin( ballOrbitSpeed * iGlobalTime);
    
  // First we define our balloon position
  vec3 balloonPosition = ballOrbitOffset + vec3(balloonPosX,balloonPosY,0); //vec3( -1.3 , .3 , -0.4 );
    
  // than we define our balloon radius
  float balloonRadius = 0.51;
    
  // Here we get the distance to the surface of the balloon
  float distanceToBalloon = length( currentRayPosition - balloonPosition );
    
  // finally we get the distance to the balloon surface
  // by substacting the balloon radius. This means that if
  // the distance to the balloon is less than the balloon radius
  // the value we get will be negative! giving us the 'Signed' in
  // Signed Distance Field!
  float distanceToBalloonSurface = distanceToBalloon - balloonRadius;
    
  
  // Finally we build the full balloon information, by giving it an ID
  float balloonID = 1.;
    	
  // And there we have it! A fully described balloon!
  vec2 balloon = vec2( distanceToBalloonSurface,  balloonID );
    
  return balloon;
    
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float opTwist_Torus( vec3 p , vec2 torusS)
{
    float twistSpedd = 0.35;
    float c = cos( 15.0 * (sin( twistSpedd * iGlobalTime)) *p.y );
    float s = sin( 15.0 * (sin( twistSpedd * iGlobalTime)) *p.y );
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xz,p.y);
    return sdTorus(q, torusS);
}

vec2 sdfTorus( vec3 currentRayPos )
{
    vec3 torusPos = vec3( 0.0, 0.0, 0.0);
    vec2 torusSpec = vec2(0.6, 0.23);
    
    vec3 adjustedRayPos = currentRayPos - torusPos;
    float distToTorusSurface = opTwist_Torus(adjustedRayPos, torusSpec); //sdTorus(adjustedRayPos, torusSpec);
    
    float torusID = 3.;
    vec2 torus = vec2( distToTorusSurface, torusID);
    return torus;
}

float smin( float a, float b)
{
    float k = 0.77521;
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float opBlend( float d1, float d2)
{
    //float d1 = primitiveA(p);
    //float d2 = primitiveB(p);
    return smin( d1, d2 );
}


vec2 sdfBox( vec3 currentRayPosition ){
  
  // First we define our box position
  vec3 boxPosition = vec3( -.8 , -.4 , 0.2 );
    
  // than we define our box dimensions using x , y and z
  vec3 boxSize = vec3( .4 , .3 , .2 );
    
  // Here we get the 'adjusted ray position' which is just
  // writing the point of the ray as if the origin of the 
  // space was where the box was positioned, instead of
  // at 0,0,0 . AKA the difference between the vectors in
  // vector format.
  vec3 adjustedRayPosition = currentRayPosition - boxPosition;
    
  // finally we get the distance to the box surface.
  // I don't get this part very much, but I bet Inigo does!
  // Thanks for making code for us IQ !
  vec3 distanceVec = abs( adjustedRayPosition ) - boxSize;
  float maxDistance = max( distanceVec.x , max( distanceVec.y , distanceVec.z ) ); 
  float distanceToBoxSurface = min( maxDistance , 0.0 ) + length( max( distanceVec , 0.0 ) );
  
  // Finally we build the full box information, by giving it an ID
  float boxID = 2.;
    	
  // And there we have it! A fully described box!
  vec2 box = vec2( distanceToBoxSurface,  boxID );
    
  return box;
    
}


// 'TAG : WHICH AM I CLOSER TO?'
// This function takes in two things
// and says which is closer by using the 
// distance to each thing, comparing them
// and returning the one that is closer!
vec2 whichThingAmICloserTo( vec2 thing1 , vec2 thing2 ){
 
   vec2 closestThing;
    
   // Check out the balloon function
   // and remember how the x of the returned
   // information is the distance, and the y 
   // is the id of the thing!
   if( thing1.x <= thing2.x ){
       
   	   closestThing = thing1;
       
   }else if( thing2.x < thing1.x ){
       
       closestThing = thing2;
       
   }
 
   return closestThing;
    
}

    

// Takes in the position of the ray, and feeds back
// 2 values of how close it is to things in the world
// what thing it is closest two in the world.
vec2 mapTheWorld( vec3 currentRayPosition ){


  vec2 result;
    
  vec2 balloon = sdfBalloon( currentRayPosition );
  //vec2 box     = sdfBox( currentRayPosition );
  vec2 torus = sdfTorus( currentRayPosition );
    
  result = whichThingAmICloserTo( balloon , torus); //box );
  result.x = opBlend( balloon.x, torus.x);
    
    
  return result;


}



//---------------------------------------------------
// SECTION 'C' : NAVIGATING THE WORLD
//---------------------------------------------------

// We want to know when the closeness to things in the world is
// 0.0 , but if we wanted to get exactly to 0 it would take us
// alot of time to be that precise. Here we define the laziness
// our navigation function. try chaning the value to see what it does!
// if you are getting too low of framerates, this value will help alot,
// but can also make your scene look very different
// from how it should
const float HOW_CLOSE_IS_CLOSE_ENOUGH = 0.0001;

// This is basically how big our scene is. each ray will be shot forward
// until it reaches this distance. the smaller it is, the quicker the 
// ray will reach the edge, which should help speed up this function
const float FURTHEST_OUR_RAY_CAN_REACH = 10.75;

// This is how may steps our ray can take. Hopefully for this
// simple of a world, it will very quickly get to the 'close enough' value
// and stop the iteration, but for more complex scenes, this value
// will dramatically change not only how good the scene looks
// but how fast teh scene can render. 

// remember that for each pixel we are displaying, the 'mapTheWorld' function
// could be called this many times! Thats ALOT of calculations!!!
const int HOW_MANY_STEPS_CAN_OUR_RAY_TAKE = 2000;


vec2 checkRayHit( in vec3 eyePosition , in vec3 rayDirection ){

  //First we set some default values
 
  
  // our distance to surface will get overwritten every step,
  // so all that is important is that it is greater than our
  // 'how close is close enough' value
  float distanceToSurface 			= HOW_CLOSE_IS_CLOSE_ENOUGH * 2.;
    
  // The total distance traveled by the ray obviously should start at 0
  float totalDistanceTraveledByRay 	= 0.;
    
  // if we hit something, this value will be overwritten by the
  // totalDistance traveled, and if we don't hit something it will
  // be overwritten by the furthest our ray can reach,
  // so it can be whatever!
  float finalDistanceTraveledByRay 	= -1.;
    
  // if our id is less that 0. , it means we haven't hit anything
  // so lets start by saying we haven't hit anything!
  float finalID = -1.;

    
    
  //here is the loop where the magic happens
  for( int i = 0; i < HOW_MANY_STEPS_CAN_OUR_RAY_TAKE; i++ ){
      
    // First off, stop the iteration, if we are close enough to the surface!
    if( distanceToSurface < HOW_CLOSE_IS_CLOSE_ENOUGH ) break;
      
    // Second off, stop the iteration, if we have reached the end of our scene! 
    if( totalDistanceTraveledByRay > FURTHEST_OUR_RAY_CAN_REACH ) break;
    
    // To check how close we are to things in the world,
    // we need to get a position in the scene. to do this, 
    // we start at the rays origin, AKA the eye
    // and move along the ray direction, the amount we have already traveled.
    vec3 currentPositionOfRay = eyePosition + rayDirection * totalDistanceTraveledByRay;
    
    // Distance to and ID of things in the world
    //--------------------------------------------------------------
	// SECTION 'D' : MAPPING THE WORLD , AKA 'SDFS ARE AWESOME!!!!'
	//--------------------------------------------------------------
    vec2 distanceAndIDOfThingsInTheWorld = mapTheWorld( currentPositionOfRay );
      
      
 	// we get out the results from our mapping of the world
    // I am reassigning them for clarity
    float distanceToThingsInTheWorld = distanceAndIDOfThingsInTheWorld.x;
    float idOfClosestThingInTheWorld = distanceAndIDOfThingsInTheWorld.y;
     
    // We save out the distance to the surface, so that
    // next iteration we can check to see if we are close enough 
    // to stop all this silly iteration
    distanceToSurface           = distanceToThingsInTheWorld;
      
    // We are also finalID to the current closest id,
    // because if we hit something, we will have the proper
    // id, and we can skip reassigning it later!
    finalID = idOfClosestThingInTheWorld;  
     
    // ATTENTION: THIS THING IS AWESOME!
   	// This last little calculation is probably the coolest hack
    // of this entire tutorial. If we wanted too, we could basically 
    // step through the field at a constant amount, and at every step
    // say 'am i there yet', than move forward a little bit, and
    // say 'am i there yet', than move forward a little bit, and
    // say 'am i there yet', than move forward a little bit, and
    // say 'am i there yet', than move forward a little bit, and
    // say 'am i there yet', than move forward a little bit, and
    // that would take FOREVER, and get really annoying.
      
    // Instead what we say is 'How far until we are there?'
    // and move forward by that amount. This means that if
    // we are really far away from everything, we can make large
    // movements towards the surface, and if we are closer
    // we can make more precise movements. making our marching functino
    // faster, and ideally more precise!!
      
    // WOW!
      
    totalDistanceTraveledByRay += 0.05 * distanceToThingsInTheWorld; //0.001 + distanceToThingsInTheWorld * abs(sin(iGlobalTime)); //distanceToThingsInTheWorld;
      

  }

  // if we hit something set the finalDirastnce traveled by
  // ray to that distance!
  if( totalDistanceTraveledByRay < FURTHEST_OUR_RAY_CAN_REACH ){
  	finalDistanceTraveledByRay = totalDistanceTraveledByRay;
  }
    
    
  // If the total distance traveled by the ray is further than
  // the ray can reach, that means that we've hit the edge of the scene
  // Set the final distance to be the edge of the scene
  // and the id to -1 to make sure we know we haven't hit anything
  if( totalDistanceTraveledByRay > FURTHEST_OUR_RAY_CAN_REACH ){ 
  	finalDistanceTraveledByRay = FURTHEST_OUR_RAY_CAN_REACH;
    finalID = -1.;
  }

  return vec2( finalDistanceTraveledByRay , finalID ); 

}







//--------------------------------------------------------------
// SECTION 'E' : COLORING THE WORLD
//--------------------------------------------------------------



// Here we are calcuting the normal of the surface
// Although it looks like alot of code, it actually
// is just trying to do something very simple, which
// is to figure out in what direction the SDF is increasing.
// What is amazing, is that this value is the same thing 
// as telling you what direction the surface faces, AKA the
// normal of the surface. 
vec3 getNormalOfSurface( in vec3 positionOfHit ){
    
	vec3 tinyChangeX = vec3( 0.001, 0.0, 0.0 );
    vec3 tinyChangeY = vec3( 0.0 , 0.001 , 0.0 );
    vec3 tinyChangeZ = vec3( 0.0 , 0.0 , 0.001 );
    
   	float upTinyChangeInX   = mapTheWorld( positionOfHit + tinyChangeX ).x; 
    float downTinyChangeInX = mapTheWorld( positionOfHit - tinyChangeX ).x; 
    
    float tinyChangeInX = upTinyChangeInX - downTinyChangeInX;
    
    
    float upTinyChangeInY   = mapTheWorld( positionOfHit + tinyChangeY ).x; 
    float downTinyChangeInY = mapTheWorld( positionOfHit - tinyChangeY ).x; 
    
    float tinyChangeInY = upTinyChangeInY - downTinyChangeInY;
    
    
    float upTinyChangeInZ   = mapTheWorld( positionOfHit + tinyChangeZ ).x; 
    float downTinyChangeInZ = mapTheWorld( positionOfHit - tinyChangeZ ).x; 
    
    float tinyChangeInZ = upTinyChangeInZ - downTinyChangeInZ;
    
    
	vec3 normal = vec3(
         			tinyChangeInX,
        			tinyChangeInY,
        			tinyChangeInZ
    	 		  );
    
	return normalize(normal);
}





// doing our background color is easy enough,
// just make it pure black. like my soul.
vec3 doBackgroundColor(){
	return vec3( 0.75 );
}




vec3 doBalloonColor(vec3 positionOfHit , vec3 normalOfSurface ){
    
    vec3 sunPosition = vec3( 1. , 4. , 3. );
    
    // the direction of the light goes from the sun
    // to the position of the hit
    vec3 lightDirection = sunPosition - positionOfHit;
   	
    
    // Here we are 'normalizing' the light direction
   	// because we don't care how long it is, we
    // only care what direction it is!
    lightDirection = normalize( lightDirection );
    
    
    // getting the value of how much the surface
    // faces the light direction
    float faceValue = dot( lightDirection , normalOfSurface );
	
    // if the face value is negative, just make it 0.
    // so it doesn't give back negative light values
    // cuz that doesn't really make sense...
    faceValue = max( 0. , faceValue );
    
    vec3 balloonColor = vec3( 1. , 0. , 0. );
    
   	// our final color is the balloon color multiplied
    // by how much the surface faces the light
    vec3 color = balloonColor * faceValue;
    
    // add in a bit of ambient color
    // just so we don't get any pure black
    color += vec3( .3 , .1, .2 );
    
    
	return color;
}



vec3 doTorusColor(vec3 positionOfHit , vec3 normalOfSurface ){
    
    vec3 sunPosition = vec3( 1. , 4. , 3. );
    
    // the direction of the light goes from the sun
    // to the position of the hit
    vec3 lightDirection = sunPosition - positionOfHit;
   	
    
    // Here we are 'normalizing' the light direction
   	// because we don't care how long it is, we
    // only care what direction it is!
    lightDirection = normalize( lightDirection );
    
    
    // getting the value of how much the surface
    // faces the light direction
    float faceValue = dot( lightDirection , normalOfSurface );
	
    // if the face value is negative, just make it 0.
    // so it doesn't give back negative light values
    // cuz that doesn't really make sense...
    faceValue = max( 0. , faceValue );
    
    vec3 torusColor = vec3( 0.25 , 0.95 , 0.25 );
    
   	// our final color is the balloon color multiplied
    // by how much the surface faces the light
    vec3 color = torusColor * faceValue;
    
    // add in a bit of ambient color
    // just so we don't get any pure black
    color += vec3( .3 , .1, .2 );
    
    
	return color;
}


// Here we are using the normal of the surface,
// and mapping it to color, to show you just how cool
// normals can be!
vec3 doBoxColor(vec3 positionOfHit , vec3 normalOfSurface ){
    
    vec3 color = vec3( normalOfSurface.x , normalOfSurface.y , normalOfSurface.z );
    
    //could also just write color = normalOfSurce
    //but trying to be explicit.
    
	return color;
}




// This is where we decide
// what color the world will be!
// and what marvelous colors it will be!
vec3 colorTheWorld( vec2 rayHitInfo , vec3 eyePosition , vec3 rayDirection ){
   
  // remember for color
  // x = red , y = green , z = blue
  vec3 color;
    
  // THE LIL RAY WENT ALL THE WAY
  // TO THE EDGE OF THE WORLD, 
  // AND DIDN'T HIT ANYTHING
  if( rayHitInfo.y < 0.0 ){
      
  	color = doBackgroundColor();  
     
      
  // THE LIL RAY HIT SOMETHING!!!!
  }else{
      
      // If we hit something, 
      // we also know how far the ray has to travel to hit it
      // and because we know the direction of the ray, we can
      // get the exact position of where we hit the surface
      // by following the ray from the eye, along its direction
      // for the however far it had to travel to hit something
      vec3 positionOfHit = eyePosition + rayHitInfo.x * rayDirection;
      
      // We can then use this information to tell what direction
      // the surface faces in
      vec3 normalOfSurface = getNormalOfSurface( positionOfHit );
      
      
      // 1.0 is the Balloon ID
      if( rayHitInfo.y == 1.0 ){
          
  		color = doBalloonColor( positionOfHit , normalOfSurface ); 
       
          
      // 2.0 is the Box ID
      }else if( rayHitInfo.y == 2.0 ){
          
      	color = doBoxColor( positionOfHit , normalOfSurface );   
          
      }
      else if( rayHitInfo.y == 3.0)
      {
          color = doTorusColor( positionOfHit , normalOfSurface );
      }
 
  
  }
    
    
    return color;
    
    
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    //---------------------------------------------------
    // SECTION 'A' : ONE PROGRAM FOR EVERY PIXEL!
    //---------------------------------------------------
    
    // Here we are getting our 'Position' of each pixel
    // This section is important, because if we didn't
    // divied by the resolution, our values would be masssive
    // as fragCoord returns the value of how many pixels over we 
    // are. which is alot :)
	vec2 p = ( -iResolution.xy + 2.0 * fragCoord.xy ) / iResolution.y;
     
    // thats a super long name, so maybe we will 
    // keep on using uv, but im explicitly defining it
    // so you can see exactly what those two letters mean
    vec2 xyPositionOfPixelInWindow = p;
    
    
    
    //---------------------------------------------------
    // SECTION 'B' : BUILDING THE WINDOW
    //---------------------------------------------------
    
    // We use the eye position to tell use where the viewer is
    float camRotSpeed = 0.5;
    float rotRadius = 2.75;
    float eyePosX = rotRadius * cos( camRotSpeed * iGlobalTime);
    float eyePosZ = rotRadius * sin( camRotSpeed * iGlobalTime);
    vec3 eyePosition = vec3( eyePosX, 0.5, eyePosZ); //vec3( 0., 0.5, 2.);
    
    // This is the point the view is looking at. 
    // The window will be placed between the eye, and the 
    // position the eye is looking at!
    vec3 pointWeAreLookingAt = vec3( 0. , 0. , 0. );
  
	// This is where the magic of actual mathematics
    // gives a way to actually place the window.
    // the 0. at the end there gives the 'roll' of the transformation
    // AKA we would be standing so up is up, but up could be changing 
    // like if we were one of those creepy dolls whos rotate their head
    // all the way around along the z axis
    mat3 eyeTransformationMatrix = calculateEyeRayTransformationMatrix( eyePosition , pointWeAreLookingAt , 0. ); 
   
    
    // Here we get the actual ray that goes out of the eye
    // and through the individual pixel! This basically the only thing
    // that is different between the pixels, but is also the bread and butter
    // of ray tracing. It should be since it has the word 'ray' in its variable name...
    // the 2. at the end is the 'lens length' . I don't know how to best
    // describe this, but once the full scene is built, tryin playing with it
    // to understand inherently how it works
    vec3 rayComingOutOfEyeDirection = normalize( eyeTransformationMatrix * vec3( p.xy , 2. ) ); 

    
    
    //---------------------------------------------------
	// SECTION 'C' : NAVIGATING THE WORLD
	//---------------------------------------------------
    vec2 rayHitInfo = checkRayHit( eyePosition , rayComingOutOfEyeDirection );
    
    
    //--------------------------------------------------------------
	// SECTION 'E' : COLORING THE WORLD
	//--------------------------------------------------------------
	vec3 color = colorTheWorld( rayHitInfo , eyePosition , rayComingOutOfEyeDirection );
    
   
   	//--------------------------------------------------------------
    // SECTION 'F' : Wrapping up
    //--------------------------------------------------------------
	fragColor = vec4(color,1.0);
    
    
    // WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW!
    // WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! 
    // WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! 
    // WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! 
    // WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! WOW! 
    
    
}

