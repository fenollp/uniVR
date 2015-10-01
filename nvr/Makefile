all: compile

modes = snowmen base fromfile boxes shaders
MODE ?= boxes

compile: build/
	cd build/ && cmake -DMODE_$(MODE)=ON --DCMAKE_VERBOSE_MAKEFILE=ON .. && cmake --build . --config Release
	cp build/$(MODE) .
.PHONY: compile

clean:
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(foreach bin, $(modes), \
            $(if $(wildcard $(bin)), rm $(bin);))

build/:
	mkdir $@


dat = 'shape_predictor_68_face_landmarks.dat'
dat_url = 'http://ftp.jaist.ac.jp/pub/sourceforge/d/dc/dclib/dlib/v18.10/'$(dat)'.bz2'
# https://copy.com/VvOZA9yL6WHAx2N8
$(dat):
	wget -O ext/$(dat).bz2 $(dat_url) || rm ext/$(dat).bz2
	cd ext/ && tar jf $(dat).bz2
