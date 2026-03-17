# jack2-vrrp — Alta Disponibilidad (VRRP)

Módulo de gestión de VRRP (Virtual Router Redundancy Protocol) usando `vrrpd`. Permite configurar IPs virtuales compartidas entre múltiples appliances JACK2 para failover automático. Si el nodo maestro falla, el nodo backup toma la IP virtual sin intervención manual.

---

## Archivos del módulo

```
/root/jack2-vrrp/
├── jack2-vrrp.sh  ← menú interactivo principal
├── vrrp.sh        ← aplica la configuración (boot y reload)
└── numvrrp.sh     ← lista numerada de instancias VRRP
```

**Archivo de configuración persistente:**

```
/opt/jack2/jack2-vrrp.conf   ← instancias VRRP (un comando vrrpd por línea)
```

---

## Comandos del menú

```
jack2-vrrp:~#>
```

| Comando | Función |
|---|---|
| `add-vrrp` | Configura una nueva instancia VRRP |
| `del-vrrp` | Elimina una instancia por número |
| `show-vrrp` | Lista las instancias configuradas |
| `show-active-vrrp` | Muestra instancias VRRP activas en el sistema (via `ps`) |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-vrrp`

```
Interface      → interfaz física donde escucha VRRP (ej: eth0, eth1)
ID             → ID del grupo VRRP, 1-255 (deben coincidir en todos los nodos del grupo)
Priority       → prioridad de este nodo, 1-254 (mayor = maestro preferido)
Virtual IP     → dirección IP virtual compartida (ej: 192.168.1.254)
Virtual Netmask → máscara de red para la IP virtual
```

El comando resultante que se guarda y ejecuta:

```bash
vrrpd -i eth0:234 -v 50 -p 101 -D 10.10.0.200 -n
```

Donde:
- `-i` → interfaz (el módulo detecta automáticamente el alias si existe)
- `-v` → VRID (Virtual Router ID)
- `-p` → prioridad
- `-D` → IP virtual
- `-n` → no daemonize (permanece en foreground para control del proceso)

---

## Cómo funciona `vrrp.sh` (boot y reload)

```bash
# 1. Termina todas las instancias vrrpd activas
killall vrrpd

# 2. Ejecuta el archivo de configuración (lanza las nuevas instancias)
sh /opt/jack2/jack2-vrrp.conf
```

---

## Ejemplo de configuración maestro/backup

**Nodo maestro** (prioridad 101):
```bash
vrrpd -i eth1 -v 50 -p 101 -D 10.10.0.200 -n
```

**Nodo backup** (prioridad 100):
```bash
vrrpd -i eth1 -v 50 -p 100 -D 10.10.0.200 -n
```

Ambos nodos tienen el mismo VRID (50) y la misma IP virtual (10.10.0.200). El nodo con prioridad más alta (101) es el maestro y mantiene la IP activa. Si falla, el backup (100) toma la IP en segundos.

---

## Notas técnicas

**Detección de alias:** al agregar una instancia VRRP, el módulo detecta si la interfaz seleccionada ya tiene un alias activo (`ethX:N`) y usa ese alias como interfaz de binding. Esto evita conflictos entre la IP real y la IP virtual en la misma interfaz física.

**`show-active-vrrp`:** usa `ps fax` para listar los procesos `vrrpd` activos, extrayendo los parámetros del proceso. Permite verificar qué instancias están corriendo sin consultar el archivo de configuración.

**Dependencia de `vrrpd`:** el paquete `vrrpd` (parte de `ipvsadm` o paquete independiente según la distribución) debe estar instalado. En Debian Etch estaba disponible como paquete separado.
