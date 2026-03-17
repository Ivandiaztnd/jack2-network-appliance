# jack2-pppoe-client — Cliente PPPoE / ADSL

Módulo para configurar conexiones ADSL/PPPoE. Permite agregar múltiples conexiones PPPoE simultáneas en diferentes interfaces físicas. Cada conexión crea una interfaz `ppp999N`.

---

## Archivos del módulo

```
/root/jack2-pppoe-client/
├── jack2-pppoe-client.sh  ← menú interactivo principal
├── pppoe-client.sh        ← aplica la configuración (boot y reload)
├── gw.sh                  ← detecta y agrega la ruta default del gateway PPPoE
└── numpppoe.sh            ← lista numerada de conexiones configuradas
```

**Archivos de configuración persistente:**

```
/opt/jack2/jack2-pppoe-client.conf     ← comandos "pon adsl-ethX" por conexión
/opt/jack2/pppoe-client.<iface>        ← archivo de opciones PPP por interfaz
/etc/ppp/peers/adsl-<iface>            ← archivo de peer pppd (copia del anterior)
/etc/ppp/chap-secrets                  ← credenciales ADSL
```

---

## Comandos del menú

```
jack2-pppoe-client:~#>
```

| Comando | Función |
|---|---|
| `add-pppoe-client` | Configura una nueva conexión PPPoE |
| `del-pppoe-client` | Elimina una conexión y sus credenciales |
| `show-connections` | Muestra conexiones PPPoE activas (`ppp999N`) |
| `printfile-pppoe-client` | Lista numerada de conexiones configuradas |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-pppoe-client`

```
Interface        → interfaz física donde está el modem ADSL (ej: eth0, eth1)
User             → usuario ISP
Password         → contraseña ISP
Add default route → Y/N — agrega ruta default via PPPoE
Use peers DNS    → Y/N — usa los DNS del ISP
```

---

## Archivos generados por conexión

Para una conexión en `eth0` con usuario `usuario@isp.com`:

```bash
# /opt/jack2/pppoe-client.eth0 (y /etc/ppp/peers/adsl-eth0):
lock
debug
asyncmap 0
holdoff 10
idle 10
lcp-echo-interval 2
lcp-echo-failure 7
lcp-max-configure 30
noipdefault
hide-password
noauth
persist
maxfail 0
plugin rp-pppoe.so eth0
unit 99947              # número aleatorio para la interfaz ppp999N
user "usuario@isp.com"
defaultroute            # si se seleccionó Y
usepeerdns             # si se seleccionó Y
```

```bash
# En /opt/jack2/jack2-pppoe-client.conf:
pon adsl-eth0

# En /etc/ppp/chap-secrets:
"usuario@isp.com"  ""  "password123"  ""  # adsl-eth0
```

---

## Cómo funciona `pppoe-client.sh` (boot y reload)

```bash
# 1. Mata procesos pppd/pon activos de conexiones ADSL
PID_ADSL=$(ps fax | grep adsl- | grep -v grep | awk '{print $1}')
for pid in $PID_ADSL; do kill -9 $pid; done

# 2. Baja y sube las interfaces físicas para resetear el modem
INTERFACES=$(cat /opt/jack2/jack2-pppoe-client.conf | sed s/"pon adsl-"/""/g)
for iface in $INTERFACES; do
    ifconfig $iface down
    ifconfig $iface up
done

# 3. Lanza todas las conexiones PPPoE
sh /opt/jack2/jack2-pppoe-client.conf
```

---

## `gw.sh` — detección automática de gateway

Después de establecer la conexión PPPoE, el gateway asignado por el ISP aparece en los logs de pppd. El script `gw.sh` lo extrae y agrega la ruta default:

```bash
# Extrae la IP del gateway PPPoE de /var/log/messages
GWIP=$(tail -n 100 /var/log/messages | grep pppd | grep "remote IP address" | \
       cut -d ":" -f4 | sed s/" remote IP address "/""/g | sort | uniq)

# Detecta la interfaz ppp asociada
PPPiface=$(ip r l | grep $GWIP | sed s/"dev "/":" /g | cut -d ":" -f2)

# Agrega la ruta default
ip route add 0.0.0.0/0 via $GWIP dev $PPPiface
```

---

## `show-connections`

```bash
ifconfig | grep "ppp999" | \
    sed s/"encap:Point-to-Point Protocol"/""/g | \
    sed s/"ppp999"/"Adsl-"/g
```

Muestra las interfaces ADSL activas con sus IPs asignadas.

---

## Notas técnicas

**`persist` y `maxfail 0`:** la configuración habilita reconexión automática permanente. Si la conexión ADSL cae, `pppd` intenta reconectarse indefinidamente con un holdoff de 10 segundos entre intentos.

**Múltiples conexiones:** se pueden agregar conexiones PPPoE en distintas interfaces físicas simultáneamente (eth0, eth1, eth2). Cada una tiene su propia unidad `ppp999N` y aparece como una interfaz independiente.
