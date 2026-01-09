FROM rocker/geospatial:4.5.2

USER root

RUN apt update -y && apt install -y \
    libgdal-dev \
    libgeos++-dev \
    libudunits2-dev \
    libproj-dev \
    libx11-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libfreetype6-dev \
    libxt-dev \
    libfftw3-dev \ 
    libsdl2-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -aG sudo rstudio
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /home/rstudio/.R/library && \
    chown -R rstudio:rstudio /home/rstudio/.R

USER rstudio
RUN R -e 'install.packages("BiocManager", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

RUN R -e 'BiocManager::install("EBImage", ask=FALSE)'

RUN R -e 'install.packages("lidR", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

RUN R -e 'install.packages("terra", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

RUN R -e 'install.packages("sf", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

RUN R -e 'install.packages("ggplot2", dependencies=TRUE, ask=FALSE, repos="https://r-lidar.r-universe.dev")'


USER root
