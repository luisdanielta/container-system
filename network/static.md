## Estrategia de Control de Tráfico: Docker-User Persistente

### 1. El Diagnóstico
Docker inserta sus reglas de `iptables` al inicio de la cadena. Si intentas bloquear o permitir tráfico en `INPUT` o `FORWARD`, Docker a menudo lo bypassa. La cadena `DOCKER-USER` es el único lugar donde nuestras reglas tienen prioridad sobre el ruteo interno de Docker sin romper su conectividad.

### 2. Definición del Flujo
Necesitamos un puente bidireccional entre la LAN y la subred de Docker:
* **Origen:** `192.168.1.0/24` (Tu red local).
* **Destino:** `10.10.3.0/24` (Tus contenedores).
* **Interfaz:** `enp1s0` (Tu salida física).

### 3. Implementación del Script de Control
No ejecutes comandos sueltos; crea un sistema reproducible. Usaremos `/etc/rc.local` para asegurar que las reglas se reapliquen tras un reinicio, pero con un retraso (`sleep`) para esperar a que el servicio de Docker levante sus propias tablas.

#### Configuración del Script
Crea o edita el archivo: `sudo nano /etc/rc.local`

```bash
#!/bin/bash

sleep 10

/sbin/iptables -F DOCKER-USER

/sbin/iptables -I DOCKER-USER -i enp1s0 -s 192.168.1.0/24 -d 10.10.3.0/24 -j ACCEPT

/sbin/iptables -I DOCKER-USER -o enp1s0 -s 10.10.3.0/24 -d 192.168.1.0/24 -j ACCEPT

# 4. (Opcional) NAT/Masquerade
/sbin/iptables -t nat -A POSTROUTING -s 10.10.3.0/24 -o enp1s0 -j MASQUERADE

/sbin/iptables -A DOCKER-USER -j RETURN

exit 0
```
*Asegúrate de dar permisos de ejecución:* `sudo chmod +x /etc/rc.local`

### 4. Activación del Servicio (Systemd)
En sistemas modernos, `rc.local` está depreciado o desactivado. Vamos a forzar su adopción para que sea el guardián de nuestras reglas.

1.  **Editar la unidad:** `sudo systemctl edit rc-local.service --full`
2.  **Asegurar la sección de instalación:** Al final del archivo, asegúrate de que contenga esto para que el sistema sepa cuándo arrancarlo:
    ```ini
    [Install]
    WantedBy=multi-user.target
    ```
3.  **Habilitar el sistema:**
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable rc-local
    sudo systemctl start rc-local
    ```