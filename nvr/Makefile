all: compile

modes = snowmen base fromfile boxes shaders
MODE ?= snowmen

compile: ext/dlib/ build/
	cd build/ && cmake -DMODE_$(MODE)=ON .. && cmake --build .
	cp build/$(MODE) .
.PHONY: compile

clean:
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(if $(wildcard ext/*), rm -r ext/)
	$(foreach bin, $(modes), \
            $(if $(wildcard $(bin)), rm $(bin);))

build/:
	mkdir $@
ext/:
	mkdir $@

DLIB = 18.16
DLIB_file = dlib-$(DLIB).tar.bz2
ext/$(DLIB_file): ext/
	wget -O ext/$(DLIB_file) 'http://freefr.dl.sourceforge.net/project/dclib/dlib/v$(DLIB)/dlib-$(DLIB).tar.bz2' || rm ext/$(DLIB_file)
ext/dlib: ext/$(DLIB_file)
	cd ext/ && tar jxf $(DLIB_file) && mv dlib-*/ dlib/ #&& rm -f $(DLIB_file)


dat = 'shape_predictor_68_face_landmarks.dat'
dat_url = 'http://ftp.jaist.ac.jp/pub/sourceforge/d/dc/dclib/dlib/v18.10/'$(dat)'.bz2'
$(dat):
	wget -O ext/$(dat).bz2 $(dat_url) || rm ext/$(dat).bz2
	cd ext/ && tar jf $(dat).bz2
