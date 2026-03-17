# jack2-pptp-client — VPN PPTP Cliente

Módulo para configurar el appliance como cliente VPN PPTP. Permite conectarse a servidores PPTP externos (incluyendo otros appliances JACK2 con `jack2-pptp-server`). Cada conexión crea una interfaz `ppp777N`.

---

## Archivos del módulo

```
/root/jack2-pptp-client/
├── jack2-pptp-client.sh   ← menú interactivo principal
├── pptp-client.sh         ← aplica la configuración (boot y reload)
├── vpn.sh                 ← script de conexión manual (referencia)
├── numpptpclient.sh       ← lista numerada de conexiones configuradas
└── numuserpptpclient.sh   ← lista numerada de usuarios PPTP client
```

**Archivos de configuración persistente:**

```
/opt/jack2/jack2-pptp-client.conf   ← comandos pptp por conexión
/etc/ppp/chap-secrets               ← credenciales (compartido con pptp-server)
```

---

## Comandos del menú

```
jack2-pptp-client:~#>
```

| Comando | Función |
|---|---|
| `add-pptp-client` | Agrega una conexión VPN PPTP |
| `del-pptp-client` | Elimina una conexión y sus credenciales |
| `show-active-clients` | Muestra conexiones PPTP activas con sus IPs |
| `show-pptp-clients` | Lista las conexiones configuradas |
| `show-pptp-users` | Lista los usuarios/credenciales guardados |
| `reload` | Reconecta todas las conexiones |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-pptp-client`

```
PPTP Server Address  → IP o hostname del servidor PPTP
User                 → nombre de usuario
Password             → contraseña
```

El sistema genera un número único (`$RANDOM % 255`) para la unidad PPP (`unit 777N`), evitando colisiones entre múltiples conexiones simultáneas.

**Lo que se guarda:**

```bash
# En /opt/jack2/jack2-pptp-client.conf:
pptp 200.1.1.1 remotename 200.1.1.1 name usuario1 noauth debug unit 777142

# En /etc/ppp/chap-secrets:
usuario1  *  password123  *  # pptp-client-user 142
```

---

## Cómo funciona `pptp-client.sh` (boot y reload)

```bash
# 1. Termina todas las conexiones pptp activas
killall pptp

# 2. Ejecuta el archivo de configuración (lanza las nuevas conexiones)
sh /opt/jack2/jack2-pptp-client.conf
```

---

## `show-active-clients`

Muestra las interfaces `ppp777N` activas con sus IPs asignadas:

```bash
ip addr | grep ppp777 | grep inet | \
    sed s/"inet"/"pptp IP"/g | \
    sed s/"peer"/"pptp-server"/g | \
    sed s/"scope global"/"pptp Iface"/g
```

Salida ejemplo:
```
pptp IP 192.168.0.100 pptp-server 192.168.0.1 pptp Iface ppp7771
```

---

## Coexistencia con `jack2-pptp-server`

Ambos módulos comparten `/etc/ppp/chap-secrets`. Las entradas se distinguen por el comentario al final de cada línea:
- Clientes: `# pptp-client-user N`
- Servidor: `# pptp-server-user`

Al eliminar entradas, cada módulo filtra solo sus propias entradas usando ese comentario como selector.
