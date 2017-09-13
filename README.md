https://www.shadertoy.com/view/ltfyWr

# uniVR • [Bitbucket](https://bitbucket.org/fenollp/univr)

One laptop, one webcam, one head.  
Move your head in front of the screen to “see in 3D” (3D desktop, 3D-computed
movies, whatever).

What happens is that your head is tracked by your webcam. An
orientation is computed. El ordenador then displays a flow of pictures
as seen from π - ‹the said angle›.  
Then it blows your mind, thank you.

Johnny Chung Lee did this with his “[Head Tracking for Desktop VR Displays using the WiiRemote](http://www.youtube.com/watch?v=Jd3-eiid-Uw&t=2m30s)” project.
He also did a [TED talk](http://youtu.be/0H1zrLZwPjQ?t=3m41s) about it.


## TODO

1. HOG and/or landmarks on Y and Cb & Cr as an attempt at palliating bad lighting.
1. Minimum head size for detectors is around 80px. Pick x240 xor x480 and reduce pyramid size for speed.
    * As of 2015 (from Wikipedia on Webcams):
        - low-end: 320x240
        - medium-end: 640x480
        - high-end: 1280x720 or even 1920x1080
1. Try a Kalman filter on landmarks (68 * x,y,vx,vy) as a better logic for calling HOG less.


#### Comparison of some algorithms
* [Comparison of feature descriptors](http://computer-vision-talks.com/articles/2011-01-28-comparison-of-feature-descriptors/)
    * => LAZY > SURF >> BRIEF
* [SO: feature detectors and descriptors comparison](http://stackoverflow.com/questions/18437878/feature-detectors-and-descriptors-comparison)
    * SIFT, SURF only similarity-invariant (homotecies)
    * affine covariance is important too (invariance to viewpoint changes)
    * Hessian-Affine, MSER are affine-invariant but as slow as SIFT, SURF
    * FAST > SURF > SIFT
    * BRIEF, FREAK faster but worse
    * for realtime: use GPU | BRIEF, FREAK
* [A Comparison of Affine Region Detectors](http://www.robots.ox.ac.uk/~vgg/research/affine/det_eval_files/vibes_ijcv2004.pdf)
    * MSER > Hessian-Affine >> Harris-Affine > EBR
* Quick links to unread documentation
    * [FREAK](http://www.ivpe.com/freak.htm)
    * [MSER](http://www.robots.ox.ac.uk/~vgg/research/affine/det_eval_files/matas_bmvc2002.pdf)
    * [Harris, Laplacian](http://www.robots.ox.ac.uk/~vgg/research/affine/det_eval_files/mikolajczyk_ijcv2004.pdf)
    * [BRIEF](http://cvlabwww.epfl.ch/~lepetit/papers/calonder_eccv10.pdf)
    * [qualitative overview](http://epubs.surrey.ac.uk/726872/1/Tuytelaars-FGV-2008.pdf)
    * Face Alignment
	    * [Face Detection, Pose Estimation and Landmark Localization in the Wild](http://www.ics.uci.edu/~xzhu/face/)
	    * [Facial Point Detection using Boosted Regression and Graph Models](http://www.doc.ic.ac.uk/~mvalstar/Documents/ValstarMartinezPantic_final.pdf)
	    * [Feature Detection and Tracking with Constrained Local Models](http://www.isbe.man.ac.uk/~bim/Papers/BMVC06/cristinacce_bmvc06.pdf)
	    * [Real-time Facial Feature Detection using Conditional Regression Forests](http://www.vision.ee.ethz.ch/~gfanelli/pubs/cvpr12.pdf)
	    * [Deep Convolutional Network Cascade for Facial Point Detection](http://www.ee.cuhk.edu.hk/~xgwang/papers/sunWTcvpr13.pdf)
	    * [SO: face alignment algorithm on images](http://stackoverflow.com/questions/12046462/face-alignment-algorithm-on-images)
	    * [Q: What is the best method for face alignment?](http://www.quora.com/Computer-Vision/What-is-the-best-method-for-face-alignment)

## Requirements
This code should compile | run with

* cmake ≥ 2.8
* OpenCV ≥ 2.4.9
* Dlib ≥ 18.10
* Apple LLVM version 5.1 (clang-503.0.40) (based on LLVM 3.4svn)
* FreeImage
* GLUT `sudo apt-get install libxmu-dev libxi-dev`
* GLEW `sudo apt-get install libglew-dev`
* OpenGL `sudo apt-get install freeglut3 freeglut3-dev`


### Testing

Categories of data:
1. dim
1. bright
1. lighting changes
1. moving object
1. stationary object
1. dropped frames
1. low resolution
1. similar background shapes
1. similar background colors


### nvr/*

`cd nvr && MODE=snowmen make -j && ./snowmen shape_predictor_68_face_landmarks.dat`

* Different `MODE`s: `snowmen`, `base`, `fromfile`, `shaders`.
* More GLSL shaders at
    * [GLSL Sandbox Gallery](http://glslsandbox.com/)
    * [Shadertoy BETA](https://www.shadertoy.com/)
* **facial landmark detection** using [C++ Dlib](http://dlib.net/)
* **Face detector:** Histogram of Oriented Gradients
    * Affine-invariant feature descriptor (like SIFT, SURF)
        * **However good enough in practice**
    * First paper by INRIA in 2005
        * *Histograms of Oriented Gradients for Human Detection by Navneet Dalal and Bill Triggs, CVPR 2005*
    * "Augmented the method slightly to use the version of HOG features from:"
        * *Object Detection with Discriminatively Trained Part Based Models by P. Felzenszwalb, R. Girshick, D. McAllester, D. Ramanan IEEE Transactions on Pattern Analysis and Machine Intelligence, Vol. 32, No. 9, Sep. 2010*
* **Feature extractor | Shape predictor:**
    * [Face Alignment at 3000 FPS via Regressing Local Binary Features](http://research.microsoft.com/en-US/people/yichenw/cvpr14_facealignment.pdf)
        * Really its public implementation: [One Millisecond Face Alignment with an Ensemble of Regression Trees](http://www.csc.kth.se/~vahidk/papers/KazemiCVPR14.pdf)
        * Both papers dating 2014
    * Related database (of still images): [helen](http://www.ifp.illinois.edu/~vuongle2/helen/)
* [dlib documentation](http://dlib.net/term_index.html)
* Possible additions:
    * Demos:
        1. Combine 3D screen / glasses & render a 3D video stream
        1. Mirror the user's face on a 3D OpenGL head (map texture?)
        1. RUN ON A WEBSITE


### motion/*

`cd nvr && make && ./nvr shape_predictor_68_face_landmarks.dat`

* **motion detection** as [explained here](http://blog.cedric.ws/opencv-simple-motion-detection)
* **facial landmark extraction**


### algorithms/*

`cd algorithms && make _/ && ./compare.sh`

Those are tests comparing speed and accuracy of OpenCV's implementation of the state-of-the-art.


### stateoftheart/*

* Uses [Google Test](https://code.google.com/p/googletest/) & [its cmake binding](https://github.com/snikulov/google-test-examples)
* Actually moved to algorithms/
