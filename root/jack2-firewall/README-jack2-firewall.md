# jack2-firewall — Gestión de Firewall iptables

Módulo completo de gestión de firewall con iptables. Administra las cuatro capas de forma independiente: reglas filter (INPUT/OUTPUT/FORWARD), SNAT, DNAT y MASQUERADE. Toda configuración se persiste automáticamente y se recarga en el boot.

---

## Archivos del módulo

```
/root/jack2-firewall/
├── jack2-firewall.sh   ← menú interactivo principal
├── fw.sh               ← aplica toda la configuración (boot y reload)
├── nat.sh              ← aplica solo las reglas NAT
├── setup-firewall.sh   ← inicializa la estructura de archivos en /opt/jack2/
├── del-rule.sh         ← helper para eliminación de reglas
├── numrules.sh         ← lista numerada de reglas filter
├── numsnat.sh          ← lista numerada de reglas SNAT
├── numdnat.sh          ← lista numerada de reglas DNAT
├── nummasq.sh          ← lista numerada de reglas MASQUERADE
└── protocols.dat       ← referencia de protocolos IP (para show-protocols)
```

**Archivos de configuración persistente:**

```
/opt/jack2/jack2-firewall.pre    ← pre-reglas: módulos kernel, flush, políticas default
/opt/jack2/jack2-firewall.conf   ← reglas iptables filter (INPUT/OUTPUT/FORWARD)
/opt/jack2/jack2-firewall.snat   ← reglas SNAT (POSTROUTING)
/opt/jack2/jack2-firewall.dnat   ← reglas DNAT (PREROUTING)
/opt/jack2/jack2-firewall.masq   ← reglas MASQUERADE (POSTROUTING)
/opt/jack2/jack2-firewall.post   ← post-regla: política de bloqueo final
```

---

## Comandos del menú

```
jack2-firewall:~#>
```

| Comando | Función |
|---|---|
| `add-rule` | Agrega regla filter (INPUT/OUTPUT/FORWARD) |
| `del-rule` | Elimina regla filter por número |
| `edit-rules` | Edita una regla filter existente |
| `printfile-rules` | Lista numerada de reglas filter guardadas |
| `print-active-rules` | Estado actual de la tabla filter en el kernel |
| `add-snat` / `del-snat` / `edit-snat` | Gestión de Source NAT |
| `add-dnat` / `del-dnat` / `edit-dnat` | Gestión de Destination NAT / Port Forward |
| `add-masq` / `del-masq` / `edit-masq` | Gestión de Masquerading |
| `printfile-snat/dnat/masq` | Listas numeradas de reglas NAT guardadas |
| `print-active-nat` | Estado actual de la tabla nat en el kernel |
| `print-active-mangle` | Estado actual de la tabla mangle en el kernel |
| `show-connections` | Conexiones activas (`netstat -puta`) |
| `show-all-rules` | Vista consolidada: SNAT + MASQ + DNAT + FILTER |
| `show-protocols` | Tabla de referencia de protocolos IP |
| `reload` | Recarga toda la configuración desde `/opt/jack2/` |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-rule`

El asistente interactivo solicita campo por campo, todos opcionales salvo la chain:

```
Ubicación        → ARRIBA (default, -I) o ABAJO (-A)
Chain            → INPUT, OUTPUT o FORWARD
Protocolo        → tcp, udp, icmp, etc. (Enter = cualquiera)
Source Port      → puerto origen (solo si protocolo es tcp o udp)
Dest Port        → puerto destino (solo si protocolo es tcp o udp)
Source Address   → IP/CIDR origen (Enter = any)
Dest Address     → IP/CIDR destino (Enter = any)
IN interface     → interfaz entrada (para INPUT y FORWARD)
OUT interface    → interfaz salida (para OUTPUT y FORWARD)
Action           → ACCEPT, REJECT o DROP (default: ACCEPT)
State            → NEW, ESTABLISHED, INVALID, RELATED
                   (default: NEW,ESTABLISHED,INVALID,RELATED)
Comentario       → texto libre (guardado con -m comment --comment)
```

El sistema construye el comando iptables, lo muestra y pide confirmación antes de aplicar.

---

## Orden de carga del firewall (`fw.sh`)

```bash
sh /opt/jack2/jack2-firewall.pre    # 1. módulos kernel + flush + políticas default ACCEPT
sh /opt/jack2/jack2-firewall.conf   # 2. reglas filter acumuladas
sh /opt/jack2/jack2-firewall.snat   # 3. reglas SNAT
sh /opt/jack2/jack2-firewall.dnat   # 4. reglas DNAT
sh /opt/jack2/jack2-firewall.masq   # 5. reglas MASQUERADE
sh /opt/jack2/jack2-firewall.post   # 6. política final (ej: DROP todo lo no matcheado)
```

El contenido inicial de `jack2-firewall.pre` generado por `setup-firewall.sh`:

```bash
#!/bin/bash

# Forwarding de paquetes
echo "1" > /proc/sys/net/ipv4/ip_forward

# Módulos de iptables
modprobe ip_tables
modprobe ip_conntrack
modprobe iptable_filter
modprobe iptable_mangle
modprobe iptable_nat
modprobe ipt_LOG
modprobe ipt_limit
modprobe ipt_MASQUERADE
modprobe ipt_state

# Reglas por default — flush y políticas permisivas
iptables -t mangle -F
iptables -t filter -F
iptables -t mangle -X
iptables -t filter -X

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
```

El `jack2-firewall.post` inicial contiene la política de cierre:

```bash
iptables -A INPUT -p tcp -j DROP -m comment --comment ' bloquear todo '
```

---

## Sistema de numeración de reglas

Cada archivo de configuración (`.conf`, `.snat`, `.dnat`, `.masq`) almacena los comandos iptables directamente, uno por línea. Los scripts `numrules.sh`, `numsnat.sh`, `numdnat.sh` y `nummasq.sh` generan una vista numerada usando `cat -n` + `sed`:

```
[FILTER RULES]
1 | iptables -I INPUT -p tcp --dport 22 -j ACCEPT -m state --state NEW,ESTABLISHED -m comment --comment ' SSH '
2 | iptables -I FORWARD -i eth0 -o eth1 -j ACCEPT -m state --state ESTABLISHED,RELATED
3 | iptables -A INPUT -p tcp -j DROP -m comment --comment ' bloquear todo '
```

El número es la referencia para `del-rule`, `edit-rules`, `del-snat`, etc.

---

## Flujo de edición de regla (`edit-rules`)

```
1. Muestra todas las reglas numeradas
2. Admin ingresa número de regla y chain (INPUT/OUTPUT/FORWARD)
3. Admin ingresa los nuevos parámetros de la regla
4. Sistema muestra: reglas restantes + regla a reemplazar + regla nueva
5. Confirmación (S/N)
6. Si S:
   a. Filtra el archivo excluyendo la regla vieja → rules.tmp
   b. Agrega la regla nueva al final de rules.tmp
   c. Ordena por número de línea (sort -n)
   d. Reemplaza jack2-firewall.conf con el resultado
   e. Recarga: pre → conf → post
```

---

## Notas técnicas

**Firewall siempre al final del boot:** en `servicios.conf`, `fw.sh` es el último script que se ejecuta. Esto garantiza que cuando el firewall se aplica, todas las interfaces están configuradas, todos los servicios están activos y las rutas están establecidas.

**Efecto inmediato + persistencia:** cada operación (add, del, edit) primero aplica el cambio en el kernel en tiempo real, luego persiste el resultado en `/opt/jack2/`. Nunca hay estado inconsistente entre lo que está activo y lo que se guardó.

**ip_forward habilitado en pre:** el archivo `jack2-firewall.pre` habilita el forwarding de paquetes (`/proc/sys/net/ipv4/ip_forward=1`), lo que activa el comportamiento de router necesario para NAT, FORWARD y balanceo de carga.
