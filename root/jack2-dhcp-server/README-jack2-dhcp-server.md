# jack2-dhcp-server — Servidor DHCP

Módulo de servidor DHCP basado en `dnsmasq`. Permite configurar un scope DHCP completo (rango de IPs, gateway, DNS) en cualquier interfaz. La configuración se persiste en `/opt/jack2/` y se recarga en el boot.

---

## Archivos del módulo

```
/root/jack2-dhcp-server/
├── jack2-dhcp-server.sh     ← menú interactivo principal
├── dhcp-server.sh           ← aplica la configuración (boot y reload)
├── set-dhcp-server          ← script de configuración (helper)
├── disable-dhcp-server      ← deshabilita el servidor
└── show-dhcp-server-config.sh ← muestra la configuración activa formateada
```

**Archivo de configuración persistente:**

```
/opt/jack2/jack2-dhcp-server.conf   ← comando dnsmasq completo con todos los parámetros
/var/spool/dnsmasq.leases           ← leases activos (generado por dnsmasq)
```

---

## Comandos del menú

```
jack2-dhcp-server:~#>
```

| Comando | Función |
|---|---|
| `set-dhcp-server` | Configura el scope DHCP (interfaz, rango, gateway, DNS) |
| `disable-dhcp-server` | Desactiva el servidor DHCP (vacía el archivo de config) |
| `show-dhcp-server-config` | Muestra la configuración activa con formato legible |
| `show-leases` | Muestra los leases DHCP activos |
| `reload` | Reinicia dnsmasq con la configuración actual |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `set-dhcp-server`

```
Listen Address    → IP de la interfaz donde escucha el servidor (ej: 192.168.1.1)
IP Range Start    → primera IP del rango (ej: 192.168.1.100)
IP Range End      → última IP del rango (ej: 192.168.1.200)
IP Range Netmask  → máscara del rango (ej: 255.255.255.0)
IP Range Router   → gateway que se entrega a los clientes
IP Range DNS      → servidor DNS que se entrega a los clientes
```

---

## Comando `dnsmasq` generado

```bash
dnsmasq -K -z \
    -i eth0 \
    -a 192.168.1.1 \
    -l /var/spool/dnsmasq.leases \
    -x 9999 \
    --dhcp-option=6,8.8.8.8 \
    --dhcp-option=3,192.168.1.1 \
    --dhcp-range=192.168.1.100,192.168.1.200,255.255.255.0,infinite
```

Donde:
- `-K` → no carga configuración de `/etc/dnsmasq.conf`
- `-z` → no escucha en todas las interfaces
- `-i` → interfaz específica
- `-a` → dirección de escucha
- `-l` → archivo de leases
- `-x 9999` → PID file
- `--dhcp-option=6` → DNS
- `--dhcp-option=3` → Gateway (router)
- `infinite` → leases sin expiración

---

## Cómo funciona `dhcp-server.sh` (boot y reload)

```bash
# 1. Termina dnsmasq si está corriendo
killall dnsmasq
PID_DHCP=$(pidof dnsmasq)
kill -9 $PID_DHCP

# 2. Aplica la configuración guardada
sleep 1
sh /opt/jack2/jack2-dhcp-server.conf
```

---

## `show-leases`

```bash
cat /var/spool/dnsmasq.leases
```

Formato: `timestamp MAC IP hostname *`

```
1234567890 aa:bb:cc:dd:ee:ff 192.168.1.105 pc-oficina *
1234567891 11:22:33:44:55:66 192.168.1.106 laptop-sala *
```

---

## Manejo de alias de interfaz

Si la `listen address` configurada corresponde a un alias (ethX:N) en lugar de una interfaz física, el módulo detecta esto automáticamente y agrega comandos adicionales para bajar el alias antes de configurar la interfaz física:

```bash
ifconfig eth0:47 down
ifconfig eth0:47 0
ifconfig eth0:47 up
ifconfig eth0 192.168.1.1 netmask 255.255.255.0 up
dnsmasq -K -z -i eth0 -a 192.168.1.1 ...
```

---

## Notas técnicas

**Un scope por appliance:** JACK2 gestiona un scope DHCP activo a la vez. Para múltiples scopes en distintas interfaces se requeriría múltiples instancias de dnsmasq, lo cual está fuera del alcance de esta versión.

**`disable-dhcp-server`:** vacía el archivo `/opt/jack2/jack2-dhcp-server.conf`, lo que hace que `dhcp-server.sh` en el próximo boot no lance dnsmasq.
