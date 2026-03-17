# jack2-mpathroute — Rutas Balanceadas / Multipath Routing

Módulo de balanceo de carga de tráfico saliente usando rutas multipath de iproute2. Permite distribuir el tráfico entre múltiples gateways para una misma subred, incluyendo la ruta default (`0.0.0.0/0`). Útil para balancear múltiples conexiones WAN.

---

## Archivos del módulo

```
/root/jack2-mpathroute/
├── jack2-mpathroute.sh  ← menú interactivo principal
├── mpathroutes.sh       ← aplica todas las rutas balanceadas (boot y reload)
└── nummpathroute.sh     ← lista numerada de archivos de rutas balanceadas
```

**Archivos de configuración persistente:**

```
/opt/jack2/mpathroute-<subnet>.conf   ← un archivo por ruta balanceada
                                         (ej: mpathroute-0.0.0.0-0.conf para default route)
```

Cada ruta balanceada tiene su propio archivo de configuración. El nombre del archivo codifica la subred (los `/` se reemplazan por `-`).

---

## Comandos del menú

```
jack2-mpathrouting:~#>
```

| Comando | Función |
|---|---|
| `add-mpath-route` | Crea una ruta balanceada con múltiples nexthops |
| `del-mpath-route` | Elimina una ruta balanceada y su archivo de configuración |
| `show-route-files` | Lista los archivos de configuración de rutas balanceadas |
| `show-routes-config` | Muestra el contenido de todos los archivos de configuración |
| `show-routes` | Tabla de rutas activa del sistema (`ip route list`) |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-mpath-route`

```
Subnet   → subred destino (ej: 0.0.0.0/0 para default route, 10.0.0.0/8, etc.)
Gateways → lista de gateways en formato gw1:iface1,gw2:iface2,gw3:iface3
           (ej: 200.1.1.1:eth0,200.2.2.1:eth1)
```

---

## Formato del archivo de configuración generado

Para una ruta balanceada default con dos gateways (`200.1.1.1:eth0` y `200.2.2.1:eth1`):

```bash
# /opt/jack2/mpathroute-0.0.0.0-0.conf

ip route del 0.0.0.0/0
ip route add 0.0.0.0/0 equalize scope global \
  nexthop via 200.1.1.1 dev eth0  weight 1 onlink \
  nexthop via 200.2.2.1 dev eth1  weight 1 onlink
ip route flush cache
```

Todos los nexthops tienen `weight 1` (balanceo equitativo). El kernel distribuye los flujos entre los gateways en round-robin por conexión.

---

## Cómo funciona `mpathroutes.sh` (boot y reload)

```bash
# 1. Elimina todas las rutas que tienen gateway (via)
for ruta in $(ip r l | grep -v link | awk '{print $1}'); do
    ip route del $ruta
done

# 2. Crea un archivo temporal para evitar errores si no hay configs
touch /opt/jack2/mpathroute-1.conf

# 3. Ejecuta todos los archivos de configuración de rutas balanceadas
for config in /opt/jack2/mpathroute-*.conf; do
    sh $config
done

# 4. Limpia la caché de rutas
ip route flush cache

# 5. Elimina el archivo temporal
rm -f /opt/jack2/mpathroute-1.conf
```

---

## Ejemplo de uso: balanceo de dos WAN

Escenario: servidor con dos ISPs, eth0 (ISP1: 200.1.1.0/24, GW 200.1.1.1) y eth1 (ISP2: 200.2.2.0/24, GW 200.2.2.1).

```
jack2-mpathrouting:~#> add-mpath-route
Subnet: 0.0.0.0/0
Gateway [gw1:gwiface1,gw2:gwiface2,...]: 200.1.1.1:eth0,200.2.2.1:eth1
```

El sistema genera `/opt/jack2/mpathroute-0.0.0.0-0.conf` con la ruta multipath y la aplica inmediatamente.

---

## Notas técnicas

**Kernel multipath:** requiere soporte de `CONFIG_IP_ROUTE_MULTIPATH` en el kernel (presente en 2.6.18). En kernels modernos (4.4+) el comportamiento del balanceo cambió; la opción `equalize` fue eliminada. Para JACK2 v2, el comando equivalente es `ip route add ... nexthop ... nexthop ...` sin `equalize`.

**Conflicto con jack2-routes:** las rutas multipath reemplazan las rutas estáticas hacia la misma subred. Si existe una ruta default en `network-routes.conf` y también en `mpathroute-0.0.0.0-0.conf`, el orden de carga en `servicios.conf` determina cuál prevalece (las multipath se cargan primero, luego `fw.sh` no toca rutas).

**Un archivo por ruta:** a diferencia de otros módulos que usan un único archivo de configuración, cada ruta balanceada tiene su propio archivo. Esto permite eliminar una ruta específica simplemente borrando su archivo (`rm -f /opt/jack2/mpathroute-X.conf`).
