# jack2-pptp-server — VPN PPTP Servidor

Módulo para configurar el appliance como servidor VPN PPTP. Permite que clientes remotos (Windows, Linux, otros JACK2) se conecten a la red local a través de un túnel PPTP. Usa `pptpd` como daemon servidor.

---

## Archivos del módulo

```
/root/jack2-pptp-server/
├── jack2-pptp-server.sh  ← menú interactivo principal
├── pptp-server.sh        ← reinicia pptpd (boot y reload)
├── numpptpserver.sh      ← lista numerada de usuarios del servidor
└── show-pptp-users.sh    ← muestra usuarios con formato legible
```

**Archivos de configuración persistente:**

```
/etc/pptpd.conf          ← configuración del daemon pptpd (IP local + rango)
/etc/ppp/pptpd-options   ← opciones PPP para conexiones PPTP
/etc/ppp/chap-secrets    ← usuarios y contraseñas (compartido con pptp-client)
```

---

## Comandos del menú

```
jack2-pptp-server:~#>
```

| Comando | Función |
|---|---|
| `set-range-ip` | Configura IP local del servidor y rango de IPs para clientes |
| `show-range-ip` | Muestra la configuración de IPs activa |
| `add-pptp-user` | Agrega un usuario VPN |
| `del-pptp-user` | Elimina un usuario |
| `show-pptp-users` | Lista todos los usuarios configurados |
| `show-active-users` | Muestra conexiones PPTP activas en tiempo real |
| `reload` | Reinicia pptpd |
| `exit` | Vuelve al menú principal |

---

## Configuración de `set-range-ip`

```
Local IP       → IP del appliance en el túnel PPTP (ej: 192.168.0.1)
IP Range       → rango de IPs para clientes (ej: 192.168.0.234-238,192.168.0.245)
```

Genera `/etc/pptpd.conf`:

```
option /etc/ppp/pptpd-options
logwtmp
localip 192.168.0.1
remoteip 192.168.0.234-238,192.168.0.245
```

Y `/etc/ppp/pptpd-options`:

```
name pptpd
require-mschap-v2
require-mschap
nodefaultroute
lock
nobsdcomp
```

---

## Agregar usuarios (`add-pptp-user`)

```
User       → nombre de usuario
Password   → contraseña
IP Type    → static (IP fija) o dynamic (asignada del rango)
IP Address → solo si IP Type = static
```

Entrada en `/etc/ppp/chap-secrets`:

```
# Usuario con IP dinámica:
usuario1 pptpd password123 * # pptp-server-user

# Usuario con IP estática:
usuario2 pptpd password456 192.168.0.200 # pptp-server-user
```

---

## Visualización de usuarios (`show-pptp-users`)

```
1 | USER usuario1  PASSWORD password123  IpAddress {DYNAMIC}
2 | USER usuario2  PASSWORD password456  IpAddress 192.168.0.200
```

El `*` en chap-secrets se traduce a `{DYNAMIC}` en la visualización.

---

## Cómo funciona `pptp-server.sh`

```bash
killall pptpd
rm -f /var/run/pptpd.pid
sleep 1
/etc/init.d/pptpd start
```

---

## `show-active-users`

```bash
ip addr | grep ppp | grep inet
```

Muestra las interfaces PPP activas con las IPs asignadas a cada cliente conectado en tiempo real.

---

## Notas técnicas

**Cifrado:** la configuración usa `require-mschap-v2` y `require-mschap` pero no `require-mppe-128` (comentado en la configuración original). Para habilitar cifrado MPPE en los túneles, descomentar esa línea y asegurarse que el módulo `ppp-mppe` esté cargado.

**Coexistencia con `jack2-pptp-client`:** ambos módulos comparten `/etc/ppp/chap-secrets`. Las entradas del servidor llevan el comentario `# pptp-server-user` y las del cliente `# pptp-client-user N`. Cada módulo opera solo sobre sus propias entradas.

**`logwtmp`:** habilitado en `pptpd.conf`, registra las conexiones en el log del sistema (`/var/log/wtmp`), visible con `last`.
