all:
	@echo "Usage: make ‹algo folder›/"

_/: _/main.cc | _/build/ _/ext/dlib
	cd $@/build && cmake .. && cmake --build .
.PHONY: _/

algo_haar/: algo_haar/main.cc | algo_haar/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_haar
.PHONY: algo_haar/

algo_detection_based_tracker/: algo_detection_based_tracker/main.cc | algo_detection_based_tracker/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_detection_based_tracker
.PHONY: algo_detection_based_tracker/

algo_haar_ocl/: algo_haar_ocl/main.cc | algo_haar_ocl/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_haar_ocl
.PHONY: algo_haar_ocl/

algo_camshift/: algo_camshift/main.cc | algo_camshift/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_camshift
.PHONY: algo_camshift/

algo_surf_ocl/: algo_surf_ocl/main.cc | algo_surf_ocl/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_surf_ocl
.PHONY: algo_surf_ocl/


# algo_%/:
# 	mkdir -p $@/build
# 	cd $@/build/ && cmake .. && make
# 	./build/$@/${CMAKE_PROJECT_NAME}_$@
# .PHONY: algo_%/


%/build/:
	mkdir $@
_/ext/:
	mkdir $@

DLIB_url = 'http://freefr.dl.sourceforge.net/project/dclib/dlib/v18.10/dlib-18.10.tar.bz2'
DLIB_ver = dlib-18.10.tar.bz2
_/ext/$(DLIB_ver): _/ext/
	wget -O $@ $(DLIB_url) || rm $@
_/ext/dlib: _/ext/$(DLIB_ver)
	cd _/ext/ && tar jxf $(DLIB_ver) && mv dlib-*/ dlib/ #&& rm -f $(DLIB_ver)

# dat = 'shape_predictor_68_face_landmarks.dat'
# dat_url = 'http://ftp.jaist.ac.jp/pub/sourceforge/d/dc/dclib/dlib/v18.10/'$(dat)'.bz2'
# $(dat):
# 	wget -O _/ext/$(dat).bz2 $(dat_url) || rm _/ext/$(dat).bz2
# 	cd _/ext/ && tar jf $(dat).bz2


clean:
	$(if $(wildcard */build), rm -r */build)

distclean: clean
	$(if $(wildcard _/ext/*), rm -r _/ext/)
