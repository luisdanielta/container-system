## Ubuntu custom image with conda_app volume

### 2. Building the Base Environment
The base image `ubuntu:local`, which contains system management logic, must be built:

```bash
docker build -t ubuntu:local .
```


## Set User Password
This guide explains how to run a container from a custom Ubuntu image, and assign a password to a predefined user created without one.

## 3. Set Password from Host

### Option A: Interactive Method

1. Get a shell as root:

   ```bash
   docker exec -it -u root ubuntu-luist bash
   ```

2. Set the user password:

   ```bash
   passwd luist
   ```


# repoblar etc, for volumes ubuntu_user_etc_luist & ubuntu_user_etc_carlj
Paso 1: Crear y poblar cada volumen individualmente

docker run --rm -it --name repopulate_luist -v ubuntu_user_etc_luist:/mnt/etc ubuntu:local bash -c "cp -a /etc/. /mnt/etc/"


docker run --rm -it --name repopulate_carlj -v ubuntu_user_etc_carlj:/mnt/etc ubuntu:local bash -c "cp -a /etc/. /mnt/etc/"



### Option B: Non-Interactive (Recommended for Automation)

```bash
docker exec -u root ubuntu-luist bash -c "echo 'luist:YourSecurePass' | chpasswd"
```