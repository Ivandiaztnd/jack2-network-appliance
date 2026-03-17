# jack2-ipsec — VPN IPSec (OpenSwan)

Módulo de gestión de túneles VPN IPSec usando OpenSwan. Permite crear túneles site-to-site con autenticación por Pre-Shared Key (PSK). Cada conexión tiene su propio archivo de configuración en `/opt/jack2/`.

---

## Archivos del módulo

```
/root/jack2-ipsec/
├── jack2-ipsec.sh    ← menú interactivo principal
├── ipsec.sh          ← reinicia el servicio OpenSwan (boot y reload)
├── numipsec.sh       ← lista numerada de conexiones con PSKs
└── show-pptp-users.sh ← helper para mostrar usuarios PPTP (compartido)
```

**Archivos de configuración persistente:**

```
/opt/jack2/ipsec.<nombre>.conf   ← un archivo por conexión IPSec
/etc/ipsec.secrets               ← PSKs (Pre-Shared Keys) de todas las conexiones
/opt/jack2/ipsec.DEFAULT.conf    ← plantilla de configuración base
/opt/jack2/ipsec.prescript.sh    ← script ejecutado antes de iniciar IPSec en boot
```

---

## Comandos del menú

```
jack2-ipsec:~#>
```

| Comando | Función |
|---|---|
| `add-connection` | Crea un nuevo túnel IPSec site-to-site |
| `del-connection` | Elimina un túnel y su PSK |
| `show-connections` | Muestra el estado de los túneles activos |
| `show-config` | Muestra la configuración de todas las conexiones |
| `show-PSKs` | Lista las PSKs configuradas en `/etc/ipsec.secrets` |
| `reload` | Reinicia el servicio OpenSwan |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-connection`

```
Connection Name    → nombre único sin espacios (ej: oficina-sucursal1)
Left IP            → IP local del tunnel endpoint (este appliance)
Left Subnet        → subred local a proteger (ej: 192.168.1.0/24)
Left Nexthop       → gateway local (%direct, %defaultroute, o IP)
Right IP           → IP remota del tunnel endpoint (otro extremo)
Right Subnet       → subred remota a proteger (ej: 10.0.0.0/24)
Right Nexthop      → gateway remoto
Pre Shared Key     → contraseña compartida secreta
```

---

## Archivo de configuración generado

Para una conexión llamada `oficina-sucursal1`:

```ini
# /opt/jack2/ipsec.oficina-sucursal1.conf

conn oficina-sucursal1
    left=200.1.1.1
    leftnexthop=%defaultroute
    leftsubnet=192.168.1.0/24
    right=200.2.2.1
    rightnexthop=%defaultroute
    rightsubnet=10.0.0.0/24
    type=tunnel
    authby=secret
    ike=3des-md5-modp1024
    keyingtries=%forever
    auto=start
```

Y en `/etc/ipsec.secrets`:
```
200.1.1.1 200.2.2.1 : PSK "mi_clave_secreta"  #oficina-sucursal1
```

---

## Cómo funciona `ipsec.sh` (boot y reload)

```bash
/etc/init.d/ipsec stop
sleep 1
/etc/init.d/ipsec start
```

OpenSwan carga automáticamente todos los archivos `ipsec.*.conf` desde el directorio configurado en `/etc/ipsec.conf` (include `/opt/jack2/ipsec.*.conf`).

---

## `show-connections`

Usa `ipsec auto --status` para mostrar el estado real de los túneles:

```
oficina-sucursal1: 200.1.1.1...200.2.2.1
sucursal2-remota: 200.1.1.1...200.3.3.1
```

---

## Eliminación de una conexión

Al borrar una conexión:
1. Elimina el archivo `/opt/jack2/ipsec.<nombre>.conf`
2. Elimina la línea correspondiente de `/etc/ipsec.secrets`
3. Reinicia OpenSwan para aplicar el cambio

---

## Notas técnicas

**`ipsec.prescript.sh`:** script que se ejecuta antes de iniciar OpenSwan en el boot (llamado desde `servicios.conf`). Puede contener configuraciones previas necesarias (módulos kernel, rutas especiales, etc.).

**Cifrado:** todas las conexiones usan `3des-md5-modp1024` (IKEv1). Para JACK2 v2, el estándar recomendado es AES-256 con SHA-256 e IKEv2.

**`auto=start`:** cada conexión se inicia automáticamente cuando OpenSwan arranca. El parámetro `keyingtries=%forever` hace que reintente indefinidamente si la conexión falla, garantizando reconexión automática.
