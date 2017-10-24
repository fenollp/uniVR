.PHONY: compile

CMAKE_FLAGS  = -DCMAKE_BUILD_TYPE=Release
CMAKE_FLAGS += -DENABLE_AVX=ON
CMAKE_FLAGS += -DENABLE_FAST_MATH=ON
CMAKE_FLAGS += -DENABLE_SSE=ON
CMAKE_FLAGS += -DENABLE_SSE2=ON
CMAKE_FLAGS += -DENABLE_SSE3=ON
CMAKE_FLAGS += -DENABLE_SSE41=ON
CMAKE_FLAGS += -DENABLE_SSE42=ON
CMAKE_FLAGS += -DENABLE_SSSE3=ON


all: compile

compile: build
	cd build && cmake --build . --config Release

clean: clean-emjs
	$(if $(wildcard build), rm -r build)

distclean: clean

build:
	mkdir -p $@
	cd build && cmake --DCMAKE_VERBOSE_MAKEFILE=ON ..


emjs_base.html: build | clean
	cd build && $(EMCMAKE) cmake --DCMAKE_VERBOSE_MAKEFILE=ON .. && $(EMMAKE) make

#FLAGS = -v
FLAGS += --js-library 'lib/emscripten/library_html5video.js'
#FLAGS += --shell-file template.html
FLAGS += -s ASSERTIONS=2
FLAGS += -s DEMANGLE_SUPPORT=1
FLAGS += -I 'libnvr/'
FLAGS += -I 'include/'
#FLAGS += -Wno-warn-absolute-paths
FLAGS += -std=c++14
FLAGS += --preload-file 'data/crate.bmp'
FLAGS += --preload-file 'data/68/shape_predictor_68_face_landmarks.dat'
FLAGS += -I '.'
#FLAGS += -s LEGACY_GL_EMULATION=1
FLAGS += -Wall
FLAGS += -Wno-deprecated
FLAGS += -W -Wextra -pedantic
FLAGS += -O3
#FLAGS += --std=c++11 -stdlib=libstdc++ -static -lstdc++
#FLAGS += -fcolor-diagnostics=always
#  FLAGS += -s ABORTING_MALLOC=0  # malloc returns NULL instead of halt
#  FLAGS += -s TOTAL_MEMORY='218104808'
#  FLAGS += -s ALLOW_MEMORY_GROWTH=1
FLAGS += -s TOTAL_MEMORY='268435456'

ifneq ($(shell which emcc),)
EMCC = emcc
EMXX = em++
EMMAKE = emmake
EMCMAKE = emcmake
else
VSN = 1.35.23
BASE = docker run -v "$$PWD":/src trzeci/emscripten:sdk-tag-$(VSN)-64bit
EMCC = $(BASE) emcc
EMXX = $(BASE) em++
EMMAKE = $(BASE) emmake
EMCMAKE = $(BASE) emcmake
endif

CCs = dlib/base64/base64_kernel_1.cpp \
      dlib/entropy_decoder/entropy_decoder_kernel_2.cpp \
      libnvr/nvr.cc

base.html: clean
	$(EMXX) $(FLAGS) $(CCs) src/main_emjs_base.cc -o $@

test: base.html
	@echo Now open 'http://localhost:1992/$^'
	@open 'http://localhost:1992/$^' || true
	python -m SimpleHTTPServer 1992

clean-emjs:
	$(if $(wildcard base.*), rm -f base.*)
