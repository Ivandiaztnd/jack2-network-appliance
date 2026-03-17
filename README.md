# JACK2 — Network & Security Appliance

> Distribución Linux especializada en routing, firewall y seguridad de red  
> Desarrollada entre 2004 y 2007, Buenos Aires, Argentina  
> Versión: **v1.21** — *"development stable"*

---

## ¿Qué es JACK2?

JACK2 es una distribución Linux live construida sobre **Debian Etch (4.0)**, diseñada como appliance de red y seguridad para entornos corporativos. Su interfaz de administración está completamente implementada en **Bash/AWK/SED puro**, con una CLI inspirada en RouterOS de MikroTik: menús interactivos, comandos descriptivos en inglés, y gestión de configuración persistente.

Fue desarrollada y desplegada en producción en entornos corporativos entre 2004 y 2007. Los scripts fueron protegidos con **SHC** (Shell Script Compiler) para distribución comercial.

En 2025, los 4 CDs físicos originales (v1.21) fueron recuperados. Este repositorio documenta la arquitectura completa del sistema.

---

## Características principales

- **Live CD booteable** — arranca desde CD sin instalación, con opción de instalación a disco (`bootcd2disk`)
- **CLI interactiva estilo MikroTik** — menú principal con 19 módulos, navegación por nombre o número
- **Configuración persistente** — toda la configuración se guarda en `/opt/jack2/` y se recarga en cada boot
- **Arquitectura modular** — cada funcionalidad es un módulo independiente en `/root/jack2-*/`
- **Bash puro** — sin dependencias de Python, Perl ni lenguajes adicionales para la gestión del sistema
- **Kernel 2.6.18-6-686** sobre Debian Etch, optimizado eliminando paquetes innecesarios
- **Splash personalizado** — logo JACK2 en GRUB, LILO e isolinux (`.xpm.gz`)

---

## Stack tecnológico

| Componente | Tecnología |
|---|---|
| Base OS | Debian GNU/Linux 4.0 (Etch) |
| Kernel | 2.6.18-6-686 |
| Live system | `bootcd` + `live-cd-tools` + `bootcdwrite` |
| Bootloader | GRUB legacy + isolinux (CD) / LILO (disco) |
| Shell | Bash / AWK / SED |
| Protección comercial | SHC (Shell Script Compiler) |
| Firewall | iptables (filter, nat, mangle) |
| Routing dinámico | Quagga (BGP, RIP, OSPF) |
| VPN | OpenSwan (IPSec), OpenVPN, PPTP, L2TP |
| DHCP | dhcp3-server / dhcp3-client |
| DNS | BIND9 |
| Proxy | Squid3 |
| Alta disponibilidad | VRRP (ucarp/keepalived) |
| Autenticación | FreeRADIUS |
| Logs | syslogd, lwatch, squidtaild |
| Seguridad | DenyHosts, fail2ban, iptables stateful |
| Módulos kernel extras | `ip_gre`, `ipip` (cargados en boot) |

---

## Arquitectura del sistema

### Flujo de arranque

```
BIOS
 └─► GRUB / isolinux (splash JACK2)
      └─► kernel 2.6.18-6-686
           └─► init → runlevel 2
                └─► /etc/rc.local
                     ├─ modprobe ip_gre
                     ├─ modprobe ipip
                     ├─ /etc/net.conf          ← levanta interfaz mínima (eth0)
                     └─ /opt/jack2/servicios.conf  ← orquestador de módulos
                          ├─ net-address.sh    (interfaces y direcciones IP)
                          ├─ net-routes.sh     (rutas estáticas)
                          ├─ mpathroutes.sh    (rutas balanceadas / multipath)
                          ├─ dhcp-server.sh    (DHCP server si configurado)
                          ├─ dhcp-client.sh    (DHCP client si configurado)
                          ├─ dnsclient.sh      (DNS client)
                          ├─ pppoe-client.sh   (PPPoE/ADSL)
                          ├─ pptp-client.sh    (VPN PPTP cliente)
                          ├─ pptp-server.sh    (VPN PPTP servidor)
                          ├─ proxy.sh          (Squid3)
                          ├─ vrrp.sh           (alta disponibilidad)
                          ├─ ipsec.prescript.sh
                          ├─ ipsec.sh          (OpenSwan/IPSec)
                          └─ fw.sh             ← firewall iptables (siempre último)
```

**Principio de diseño:** el firewall se carga al final, después de que toda la red está configurada y todos los servicios están activos. Primero se levanta la red, luego se protege.

### Separación configuración / lógica

```
/opt/jack2/          ← PERSISTENCIA (configuración guardada por el admin)
├── servicios.conf            (qué módulos arrancan y en qué orden)
├── network-address.conf      (IPs y máscaras de interfaces)
├── network-interfaces.conf   (estado habilitado/deshabilitado de interfaces)
├── network-routes.conf       (rutas estáticas)
├── network-routes.pre        (rutas de red local, precalculadas)
├── network-dns.conf          (servidores DNS)
├── jack2-firewall.conf       (reglas iptables filter)
├── jack2-firewall.pre        (pre-reglas: módulos, defaults, políticas)
├── jack2-firewall.post       (post-regla: política de bloqueo final)
├── jack2-firewall.snat       (reglas SNAT)
├── jack2-firewall.dnat       (reglas DNAT)
├── jack2-firewall.masq       (reglas MASQUERADE)
├── jack2-proxy.conf          (configuración Squid3)
├── jack2-dhcp-server.conf    (configuración DHCP server)
├── jack2-dhcp-client.conf    (configuración DHCP client)
├── jack2-pptp-client.conf    (configuración PPTP cliente)
├── jack2-pppoe-client.conf   (configuración PPPoE)
├── jack2-vrrp.conf           (configuración VRRP)
├── ipsec.DEFAULT.conf        (plantilla IPSec)
├── mpathroute-0.0.0.0-0.conf (configuración rutas balanceadas)
└── proxy.{options,policy,rules.ip,rules.url,...}

/root/                ← LÓGICA (scripts de gestión de cada módulo)
├── Jack2-Main.sh             (menú principal — punto de entrada del admin)
├── jack2-interfaces/         (gestión de interfaces y direcciones IP)
├── jack2-firewall/           (gestión completa de iptables)
├── jack2-routes/             (gestión de rutas estáticas)
├── jack2-mpathroute/         (gestión de rutas balanceadas / multipath)
├── jack2-dhcp-server/        (gestión DHCP server)
├── jack2-dhcp-client/        (gestión DHCP client)
├── jack2-dnsclient/          (gestión DNS client)
├── jack2-proxy/              (gestión proxy Squid3)
├── jack2-pppoe-client/       (gestión PPPoE/ADSL)
├── jack2-pptp-client/        (gestión VPN PPTP cliente)
├── jack2-pptp-server/        (gestión VPN PPTP servidor)
├── jack2-ipsec/              (gestión IPSec/OpenSwan)
├── jack2-vrrp/               (gestión VRRP)
└── jack2-setup/              (inicialización de estructura /opt/jack2/)
```

---

## Interfaz de administración

### Menú principal (`Jack2-Main.sh`)

Al conectar por SSH o consola, el admin ve este menú:

```
       ####                         ####           ########
       ####                         ####         ####    ###
       ####   ########     ######## ####    ####         ####
       #### ####    #### ####    ## #####  ####           ###
       ####   ########## ####       ########           ####
####   #### ####    #### ####       ########         ####
####   #### ####  ###### ####    ## ####  ####     ####
  ########    ########     ######## ####    #### ############

.:.:.:..:..:..:..:..:..:..:..:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:
1  [Interfaces]
2  [Routes]
3  [Balanced-Routes]
4  [Firewall]
5  [Proxy]
6  [VRRP]
7  [IPSEC]
8  [PPTP-Client]
9  [PPTP-Server]
10 [PPPoE-Client]
11 [DCHP-Server]
12 [DHCP-Client]
13 [DNS-Client]
14 [Qos]

15 [System-Backup]
16 [Password]
17 [Reboot]
18 [Shutdown]
19 [exit]

jack2-MAIN:~#>
```

Cada módulo abre su propio submenú con comandos del tipo `add-rule`, `del-rule`, `edit-rules`, `show-connections`, `reload`, etc. Todos los módulos del menú están implementados y operativos en v1.21.

### Módulo de Firewall (`jack2-firewall/`)

El módulo de firewall es el más completo del sistema. Gestiona cuatro capas de iptables de forma independiente:

**Comandos disponibles:**

| Comando | Función |
|---|---|
| `add-rule` / `del-rule` / `edit-rules` | Gestión de reglas filter (INPUT/OUTPUT/FORWARD) |
| `add-snat` / `del-snat` / `edit-snat` | Gestión de Source NAT |
| `add-dnat` / `del-dnat` / `edit-dnat` | Gestión de Destination NAT / Port Forwarding |
| `add-masq` / `del-masq` / `edit-masq` | Gestión de Masquerading |
| `print-active-rules` | Estado actual de la tabla filter |
| `print-active-nat` | Estado actual de la tabla nat |
| `print-active-mangle` | Estado actual de la tabla mangle |
| `show-connections` | Conexiones activas (`netstat -puta`) |
| `show-all-rules` | Vista consolidada de todas las tablas |
| `show-protocols` | Referencia de protocolos IP |
| `reload` | Recarga toda la configuración desde `/opt/jack2/` |

**Flujo de una regla filter:**

```
Admin ingresa parámetros por prompt interactivo:
  → Ubicación (ARRIBA/ABAJO)
  → Chain (INPUT/OUTPUT/FORWARD)
  → Protocolo, puertos origen/destino
  → IP origen/destino con prefijo CIDR
  → Interfaz entrada/salida
  → Acción (ACCEPT/REJECT/DROP)
  → Estado de conexión (NEW/ESTABLISHED/INVALID/RELATED)
  → Comentario (guardado con -m comment --comment)
  
Sistema construye el comando iptables, lo muestra para confirmación,
y si se aprueba:
  1. Ejecuta la regla inmediatamente (efecto en tiempo real)
  2. La persiste en /opt/jack2/jack2-firewall.conf
```

**Orden de carga del firewall en boot:**

```bash
sh /opt/jack2/jack2-firewall.pre   # módulos kernel, flush, políticas default ACCEPT
sh /opt/jack2/jack2-firewall.conf  # reglas filter acumuladas
sh /opt/jack2/jack2-firewall.snat  # reglas SNAT
sh /opt/jack2/jack2-firewall.dnat  # reglas DNAT
sh /opt/jack2/jack2-firewall.masq  # reglas MASQUERADE
sh /opt/jack2/jack2-firewall.post  # política final (ej: DROP todo lo que no matcheó)
```

### Módulo de Interfaces (`jack2-interfaces/`)

Gestiona direcciones IP y estado de interfaces con persistencia automática.

**Comandos disponibles:**

| Comando | Función |
|---|---|
| `add-address` | Agrega IP/máscara a una interfaz (usa alias ethX:N) |
| `del-address` | Elimina una dirección IP |
| `enable-address` / `disable-address` | Habilita/deshabilita una IP sin borrarla |
| `enable-interface` / `disable-interface` | Habilita/deshabilita una interfaz completa |
| `show-active-address` | IPs activas con formato mejorado |
| `show-disabled-address` | IPs deshabilitadas (marcadas con `#{DISABLED}`) |
| `printfile-address` | Contenido del archivo de configuración numerado |
| `printfile-interfaces` | Listado numerado de interfaces |

**Mecanismo de persistencia con estados:**

Las configuraciones en `/opt/jack2/` usan un sistema de marcadores en línea:

```bash
# IP habilitada — se ejecuta en boot
ifconfig eth0:1 192.168.1.1 netmask 255.255.255.0 up

# IP deshabilitada — no se ejecuta, pero se conserva
#{DISABLED} ifconfig eth0:2 10.0.0.1 netmask 255.255.255.0 up

# Interfaz habilitada
#{ENABLED} ifconfig eth1 0
```

Al deshabilitar una entrada, el script la reescribe con el prefijo `#{DISABLED}`. Al habilitar, lo quita. Los archivos de estado se numeran automáticamente para referencia en los menús.

---

## Construcción del Live CD

### Herramientas utilizadas

JACK2 v1.21 fue construido con:

- **`bootcd`** — paquete Debian que convierte un sistema instalado en CD booteable. Genera las imágenes ramdisk y el árbol ISO.
- **`bootcdwrite`** — componente de bootcd que construye la imagen ISO final. Configurado en `/etc/bootcd/bootcdwrite.conf`.
- **`bootcd2disk`** — herramienta para instalar el sistema live a disco duro desde el CD en ejecución. Configurado en `/etc/bootcd/bootcd2disk.conf`.
- **`live-cd-tools`** / **`live-helper`** — herramientas auxiliares de Debian Live para construcción y configuración del entorno.
- **`isolinux`** — bootloader para CD/DVD (parte de syslinux). Configurado en `/etc/bootcd/isolinux.cfg`.
- **`GRUB legacy`** — bootloader para disco instalado. Splash personalizado `.xpm.gz` con logo JACK2.

### Configuración del Live CD (`/etc/bootcd/bootcdwrite.conf`)

Parámetros clave:

```bash
DISPLAY="/boot/JACK2LOGO.TXT"    # logo ASCII en pantalla de arranque isolinux
RAMDISK_SIZE=250000              # tamaño ramdisk (250 MB)
TYP=CD                           # tipo de medio
FASTBOOT=yes                     # genera imágenes adicionales para boot rápido
ISOLINUX=auto                    # usa isolinux si está disponible
COMPRESS=auto                    # compresión ISO 9660 automática
NOTCOMPRESSED="/lib /usr /home /etc"  # directorios excluidos de compresión
ARCH=i386                        # arquitectura x86 32-bit
INITRD="/boot/initrd.img-2.6.18-6-686"
BOOTCDMODPROBE=auto              # detección automática de módulos con discover
DISABLE_CRON="etc/cron.daily/find etc/cron.daily/standard etc/cron.daily/security"
```

### Splash de GRUB

El splash del bootloader fue implementado como imagen `.xpm.gz` (formato nativo de GRUB legacy). El logo JACK2 en ASCII art se muestra también en la pantalla de boot de isolinux a través de `/boot/JACK2LOGO.TXT`.

### Optimización de Debian

Para reducir el tamaño del CD y el tiempo de carga en ramdisk, se eliminaron del sistema base:

- Paquetes de escritorio (X11, GTK, Qt)
- Documentación y man pages no esenciales
- Locales no utilizados
- Servicios de impresión
- Editores gráficos y aplicaciones de usuario final
- Tareas cron innecesarias para appliance (marcadas como `.no_run_on_bootcd`)

El sistema resultante es un Debian mínimo con foco exclusivo en networking y seguridad.

---

## Instalación a disco (`bootcd2disk`)

Desde el CD en ejecución, el admin puede instalar el sistema completo a disco duro con el comando `bootcd2disk`. La instalación es automática:

```bash
DISK=auto       # detecta el primer disco disponible
SFDISK=auto     # particiona automáticamente (boot + swap + /)
EXT2FS=auto     # crea filesystems ext2/ext3
EXT3=auto       # usa ext3 si está disponible
SWAP=auto       # crea partición swap
MOUNT=auto      # monta automáticamente
FSTAB=auto      # genera /etc/fstab
GRUB=auto       # instala y configura GRUB
SSHHOSTKEY=yes  # genera SSH host key única para cada instalación
```

También existe un script manual `INSTALAR.SH` que realiza la instalación via `chroot` con LILO como bootloader alternativo.

---

## Módulos del sistema

### Módulos completamente recuperados

| Módulo | Directorio | Función |
|---|---|---|
| **Firewall** | `jack2-firewall/` | iptables: filter, SNAT, DNAT, MASQ, mangle |
| **Interfaces** | `jack2-interfaces/` | IPs, máscaras, aliases, estado de interfaces |
| **Routes** | `jack2-routes/` | Rutas estáticas (`ip route`) |
| **Balanced-Routes** | `jack2-mpathroute/` | Rutas multipath / balanceo de carga |
| **DHCP Server** | `jack2-dhcp-server/` | dhcp3-server con gestión de scopes |
| **DHCP Client** | `jack2-dhcp-client/` | dhcp3-client por interfaz |
| **DNS Client** | `jack2-dnsclient/` | Configuración de resolvers |
| **PPPoE Client** | `jack2-pppoe-client/` | Conexiones ADSL/PPPoE |
| **PPTP Client** | `jack2-pptp-client/` | VPN PPTP cliente |
| **PPTP Server** | `jack2-pptp-server/` | VPN PPTP servidor |
| **Proxy** | `jack2-proxy/` | Squid3: ACLs, políticas, caché |
| **VRRP** | `jack2-vrrp/` | Alta disponibilidad (failover) |
| **IPSec** | `jack2-ipsec/` | OpenSwan: túneles site-to-site y road warrior |
| **QoS** | `jack2-qos/` | Traffic shaping con tc/iproute2 (HTB, clases, filtros u32) |
| **System-Backup** | `jack2-setup/` | Backup/restore de configuración completa, info del sistema |

### Módulos pendientes de recuperación

Los siguientes módulos estaban presentes en el sistema original pero aún no han sido extraídos de las ISOs:

- **SNMP** — Agente snmpd para monitoreo
- **Configuración live-helper** — Scripts de construcción del live CD
- **Módulos GRUB splash** — Archivos de imagen `.xpm.gz` originales

### Módulo de QoS (`jack2-qos/`)

Gestión de traffic shaping con `tc` (iproute2), usando disciplinas HTB (Hierarchical Token Bucket). Permite limitar y garantizar ancho de banda por IP, red, protocolo o puerto, con persistencia automática.

**Comandos disponibles:**

| Comando | Función |
|---|---|
| `add-qos-rule` | Crea una regla de QoS con parámetros interactivos |
| `del-qos-rule` | Elimina una regla por número |
| `show-qos-rules` | Lista las reglas guardadas (ENABLED/DISABLED) |
| `show-active-qos` | Estado real del sistema: `tc qdisc`, `tc class`, `tc filter` |
| `set-default-policy` | Define política default por interfaz (ancho de banda para tráfico no clasificado) |
| `show-default-policy` | Muestra la política default configurada |
| `reload` | Recarga todas las reglas desde `/opt/jack2/jack2-qos.conf` |

**Parámetros de una regla QoS:**

```
Interface         → interfaz de salida (eth0, ppp0, etc.)
Bandwidth total   → ancho de banda total de la interfaz (kbps)
Tipo de cola      → htb (default), pfifo, sfq
Source Address    → IP/CIDR origen (opcional)
Destination Address → IP/CIDR destino (opcional)
Protocol          → tcp, udp (opcional)
Puerto destino    → número de puerto (opcional)
Prioridad         → 1=alta, 3=media (default), 5=baja
Rate garantizado  → kbps garantizados para esta clase
Rate máximo       → kbps máximo (burst) para esta clase
Comentario        → etiqueta descriptiva
```

**Cómo funciona `qos.sh` (aplicación en boot):**

```bash
# 1. Limpia todas las qdiscs existentes en cada interfaz
tc qdisc del dev $iface root

# 2. Por cada regla en /opt/jack2/jack2-qos.conf:
tc qdisc add dev $iface root handle 1: htb default 99   # HTB root
tc class add dev $iface parent 1: classid 1:1 htb rate ${bwtotal}kbit  # clase raíz
tc class add dev $iface parent 1:1 classid 1:N htb rate ${rate}kbit ceil ${ceil}kbit prio $prio  # subclase
tc filter add dev $iface parent 1: protocol ip prio N u32 \
    match ip src X.X.X.X \
    match ip dst X.X.X.X \
    match ip dport XXXX 0xffff \
    flowid 1:N   # filtro de clasificación
```

El `default 99` en la qdisc raíz garantiza que el tráfico no clasificado por ninguna regla recibe el ancho de banda residual, nunca queda bloqueado.

**Archivos de configuración:**

```
/opt/jack2/jack2-qos.conf          ← reglas QoS (una por línea, formato interno)
/opt/jack2/jack2-qos-default.conf  ← política default por interfaz
```

### Módulo de System-Backup (`jack2-setup/`)

Backup y restore de toda la configuración del appliance. Los backups se guardan como archivos `.tar.gz` con timestamp en `/opt/jack2/backups/`. El restore recarga automáticamente todos los servicios después de aplicar la configuración.

**Comandos disponibles:**

| Comando | Función |
|---|---|
| `backup-config` | Crea backup comprimido de toda la configuración |
| `restore-config` | Restaura una configuración desde backup y recarga servicios |
| `show-backups` | Lista los backups disponibles con fecha y tamaño |
| `del-backup` | Elimina un backup específico |
| `show-system-info` | Muestra hostname, kernel, uptime, CPU, RAM, disco e interfaces |

**Qué incluye cada backup:**

```bash
/opt/jack2/*.conf      # toda la configuración de módulos
/opt/jack2/*.pre       # pre-reglas de firewall
/opt/jack2/*.post      # post-reglas de firewall
/opt/jack2/*.dnat      # reglas DNAT
/opt/jack2/*.snat      # reglas SNAT
/opt/jack2/*.masq      # reglas MASQUERADE
/etc/ppp/chap-secrets  # credenciales PPTP/L2TP
/etc/ppp/pap-secrets
/etc/pptpd.conf        # configuración PPTP server
/etc/squid3/squid.conf # configuración Squid3
/etc/quagga/daemons    # configuración routing dinámico
```

**Flujo de restore:**

```bash
# 1. Descomprime sobre el sistema en ejecución
tar xzf /opt/jack2/backups/jack2-backup-YYYYMMDD-HHMMSS.tar.gz -C /

# 2. Recarga todos los servicios inmediatamente
sh /opt/jack2/servicios.conf
```

El restore no requiere reinicio del sistema. Los servicios se recargan en el mismo orden que el boot normal, garantizando consistencia.

---

## Estructura de archivos del repositorio

```
jack2/
├── README.md                    ← este archivo
├── etc/
│   ├── rc.local                 ← punto de entrada del sistema
│   ├── net.conf                 ← levanta interfaz mínima en boot
│   ├── bootcd/
│   │   ├── bootcdwrite.conf     ← configuración de construcción del live CD
│   │   ├── bootcd2disk.conf     ← configuración de instalación a disco
│   │   ├── thisbootcd.conf      ← parámetros del sistema live
│   │   ├── isolinux.cfg         ← configuración del bootloader CD
│   │   └── syslinux.cfg         ← configuración syslinux
│   ├── inittab                  ← configuración init (runlevel 2)
│   └── casper.conf              ← configuración de sesión live
├── boot/
│   ├── grub/
│   │   └── menu.lst             ← configuración GRUB legacy
│   └── JACK2LOGO.TXT            ← logo ASCII para pantalla de boot
├── opt/
│   └── jack2/                   ← archivos de configuración persistente
│       ├── servicios.conf       ← orquestador de arranque de módulos
│       ├── network-address.conf
│       ├── network-interfaces.conf
│       ├── network-routes.conf
│       ├── network-routes.pre
│       ├── network-dns.conf
│       ├── jack2-firewall.conf
│       ├── jack2-firewall.pre
│       ├── jack2-firewall.post
│       ├── jack2-firewall.snat
│       ├── jack2-firewall.dnat
│       ├── jack2-firewall.masq
│       ├── jack2-proxy.conf
│       ├── jack2-dhcp-server.conf
│       ├── jack2-vrrp.conf
│       ├── ipsec.DEFAULT.conf
│       ├── ipsec.prescript.sh
│       └── mpathroute-0.0.0.0-0.conf
└── root/
    ├── Jack2-Main.sh            ← menú principal interactivo
    ├── jack2-firewall/          ← módulo firewall (completo)
    ├── jack2-interfaces/        ← módulo interfaces (completo)
    ├── jack2-routes/            ← módulo rutas estáticas
    ├── jack2-mpathroute/        ← módulo rutas balanceadas
    ├── jack2-dhcp-server/       ← módulo DHCP server
    ├── jack2-dhcp-client/       ← módulo DHCP client
    ├── jack2-dnsclient/         ← módulo DNS client
    ├── jack2-proxy/             ← módulo proxy Squid3
    ├── jack2-pppoe-client/      ← módulo PPPoE
    ├── jack2-pptp-client/       ← módulo PPTP client
    ├── jack2-pptp-server/       ← módulo PPTP server
    ├── jack2-ipsec/             ← módulo IPSec
    ├── jack2-vrrp/              ← módulo VRRP
    ├── jack2-qos/               ← módulo QoS / traffic shaping
    ├── jack2-setup/             ← módulo system backup / restore
```

---

## Contexto histórico

JACK2 fue desarrollado en un momento en que las soluciones de appliance de red tenían un costo de licencia significativo para las empresas argentinas. El objetivo era ofrecer una alternativa basada en Linux con una interfaz de administración accesible para técnicos sin experiencia profunda en Linux, manteniendo la potencia de iptables, Quagga y el stack completo de servicios de red.

La CLI estilo MikroTik fue una decisión deliberada: en Argentina, RouterOS de MikroTik era (y es) el estándar de facto en redes ISP y corporativas. Al replicar la filosofía de menús y comandos, cualquier técnico familiarizado con MikroTik podía administrar JACK2 con mínima curva de aprendizaje.

Los scripts fueron compilados con **SHC** (Shell Script Compiler) para distribución comercial, transformando los `.sh` en binarios ELF que ocultan el código fuente. El código publicado en este repositorio corresponde a los fuentes originales.

---

## JACK2 v2 — Roadmap

El proyecto JACK2 v2 está planificado como una reescritura completa con:

- **Base:** Debian 12 (Bookworm)
- **Interfaz:** Web UI (estilo pfSense/VyOS) sobre el CLI original
- **IDS/IPS integrado:** Suricata o Snort
- **Vuln-recon nativo:** escáner de vulnerabilidades integrado en la interfaz
- **Modelo:** open-source core + features premium (modelo pfSense/Proxmox)
- **Mercado objetivo:** LATAM hispanoparlante
- **Diferenciadores:** interfaz en español, vuln-recon nativo, documentación local

---

## Autor

**Iván Alberto Díaz**  
Senior IT Engineer — Buenos Aires, Argentina  
[linkedin.com/in/ivan-alberto-diaz-0b345410](https://linkedin.com/in/ivan-alberto-diaz-0b345410)

JACK2 fue desarrollado entre 2004 y 2007 y publicado en 2025 a partir de la recuperación de los fuentes originales.

---

## Licencia

Este código se publica con fines educativos, históricos y como base para JACK2 v2. No se recomienda su uso en producción sin actualización del sistema base (Debian Etch está EOL desde 2010).
