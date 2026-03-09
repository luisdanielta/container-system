"insecure-registries": ["127.0.0.1:5000"]

docker run --rm -it -v registry_auth:/auth httpd:2 bash
cd /auth
rm htpasswd

# new
htpasswd -Bbn admin password123 > htpasswd

### Using the Local Docker Registry
alias dpush='bash -c "docker tag \$1 registry.docker.local/\$1 && docker push registry.docker.local/\$1" bash'

#### Tag and Push the Image to Local Registry
docker tag ubuntu:local registry.docker.local/ubuntu:local
docker push registry.docker.local/ubuntu:local