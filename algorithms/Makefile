

all:
	@echo "Usage: make ‹algo folder›/"

algo_basic_haar/: algo_basic_haar/main.cc | algo_basic_haar/build/
	cd $@/build && ALGO=algo_basic_haar cmake .. && make
.PHONY: algo_basic_haar/

algo_basic_haar/build/:
	mkdir algo_basic_haar/build/

# algo_%/:
# 	mkdir -p $@/build
# 	cd $@/build/ && cmake .. && make
# 	./build/$@/${CMAKE_PROJECT_NAME}_$@
# .PHONY: algo_%/


distclean:
	rm -rf */build/
