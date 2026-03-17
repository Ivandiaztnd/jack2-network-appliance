# jack2-dnsclient — Configuración de DNS

Módulo para gestionar los servidores DNS del appliance. Administra el archivo `/opt/jack2/network-dns.conf` que se aplica directamente a `/etc/resolv.conf` en el boot. Soporta múltiples servidores DNS.

---

## Archivos del módulo

```
/root/jack2-dnsclient/
├── jack2-dnsclient.sh   ← menú interactivo principal
├── dnsclient.sh         ← aplica la configuración (boot y reload)
└── numdns.sh            ← lista numerada de servidores DNS
```

**Archivo de configuración persistente:**

```
/opt/jack2/network-dns.conf   ← entradas nameserver (formato resolv.conf)
```

---

## Comandos del menú

```
jack2-dnsclient:~#>
```

| Comando | Función |
|---|---|
| `add-dns` | Agrega un servidor DNS |
| `del-dns` | Elimina un servidor DNS por número |
| `show-dns` | Lista los servidores DNS configurados |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-dns`

```
DNS Server Address  → IP del servidor DNS (ej: 8.8.8.8, 200.69.193.1)
```

Agrega una línea al archivo de configuración y la aplica inmediatamente:

```bash
# En /opt/jack2/network-dns.conf:
nameserver 8.8.8.8
nameserver 8.8.4.4
```

---

## Cómo funciona `dnsclient.sh` (boot y reload)

```bash
# Copia el archivo de configuración directamente a resolv.conf
cat /opt/jack2/network-dns.conf > /etc/resolv.conf
```

Es el módulo más simple del sistema: una sola línea de aplicación.

---

## Visualización numerada (`numdns.sh`)

```
[Dns Servers]
1 | nameserver 8.8.8.8
2 | nameserver 8.8.4.4
```

---

## Notas técnicas

**Prioridad sobre otros módulos:** si `jack2-pppoe-client` tiene habilitado `usepeerdns`, los DNS del ISP se escriben en `/etc/resolv.conf` al conectarse, sobreescribiendo los configurados aquí. Para DNS fijos, deshabilitar `usepeerdns` en la configuración PPPoE.

**Orden en `servicios.conf`:** `dnsclient.sh` se ejecuta antes que `pppoe-client.sh` y `pptp-client.sh`, por lo que los DNS estáticos se aplican primero. Las conexiones VPN/PPPoE pueden sobreescribirlos si están configuradas para usar los DNS del servidor remoto.
