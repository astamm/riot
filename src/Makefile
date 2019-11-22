all:
	"${R_HOME}/bin${R_ARCH_BIN}/Rscript" -e "utils::untar('VTK-8.2.0.tar.gz')";
	mkdir -p vtk_build;
	mkdir -p ../inst;
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../inst -S VTK-8.2.0 -B vtk_build
	cd vtk_build && make clean && make -j`"${R_HOME}/bin${R_ARCH_BIN}/Rscript" -e "writeLines(as.character(parallel::detectCores(logical = FALSE)))"` && make install;
	rm -fr VTK-8.2.0;
	rm -fr vtk_build;

# Linux
cp ../inst/lib/trio.so . || echo "Failed: trio.so -> src"

# Mac
cp ../inst/lib/trio.dylib ./trio.so || echo "Failed: trio.dylib -> src"
