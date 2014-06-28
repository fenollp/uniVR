

all:
	@echo "Usage: make ‹algo folder›/"

algo_%/:
	mkdir -p $@/build
	cd $@/build/ && cmake .. && make
	./build/$@/${CMAKE_PROJECT_NAME}_$@
.PHONY: demo%


distclean:
	rm -rf */build/*
