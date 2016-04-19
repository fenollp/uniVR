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

clean: clean-emjs
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(foreach bin, $(modes), \
            $(if $(wildcard nvr_$(bin)), rm nvr_$(bin);))

build/:
	mkdir $@


FLAGS = -v
FLAGS += --js-library 'lib/emscripten/library_html5video.js'
#FLAGS += --shell-file template.html
FLAGS += -s ASSERTIONS=2
FLAGS += -s DEMANGLE_SUPPORT=1
FLAGS += -I 'lib/'
FLAGS += -I 'include/'
#FLAGS += -Wno-warn-absolute-paths
FLAGS += -std=c++14
FLAGS += -Wall
FLAGS += -O3
FLAGS += --preload-file 'data/crate.bmp'
FLAGS += --preload-file 'data/ldmrks68.dat'
FLAGS += -I '.'
FLAGS += -s TOTAL_MEMORY='218103808'
#FLAGS += -s LEGACY_GL_EMULATION=1
FLAGS += -Wall
FLAGS += -Wno-deprecated
FLAGS += -W -Wextra -pedantic
FLAGS += -O3
FLAGS += --std=c++11 -stdlib=libstdc++ -static -lstdc++

ifeq ($(shell uname -o),Darwin)
EMCC = emcc
EMXX = em++
else
VSN = 1.35.23
BASE = docker run -v "$$PWD":/src trzeci/emscripten:sdk-tag-$(VSN)-64bit
EMCC = $(BASE) emcc
EMXX = $(BASE) em++
endif

boxes.html: clean
	$(EMXX) $(FLAGS) lib/emjs.cc src/main_emjs_boxes.cc -o $@

test: boxes.html
	@echo Now open 'http://localhost:1992/$^'
	@open 'http://localhost:1992/$^' || true
	python -m SimpleHTTPServer 1992

clean-emjs:
	$(if $(wildcard boxes.*), rm -f boxes.*)
