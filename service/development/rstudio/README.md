### fix
1. rstudio is not in the sudoers file. This incident will be reported.

docker exec -it rstudio_id bash
apt-get update
apt-get install -y sudo
usermod -aG sudo rstudio
echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


2. tlmgr install home path