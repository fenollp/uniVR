all: compile

# modes: snowmen base fromfile
MODE ?= snowmen

compile: ext/dlib/ build/
	cd build/ && cmake -DMODE_$(MODE)=ON .. && cmake --build .
	cp build/$(MODE) .
.PHONY: compile

build/:
	mkdir $@
ext/:
	mkdir $@

DLIB_url = 'http://freefr.dl.sourceforge.net/project/dclib/dlib/v18.11/dlib-18.11.tar.bz2'
DLIB_ver = dlib-18.11.tar.bz2
ext/$(DLIB_ver): ext/
	wget -O ext/$(DLIB_ver) $(DLIB_url) || rm ext/$(DLIB_ver)
ext/dlib: ext/$(DLIB_ver)
	cd ext/ && tar jxf $(DLIB_ver) && mv dlib-*/ dlib/ #&& rm -f $(DLIB_ver)


clean:
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(if $(wildcard ext/*), rm -r ext/)
	$(foreach bin, snowmen base fromfile, \
            $(if $(wildcard $(bin)), rm $(bin);))



dat = 'shape_predictor_68_face_landmarks.dat'
dat_url = 'http://ftp.jaist.ac.jp/pub/sourceforge/d/dc/dclib/dlib/v18.10/'$(dat)'.bz2'
$(dat):
	wget -O ext/$(dat).bz2 $(dat_url) || rm ext/$(dat).bz2
	cd ext/ && tar jf $(dat).bz2
