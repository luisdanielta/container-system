openssl req -x509 -nodes -days 825 -newkey rsa:2048 -keyout coder.local.key -out coder.local.crt -subj "/CN=coder.local"
