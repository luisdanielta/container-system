## Almacenamiento portable con límite estricto de tamaño

**LVM real vs archivo `.img` en loop**

---

## 1) Objetivo

Definir y ejecutar un mecanismo de **almacenamiento portable con límite de capacidad estrictamente controlado**, utilizable como volumen de Docker o como punto de montaje en Linux, eligiendo entre:

* **LVM real** (volúmenes lógicos en el host).
* **Archivo `.img` montado por loop** (disco virtual portable).

El objetivo es garantizar:

* **Límite duro de espacio** (hard cap).
* **Comportamiento predecible** bajo carga.
* **Reproducibilidad y auditabilidad** del montaje.

---

## 2) Modelos disponibles (decisión arquitectónica)

### Opción A — LVM real (volúmenes lógicos)

**Perfil**

* Entornos productivos
* Infraestructura administrada
* Host con LVM ya configurado

**Características**

* Límite real a nivel de bloque
* Mayor robustez
* Menor portabilidad entre hosts

---

### Opción B — Archivo `.img` en loop

**Perfil**

* Desarrollo
* Portabilidad entre sistemas
* Hosts sin LVM o sin permisos elevados

**Características**

* Disco virtual autocontenido
* Fácil copia, backup y migración
* Rendimiento ligeramente inferior

---

## 3) Inputs (parámetros controlados)

### 3.1 Parámetros comunes

* **Tamaño objetivo**: p. ej. `5G`
* **Sistema de archivos**: `ext4`
* **Punto de montaje**: `/mnt/docker_vol`
* **Uso previsto**: volumen Docker (`-v host:container`)

---

### 3.2 Inputs específicos

#### LVM

* Volume Group existente (ej.: `vg0`)
* Permisos root
* LVM activo en el sistema

#### `.img`

* Ruta del archivo (ej.: `/opt/docker_vol.img`)
* Espacio disponible en el filesystem host
* Soporte de loop devices (`losetup`)

---

## 4) Equipamiento mínimo (dependencias)

* Linux con soporte ext4
* `mount`, `mkfs.ext4`
* Docker
* Para LVM: `lvm2`
* Para `.img`: soporte loop (`losetup`)

---

## 5) Condiciones previas (pre-flight)

1. Confirmar espacio suficiente en el host.
2. Definir tamaño **antes** de crear el volumen (no dinámico).
3. Confirmar que el punto de montaje no esté en uso.
4. Verificar permisos root.
5. Detener contenedores que puedan reutilizar el path.

---

## 6) Flujo de ejecución — Opción A: **LVM real**

### Estado A1 — Creación del volumen lógico

```bash
lvcreate -L 5G -n docker_vol vg0
```

**Resultado esperado**

* `/dev/vg0/docker_vol` existe
* Tamaño fijo e inmutable salvo resize explícito

---

### Estado A2 — Formateo

```bash
mkfs.ext4 /dev/vg0/docker_vol
```

**Propósito**

* Inicializar el bloque con FS controlado

---

### Estado A3 — Preparación del punto de montaje

```bash
mkdir -p /mnt/docker_vol
```

---

### Estado A4 — Montaje

```bash
mount /dev/vg0/docker_vol /mnt/docker_vol
```

**Señal observable**

```bash
df -h /mnt/docker_vol
```

Debe mostrar **exactamente 5G**.

---

### Estado A5 — Uso en Docker

```bash
docker run -v /mnt/docker_vol:/data imagen
```

**Garantía**

* El contenedor no puede exceder 5 GB bajo ninguna circunstancia.

---

## 7) Flujo de ejecución — Opción B: **Archivo `.img` en loop**

### Estado B1 — Creación del archivo-disco

```bash
truncate -s 5G /opt/docker_vol.img
```

**Propósito**

* Definir límite físico desde el inicio

---

### Estado B2 — Formateo del archivo

```bash
mkfs.ext4 /opt/docker_vol.img
```

---

### Estado B3 — Preparación del punto de montaje

```bash
mkdir -p /mnt/docker_vol
```

---

### Estado B4 — Montaje por loop

```bash
mount -o loop /opt/docker_vol.img /mnt/docker_vol
```

**Verificación**

```bash
df -h /mnt/docker_vol
```

Debe reflejar **5G exactos**.

---

### Estado B5 — Uso en Docker

```bash
docker run --rm -it -v /mnt/docker_vol:/opt/data alpine:3.20 sh
df -h /opt/data
```

**Resultado**

* Límite impuesto por el tamaño del `.img`.

---

### Estado B6 — Desmontaje y limpieza (opcional)

```bash
umount /mnt/docker_vol
losetup -D
```

---

## 8) Control de calidad (postcondiciones)

Validar siempre:

* `df -h` refleja el tamaño esperado
* Escrituras fallan al alcanzar el límite (ENOSPC)
* Docker no sobrepasa el cap
* No hay mounts huérfanos

---

## 9) Diagnóstico rápido (troubleshooting)

| Síntoma                    | Causa probable                   | Acción             |
| -------------------------- | -------------------------------- | ------------------ |
| Docker ignora el límite    | Volumen no montado correctamente | Revisar `mount`    |
| Tamaño incorrecto          | Error en `truncate` o `lvcreate` | Re-crear           |
| `device busy` al desmontar | Contenedor activo                | Detener contenedor |
| Bajo rendimiento           | Loop FS                          | Preferir LVM       |

---

## 10) Procedimiento compacto (referencia rápida)

**LVM**

1. `lvcreate -L 5G`
2. `mkfs.ext4`
3. `mount`
4. `docker -v`

**IMG**

1. `truncate -s 5G`
2. `mkfs.ext4`
3. `mount -o loop`
4. `docker -v`

---

## 11) Conclusión operativa

* **LVM** → producción, control fuerte, menor portabilidad.
* **`.img` loop** → portable, simple, autocontenido.

Ambos cumplen el objetivo; la elección depende del **contexto operativo**, no de preferencia personal.