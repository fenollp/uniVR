// Shader downloaded from https://www.shadertoy.com/view/Mlj3zR
// written by shadertoy user NBickford
//
// Name: [NV15] blankspace
// Description: This shader prints its own code, including the code for printing its own code.
mat4 a000=mat4( 9,14,20, 0, 7, 3,44, 9,14,20, 0, 9,45,48, 9,14);
mat4 a001=mat4(20, 0,17,43, 9,40,31,41,44, 9,42,31,45,52, 9,14);
mat4 a002=mat4(20, 0,18,43, 9,42,31,40,31,41,44, 9,42,28,33,45);
mat4 a003=mat4(52, 9,14,20, 0,22,43, 9,42,28,33,52,13, 1,20,31);
mat4 a004=mat4( 0, 2,43,13, 1,20,31,44,27,45,52,22, 5, 3,31, 0);
mat4 a005=mat4(23,43,22, 5, 3,31,44,27,45,52, 9, 6,44,18,43,43);
mat4 a006=mat4(27,45,23,43, 2,46,27,47,52, 9, 6,44,18,43,43,28);
mat4 a007=mat4(45,23,43, 2,46,28,47,52, 9, 6,44,18,43,43,29,45);
mat4 a008=mat4(23,43, 2,46,29,47,52, 9, 6,44,18,43,43,30,45,23);
mat4 a009=mat4(43, 2,46,30,47,52, 6,12,15, 1,20, 0, 5,43,27,37);
mat4 a010=mat4(27,52, 9, 6,44,17,43,43,27,45, 5,43,23,37,18,52);
mat4 a011=mat4( 9, 6,44,17,43,43,28,45, 5,43,23,37, 7,52, 9, 6);
mat4 a012=mat4(44,17,43,43,29,45, 5,43,23,37, 2,52, 9, 6,44,17);
mat4 a013=mat4(43,43,30,45, 5,43,23,37, 1,52,18, 5,20,21,18,14);
mat4 a014=mat4( 0, 9,14,20,44, 5,45,52,49, 9,14,20, 0,16,29,44);
mat4 a015=mat4( 9,14,20, 0, 4,45,48, 9,14,20, 0,13,43,28,52, 9);
mat4 a016=mat4(14,20, 0,12,43,27,52, 6,15,18,44, 9,14,20, 0,12);
mat4 a017=mat4(43,27,52,12,50,28,33,52,12,39,39,45,48, 9, 6,44);
mat4 a018=mat4(12,51,43, 4,45, 2,18, 5, 1,11,52,13,41,43,29,52);
mat4 a019=mat4(49,18, 5,20,21,18,14, 0,13,52,49, 6,12,15, 1,20);
mat4 a020=mat4( 0,12,20,18,44, 9,14,20, 0, 3,38, 9,14,20, 0, 4);
mat4 a021=mat4(45,48, 9,14,20, 0,13,43,16,29,44, 4,45,52, 9,14);
mat4 a022=mat4(20, 0,18,43,27,52, 9, 6,44, 3,43,43,27,45,18,43);
mat4 a023=mat4(30,29,34,33,34,52, 9, 6,44, 3,43,43,28,45,18,43);
mat4 a024=mat4(36,29,30,34,52, 9, 6,44, 3,43,43,29,45,18,43,28);
mat4 a025=mat4(34,33,35,31,52, 9, 6,44, 3,43,43,30,45,18,43,34);
mat4 a026=mat4(33,27,28,52, 9, 6,44, 3,43,43,31,45,18,43,28,34);
mat4 a027=mat4(32,32,33,52, 9, 6,44, 3,43,43,32,45,18,43,30,30);
mat4 a028=mat4(34,33,52, 9, 6,44, 3,43,43,33,45,18,43,29,34,36);
mat4 a029=mat4(32,29,52, 9, 6,44, 3,43,43,34,45,18,43,29,28,33);
mat4 a030=mat4(35,28,52, 9, 6,44, 3,43,43,35,45,18,43,36,29,30);
mat4 a031=mat4(31,52, 9, 6,44, 3,43,43,36,45,18,43,29,36,29,27);
mat4 a032=mat4(52, 9, 6,44, 3,43,43,28,27,45,18,43,29,34,31,36);
mat4 a033=mat4(33,52, 9, 6,44, 3,43,43,28,28,45,18,43,36,31,36);
mat4 a034=mat4(27,52, 9, 6,44, 3,43,43,28,29,45,18,43,30,32,28);
mat4 a035=mat4(27,52, 9, 6,44, 3,43,43,28,30,45,18,43,36,29,28);
mat4 a036=mat4(33,52, 9, 6,44, 3,43,43,28,31,45,18,43,35,28,36);
mat4 a037=mat4(31,52, 9, 6,44, 3,43,43,28,32,45,18,43,29,28,33);
mat4 a038=mat4(32,30,52, 9, 6,44, 3,43,43,28,33,45,18,43,29,34);
mat4 a039=mat4(36,29,31,52, 9, 6,44, 3,43,43,28,34,45,18,43,31);
mat4 a040=mat4(29,31,32,52, 9, 6,44, 3,43,43,28,35,45,18,43,36);
mat4 a041=mat4(31,36,29,52, 9, 6,44, 3,43,43,28,36,45,18,43,28);
mat4 a042=mat4(35,29,35,36,52, 9, 6,44, 3,43,43,29,27,45,18,43);
mat4 a043=mat4(29,30,31,27,27,52, 9, 6,44, 3,43,43,29,28,45,18);
mat4 a044=mat4(43,28,28,34,27,52, 9, 6,44, 3,43,43,29,29,45,18);
mat4 a045=mat4(43,29,28,33,32,27,52, 9, 6,44, 3,43,43,29,30,45);
mat4 a046=mat4(18,43,28,35,52, 9, 6,44, 3,43,43,29,31,45,18,43);
mat4 a047=mat4(36,32,32,31,52, 9, 6,44, 3,43,43,29,32,45,18,43);
mat4 a048=mat4(29,30,30,34,35,52, 9, 6,44, 3,43,43,29,33,45,18);
mat4 a049=mat4(43,30,31,28,33,52, 9, 6,44, 3,43,43,29,34,45,18);
mat4 a050=mat4(43,29,28,32,29,32,52, 9, 6,44, 3,43,43,29,35,45);
mat4 a051=mat4(18,43,29,36,29,31,52, 9, 6,44, 3,43,43,29,36,45);
mat4 a052=mat4(18,43,30,31,29,27,52, 9, 6,44, 3,43,43,30,27,45);
mat4 a053=mat4(18,43,28,35,29,33,35,52, 9, 6,44, 3,43,43,30,28);
mat4 a054=mat4(45,18,43,28,30,36,27,33,52, 9, 6,44, 3,43,43,30);
mat4 a055=mat4(29,45,18,43,28,32,35,31,52, 9, 6,44, 3,43,43,30);
mat4 a056=mat4(30,45,18,43,29,28,35,27,36,52, 9, 6,44, 3,43,43);
mat4 a057=mat4(30,31,45,18,43,29,30,30,35,31,52, 9, 6,44, 3,43);
mat4 a058=mat4(43,30,32,45,18,43,29,28,35,31,32,52, 9, 6,44, 3);
mat4 a059=mat4(43,43,30,33,45,18,43,29,29,28,27,28,52, 9, 6,44);
mat4 a060=mat4( 3,43,43,30,34,45,18,43,29,31,32,34,32,52, 9, 6);
mat4 a061=mat4(44, 3,43,43,30,35,45,18,43,29,30,32,32,28,52, 9);
mat4 a062=mat4( 6,44, 3,43,43,30,36,45,18,43,30,28,29,34,36,52);
mat4 a063=mat4( 9, 6,44, 3,43,43,31,27,45,18,43,30,29,30,28,36);
mat4 a064=mat4(52, 9, 6,44, 3,43,43,31,28,45,18,43,30,29,31,29);
mat4 a065=mat4(33,52, 9, 6,44, 3,43,43,31,29,45,18,43,29,34,36);
mat4 a066=mat4(36,32,52, 9, 6,44, 3,43,43,31,30,45,18,43,29,36);
mat4 a067=mat4(28,29,34,52, 9, 6,44, 3,43,43,31,31,45,18,43,29);
mat4 a068=mat4(30,36,35,36,52, 9, 6,44, 3,43,43,31,32,45,18,43);
mat4 a069=mat4(29,29,29,30,34,52, 9, 6,44, 3,43,43,31,33,45,18);
mat4 a070=mat4(43,28,36,35,36,29,52, 9, 6,44, 3,43,43,31,34,45);
mat4 a071=mat4(18,43,32,35,31,36,52, 9, 6,44, 3,43,43,31,35,45);
mat4 a072=mat4(18,43,34,27,35,28,52, 9, 6,44, 3,43,43,31,36,45);
mat4 a073=mat4(18,43,28,36,28,35,27,52, 9, 6,44, 3,43,43,32,27);
mat4 a074=mat4(45,18,43,28,32,29,34,32,52, 9, 6,44, 3,43,43,32);
mat4 a075=mat4(28,45,18,43,29,34,30,34,31,52, 9, 6,44, 3,43,43);
mat4 a076=mat4(32,29,45,18,43,29,29,31,36,32,52, 9, 6,44, 3,43);
mat4 a077=mat4(43,32,30,45,18,43,28,28,33,28,27,52, 9, 6,44, 3);
mat4 a078=mat4(43,43,32,31,45,18,43,29,30,31,27,32,52, 9,14,20);
mat4 a079=mat4( 0, 4,13,43,18,42,13,52,18,43,18,40,29,41,13,41);
mat4 a080=mat4(44,18,42,44,29,41,13,45,45,40,44,18,40,13,41,44);
mat4 a081=mat4(18,42,13,45,45,52, 9, 6,44,18,51,27,45,18, 5,20);
mat4 a082=mat4(21,18,14, 0,28,37,27,52,18, 5,20,21,18,14, 0,27);
mat4 a083=mat4(37,27,52,49, 9,14,20, 0,13, 9,44,13, 1,20,31, 0);
mat4 a084=mat4( 2,38, 9,14,20, 0, 9,45,48, 9, 6,44, 9,51,43,28);
mat4 a085=mat4(33,45,18, 5,20,21,18,14, 0,27,52, 9,14,20, 0,18);
mat4 a086=mat4(43, 9,42,31,40,31,41,44, 9,42,28,33,45,52, 9,14);
mat4 a087=mat4(20, 0,17,43, 9,40,31,41,44, 9,42,31,45,52,22, 5);
mat4 a088=mat4( 3,31, 0,23,43,22, 5, 3,31,44,27,45,52, 9, 6,44);
mat4 a089=mat4(18,43,43,27,45,23,43, 2,46,27,47,52, 9, 6,44,18);
mat4 a090=mat4(43,43,28,45,23,43, 2,46,28,47,52, 9, 6,44,18,43);
mat4 a091=mat4(43,29,45,23,43, 2,46,29,47,52, 9, 6,44,18,43,43);
mat4 a092=mat4(30,45,23,43, 2,46,30,47,52, 6,12,15, 1,20, 0, 5);
mat4 a093=mat4(43,27,37,27,52, 9, 6,44,17,43,43,27,45, 5,43,23);
mat4 a094=mat4(37,18,52, 9, 6,44,17,43,43,28,45, 5,43,23,37, 7);
mat4 a095=mat4(52, 9, 6,44,17,43,43,29,45, 5,43,23,37, 2,52, 9);
mat4 a096=mat4( 6,44,17,43,43,30,45, 5,43,23,37, 1,52,18, 5,20);
mat4 a097=mat4(21,18,14, 0, 9,14,20,44, 5,45,52,49, 6,12,15, 1);
mat4 a098=mat4(20, 0, 2,12, 1,14,11,19,16, 1, 3, 5,44,22, 5, 3);
mat4 a099=mat4(29, 0,21,22,45,48, 9,14,20, 0,14, 3,23,43,33,31);
mat4 a100=mat4(52, 9,14,20, 0,20,22,43,28,33,33,52, 9,14,20, 0);
mat4 a101=mat4(24,16,43, 9,14,20,44,21,22,37,24,45,52, 9,14,20);
mat4 a102=mat4( 0,25,16,43, 9,14,20,44,21,22,37,25,45,52, 9,14);
mat4 a103=mat4(20, 0,24, 3,43,24,16,42,31,52, 9,14,20, 0,24,13);
mat4 a104=mat4(43,24,16,40,31,41,24, 3,52, 9,14,20, 0,25, 3,43);
mat4 a105=mat4(25,16,42,33,52, 9,14,20, 0,25,13,43,25,16,40,33);
mat4 a106=mat4(41,25, 3,52, 9, 6,44,44,24,13,43,43,30,45,54,54);
mat4 a107=mat4(44,25,13,43,43,32,45,54,54,44,24, 3,51,43,14, 3);
mat4 a108=mat4(23,45,45,48,18, 5,20,21,18,14, 0,28,37,27,52,49);
mat4 a109=mat4( 9,14,20, 0, 4,43,24,13,39,30,41,25,13,52, 9,14);
mat4 a110=mat4(20, 0,20, 3,43,24, 3,39,14, 3,23,41,25, 3,52, 6);
mat4 a111=mat4(12,15, 1,20, 0,22,43,27,37,27,52, 9, 6,44,20, 3);
mat4 a112=mat4(36,36,45,22,43,12,20,18,44,29,34,39,22,14,42,28);
mat4 a113=mat4(27,27,38, 4,45,52, 9, 6,44,19, 3,43,43,34,45, 9);
mat4 a114=mat4( 6,44,22,14,51,36,45,22,43,12,20,18,44,29,34,39);
mat4 a115=mat4( 4,29,38, 4,45,52, 9, 6,44,19, 3,43,43,35,45,22);
mat4 a116=mat4(43,12,20,18,44,29,34,39, 4,30,38, 4,45,52,49, 5);
mat4 a117=mat4(12,19, 5, 0, 9, 6,44,19, 3,50,43,28,29,45,48,22);
mat4 a118=mat4(43,12,20,18,44,13, 9,44,20,24,20,38,19, 3,40,30);
mat4 a119=mat4(45,38, 4,45,52,49, 5,12,19, 5, 0, 9, 6,44,19, 3);
mat4 a120=mat4(50,43,28,32,45,48, 9, 6,44,19, 3,43,43,28,30,45);
mat4 a121=mat4(22,43,12,20,18,44,29,34,39,22,14,42,28,27,27,38);
mat4 a122=mat4( 4,45,52, 9, 6,44,19, 3,43,43,28,31,45,22,43,12);
mat4 a123=mat4(20,18,44,29,34,39, 4,29,38, 4,45,52, 9, 6,44,19);
mat4 a124=mat4( 3,43,43,28,32,45,22,43,12,20,18,44,29,34,39, 4);
mat4 a125=mat4(30,38, 4,45,52,49, 5,12,19, 5,48,22,43,12,20,18);
mat4 a126=mat4(44,13, 9,44,20,24,20,38,19, 3,40,33,45,38, 4,45);
mat4 a127=mat4(52,49,49, 5,12,19, 5,48,22,43,12,20,18,44, 7, 3);
mat4 a128=mat4(44,20, 3,40,14, 3,23,41,44,20,22,45,40,33,31,40);
mat4 a129=mat4(28,34,41,20,22,39,33,31,45,38, 4,45,52,49,18, 5);
mat4 a130=mat4(20,21,18,14, 0,22,52,49,22,15, 9, 4, 0,13, 1, 9);
mat4 a131=mat4(14, 9,13, 1, 7, 5,44,15,21,20, 0,22, 5, 3,31, 0);
mat4 a132=mat4( 6,18, 1, 7, 3,15,12,15,18,38, 9,14, 0,22, 5, 3);
mat4 a133=mat4(29, 0, 6,18, 1, 7, 3,15,15,18, 4,45,48,22, 5, 3);
mat4 a134=mat4(29, 0,21,22,43,29,37,27,41,44, 6,18, 1, 7, 3,15);
mat4 a135=mat4(15,18, 4,40, 9,18, 5,19,15,12,21,20, 9,15,14,37);
mat4 a136=mat4(24,25,41,27,37,32,45,42, 9,18, 5,19,15,12,21,20);
mat4 a137=mat4( 9,15,14,37,24,52, 6,12,15, 1,20, 0, 6,15, 7,43);
mat4 a138=mat4(28,37,27,40, 3,12, 1,13,16,44,16,15,23,44, 4,15);
mat4 a139=mat4(20,44,21,22,38,21,22,45,38,28,37,27,45,41,27,37);
mat4 a140=mat4(28,40,27,37,29,39,27,37,29,41,21,22,37,25,38,27);
mat4 a141=mat4(37,27,38,28,37,27,45,52,22, 5, 3,30, 0, 9,15,43);
mat4 a142=mat4(22, 5, 3,30,44,27,37,27,38,28,37,27,38,27,37,27);
mat4 a143=mat4(45,52, 6,12,15, 1,20, 0, 1,14, 7,12, 5, 5,43, 3);
mat4 a144=mat4(12, 1,13,16,44,28,37,28,40, 9, 7,12,15, 2, 1,12);
mat4 a145=mat4(20, 9,13, 5,41,27,37,27,27,31,38,27,37,27,38,28);
mat4 a146=mat4(37,28,45,52, 6,12,15, 1,20, 0, 3,43, 3,15,19,44);
mat4 a147=mat4( 1,14, 7,12, 5, 5,45,52, 6,12,15, 1,20, 0,19,43);
mat4 a148=mat4(19, 9,14,44, 1,14, 7,12, 5, 5,45,52,22, 5, 3,30);
mat4 a149=mat4( 0, 9,18,43,22, 5, 3,30,44,21,22,37,24,38, 3,41);
mat4 a150=mat4(21,22,37,25,40,19,38,40,19,41,21,22,37,25,40, 3);
mat4 a151=mat4(45,52, 6,12,15, 1,20, 0,20,43,40, 9,15,37,25,42);
mat4 a152=mat4( 9,18,37,25,52,22, 5, 3,30, 0,16,43, 9,15,39,20);
mat4 a153=mat4(41, 9,18,52,21,22,43,27,37,32,41,16,37,24,26,40);
mat4 a154=mat4(22, 5, 3,29,44,40,27,37,32,38,40, 9, 7,12,15, 2);
mat4 a155=mat4( 1,12,20, 9,13, 5,41,27,37,27,34,45,52, 9, 6,44);
mat4 a156=mat4(21,22,37,24,50,27,37,27, 0,54,54, 0,21,22,37,24);
mat4 a157=mat4(51,28,37,27, 0,54,54, 0,21,22,37,25,50,27,37,27);
mat4 a158=mat4(45,48, 6,18, 1, 7, 3,15,12,15,18,43,22, 5, 3,31);
mat4 a159=mat4(44, 6,15, 7,38, 6,15, 7,38, 6,15, 7,38,28,37,27);
mat4 a160=mat4(45,52,18, 5,20,21,18,14,52,49,21,22,41,43,29,32);
mat4 a161=mat4(33,37,27,52,21,22,37,25,43,13,15, 4,44,21,22,37);
mat4 a162=mat4(25,38,28,33,27,27,37,27,45,52, 6,12,15, 1,20, 0);
mat4 a163=mat4(22,43, 2,12, 1,14,11,19,16, 1, 3, 5,44,21,22,45);
mat4 a164=mat4(41, 6,15, 7,52, 6,18, 1, 7, 3,15,12,15,18,43,22);
mat4 a165=mat4( 5, 3,31,44,22,38,22,38,22,38,28,37,27,45,52,49);

int gc(int i){
    int q=i-4*(i/4);
    int r=i/4-4*(i/16);
    int v=i/16;
    mat4 b=mat4(0);
    if(v==  0)b=a000;
    if(v==  1)b=a001;
    if(v==  2)b=a002;
    if(v==  3)b=a003;
    if(v==  4)b=a004;
    if(v==  5)b=a005;
    if(v==  6)b=a006;
    if(v==  7)b=a007;
    if(v==  8)b=a008;
    if(v==  9)b=a009;
    if(v== 10)b=a010;
    if(v== 11)b=a011;
    if(v== 12)b=a012;
    if(v== 13)b=a013;
    if(v== 14)b=a014;
    if(v== 15)b=a015;
    if(v== 16)b=a016;
    if(v== 17)b=a017;
    if(v== 18)b=a018;
    if(v== 19)b=a019;
    if(v== 20)b=a020;
    if(v== 21)b=a021;
    if(v== 22)b=a022;
    if(v== 23)b=a023;
    if(v== 24)b=a024;
    if(v== 25)b=a025;
    if(v== 26)b=a026;
    if(v== 27)b=a027;
    if(v== 28)b=a028;
    if(v== 29)b=a029;
    if(v== 30)b=a030;
    if(v== 31)b=a031;
    if(v== 32)b=a032;
    if(v== 33)b=a033;
    if(v== 34)b=a034;
    if(v== 35)b=a035;
    if(v== 36)b=a036;
    if(v== 37)b=a037;
    if(v== 38)b=a038;
    if(v== 39)b=a039;
    if(v== 40)b=a040;
    if(v== 41)b=a041;
    if(v== 42)b=a042;
    if(v== 43)b=a043;
    if(v== 44)b=a044;
    if(v== 45)b=a045;
    if(v== 46)b=a046;
    if(v== 47)b=a047;
    if(v== 48)b=a048;
    if(v== 49)b=a049;
    if(v== 50)b=a050;
    if(v== 51)b=a051;
    if(v== 52)b=a052;
    if(v== 53)b=a053;
    if(v== 54)b=a054;
    if(v== 55)b=a055;
    if(v== 56)b=a056;
    if(v== 57)b=a057;
    if(v== 58)b=a058;
    if(v== 59)b=a059;
    if(v== 60)b=a060;
    if(v== 61)b=a061;
    if(v== 62)b=a062;
    if(v== 63)b=a063;
    if(v== 64)b=a064;
    if(v== 65)b=a065;
    if(v== 66)b=a066;
    if(v== 67)b=a067;
    if(v== 68)b=a068;
    if(v== 69)b=a069;
    if(v== 70)b=a070;
    if(v== 71)b=a071;
    if(v== 72)b=a072;
    if(v== 73)b=a073;
    if(v== 74)b=a074;
    if(v== 75)b=a075;
    if(v== 76)b=a076;
    if(v== 77)b=a077;
    if(v== 78)b=a078;
    if(v== 79)b=a079;
    if(v== 80)b=a080;
    if(v== 81)b=a081;
    if(v== 82)b=a082;
    if(v== 83)b=a083;
    if(v== 84)b=a084;
    if(v== 85)b=a085;
    if(v== 86)b=a086;
    if(v== 87)b=a087;
    if(v== 88)b=a088;
    if(v== 89)b=a089;
    if(v== 90)b=a090;
    if(v== 91)b=a091;
    if(v== 92)b=a092;
    if(v== 93)b=a093;
    if(v== 94)b=a094;
    if(v== 95)b=a095;
    if(v== 96)b=a096;
    if(v== 97)b=a097;
    if(v== 98)b=a098;
    if(v== 99)b=a099;
    if(v==100)b=a100;
    if(v==101)b=a101;
    if(v==102)b=a102;
    if(v==103)b=a103;
    if(v==104)b=a104;
    if(v==105)b=a105;
    if(v==106)b=a106;
    if(v==107)b=a107;
    if(v==108)b=a108;
    if(v==109)b=a109;
    if(v==110)b=a110;
    if(v==111)b=a111;
    if(v==112)b=a112;
    if(v==113)b=a113;
    if(v==114)b=a114;
    if(v==115)b=a115;
    if(v==116)b=a116;
    if(v==117)b=a117;
    if(v==118)b=a118;
    if(v==119)b=a119;
    if(v==120)b=a120;
    if(v==121)b=a121;
    if(v==122)b=a122;
    if(v==123)b=a123;
    if(v==124)b=a124;
    if(v==125)b=a125;
    if(v==126)b=a126;
    if(v==127)b=a127;
    if(v==128)b=a128;
    if(v==129)b=a129;
    if(v==130)b=a130;
    if(v==131)b=a131;
    if(v==132)b=a132;
    if(v==133)b=a133;
    if(v==134)b=a134;
    if(v==135)b=a135;
    if(v==136)b=a136;
    if(v==137)b=a137;
    if(v==138)b=a138;
    if(v==139)b=a139;
    if(v==140)b=a140;
    if(v==141)b=a141;
    if(v==142)b=a142;
    if(v==143)b=a143;
    if(v==144)b=a144;
    if(v==145)b=a145;
    if(v==146)b=a146;
    if(v==147)b=a147;
    if(v==148)b=a148;
    if(v==149)b=a149;
    if(v==150)b=a150;
    if(v==151)b=a151;
    if(v==152)b=a152;
    if(v==153)b=a153;
    if(v==154)b=a154;
    if(v==155)b=a155;
    if(v==156)b=a156;
    if(v==157)b=a157;
    if(v==158)b=a158;
    if(v==159)b=a159;
    if(v==160)b=a160;
    if(v==161)b=a161;
    if(v==162)b=a162;
    if(v==163)b=a163;
    if(v==164)b=a164;
    if(v==165)b=a165;
    
    vec4 w=vec4(0);
    if(r==0) w=b[0];
    if(r==1) w=b[1];
    if(r==2) w=b[2];
    if(r==3) w=b[3];
    
    float e=0.0;
    if(q==0) e=w.r;
    if(q==1) e=w.g;
    if(q==2) e=w.b;
    if(q==3) e=w.a;
    return int(e);
}

int p2(int d){
    int m=1;
    int l=0;
    for(int l=0;l<16;l++){
        if(l>=d) break;
        m*=2;
    }
    return m;
}

float ltr(int c, int d){
    int m=p2(d);
    int r=0;
    if(c==0)r=32767; //space
	if(c==1)r=9237; //a through...
	if(c==2)r=17684;
	if(c==3)r=7601;
	if(c==4)r=17556;
	if(c==5)r=3376;
	if(c==6)r=27952;
	if(c==7)r=21681;
	if(c==8)r=9234;
	if(c==9)r=2920;
	if(c==10)r=27496;
	if(c==11)r=9490;
	if(c==12)r=3510;
	if(c==13)r=9216;
	if(c==14)r=8194;
	if(c==15)r=21653;
	if(c==16)r=27924;
	if(c==17)r=4245;
	if(c==18)r=9492;
	if(c==19)r=18289;
	if(c==20)r=23400;
	if(c==21)r=1170;
	if(c==22)r=21650;
	if(c==23)r=18;
	if(c==24)r=9554;
	if(c==25)r=23378;
	if(c==26)r=3416; //z
	if(c==27)r=21525; //0 through...
	if(c==28)r=2924;
	if(c==29)r=3420;
	if(c==30)r=18268;
	if(c==31)r=13906;
	if(c==32)r=1584;
	if(c==33)r=21809;
	if(c==34)r=23384;
	if(c==35)r=21845;
	if(c==36)r=22101;
	if(c==37)r=24575; //9
	if(c==38)r=23551;
	if(c==39)r=31279;
	if(c==40)r=32319;
	if(c==41)r=32426;
	if(c==42)r=27995;
	if(c==43)r=29127;
	if(c==44)r=23989;
	if(c==45)r=22237;
	if(c==46)r=19892;
	if(c==47)r=5849;
	if(c==48)r=7081;
	if(c==49)r=19180;
	if(c==50)r=15275;
	if(c==51)r=27374;
	if(c==52)r=22495;
	if(c==53)r=11610;
	if(c==54)r=23405;
    
    int dm=r/m;
    r=r-2*m*(r/(2*m))-(r-m*(r/m));
    if(r>0)return 1.0;
    return 0.0;
}

int mi(mat4 b, int i){
    if(i>=16) return 0;
    
    int r=i/4-4*(i/16);
    int q=i-4*(i/4);
    vec4 w=vec4(0);
    if(r==0) w=b[0];
    if(r==1) w=b[1];
    if(r==2) w=b[2];
    if(r==3) w=b[3];
    
    float e=0.0;
    if(q==0) e=w.r;
    if(q==1) e=w.g;
    if(q==2) e=w.b;
    if(q==3) e=w.a;
    return int(e);
}

float blankspace(vec2 uv){
    int ncw=64;
    int tv=166;//164 constants!
    int xp=int(uv.x);
    int yp=int(uv.y);
    int xc=xp/4; int xm=xp-4*xc;
    int yc=yp/6; int ym=yp-6*yc;
    if((xm==3)||
       (ym==5)||
       (xc>=ncw)){
        return 1.0;
    }
    int d=xm+3*ym;
    
    int tc=xc+ncw*yc;
    float v=0.0;
    if(tc<ncw*tv){
        int sc=xc; //variable string index
        int vn=tc/64; //variable num
        mat4 txt=mat4(13,1,20,31,0,1,43,13,1,20,31,44,45,52,0,0); 
        int d2=vn/10-10*(vn/100);
        int d3=vn-10*(vn/10);
        if(sc<=5){
            v=ltr(mi(txt,sc),d);
        }else if(sc<=8){ //three-character digitcode 
            if(sc==6) v=ltr(27+vn/100,d);
            if(sc==7) v=ltr(27+d2,d);
            if(sc==8) v=ltr(27+d3,d);
        }else if(sc<=14){
            v=ltr(mi(txt,sc-3),d);
        }else if(sc<=61){
            int m3=sc-3*(sc/3);
            int midx=(sc-14)/3;
            int num=gc(midx+16*vn);
            if(m3==0){
                if(num<10){
                    v=ltr(0,d);
                }else{
                	v=ltr(27+num/10,d);
                }
            }
            if(m3==1) v=ltr(27+(num-10*(num/10)),d);
            if(m3==2) v=ltr(38,d);
        }else{
            v=ltr(mi(txt,sc-50),d);
        }
    }else if(tc<ncw*(tv)+75){
		v=ltr(gc(tc-ncw*tv),d);
    }else if(tc<ncw*(tv)+75+17*tv){
        //01234567890123456 - 17 chars!!!
        //if(v==149)b=a149;
        int rp=(tc-ncw*(tv)-75);//rel-pos
        int vn=rp/17;
        int sc=rp-17*vn; //within-var index
        //            i f  (  v  =  =  ) b  = a  ;
        mat4 txt=mat4(9,6,44,22,43,43,45,2,43,1,52,0,0,0,0,0);
        v=1.0;
        int d2=vn/10-10*(vn/100);
        int d3=vn-10*(vn/10);
        if(sc<=5){
            v=ltr(mi(txt,sc),d);
        }else if(sc<=8){
            if(sc==6) if(vn>99) v=ltr(27+vn/100,d);
            if(sc==7) if(vn>9) v=ltr(27+d2,d);
            if(sc==8) v=ltr(27+d3,d);
        }else if(sc<=12){
            v=ltr(mi(txt,sc-3),d);
        }else if(sc<=15){
            if(sc==13) v=ltr(27+vn/100,d);
            if(sc==14) v=ltr(27+d2,d);
            if(sc==15) v=ltr(27+d3,d);
        }else{
            v=ltr(mi(txt,sc-6),d);
        }
    }else{
    	v=ltr(gc(tc-ncw*(tv)-64-17*tv+64),d);
    }
    return v;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //perspective lines converge at (iResolution.x/2,h)
    //
    vec2 uv=2.0*(fragCoord-iResolution.xy*0.5)/iResolution.x;
    //float fog=exp(0.45*0.2*p.z);
    float fog=1.0-clamp(pow(dot(uv,uv),1.0)*0.1-0.2+0.2*uv.y,0.0,1.0);
    //camera: io,vec3(uv.x,uv.y,-1) rotatied around x
    //(io+ir*t).y=0->t=-io.y/it.y
    vec3 io=vec3(0.0,1.0,0.0);
    float anglee=clamp(1.1-iGlobalTime*0.004,0.0,1.1);
    float c=cos(anglee); float s=sin(anglee);
    vec3 ir=vec3(uv.x,c*uv.y-s,-s*uv.y-c);
    float t=-io.y/ir.y;
    vec3 p=io+t*ir;
    
    //fog*=exp(p.z*0.03*0.45);
    
    uv=0.5*p.xz-vec2(-0.5,-iGlobalTime*0.07);
    
    if(uv.x<0.0 || uv.x>1.0 || uv.y<0.0){
        fragColor=vec4(fog,fog,fog,1.0);
        return;
    }
    uv*=256.0;
    
    //uv*=0.5; //easy reader
    //uv*=2.0; //hard reader
    uv.y=mod(uv.y,1600.0);
    
    float v=blankspace(uv)*fog;
    fragColor=vec4(v,v,v,1.0);
}

/*Okay, you've made it to the end! You probably would like an explanation
of what the heck's going on here.
If you try to code a program like this the normal way, you might store
the code in a string, then print back the string.
But that doesn't work, because the string has to include both the string
and the code for printing the string, which leads to horrible recursion.

The way you get around this is to have the string store the printing code,
and have the printing code print the programmer version of the string, then
some stuff in between, then the string itself (which is actually the code).
In other words, the string knows how to print the code, and the code knows 
how to print the string.
Easy, except...

Shadertoy doesn't have strings.
Shadertoy doesn't have arrays. (well, not iterable arrays)
Shadertoy doesn't have fonts.
Shadertoy doesn't even have switch statements.

So we're using a whole bunch of neat tricks.
First, I made a pixel font based off of one I did a few years ago
which only supports symbols found in the code - all 54 or so of them.
Since each letter is 5x3, we can encode on/off values into a 15-bit integer.
Then, we do lookups, not using bit operations (since Shadertoy doesn't
have those) but instead using modular arithmetic and a custom pow function.

Since Shadertoy doesn't have switch statements, we have to use 54 IF
statements, lovingly handcoded using copy+paste.

So now we can print an arbitrary character.

Instead of arrays, we use lots and lots of constant vectors (164 of them).
Each number cooresponds to a two-digit character in the font's custom encoding.
iVec4s don't require float->integer conversions, but are so small that this
program would need about 655 of them, which is just too much.
Instead, we use 4x4 matrices, which require slightly more difficult lookup
methods, but allow us to use 1/4th the number of constant vectors.
(We could compress things EVEN FURTHER and use only half of that, but 
we're good for the moment.)

The only problem? WebGL won't let us index into vectors, so we do a two-level
heirarchical lookup instead: we find the row of the index, then do another
pseudo-switch statement to find the value itself.

So, we pack the 'string' (the code for printing) into 164 mat4s, then
use 166 statements of the form
...
if(i=113)b=a113;
...
to simulate a larger array.

Since each mat4 is miraculously 64 characters long, it's really easy
to write code which will print out the values of each mat4 in sequence,
in the same way you might concatenate Console.Write() calls, except
we need to do binary->decimal conversion manually (since WebGL doesn't
have .ToString, of course)

By this point I had quickly realized manually typing about three thousand
character codes was out of the question, so I wrote a quick C# program to
generate code for a Shadertoy program that would eventually generate itself.
By this point I had also realized that this was getting just a bit ridiculous.

Anyways, if we keep on packing the code into one of these constant arrays and
modifying the code to handle the larger constant array, we should eventually
reach a fixed point, at which point we'll be done.

BUT WAIT! Each of those IF statements (which will be included in the code
to be packed, remember) uses 17 characters - and a single mat4 can only
hold 16. That means that the size of the code would rise exponentially and
never reach a fixed point, which is BAD.

The solution?
The IF statements are so predictable that we can print those in roughly
the same way as we print the mat4s.

The result converges in two iterations to exactly 166 constants.

And then I made the text scroll down a slowly rotating plane with subtle
vignetting, because Shadertoy can do that.

CHANGELOG:
2015-03-19: Thanks to poljere and CrossProduct, changed integer mods to use the md() function
for full compatibility with OpenGL ES 2.0. (Full quine-ness temporarily disabled for now)
3:25 PM: Whoops. Now works on reasonably fast Windows boxes.

Thanks!
-nbickford

(Just FYI: This is a kinda-remote submission 
because I have to leave Friday morning. Sorry.)
*/