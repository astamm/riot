#! /bin/sh

RSCRIPT_BIN=$1

# Download VTK source
${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/9.1/VTK-9.1.0.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-9.1.0 vtk-src

# # Download VTK source
# ${RSCRIPT_BIN} -e "utils::download.file(
#     url = 'https://www.vtk.org/files/release/7.1/VTK-7.1.1.tar.gz',
#     destfile = 'vtk-src.tar.gz')"
#
# # Uncompress VTK source
# ${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
# mv VTK-7.1.1 vtk-src

# # Download VTK source
# ${RSCRIPT_BIN} -e "utils::download.file(
#     url = 'https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz',
#     destfile = 'vtk-src.tar.gz')"
#
# # Uncompress VTK source
# ${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
# mv VTK-8.2.0 vtk-src
