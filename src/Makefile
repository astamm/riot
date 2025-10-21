all:
	@echo "Configuring build with RPATH settings..."
	cmake -S . -B build \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE
	@echo "Build riot target..."
	@NPROC=$$(nproc 2>/dev/null || echo 1); \
	cmake --build build --config Release -- -j$$NPROC || { echo "Build failed"; exit 1; }
	cmake --install build --prefix . || { echo "Install failed"; exit 1; }
	for f in build/CMakeFiles/riot.dir/*.o; do \
	  cp $$f . || { echo "Copy failed"; exit 1; }; \
	done
	rm -rf build

clean:
	rm -rf build riot.so riot.dll
