1. usar **LVM real** (volúmenes lógicos),
2. usar un **archivo .img en loop** (que se comporta como un “disco” pero sin crear particiones reales).

Las dos son válidas; la primera es más empresarial, la segunda es más simple. A continuación, ambas.

---

## 1. Con **LVM real** (volúmenes lógicos)

Aquí no usas `.img`. Creas un volumen lógico con tamaño fijo y lo formateas.

### Pasos típicos

**1. Crear un volumen lógico**

```bash
lvcreate -L 5G -n docker_vol vg0
```

* `vg0`: tu *volume group*.
* `5G`: tamaño exacto y limitado.

**2. Formatearlo**

```bash
mkfs.ext4 /dev/vg0/docker_vol
```

**3. Crear un punto de montaje**

```bash
mkdir -p /mnt/docker_vol
```

**4. Montarlo**

```bash
mount /dev/vg0/docker_vol /mnt/docker_vol
```

**5. Usarlo como volumen en Docker**

```bash
docker run -v /mnt/docker_vol:/data imagen
```

Resultado: el directorio `/data` dentro del contenedor **no puede superar 5 GB**, porque el volumen lógico aplicado al host lo limita de forma estricta.

---

## 2. Con **archivo `.img` tipo loop** (sin particiones reales)

Esto es útil si no quieres tocar LVM ni crear particiones.
Crea un archivo que actúa como disco virtual.

### Pasos

**1. Crear archivo con tamaño fijo**

```bash
truncate -s 5G /opt/docker_vol.img
```

**2. Formatearlo**

```bash
mkfs.ext4 /opt/docker_vol.img
```

**3. Montarlo usando loop**

```bash
mkdir -p /mnt/docker_vol
mount -o loop docker_vol.img /mnt/docker_vol
umount /mnt/docker_vol
sudo losetup -D
```

**4. Usarlo en Docker**

```bash
docker run --rm -it -v /mnt/docker_vol:/opt/data alpine:3.20 sh
df -h /opt/data
```

El límite lo impone el tamaño del archivo `.img`.