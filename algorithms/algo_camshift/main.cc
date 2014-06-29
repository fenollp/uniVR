#define ALGO "algo_camshift"  // Haar detects then CAMSHIFT tracks

#include <opencv/cv.h>
#include <opencv/highgui.h>

#include <iostream>

IplImage* capture_video_frame (CvCapture*);
CvRect* detect_face (IplImage*, CvHaarClassifierCascade*, CvMemStorage*);
void cleanup (CvHaarClassifierCascade*, CvMemStorage*);
void print_help (char*);

//used by capture_video_frame, so we don't have to keep creating.
IplImage* frame_curr;
IplImage* frame_copy;

typedef struct {
  IplImage* hsv;     //input image converted to HSV
  IplImage* hue;     //hue channel of HSV image
  IplImage* mask;    //image for masking pixels
  IplImage* prob;    //face probability estimates for each pixel

  CvHistogram* hist; //histogram of hue in original face image

  CvRect prev_rect;  //location of face in previous frame
  CvBox2D curr_box;  //current face location estimate
} TrackedObj;

TrackedObj* create_tracked_object (IplImage* image, CvRect* face_rect);
void destroy_tracked_object (TrackedObj* tracked_obj);
CvBox2D camshift_track_face (IplImage* image, TrackedObj* imgs);
void update_hue_image (const IplImage* image, TrackedObj* imgs);


#define CASCADE_NAME "xml/haarcascade_frontalface_alt.xml"

int
main (int argc, const char* argv[]) {
    CvCapture *capture = NULL;
    CvHaarClassifierCascade *cascade = NULL;
    CvMemStorage *storage = NULL;

    cascade = (CvHaarClassifierCascade*)cvLoad(CASCADE_NAME, 0, 0, 0);
    storage = cvCreateMemStorage(0);
    assert(cascade && storage);

    cvNamedWindow(ALGO, 1);

    CvRect *face_rect = 0;

    //CvCapture* capture = cvCaptureFromFile(argv[1]);
    if (!(capture = cvCaptureFromCAM(0))) {
        std::cerr << "!cap from webcam 0" << std::endl;
        return 2;
    }

    IplImage *image = NULL;
    while (true) {
        image = cvQueryFrame(capture);
        if (!image)
            break;

        face_rect = detect_face(image, cascade, storage);
        cvShowImage(ALGO, image);

        if (face_rect)
            break;

        if (cvWaitKey(10) >= 0) {
            cvReleaseCapture(&capture);
            cleanup(cascade, storage);
            exit(0);
        }
    }

    std::cout << "Detected face. CAMSHIFT tracking…" << std::endl;
    TrackedObj *tracked_obj = create_tracked_object(image, face_rect);

    CvBox2D face_box; //area to draw

    while (true) {
      image = cvQueryFrame(capture);
      if (!image)
          break;

      face_box = camshift_track_face(image, tracked_obj);

      cvEllipseBox(image, face_box, CV_RGB(255,0,0), 3, CV_AA, 0);
      cvShowImage(ALGO, image);

      if (cvWaitKey(10) >= 0)
          break;
    }

    destroy_tracked_object(tracked_obj);
    cvReleaseCapture(&capture);

    cleanup(cascade, storage);
}


CvRect *
detect_face (IplImage* image,
             CvHaarClassifierCascade* cascade,
             CvMemStorage* storage) {
    CvRect* rect = NULL;
    CvSeq *faces = cvHaarDetectObjects(image, cascade, storage,
     1.1,                       //increase search scale by 10% each pass
     6,                         //require 6 neighbors
     CV_HAAR_DO_CANNY_PRUNING,  //skip regions unlikely to contain a face
     cvSize(0, 0));             //use default face size from xml

    if(faces && faces->total)
        rect = (CvRect*) cvGetSeqElem(faces, 0);

  return rect;
}

/* Capture frame and return a copy so not to write to source. */
IplImage *
capture_video_frame (CvCapture* capture) {
    //capture the next frame
    frame_curr = cvQueryFrame(capture);
    frame_copy = cvCreateImage(cvGetSize(frame_curr), 8, 3);
    assert(frame_curr && frame_copy); //make sure it's there

    //make copy of frame so we don't write to src
    cvCopy(frame_curr, frame_copy, NULL);
    frame_copy->origin = frame_curr->origin;

    //invert if needed, 1 means the image is inverted
    if (frame_copy->origin == 1) {
        cvFlip(frame_copy, 0, 0);
        frame_copy->origin = 0;
    }

    return frame_copy;
}

void
cleanup (CvHaarClassifierCascade* cascade,
         CvMemStorage* storage) {
    //cleanup and release resources
    cvDestroyWindow(ALGO);
    if (cascade)
        cvReleaseHaarClassifierCascade(&cascade);
    if (storage)
        cvReleaseMemStorage(&storage);
}



TrackedObj *
create_tracked_object (IplImage* image, CvRect* region) {
    TrackedObj* obj;

    if ((obj = (TrackedObj *)malloc(sizeof *obj)) != NULL) {
        //create-image: size(w,h), bit depth, channels
        obj->hsv  = cvCreateImage(cvGetSize(image), 8, 3);
        obj->mask = cvCreateImage(cvGetSize(image), 8, 1);
        obj->hue  = cvCreateImage(cvGetSize(image), 8, 1);
        obj->prob = cvCreateImage(cvGetSize(image), 8, 1);

        int hist_bins = 30;           //number of histogram bins
        float hist_range[] = {0,180}; //histogram range
        float* range = hist_range;
        obj->hist = cvCreateHist(1,             //number of hist dimensions
                                 &hist_bins,    //array of dimension sizes
                                 CV_HIST_ARRAY, //representation format
                                 &range,        //array of ranges for bins
                                 1);            //uniformity flag
    }

    update_hue_image(image, obj);

    float max_val = 0.f;

    //create a histogram representation for the face
    cvSetImageROI(obj->hue, *region);
    cvSetImageROI(obj->mask, *region);
    cvCalcHist(&obj->hue, obj->hist, 0, obj->mask);
    cvGetMinMaxHistValue(obj->hist, 0, &max_val, 0, 0 );
    cvConvertScale(obj->hist->bins, obj->hist->bins,
                   max_val ? 255.0/max_val : 0, 0);
    cvResetImageROI(obj->hue);
    cvResetImageROI(obj->mask);

    obj->prev_rect = *region;

    return obj;
}

void
destroy_tracked_object (TrackedObj* obj) {
    cvReleaseImage(&obj->hsv);
    cvReleaseImage(&obj->hue);
    cvReleaseImage(&obj->mask);
    cvReleaseImage(&obj->prob);
    cvReleaseHist(&obj->hist);
    free(obj);
}


CvBox2D
camshift_track_face (IplImage* image, TrackedObj* obj) {
    CvConnectedComp components;

    //create a new hue image
    update_hue_image(image, obj);

    //create a probability image based on the face histogram
    cvCalcBackProject(&obj->hue, obj->prob, obj->hist);
    cvAnd(obj->prob, obj->mask, obj->prob, 0);

    //use CamShift to find the center of the new face probability
    cvCamShift(obj->prob, obj->prev_rect,
               cvTermCriteria(CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 10, 1),
               &components, &obj->curr_box);

    //update face location and angle
    obj->prev_rect = components.rect;
    obj->curr_box.angle = -obj->curr_box.angle;

    return obj->curr_box;
}

void
update_hue_image (const IplImage* image, TrackedObj* obj) {
    //limits for calculating hue
    int vmin = 65, vmax = 256, smin = 55;

    //convert to HSV color model
    cvCvtColor(image, obj->hsv, CV_BGR2HSV);

    //mask out-of-range values
    cvInRangeS(obj->hsv,                               //source
               cvScalar(0, smin, MIN(vmin, vmax), 0),  //lower bound
               cvScalar(180, 256, MAX(vmin, vmax) ,0), //upper bound
               obj->mask);                             //destination

    //extract the hue channel, split: src, dest channels
    cvSplit(obj->hsv, obj->hue, 0, 0, 0 );
}
