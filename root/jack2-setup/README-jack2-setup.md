# jack2-setup — System Backup / Restore

Módulo de backup y restauración de la configuración completa del appliance. Los backups se guardan como archivos `.tar.gz` con timestamp en `/opt/jack2/backups/`. El restore recarga automáticamente todos los servicios sin necesidad de reiniciar.

---

## Archivos del módulo

```
/root/jack2-setup/
└── jack2-setup.sh   ← menú interactivo principal (backup + system info)
```

**Directorio de backups:**

```
/opt/jack2/backups/
└── jack2-backup-YYYYMMDD-HHMMSS.tar.gz   ← un archivo por backup
```

---

## Comandos del menú

```
jack2-setup:~#>
```

| Comando | Función |
|---|---|
| `backup-config` | Crea backup comprimido de toda la configuración |
| `restore-config` | Restaura una configuración desde backup y recarga servicios |
| `show-backups` | Lista los backups disponibles con fecha y tamaño |
| `del-backup` | Elimina un backup específico |
| `show-system-info` | Muestra información del sistema en tiempo real |
| `exit` | Vuelve al menú principal |

---

## `backup-config` — Qué incluye el backup

```bash
tar czf /opt/jack2/backups/jack2-backup-YYYYMMDD-HHMMSS.tar.gz \
    /opt/jack2/*.conf    \   # toda la configuración de módulos
    /opt/jack2/*.pre     \   # pre-reglas de firewall
    /opt/jack2/*.post    \   # post-reglas de firewall
    /opt/jack2/*.dnat    \   # reglas DNAT
    /opt/jack2/*.snat    \   # reglas SNAT
    /opt/jack2/*.masq    \   # reglas MASQUERADE
    /etc/ppp/chap-secrets \  # credenciales PPTP (client y server)
    /etc/ppp/pap-secrets  \  # credenciales PAP
    /etc/pptpd.conf       \  # configuración PPTP server
    /etc/squid3/squid.conf \  # configuración proxy
    /etc/quagga/daemons   \  # configuración routing dinámico
    /tmp/jack2-bkp-desc.txt  # descripción del backup (si se ingresó)
```

El backup incluye una descripción opcional ingresada por el admin al momento de crearlo.

---

## `restore-config` — Flujo de restauración

```bash
# 1. Descomprime sobre el sistema en ejecución
tar xzf /opt/jack2/backups/jack2-backup-YYYYMMDD-HHMMSS.tar.gz -C /

# 2. Recarga todos los servicios inmediatamente (mismo orden que el boot)
sh /opt/jack2/servicios.conf
```

El restore no requiere reinicio. Los servicios se recargan en el mismo orden que el boot normal, garantizando consistencia.

---

## `show-system-info` — Información del sistema

Muestra en tiempo real:

```
[Hostname]      → hostname del appliance
[Kernel]        → versión del kernel (uname -a)
[Uptime]        → tiempo de actividad y carga
[CPU]           → modelo del procesador (/proc/cpuinfo)
[Memoria]       → uso de RAM (free -m)
[Disco]         → uso del filesystem (df -h)
[Interfaces]    → interfaces activas (eth*, ppp*, lo)
```

---

## `show-backups`

Lista los archivos de backup con número, tamaño, fecha y nombre:

```
1|  2.3M  Feb 04 2009  jack2-backup-20090204-143022.tar.gz
2|  2.1M  Mar 15 2009  jack2-backup-20090315-091547.tar.gz
```

---

## Notas técnicas

**Ubicación de backups:** los backups se guardan en `/opt/jack2/backups/`, dentro del mismo directorio de configuración persistente. En un sistema live CD, este directorio está en ramdisk. Para backups permanentes, copiarlos a un disco externo o transferirlos por SCP antes de apagar el appliance.

**Descripción del backup:** al crear un backup, el sistema permite ingresar una descripción en texto libre. Esta se guarda como `/tmp/jack2-bkp-desc.txt` y se incluye en el `.tar.gz`. Al restaurar, la descripción queda disponible en el archivo descomprimido.

**`servicios.conf` como punto de recarga:** el restore usa el mismo orquestador que el boot (`servicios.conf`), garantizando que todos los módulos se recargan en el orden correcto: red → rutas → servicios → firewall.
