# jack2-dhcp-client — Cliente DHCP

Módulo para configurar interfaces del appliance como clientes DHCP. Permite obtener configuración de red automáticamente desde un servidor DHCP externo. Usa `dhcpcd` como cliente. Soporta múltiples clientes DHCP simultáneos en distintas interfaces.

---

## Archivos del módulo

```
/root/jack2-dhcp-client/
├── jack2-dhcp-client.sh   ← menú interactivo principal
├── dhcp-client.sh         ← aplica la configuración (boot y reload)
└── numdhcpc.sh            ← lista numerada de clientes configurados
```

**Archivo de configuración persistente:**

```
/opt/jack2/jack2-dhcp-client.conf   ← comandos dhcpcd por interfaz (uno por línea)
```

---

## Comandos del menú

```
jack2-dhcp-client:~#>
```

| Comando | Función |
|---|---|
| `add-dhcp-client` | Configura una interfaz como cliente DHCP |
| `del-dhcp-client` | Elimina un cliente DHCP |
| `show-dhcp-clients` | Muestra los procesos dhcpcd activos |
| `printfile-dhcp-clients` | Lista numerada de clientes configurados |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-dhcp-client`

```
Interface  → interfaz física donde solicitar IP por DHCP (ej: eth0, eth1)
```

El sistema genera un alias `ethX:N` (con N aleatorio) para no interferir con la IP estática de la interfaz si existe:

```bash
# En /opt/jack2/jack2-dhcp-client.conf:
dhcpcd eth0:142
```

---

## Cómo funciona `dhcp-client.sh` (boot y reload)

```bash
# 1. Termina todos los procesos dhcpcd activos
killall dhcpcd-bin

# 2. Aplica la configuración guardada
sh /opt/jack2/jack2-dhcp-client.conf
```

---

## `show-dhcp-clients`

Muestra los procesos `dhcpcd-bin` activos:

```bash
ps ax | grep /sbin/dhcpcd-bin | grep -v grep | \
    sed s/"\/sbin"/"| \/sbin"/g | cut -d "|" -f2
```

---

## Notas técnicas

**Coexistencia con IPs estáticas:** al usar un alias `ethX:N`, el cliente DHCP puede obtener una IP dinámica en la misma interfaz física que ya tiene una IP estática configurada por `jack2-interfaces`. Ambas coexisten en la misma interfaz.

**`dhcpcd` vs `dhclient`:** JACK2 usa `dhcpcd` (Debian Etch incluía `dhcpcd` como cliente DHCP por defecto antes de que `dhclient` se volviera estándar).
