// Shader downloaded from https://www.shadertoy.com/view/ld3GWr
// written by shadertoy user tsone
//
// Name: Chocobo Music
// Description: Chocobo music from Final Fantasy III (NES). Used FamiTracker module tracked by InstantTrain: https://www.youtube.com/watch?v=GWFojEru0C8
/*

Copyright 2016 Valtteri "tsone" Heikkilä

This work is licensed under the Creative Commons Attribution 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

*/

/*
Animation frames (16x16) were converted with following Python script:

# Input must be 4-color paletted image (ex. PNG)
import sys
from PIL import Image
im = Image.open(sys.argv[1])
j = 0
for iy in range(0, im.size[1], 2):
  for ix in range(0, im.size[0], 4):
    k = 0
    for y in range(iy, iy+2):
      for x in range(ix, ix+4):
        k = (k << 2) + im.getpixel( (x,y) )
    print "    if (i==%d.) b=%.32g;" % (j, k / 2.**14)
    j = j + 1

*/

float Frame1(float i)
{
    float b=1.3330078125;
    if (i==1.) b=0.0103759765625;
    if (i==2.) b=0.01165771484375;
    if (i==3.) b=1.32940673828125;
    if (i==4.) b=1.15869140625;
    if (i==5.) b=3.9097900390625;
    if (i==6.) b=3.00299072265625;
    if (i==7.) b=1.33331298828125;
    if (i==8.) b=0.6275634765625;
    if (i==9.) b=0.91668701171875;
    if (i==10.) b=3.09014892578125;
    if (i==11.) b=1.333251953125;
    if (i==12.) b=0.50421142578125;
    if (i==13.) b=0.05169677734375;
    if (i==14.) b=0.32940673828125;
    if (i==15.) b=1.301513671875;
    if (i==16.) b=1.333251953125;
    if (i==17.) b=0.99993896484375;
    if (i==18.) b=3.07733154296875;
    if (i==19.) b=0.812255859375;
    if (i==20.) b=1.31768798828125;
    if (i==21.) b=3.9881591796875;
    if (i==22.) b=2.74481201171875;
    if (i==23.) b=3.77764892578125;
    if (i==24.) b=0.080078125;
    if (i==25.) b=0.7265625;
    if (i==26.) b=2.6251220703125;
    if (i==27.) b=0.26611328125;
    if (i==28.) b=1.1612548828125;
    if (i==29.) b=0.3359375;
    if (i==30.) b=1.2506103515625;
    if (i==31.) b=2.5234375;
    return b;
}

float Frame2(float i)
{
    float  b=1.3330078125;
    if (i==1.) b=0.0103759765625;
    if (i==2.) b=0.01165771484375;
    if (i==3.) b=1.32940673828125;
    if (i==4.) b=1.15869140625;
    if (i==5.) b=3.9097900390625;
    if (i==6.) b=3.00299072265625;
    if (i==7.) b=1.33331298828125;
    if (i==8.) b=0.6275634765625;
    if (i==9.) b=0.91668701171875;
    if (i==10.) b=3.09014892578125;
    if (i==11.) b=1.33306884765625;
    if (i==12.) b=0.50421142578125;
    if (i==13.) b=0.04779052734375;
    if (i==14.) b=0.32940673828125;
    if (i==15.) b=1.20611572265625;
    if (i==16.) b=1.31756591796875;
    if (i==17.) b=3.99993896484375;
    if (i==18.) b=0.26263427734375;
    if (i==19.) b=3.21783447265625;
    if (i==20.) b=1.302001953125;
    if (i==21.) b=3.9205322265625;
    if (i==22.) b=0.99603271484375;
    if (i==23.) b=3.07940673828125;
    if (i==24.) b=1.33331298828125;
    if (i==25.) b=0.9102783203125;
    if (i==26.) b=2.75030517578125;
    if (i==27.) b=1.33331298828125;
    if (i==28.) b=1.333251953125;
    if (i==29.) b=1.2506103515625;
    if (i==30.) b=2.02587890625;
    if (i==31.) b=1.32818603515625;
    return b;
}

vec3 Pal(float j)
{
    if (j < 1.) return vec3(.023);
    if (j >= 3.) return vec3(1.,1.,.992);
    if (j >= 2.) return vec3(.867,.549,.192);
    return vec3(.82);
}

float Decode4x2Block(float i, float v)
{
    return mod(v * pow(4.,i), 4.);
}

vec3 Eval(in vec2 p, bool frame)
{
    vec2 q = floor(p / vec2(4.,2.));
    vec2 f = p - q*vec2(4.,2.);
    float i = 4.*q.y + q.x;
    float fi = 4.*f.y + f.x;
    float b = frame ? Frame1(i) : Frame2(i);
    return Pal(Decode4x2Block(fi, b));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 p = (2.*fragCoord.xy - iResolution.xy) / iResolution.y;
    bool frame = mod(iGlobalTime, 16./60.) >= 8./60.;
    if (frame) p.x += 1./10.;
    p = floor(10.*p + 8.);
    p.y = 15. - p.y;
    if (p.x < 0. || p.x > 15. || p.y < 0. || p.y > 15.) p = vec2(0.);
    fragColor = vec4(Eval(p, frame), 1.);
}
