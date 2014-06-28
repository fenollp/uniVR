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

## Requierements
This code should compile | run with

* cmake ≥ 2.8
* OpenCV ≥ 2.4.8
* Apple LLVM version 5.1 (clang-503.0.40) (based on LLVM 3.4svn)


### algorithms/*

`cd algorithms && make test`

Those are tests comparing speed and accuracy of OpenCV's implementation of the state-of-the-art.
