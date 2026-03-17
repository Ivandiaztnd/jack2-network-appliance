# jack2-interfaces — Gestión de Interfaces y Direcciones IP

Módulo de administración de interfaces de red, direcciones IP y sus estados. Permite agregar, eliminar, habilitar y deshabilitar IPs e interfaces con persistencia automática en `/opt/jack2/`.

---

## Archivos del módulo

```
/root/jack2-interfaces/
├── jack2-interfaces.sh     ← menú interactivo principal
├── net-address.sh          ← aplica configuración de red (usado en boot y reload)
├── numaddress.sh           ← lista numerada de direcciones IP con estados
├── numinterfaces.sh        ← lista numerada de interfaces con estados
├── numlocalroutes.sh       ← lista rutas de red local (precalculadas al agregar IP)
└── show-active-interfaces.sh ← muestra interfaces activas con formato legible
```

**Archivos de configuración persistente:**

```
/opt/jack2/network-address.conf    ← direcciones IP (una por línea, con marcadores de estado)
/opt/jack2/network-interfaces.conf ← interfaces físicas (con marcadores de estado)
/opt/jack2/network-routes.pre      ← rutas de red local (generadas automáticamente al agregar IP)
```

---

## Comandos del menú

```
jack2-interfaces:~#>
```

| Comando | Función |
|---|---|
| `add-address` | Agrega una dirección IP a una interfaz |
| `del-address` | Elimina una dirección IP (habilitada o deshabilitada) |
| `enable-address` | Reactiva una IP marcada como deshabilitada |
| `disable-address` | Desactiva una IP sin eliminarla de la configuración |
| `enable-interface` | Habilita una interfaz física |
| `disable-interface` | Desactiva una interfaz física sin eliminarla |
| `show-active-address` | Muestra IPs activas en el sistema (`ifconfig` formateado) |
| `show-disabled-address` | Lista las IPs marcadas como `#{DISABLED}` |
| `printfile-address` | Muestra el contenido de `network-address.conf` numerado |
| `printfile-interfaces` | Muestra el contenido de `network-interfaces.conf` numerado |
| `show-active-interfaces` | Interfaces activas con formato legible (sin ruido de ifconfig) |
| `exit` | Vuelve al menú principal (`Jack2-Main.sh`) |

---

## Sistema de estados — cómo funciona la persistencia

Todos los archivos de configuración en `/opt/jack2/` usan un sistema de marcadores en línea para representar el estado de cada entrada sin necesidad de archivos de estado separados:

```bash
# IP HABILITADA — se ejecuta en boot y en reload
ifconfig eth0:12 192.168.1.1 netmask 255.255.255.0 up

# IP DESHABILITADA — no se ejecuta, pero se conserva en el archivo
#{DISABLED} ifconfig eth0:23 10.0.0.1 netmask 255.255.255.0 up

# INTERFAZ HABILITADA
#{ENABLED} ifconfig eth1:82 0

# INTERFAZ DESHABILITADA (sin marcador #{ENABLED})
ifconfig eth1:82 0
```

Al **deshabilitar** una entrada, el script inserta el prefijo `#{DISABLED}` o elimina `#{ENABLED}`. Al **habilitar**, lo invierte. Los archivos se reescriben completamente usando archivos temporales (`tmp1.net`, `tmp2.net`, `tmp3.net`) que luego reemplazan el original.

---

## Flujo de `add-address`

```
1. Solicita: IP, máscara, interfaz destino
2. Genera un alias automático: ethX:N (N = número aleatorio 0-255)
3. Muestra el comando ifconfig resultante para confirmación
4. Si se aprueba (S):
   a. Ejecuta ifconfig inmediatamente → efecto en tiempo real
   b. Persiste en /opt/jack2/network-address.conf
   c. Agrega la interfaz al registro de network-interfaces.conf como #{ENABLED}
   d. Calcula la red (via ipcalc) y agrega la ruta local a network-routes.pre
```

Ejemplo de lo que genera internamente al agregar `192.168.1.1/24` en `eth0`:

```bash
# En network-address.conf:
ifconfig eth0:47 192.168.1.1 netmask 255.255.255.0 up

# En network-interfaces.conf:
#{ENABLED} ifconfig eth0:47 0

# En network-routes.pre:
ip route add 192.168.1.0/24 dev eth0:47
```

La ruta local se agrega automáticamente porque el módulo de rutas (`jack2-routes`) la necesita para construir la tabla de routing correctamente.

---

## Flujo de `net-address.sh` (aplicación en boot y reload)

Este script es el que realmente aplica la configuración de red. Se ejecuta desde `servicios.conf` en el boot y también al recargar desde cualquier módulo que modifique interfaces.

```bash
# 1. Detecta interfaces virtuales (aliases ethX:N) y reales (ethX)
vinterfaces=$(ifconfig | grep eth | grep ":")   # eth0:1, eth1:47, etc.
rinterfaces=$(ifconfig | grep eth | grep -v ":") # eth0, eth1, etc.

# 2. Baja todas las interfaces virtuales
for iface in $vinterfaces; do ifconfig $iface down; done

# 3. Baja y limpia las interfaces físicas (ip=0)
for iface in $rinterfaces; do
    ifconfig $iface down
    ifconfig $iface 0
done

# 4. Levanta las interfaces físicas
sleep 1
for iface in $rinterfaces; do ifconfig $iface up; done

# 5. Aplica toda la configuración guardada
sh /opt/jack2/network-address.conf    # aplica IPs (solo las habilitadas)
sh /opt/jack2/network-interfaces.conf # aplica estado de interfaces
```

El `sleep 1` entre bajar y subir las interfaces físicas es intencional: evita condiciones de carrera con el kernel al reinicializar los drivers de red.

Las líneas `#{DISABLED}` son ignoradas automáticamente porque el archivo se ejecuta como shell script y `#{...}` es tratado como comentario por Bash.

---

## Visualización de IPs activas (`show-active-address`)

El módulo reformatea la salida cruda de `ifconfig` para hacerla más legible:

```
# Salida de ifconfig original (verbose, difícil de leer):
eth0      Link encap:Ethernet  HWaddr 00:11:22:33:44:55
          inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0

# Salida reformateada por show-active-address:
eth0      192.168.1.1  Bcast:192.168.1.255     Mask:255.255.255.0
eth1      10.0.0.1     Bcast:10.0.0.255        Mask:255.255.255.0
```

Elimina: líneas de paquetes, bytes, colisiones, estado RUNNING, HWaddr y ruido de formato.

---

## Visualización numerada (`numaddress.sh` / `numinterfaces.sh`)

Los comandos `printfile-*` muestran el contenido de los archivos de configuración en formato numerado, lo que permite referenciar entradas por número en los comandos de edición y borrado:

```
[ADDRESS]

[ENABLED]
1 | ifconfig eth1:95  10.10.0.90  netmask 255.255.255.0 up
2 | ifconfig eth1:189 172.16.255.1 netmask 255.255.255.0 up
3 | ifconfig eth1:116 10.10.0.91  netmask 255.255.255.0 up

[DISABLED]
1 | #{DISABLED} ifconfig eth0:23 10.0.0.2 netmask 255.255.255.0 up
```

La numeración es generada en tiempo real con `cat -n` y no se almacena — es solo referencia para el admin en esa sesión.

---

## Relación con otros módulos

| Módulo | Dependencia |
|---|---|
| `jack2-routes` | Lee `network-routes.pre` para rutas de red local generadas automáticamente |
| `jack2-firewall` | Usa `ifconfig -a` en tiempo real para mostrar interfaces disponibles al construir reglas |
| `jack2-mpathroute` | Necesita interfaces activas para configurar balanceo de carga |
| `jack2-dhcp-server` | Escucha en interfaces configuradas por este módulo |
| `servicios.conf` | Llama a `net-address.sh` como primer paso del arranque del sistema |

---

## Notas técnicas

**Aliases con número aleatorio:** al agregar una IP, el alias se genera con `$RANDOM % 255`. Esto evita colisiones entre múltiples IPs en la misma interfaz física, pero puede generar gaps en la numeración (eth0:1, eth0:47, eth0:189). Es intencional — no es un índice secuencial sino un identificador único.

**Reescritura completa del archivo:** cada operación de habilitar/deshabilitar/borrar reescribe el archivo de configuración completo usando archivos temporales. El patrón es siempre:
```bash
# Filtra lo que no se modifica → tmp2.net
# Agrega la línea modificada → tmp2.net
# Limpia líneas vacías → tmp3.net
# Reemplaza el archivo original
cat tmp3.net > /opt/jack2/network-address.conf
rm -f tmp1.net tmp2.net tmp3.net
```

**`ipcalc` como dependencia:** el cálculo automático de la ruta de red local usa `ipcalc`, que debe estar instalado en el sistema base.
