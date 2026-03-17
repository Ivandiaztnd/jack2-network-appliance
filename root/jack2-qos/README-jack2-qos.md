# jack2-qos — QoS / Traffic Shaping

Módulo de gestión de calidad de servicio (QoS) usando `tc` (iproute2) con disciplinas HTB (Hierarchical Token Bucket). Permite limitar y garantizar ancho de banda por interfaz, IP, red, protocolo o puerto, con persistencia automática.

---

## Archivos del módulo

```
/root/jack2-qos/
├── jack2-qos.sh   ← menú interactivo principal
├── qos.sh         ← aplica todas las reglas QoS (boot y reload)
└── numqos.sh      ← lista numerada de reglas con estados
```

**Archivos de configuración persistente:**

```
/opt/jack2/jack2-qos.conf           ← reglas QoS (formato interno JACK2)
/opt/jack2/jack2-qos-default.conf   ← política default por interfaz
```

---

## Comandos del menú

```
jack2-qos:~#>
```

| Comando | Función |
|---|---|
| `add-qos-rule` | Crea una regla de QoS |
| `del-qos-rule` | Elimina una regla por número |
| `show-qos-rules` | Lista las reglas guardadas (ENABLED/DISABLED) |
| `show-active-qos` | Estado real del sistema: qdiscs, clases y filtros activos |
| `set-default-policy` | Define política default por interfaz |
| `show-default-policy` | Muestra la política default configurada |
| `reload` | Recarga todas las reglas desde el archivo de configuración |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-qos-rule`

```
Interface          → interfaz de salida (ej: eth0, eth1, ppp0)
Bandwidth total    → ancho de banda total de la interfaz en kbps (ej: 1024)
Tipo de cola       → htb (default), pfifo, sfq
Source Address     → IP/CIDR origen (Enter = any)
Destination Address → IP/CIDR destino (Enter = any)
Protocol           → tcp, udp (Enter = any)
Puerto Destino     → número de puerto (Enter = any)
Prioridad          → 1=alta, 3=media (default), 5=baja
Rate garantizado   → kbps garantizados para esta clase
Rate máximo        → kbps máximo en burst para esta clase
Comentario         → texto libre
```

---

## Formato de configuración interna

Las reglas se guardan en `/opt/jack2/jack2-qos.conf` con un formato propio de JACK2:

```
tc-htb eth0 bw:1024 rate:256 ceil:1024 prio:3 src:192.168.1.0/24 dst:any #Usuarios LAN
tc-htb eth0 bw:1024 rate:512 ceil:1024 prio:1 dport:80 proto:tcp #HTTP prioritario
```

El script `qos.sh` parsea este formato y genera los comandos `tc` correspondientes.

---

## Cómo funciona `qos.sh` (boot y reload)

```bash
# 1. Limpia todas las qdiscs existentes en todas las interfaces activas
for iface in $(ifconfig | grep "Link encap" | awk '{print $1}' | grep -v lo); do
    tc qdisc del dev $iface root 2>/dev/null
done

# 2. Por cada regla en jack2-qos.conf:
#    a. Crea qdisc HTB root con clase default (tráfico no clasificado → clase 99)
tc qdisc add dev eth0 root handle 1: htb default 99

#    b. Crea clase raíz con el ancho de banda total
tc class add dev eth0 parent 1: classid 1:1 htb rate 1024kbit

#    c. Crea subclase con rate garantizado y ceil máximo
tc class add dev eth0 parent 1:1 classid 1:N htb rate 256kbit ceil 1024kbit prio 3

#    d. Crea filtro u32 para clasificar el tráfico hacia esta clase
tc filter add dev eth0 parent 1: protocol ip prio 3 u32 \
    match ip src 192.168.1.0/24 \
    flowid 1:N
```

**`default 99`:** el tráfico que no coincide con ningún filtro va a la clase 99, que recibe el ancho de banda residual. Nunca hay bloqueo involuntario de tráfico no clasificado.

---

## Visualización de reglas (`numqos.sh`)

```
[QoS RULES]

[ENABLED]
1 | tc-htb eth0 bw:1024 rate:256 ceil:1024 prio:3 src:192.168.1.0/24 #Usuarios LAN
2 | tc-htb eth0 bw:1024 rate:512 ceil:1024 prio:1 dport:80 proto:tcp #HTTP

[DISABLED]
(ninguna)
```

---

## `show-active-qos`

Muestra el estado real del subsistema QoS del kernel en tres secciones:

```bash
tc qdisc show    # qdiscs activas
tc class show    # clases HTB activas
tc filter show   # filtros de clasificación activos
```

---

## `set-default-policy`

Configura la política para tráfico no clasificado por interfaz. Se guarda en `/opt/jack2/jack2-qos-default.conf`:

```
default-policy eth0 bw:128
```

Garantiza que el tráfico que no coincide con ninguna regla tenga al menos 128 kbps disponibles.

---

## Notas técnicas

**Handles con `$RANDOM`:** cada regla genera un handle ID aleatorio (1-99) para su clase HTB. Esto puede causar colisiones si se agregan muchas reglas en la misma interfaz. Para JACK2 v2, se recomienda un sistema de asignación secuencial.

**Kernel HTB:** requiere soporte de `CONFIG_NET_SCH_HTB` en el kernel (presente en 2.6.18). Universalmente soportado en todos los kernels Linux modernos.
