FROM rocker/geospatial:4.5.2

RUN apt-get update && apt-get install -y sudo

RUN usermod -aG sudo rstudio
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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