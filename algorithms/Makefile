

all:
	@echo "Usage: make ‹algo folder›/"

algo_basic_haar/: algo_basic_haar/main.cc | algo_basic_haar/build/
	cd $@/build && cmake .. && make
	./algo_basic_haar/build/algo_basic_haar
.PHONY: algo_basic_haar/

algo_detection_based_tracker/: algo_detection_based_tracker/main.cc | algo_detection_based_tracker/build/
	cd $@/build && cmake .. && make
	./algo_detection_based_tracker/build/algo_detection_based_tracker
.PHONY: algo_detection_based_tracker/

%/build/:
	mkdir $@

# algo_%/:
# 	mkdir -p $@/build
# 	cd $@/build/ && cmake .. && make
# 	./build/$@/${CMAKE_PROJECT_NAME}_$@
# .PHONY: algo_%/


distclean:
	rm -rf */build/
