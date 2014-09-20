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

## Requirements
This code should compile | run with

* cmake ≥ 2.8
* OpenCV ≥ 2.4.8
* Apple LLVM version 5.1 (clang-503.0.40) (based on LLVM 3.4svn)


### nvr/*

`cd nvr && make && ./nvr shape_predictor_68_face_landmarks.dat`

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


### algorithms/*

`cd algorithms && make _/ && ./compare.sh`

Those are tests comparing speed and accuracy of OpenCV's implementation of the state-of-the-art.


### stateoftheart/*

* Uses [Google Test](https://code.google.com/p/googletest/) & [its cmake binding](https://github.com/snikulov/google-test-examples)
