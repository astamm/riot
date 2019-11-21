all:
	"${R_HOME}/bin${R_ARCH_BIN}/Rscript" -e "utils::untar('VTK-8.2.0.tar.gz')";
	rm -rf __MACOSX/;
	mkdir -p build_tmp;
	mkdir -p ../inst;
	cmake \
	  -DBUILD_SHARED_LIBS=OFF \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX=../inst \
	  -S VTK-8.2.0 \
	  -B build_tmp
	cd build_tmp && make clean && make -j`"${R_HOME}/bin${R_ARCH_BIN}/Rscript" -e "writeLines(as.character(parallel::detectCores(logical = FALSE)))"` && make install;
	rm -fr VTK-8.2.0;
	rm -fr build_tmp;
