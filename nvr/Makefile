all: compile

compile: ext/dlib/ build/
	cd build/ && cmake .. && cmake --build .
	cp build/nvr nvr
.PHONY: compile

build/:
	mkdir build/
ext/:
	mkdir ext/

DLIB_url = 'http://freefr.dl.sourceforge.net/project/dclib/dlib/v18.10/dlib-18.10.tar.bz2'
DLIB_ver = 'dlib-18.10.tar.bz2'

ext/dlib: ext/
	wget -O ext/$(DLIB_ver) $(DLIB_url) || rm ext/$(DLIB_ver)
	cd ext/ && tar jxf $(DLIB_ver) && mv dlib-*/ dlib/ #&& rm -f $(DLIB_ver)


clean:
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(if $(wildcard ext/*), rm -r ext/)
	$(if $(wildcard nvr), rm nvr)
