

all:
	@echo "Usage: make ‹algo folder›/"

algo_haar/: algo_haar/main.cc | algo_haar/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_haar
.PHONY: algo_haar/

algo_detection_based_tracker/: algo_detection_based_tracker/main.cc | algo_detection_based_tracker/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_detection_based_tracker
.PHONY: algo_detection_based_tracker/

algo_haar_ocl/: algo_haar_ocl/main.cc | algo_haar_ocl/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_haar_ocl
.PHONY: algo_haar_ocl/

algo_camshift/: algo_camshift/main.cc | algo_camshift/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_camshift
.PHONY: algo_camshift/

algo_surf_ocl/: algo_surf_ocl/main.cc | algo_surf_ocl/build/
	cd $@/build && cmake .. && make
	./$@/build/algo_surf_ocl
.PHONY: algo_surf_ocl/


%/build/:
	mkdir $@

# algo_%/:
# 	mkdir -p $@/build
# 	cd $@/build/ && cmake .. && make
# 	./build/$@/${CMAKE_PROJECT_NAME}_$@
# .PHONY: algo_%/


distclean:
	rm -rf */build/
