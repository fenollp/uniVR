all: compile

compile: deps/dlib/ build/
	cd build/ && cmake .. && cmake --build .
	cp build/nvr nvr
.PHONY: compile

build/:
	mkdir build/

DLIB_url = 'http://freefr.dl.sourceforge.net/project/dclib/dlib/v18.10/dlib-18.10.tar.bz2'
DLIB_ver = 'dlib-18.10.tar.bz2'

deps/dlib/:
	cd deps/ && wget -O $(DLIB_ver) $(DLIB_url) || rm $(DLIB_ver)
	cd deps/ && tar jxf $(DLIB_ver) && mv dlib-* dlib/ && rm -f $(DLIB_ver)


clean:
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(if $(wildcard deps/*), rm -r deps/)
	$(if $(wildcard nvr), rm nvr)
