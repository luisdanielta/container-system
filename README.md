### Make the following list, compose 
1. network
2. user/entrypoint
3. ubuntu/base
4. app/conda
5. cuda

docker run --rm -v "${PWD}:/src" semgrep/semgrep:1.150.0 semgrep scan --config auto

sudo systemctl restart docker