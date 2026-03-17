# jack2-routes — Gestión de Rutas Estáticas

Módulo de administración de rutas estáticas usando `ip route` (iproute2). Permite agregar, eliminar, habilitar y deshabilitar rutas con persistencia automática en `/opt/jack2/`.

---

## Archivos del módulo

```
/root/jack2-routes/
├── jack2-routes.sh   ← menú interactivo principal
├── net-routes.sh     ← aplica la tabla de rutas (boot y reload)
└── numroutes.sh      ← lista numerada de rutas con estados
```

**Archivos de configuración persistente:**

```
/opt/jack2/network-routes.conf   ← rutas estáticas definidas por el admin
/opt/jack2/network-routes.pre    ← rutas de red local (generadas automáticamente por jack2-interfaces)
```

---

## Comandos del menú

```
jack2-routes:~#>
```

| Comando | Función |
|---|---|
| `add-route` | Agrega una ruta estática |
| `del-route` | Elimina una ruta (habilitada o deshabilitada) |
| `enable-route` | Reactiva una ruta marcada como `#{DISABLED}` |
| `disable-route` | Desactiva una ruta sin eliminarla |
| `show-routes` | Tabla de rutas del sistema (`route -e -v -n`) |
| `show-detailed-routes` | Tabla de rutas detallada (`ip route list`) |
| `printfile-routes` | Contenido de `network-routes.conf` numerado |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-route`

```
Destination Address  → red destino en formato IP/prefijo (ej: 192.168.2.0/24, 0.0.0.0/0)
Gateway              → gateway via (opcional)
Interface            → interfaz de salida (opcional, ej: eth0, ppp0)
Pref. Source         → IP preferida como origen (src, opcional)
Metric               → métrica de la ruta (opcional)
```

El comando resultante sigue la sintaxis de `ip route add`:

```bash
ip route add 192.168.2.0/24 via 10.0.0.1 dev eth0 src 10.0.0.5 metric 100
```

---

## Cómo funciona `net-routes.sh` (aplicación en boot y reload)

```bash
# 1. Captura todas las rutas actuales que tienen gateway (via)
ip route show all | grep via > /tmp/netroutes.tmp

# 2. Las convierte en comandos "ip route del" y las ejecuta (limpia la tabla)
sh /tmp/netroutes.tmp

# 3. Aplica las rutas guardadas
sh /opt/jack2/network-routes.conf   # rutas del admin
rm -f /tmp/netroutes.tmp
```

Las rutas de red local (`network-routes.pre`) se aplican desde el arranque del módulo de interfaces, no desde aquí. Eso garantiza que las rutas directas estén disponibles antes que las rutas vía gateway.

---

## Sistema de estados

Mismo mecanismo que `jack2-interfaces`: las entradas deshabilitadas llevan el prefijo `#{DISABLED}` y son tratadas como comentarios por Bash al ejecutar el archivo:

```bash
# Ruta habilitada
ip route add 0.0.0.0/0 via 200.200.200.1 dev eth0

# Ruta deshabilitada (no se aplica en boot)
#{DISABLED} ip route add 10.0.0.0/8 via 172.16.0.1 dev eth1
```

---

## Visualización numerada (`numroutes.sh`)

```
[ROUTES]

[ENABLED]
1 | ip route add 0.0.0.0/0 via 200.200.200.1 dev eth0
2 | ip route add 10.0.0.0/8 via 172.16.0.1 dev eth1

[DISABLED]
1 | #{DISABLED} ip route add 192.168.100.0/24 via 10.0.0.254
```

---

## Diferencia entre `network-routes.conf` y `network-routes.pre`

| Archivo | Quién lo escribe | Contenido |
|---|---|---|
| `network-routes.conf` | Admin (via este módulo) | Rutas estáticas: default GW, rutas a redes remotas |
| `network-routes.pre` | `jack2-interfaces` automáticamente | Rutas de red local de cada IP configurada |

Ejemplo: si el admin agrega la IP `192.168.1.1/24` en eth0, `jack2-interfaces` escribe automáticamente en `network-routes.pre`:
```bash
ip route add 192.168.1.0/24 dev eth0:47
```
Esto evita que el admin tenga que agregar manualmente las rutas de red local.
