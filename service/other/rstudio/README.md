### fix
1. rstudio is not in the sudoers file. This incident will be reported.

docker exec -it rstudio_id bash
apt-get update
apt-get install -y sudo
usermod -aG sudo rstudio
echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


2. tlmgr install home path

 # privileged: true
    # devices:
    #   - /dev/dri/card0:/dev/dri/card0:rwm
    #   - /dev/dri/renderD128:/dev/dri/renderD128:rwm


# RUN mkdir -p /home/rstudio/.R/library && \
#     chown -R rstudio:rstudio /home/rstudio/.R

# RUN sudo R -e 'install.packages("BiocManager", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

# RUN sudo R -e 'BiocManager::install("EBImage", ask=FALSE)'

# RUN sudo R -e 'install.packages("lidR", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

# RUN sudo R -e 'install.packages("terra", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

# RUN sudo R -e 'install.packages("sf", dependencies=TRUE, ask=FALSE, repos="https://cloud.r-project.org")'

# RUN sudo R -e 'install.packages("ggplot2", dependencies=TRUE, ask=FALSE, repos="https://r-lidar.r-universe.dev")'