.PHONY: compile compile_all

all: compile

modes = shaders boxes fromfile base snowmen
MODE ?= boxes

compile: build/
	cd build/ && cmake -DMODE_$(MODE)=ON --DCMAKE_VERBOSE_MAKEFILE=ON .. && cmake --build . --config Release
	cp build/$(MODE) nvr_$(MODE)

compile_all:
	MODE='shaders' $(MAKE) -C . clean compile
	MODE='boxes' $(MAKE) -C . clean compile
	MODE='fromfile' $(MAKE) -C . clean compile
	MODE='base' $(MAKE) -C . clean compile
	MODE='snowmen' $(MAKE) -C . clean compile

clean:
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(foreach bin, $(modes), \
            $(if $(wildcard nvr_$(bin)), rm nvr_$(bin);))

build/:
	mkdir $@
