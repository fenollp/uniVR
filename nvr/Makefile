all: compile

modes = snowmen base fromfile boxes shaders
MODE ?= boxes

compile: build/
	cd build/ && cmake -DMODE_$(MODE)=ON --DCMAKE_VERBOSE_MAKEFILE=ON .. && cmake --build . --config Release
	cp build/$(MODE) nvr_$(MODE)
.PHONY: compile

js: includes = -I . -I include `pkg-config --cflags opencv`
#js: dlib = -DDLIB_NO_GUI_SUPPORT dlib/all/source.cpp
###js: dlib = -I/opt/X11/include dlib/all/source.cpp -lpthread -lX11
js: dlib = build/dlib_build/libdlib.a
js: #compile
	em++ -O3 -std=c++11 -v $(includes) $(dlib) src/nvr.cc src/main_$(MODE).cc -o nvr_$(MODE).html -s ASSERTIONS=1

clean:
	$(if $(wildcard build/*), rm -r build/)

distclean: clean
	$(foreach bin, $(modes), \
            $(if $(wildcard nvr_$(bin)), rm nvr_$(bin);))

build/:
	mkdir $@
