# jack2-proxy — Proxy Web (Squid3)

Módulo de gestión del proxy web basado en Squid3. Permite definir ACLs por IP origen y URL, establecer políticas de acceso (allow/deny), configurar puerto y tamaño de caché. La configuración se ensambla desde múltiples archivos de `/opt/jack2/` y se aplica a Squid3 en tiempo real.

---

## Archivos del módulo

```
/root/jack2-proxy/
├── jack2-proxy.sh   ← menú interactivo principal
├── proxy.sh         ← ensambla y aplica la configuración de Squid3
└── numproxy.sh      ← lista numerada de reglas de proxy
```

**Archivos de configuración persistente:**

```
/opt/jack2/proxy.port          ← puerto de escucha (ej: http_port 3128)
/opt/jack2/cache.size          ← tamaño del caché (ej: cache_dir ufs /var/spool/squid 100 16 256)
/opt/jack2/proxy.options       ← opciones generales de Squid
/opt/jack2/proxy.rules.url     ← ACLs de URL (acl URL_N url_regex ...)
/opt/jack2/proxy.rules.ip      ← ACLs de IP origen (acl SOURCE_N src ...)
/opt/jack2/proxy.ip.policy     ← políticas por IP directa
/opt/jack2/proxy.control       ← reglas de control de acceso (http_access ...)
/opt/jack2/proxy.policy        ← política default (http_access allow/deny all)
/opt/jack2/jack2-proxy.conf    ← configuración final ensamblada (copia a squid.conf)
```

---

## Comandos del menú

```
jack2-proxy:~#>
```

| Comando | Función |
|---|---|
| `add-proxy-rule` | Agrega una regla ACL (IP origen + URL + acción) |
| `del-proxy-rule` | Elimina una regla por número |
| `show-proxy-rules` | Lista numerada de todas las reglas |
| `set-default-policy` | Define la política default: ALLOW ALL o DENY ALL |
| `show-default-policy` | Muestra la política default activa |
| `set-proxy-port` | Cambia el puerto de escucha (default: 3128) |
| `show-proxy-port` | Muestra el puerto activo |
| `set-cache-size` | Configura el tamaño del caché en MB |
| `show-cache-size` | Muestra el tamaño de caché activo |
| `clear-proxy-cache` | Detiene Squid, limpia el caché y lo reinicia |
| `exit` | Vuelve al menú principal |

---

## Parámetros de `add-proxy-rule`

```
SRC IP   → IP/prefijo origen (ej: 192.168.1.0/24)
URL/Word → expresión regular para URL (ej: youtube, .mp3, facebook.com)
Action   → allow o deny
```

El sistema genera automáticamente un identificador único (`$RANDOM % 2555`) para cada ACL, evitando colisiones de nombres:

```bash
# En proxy.rules.ip:
acl SOURCE_1247 src 192.168.1.0/24

# En proxy.rules.url:
acl URL_1247 url_regex youtube

# En proxy.control:
http_access deny SOURCE_1247 URL_1247
```

---

## Cómo funciona `proxy.sh` (ensamblado y aplicación)

```bash
# 1. Ensambla todos los archivos de configuración en orden
cat proxy.port cache.size proxy.options proxy.rules.url \
    proxy.rules.ip proxy.ip.policy proxy.control proxy.policy \
    > /opt/jack2/jack2-proxy.conf

# 2. Copia a la configuración real de Squid3
cat /opt/jack2/jack2-proxy.conf > /etc/squid3/squid.conf

# 3. Recarga Squid3 (o lo inicia si no está corriendo)
if [ -e /var/run/squid3.pid ]; then
    /etc/init.d/squid3 reload
else
    killall squid3
    /etc/init.d/squid3 start
fi
```

El orden de ensamblado es importante: las ACLs deben definirse antes de las reglas `http_access` que las referencian.

---

## Visualización de reglas (`numproxy.sh`)

Las reglas se muestran agrupadas en tres secciones:

```
[SRC]
1 | acl SOURCE_1247 src 192.168.1.0/24
2 | acl SOURCE_892 src 10.0.0.0/8

[URL]
1 | acl URL_1247 url_regex youtube
2 | acl URL_892 url_regex facebook

[Control List]
1 | http_access deny SOURCE_1247 URL_1247
2 | http_access allow SOURCE_892 URL_892
```

El número en cada sección es independiente. Al borrar una regla por número, se eliminan las tres entradas correspondientes (SRC, URL y control) simultáneamente.

---

## Configuración de proxy transparente

Para usar JACK2 como proxy transparente (sin configuración en los clientes), se debe combinar este módulo con una regla DNAT en `jack2-firewall`:

```bash
# En jack2-firewall → add-dnat:
# Redirigir todo el tráfico HTTP al proxy local
iptables -t nat -I PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:3128
```

El puerto del proxy debe configurarse con `set-proxy-port` para que coincida.

---

## Notas técnicas

**`clear-proxy-cache`:** detiene Squid con `killall squid3`, borra `/var/spool/squid/*` y `/var/spool/squid3/*`, recrea la estructura de directorios con `squid3 -z`, y reinicia el servicio. Útil cuando el caché se corrompe o cuando se cambia el tamaño.

**Política default:** el archivo `proxy.policy` es siempre el último en ensamblarse. Si la política es `http_access deny all`, todo tráfico no explícitamente permitido es bloqueado. Si es `http_access allow all`, todo se permite y solo las reglas `deny` funcionan.
