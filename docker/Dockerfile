FROM rocker/r-ver:4.4

# System dependencies for VTK (Linux detection path in rvtk) and riot
RUN apt-get update && apt-get install -y --no-install-recommends \
    libvtk9-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Python packages used by riot via reticulate
RUN pip3 install --break-system-packages fury dipy 2>/dev/null \
    || pip3 install fury dipy

# Install remotes for GitHub installation
RUN Rscript -e "install.packages('remotes')"

# Install rvtk and its dependencies from GitHub
RUN Rscript -e "remotes::install_github('astamm/rvtk')"

# Copy riot source
COPY . /riot

# Install riot from local source (dependencies resolved automatically)
RUN Rscript -e "remotes::install_local('/riot', dependencies = TRUE)"

# Quick smoke test
RUN Rscript -e " \
  library(riot); \
  f <- system.file('extdata', 'UF_left.vtk', package = 'riot'); \
  x <- read_tractogram(f); \
  stopifnot(nrow(x) > 0); \
  cat('OK: read', nrow(x), 'streamlines from', f, '\n') \
"
