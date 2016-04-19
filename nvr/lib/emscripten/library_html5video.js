var LibraryHTML5Video = {
    $VIDEO: {
        grabbers: [],
        grabbersContexts: [],
        grabbersCounter: 0,

        getNewGrabberId: function () {
            var ret = VIDEO.grabbersCounter++;
            return ret;
        },

        getUserMedia: function () {
            return navigator.getUserMedia ||
        	navigator.webkitGetUserMedia ||
        	navigator.mozGetUserMedia ||
        	navigator.msGetUserMedia;
        },

        update: function (updatePixels, video, context, dstPixels) {
            if ((updatePixels || video.pixelFormat != "RGBA")
                && video.width != 0
                && video.height != 0
                && dstPixels != 0) {
        	try {
	            context.drawImage(video, 0, 0, video.width, video.height);
	            imageData = context.getImageData(0, 0, video.width, video.height);
	            srcPixels = imageData.data;

	            if (video.pixelFormat == "RGBA") {
		        //TODO: this is faster but under chrome, loop and set_time stop working
		        array.set(imageData.data);
		        // array = Module.HEAPU8.subarray(dstPixels, dstPixels + video.width * video.height * 4);
		        // for (var i = 0 ; i < data.length; ++i) {
		        //     array[i] = srcPixels[i];
		        // }
	            }

                    else if (video.pixelFormat == "RGB") {
		        array = Module.HEAPU8.subarray(dstPixels, dstPixels + video.width * video.height * 3);
		        for (var i = 0, j = 0; i < array.length; ) {
		            array[i++] = srcPixels[j++];
		            array[i++] = srcPixels[j++];
		            array[i++] = srcPixels[j++];
		            ++j;
		        }
	            }

                    else if (video.pixelFormat == "GRAY") {
		        array = Module.HEAPU8.subarray(dstPixels, dstPixels + video.width * video.height);
		        for (var i = 0, j = 0; i < array.length; ) {
		            array[i++] = (((srcPixels[j++]|0) << 1)
                                          + ((srcPixels[j]|0) << 2)
                                          + (srcPixels[j++]|0)
                                          + (srcPixels[j++]|0)) >> 3;
		            ++j;
		        }
	            }

        	}
                catch (e) {
                    console.log(e);
                }
            }
        }
    },

    html5video_grabber_create: function () {
    	if (VIDEO.getUserMedia()) {
	    var video = document.createElement('video');
	    video.autoplay = true;
	    video.pixelFormat = "RGB";

	    var grabber_id = VIDEO.getNewGrabberId();
	    VIDEO.grabbers[grabber_id] = video;
	    return grabber_id;
    	} else {
    	    console.log("coudln't create grabber");
    	    return -1;
    	}
    },

    html5video_grabber_init: function (id, w, h, framerate) {
    	if (id != -1) {
            VIDEO.grabbers[id].width = w;
            VIDEO.grabbers[id].height = h;

    	    var videoImage = document.createElement('canvas');
    	    videoImage.width = w;
    	    videoImage.height = h;

    	    var videoImageContext = videoImage.getContext('2d');
    	    // background color if no video present
    	    videoImageContext.fillStyle = '#000000';
    	    videoImageContext.fillRect(0, 0, w, h);

    	    VIDEO.grabbersContexts[id] = videoImageContext;

    	    var errorCallback = function (e) {
    		console.log("Couldn't init grabber!", e);
    	    };

    	    if (framerate == -1) {
    		var constraints = {
	    	    video: {
		    	mandatory: {
		    	    maxWidth: w,
		    	    maxHeight: h
		    	}
	    	    }
    		};
    	    } else {
    		var constraints = {
	    	    video: {
		    	mandatory: {
		    	    maxWidth: w,
		    	    maxHeight: h,
		    	},
    			optional: [ { minFrameRate: framerate }
		    	          ]
	    	    }
    		};
    	    }

    	    var getUserMedia = VIDEO.getUserMedia().bind(navigator);
    	    getUserMedia(constraints, function (stream) {
		VIDEO.grabbers[id].src = window.URL.createObjectURL(stream);
	    }, errorCallback);
    	}
    },

    html5video_grabber_pixel_format: function (id) {
        return allocate(intArrayFromString(VIDEO.grabbers[id].pixelFormat), 'i8', ALLOC_STACK);
    },

    html5video_grabber_set_pixel_format: function (id, format) {
        VIDEO.grabbers[id].pixelFormat = Pointer_stringify(format);
    },

    html5video_grabber_update: function (id, update_pixels, pixels) {
        var grabber = VIDEO.grabbers[id];
        if (grabber.readyState >= grabber.HAVE_METADATA) {
            VIDEO.update(update_pixels, grabber, VIDEO.grabbersContexts[id], pixels);
            return true;
        } else {
            return false;
        }
    },

    html5video_grabber_width: function (id) {
        return VIDEO.grabbers[id].width;
    },

    html5video_grabber_height: function (id) {
        return VIDEO.grabbers[id].height;
    },

    html5video_grabber_ready_state: function (id) {
        return VIDEO.grabbers[id].readyState;
    },
}


autoAddDeps(LibraryHTML5Video, '$VIDEO');
mergeInto(LibraryManager.library, LibraryHTML5Video);
