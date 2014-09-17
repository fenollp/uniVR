all: build
	cd build/ && cmake .. && make all test

build:
	mkdir build

distclean:
	$(if $(wildcard build/), rm -rf build/)
