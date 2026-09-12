# Conceptos de Docker — imagen, contenedor, volumen, compose y Kubernetes

> Documento conceptual del curso. En la v1 usted ya usó Docker (el
> `docker compose up -d --build` que levanta la BD y la API); aquí está el
> mapa completo de conceptos, con los ejemplos de este proyecto y lo que
> viene en la ruta de versiones.

---

## 1. ¿Qué problema resuelve Docker?

"En mi máquina sí funciona." Cada estudiante tiene un PC distinto (Windows,
versiones, configuraciones) y un software como MariaDB instalado a mano se
comporta distinto en cada uno. Docker empaqueta el software **con todo su
entorno** en una unidad estándar que corre igual en cualquier máquina.
En este curso: nadie instala MariaDB ni PHP — todos corren **el mismo contenedor**.

## 2. Imagen

Una imagen es una **plantilla inmutable y empaquetada**: un sistema de
archivos congelado (SO base + programa + librerías + configuración) más
metadatos (qué comando arrancar, qué puerto expone).

- **Inmutable**: una vez construida, no cambia. Cambiar algo = construir OTRA imagen.
- Se construye en **capas** (cada instrucción de un `Dockerfile` es una capa
  que se cachea — por eso las reconstrucciones son rápidas).
- Viene de un **registro** (Docker Hub) o se construye localmente. En la v1
  usamos una del registro: `mariadb:11` (el `:11` es la
  **etiqueta**: la versión 11 de MariaDB).

**Analogía:** la imagen es el **molde de la galleta**.

### 2.1 El `Dockerfile`: la receta de la imagen

Una imagen no aparece sola: **alguien escribe cómo se arma**. Ese «cómo»
va en un archivo llamado `Dockerfile` (sin extensión), y este proyecto
tiene 2: `./api_mapa`, `./front_php`.

Este es el de `api-mapa`, sin los comentarios para verlo de un vistazo:

```dockerfile
FROM php:8.3-cli
RUN docker-php-ext-install pdo_mysql
WORKDIR /app
COPY . .
EXPOSE 8117
CMD ["php", "-S", "0.0.0.0:8117", "index.php"]
```

Esto hace cada instrucción:

| Instrucción | Qué hace | Por qué está aquí |
|---|---|---|
| `FROM php:8.3-cli` | **De dónde se parte.** Toma una imagen ya hecha | Nadie arma un sistema desde cero: se parte de una que ya trae lo básico |
| `RUN docker-php-ext-install pdo_mysql` | **Ejecuta algo AL CONSTRUIR** la imagen, una sola vez | Lo que instale aquí queda **dentro** de la imagen |
| `WORKDIR /app` | La carpeta donde se trabaja dentro del contenedor | Para no repetir la ruta completa en cada instrucción siguiente |
| `COPY . .` | **Copia archivos** de su computador hacia adentro de la imagen | Así la imagen se lleva la aplicación |
| `EXPOSE 8117` | **Documenta** en qué puerto escucha el programa | No abre nada: quien publica el puerto es el `ports:` del compose |
| `CMD ["php", "-S", "0.0.0.0:8117", "index.ph…` | **El comando que se ejecuta al encender** el contenedor | Si ese proceso termina, el contenedor se apaga |

**La diferencia entre `RUN` y `CMD`** es la que más se confunde:

| | Cuándo corre | Cuántas veces |
|---|---|---|
| `RUN` | Al **construir** la imagen (`--build`) | Una sola vez, y queda guardado |
| `CMD` | Al **encender** el contenedor | Cada vez que arranca |


## 3. Contenedor

Un contenedor es una **instancia viva de una imagen**: un proceso corriendo
con su propio sistema de archivos, red y espacio de procesos, aislado del
resto de su PC.

- De una imagen salen **muchos contenedores** (galletas del mismo molde).
- Es **efímero y desechable**: `docker compose down` lo destruye sin drama, y
  se recrea idéntico con `docker compose up -d`.
- **No es una máquina virtual**: no carga un sistema operativo completo —
  comparte el kernel del host con aislamiento de procesos. Por eso arranca en
  segundos y pesa MB, no GB.
- En la v1: `proyecto_php1-mariadb-1` es un contenedor creado desde la imagen
  `mariadb:11`, con el puerto interno 3306 **publicado** en el 13333 de su PC
  (`"13333:3306"` en el compose).

**Analogía:** el contenedor es la **galleta**.

## 4. Volumen (y el estado)

Si los contenedores son desechables… ¿dónde viven los datos? En
**almacenamiento que sobrevive al contenedor**:

| Mecanismo | Qué es | En este proyecto |
|---|---|---|
| **Volumen** | Espacio administrado por Docker, montado dentro del contenedor | Los datos de MariaDB (`mariadbdata` — por eso `docker compose down`/`up` los conserva) |
| **Bind mount** | Una carpeta de SU disco montada dentro del contenedor | la línea `./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro` del compose — el script de la BD entra al contenedor desde su carpeta (`:ro` = solo lectura) |

Detalle importante que ya vivió en la v1: MariaDB ejecuta el `init.sql`
**solo la primera vez** (cuando su almacenamiento está vacío). Por eso el
"reset" de la BD es destruir y recrear el contenedor — no reiniciarlo.

**La regla de oro que ata los tres conceptos:** *la imagen es inmutable, el
contenedor es desechable, y el volumen es lo único que debe importarte
perder.*

```
Dockerfile   →  IMAGEN      →  CONTENEDOR   →  VOLUMEN
(receta)        (molde)        (galleta)       (la memoria)
             docker build    docker run       -v / volumes
```

> **La sorpresa que confunde a todo el mundo:** el volumen sobrevive
> INCLUSO a borrar la carpeta del proyecto. Si usted borra la carpeta,
> vuelve a hacer `git clone` y ejecuta `docker compose up -d --build`,
> la BD arranca **con los datos de la última vez** — no con las semillas.
> ¿Por qué? El volumen no vive en la carpeta: vive en el área de Docker,
> identificado por el nombre del proyecto compose (= el nombre de la
> carpeta). Misma carpeta → mismo nombre → mismo volumen de siempre.
>
> | Comando | ¿Y los datos? |
> |---|---|
> | `docker compose up -d --build` | Se conservan |
> | `docker compose down` | Se conservan |
> | borrar la carpeta y re-clonar | **Se conservan** (el volumen no estaba ahí) |
> | `docker compose down -v` | **SE BORRAN** — el único que resetea |
>
> Para una demo con las semillas exactas:
> `docker compose down -v` y luego `docker compose up -d --build`.

### El despliegue de ESTE proyecto, dibujado (Mermaid)

Todo lo anterior, junto: lo que `docker compose up -d` levanta aquí es un
**sistema de servidores en miniatura** — cada contenedor es un servidor
con su propio hostname, unidos por la red interna del compose:

```mermaid
flowchart LR
    NAV["Navegador / curl / Swagger"]
    subgraph PC["Su PC — Docker Desktop (el 'centro de datos')"]
        subgraph RED["red interna del compose (LAN virtual, con DNS propio)"]
            APIFACTURAS["SERVIDOR DE APLICACIONES<br/>contenedor api-registros<br/>hostname: api-registros · escucha en 8117"]
            PHPMYADMIN["SERVIDOR DE APLICACIONES<br/>contenedor phpmyadmin<br/>hostname: phpmyadmin · escucha en 80"]
            MARIADB[("SERVIDOR DE BASE DE DATOS<br/>MariaDB/MySQL · contenedor mariadb<br/>hostname: mariadb · escucha en 3306")]
        end
    end
    NAV -->|"localhost:8117"| APIFACTURAS
    NAV -->|"localhost:8101"| PHPMYADMIN
    APIFACTURAS -->|"mariadb:3306 (DNS de Docker)"| MARIADB
    PHPMYADMIN -->|"mariadb:3306 (DNS de Docker)"| MARIADB
    NAV -.->|"opcional (diagnóstico):<br/>localhost:13333"| MARIADB
```

**Guía de lectura:** los servicios se hablan entre sí **por nombre**
(el DNS interno de Docker resuelve `postgres`, `api-registros`, etc. a la
IP del contenedor — jamás `localhost`, que dentro de un contenedor es él
mismo). Hacia su PC solo existen las puertas `localhost:PUERTO` que el
compose publica. Por eso este mismo diseño se despliega igual en un
servidor real: cambiar de máquina no cambia la arquitectura.

## 5. Docker Compose (el "un solo comando" del proyecto)

¿Cómo levantar VARIOS contenedores (BD + API, y pronto más) sin escribir N
comandos `docker run` con todos sus flags, en el orden correcto, cada vez?

**Compose** es la respuesta **declarativa**: un archivo `docker-compose.yml`
(formato YAML) que declara el estado deseado del sistema completo — qué
servicios existen, de qué imagen sale cada uno, puertos, volúmenes, variables
y dependencias — y `docker compose up -d` lo materializa. Es **declarativo,
no imperativo**: usted no escribe los pasos, escribe el resultado; en cada
`up -d` Compose compara lo declarado con lo que corre y solo recrea lo que
cambió (el mismo espíritu de SDD: describir el QUÉ).

### El `docker-compose.yml` de ESTE proyecto, explicado línea por línea

Es el archivo que está en la raíz desde la v1 (mínimo: BD + API) y que
**crecerá con las versiones** hasta orquestar los 3 motores, las 2 APIs y el
front. Esto es lo que dice hoy:

```yaml
services:                          # el mapa de TODOS los contenedores del sistema

  mariadb:                         # ← este nombre es también su HOSTNAME interno
    image: mariadb:11              # imagen del registro (no se construye)
    environment:                   # variables que la imagen usa al crear la BD
      MARIADB_ROOT_PASSWORD: paradigmas123
      MARIADB_DATABASE: mapa_php_local
      MARIADB_USER: paradigmas
      MARIADB_PASSWORD: paradigmas123
    volumes:
      - mariadbdata:/var/lib/mysql           # volumen NOMBRADO: los datos sobreviven
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
        # ↑ bind mount: SU archivo entra al contenedor (:ro = solo lectura).
        #   MariaDB ejecuta lo que haya en esa carpeta SOLO si el volumen
        #   está vacío (primera vez) — por eso el reset es `down -v`.
    ports:
      - "13333:3306"               # "puerto en su PC : puerto interno del contenedor"
    healthcheck:                   # cómo saber si la BD ya RESPONDE (no solo "existe")
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 5s
      timeout: 5s
      retries: 10

  api-registros:
    build: ./api_mapa          # esta imagen SE CONSTRUYE con el Dockerfile de esa carpeta
    volumes:
      - ./api_mapa:/app        # el código montado: guardar un .php = refrescar
    restart: unless-stopped        # si el proceso muere, Docker lo levanta de nuevo
    ports:
      - "8117:8117"                # http://localhost:8117
    environment:
      # El DSN usa el NOMBRE del servicio como host (mariadb:3306), no
      # localhost: dentro de la red interna de compose los servicios se
      # resuelven por nombre (DNS propio).
      DB_DSN: mysql:host=mariadb;port=3306;dbname=mapa_php_local
      DB_USUARIO: paradigmas
      DB_CLAVE: paradigmas123
    depends_on:
      mariadb:
        condition: service_healthy # arranca cuando la BD RESPONDE (healthcheck), no por azar

  phpmyadmin:                      # administrador web de MariaDB (también un contenedor)
    image: phpmyadmin:latest       # imagen del registro: no escribimos ni una línea de él
    environment:
      PMA_HOST: mariadb            # a cuál servidor se conecta: el nombre del servicio
      PMA_USER: paradigmas
      PMA_PASSWORD: paradigmas123
    ports:
      - "8101:80"                  # http://localhost:8101 (adentro escucha en el 80)
    depends_on:
      - mariadb                    # versión simple: solo orden de arranque

volumes:
  mariadbdata:                     # declaración del volumen nombrado (la "memoria" de la BD)
```

Las tres ideas que este archivo demuestra:

1. **Dos redes de nombres**: hacia su PC, puertos publicados
   (`localhost:8117`, `localhost:8101`, `localhost:13333`); entre
   contenedores, nombres de servicio (`mariadb:3306`). La misma BD tiene dos
   "direcciones" según quién la llame — phpMyAdmin lo demuestra: usted lo abre
   por `localhost:8101`, pero él le habla a la BD por `mariadb:3306`.
2. **Dependencias por salud**: `service_healthy` + healthcheck — la API
   espera a que la BD responda, no a que el contenedor exista.
3. **Desarrollo dentro del contenedor**: el código montado como volumen —
   y en PHP ni siquiera hay "reload": cada petición reinterpreta los `.php`,
   así que guardar y refrescar ES el ciclo. Solo se reconstruye (`--build`)
   cuando cambia el Dockerfile.

### Contenedores huérfanos y `--remove-orphans`

Compose recuerda qué contenedores creó para este proyecto (los marca con el
nombre de la carpeta: `proyecto_php1-...`). Si el `docker-compose.yml` **deja
de declarar** un servicio que antes existía, su contenedor no se borra solo:
queda **huérfano** — creado por el proyecto, pero ya sin servicio que lo
respalde — y Compose lo avisa al arrancar:

```
Found orphan containers ([proyecto_php1-phpmyadmin-1 ...]) for this project.
```

En este repositorio puede pasar porque el curso es **por versiones**: si una
versión futura elimina o renombra un servicio del compose (o si usted agregó
uno de prueba y luego lo quitó del archivo), el contenedor viejo queda ahí.
No estorba para trabajar (está detenido), pero ocupa disco y ensucia
`docker ps -a`. La limpieza:

```powershell
docker compose up -d --remove-orphans   # levanta lo declarado Y borra los huérfanos
```

Importante: borra los **contenedores** sobrantes, no los **volúmenes** — los
datos de la BD siguen ahí (sección 4).

### Las directivas del `docker-compose.yml`, una por una

Estas son las palabras clave que usa el archivo de arriba, con lo que
significan y qué pasaría si faltaran:

| Directiva | Qué declara | Si no está |
|---|---|---|
| `services:` | La lista de contenedores del sistema. Cada nombre debajo es un servicio | No hay nada que levantar |
| `image:` | **Usa** una imagen ya hecha, del registro público | Habría que construirla con `build:` |
| `build:` | **Construye** la imagen con el `Dockerfile` de esa carpeta | Docker no sabría cómo armar su aplicación |
| `environment:` | Variables que el programa lee al arrancar (claves, direcciones) | El programa arranca sin saber a qué base conectarse |
| `volumes:` | Qué carpetas o volúmenes se montan dentro del contenedor | Los datos se pierden al apagar, y el código no se refresca |
| `ports:` | `"puerto en su PC : puerto dentro del contenedor"` | El servicio corre pero **usted no lo puede abrir** desde el navegador |
| `depends_on:` | En qué orden arrancan los servicios | Arrancan a la vez, y la API busca una base que todavía no existe |
| `healthcheck:` | Cómo saber si el servicio **ya responde**, no solo si «existe» | `depends_on` esperaría a que arranque, no a que sirva |
| `restart:` | Qué hacer si el proceso se muere | El contenedor se queda caído |
| `volumes:` (al final, sin indentar) | Declara los volúmenes **nombrados** que usan los servicios | El volumen no existe y el servicio no arranca |

**El nombre del servicio es también su dirección.** Cuando un servicio le
habla a otro, lo llama por el nombre que tiene en este archivo: Docker crea
una red interna y lo resuelve. Por eso no se usa `localhost` — **dentro de
un contenedor, `localhost` es el contenedor mismo**.

**Los dos números de `ports:` no son lo mismo.** El de la izquierda es el
puerto de su computador; el de la derecha, el de adentro. Cambiar el de la
izquierda no toca una línea de código.


### `docker compose up -d --build`: un comando que hace siete cosas

Esta es la parte que hace que valga la pena. **Un solo comando ejecuta toda
esta secuencia**, en este orden:

| # | Qué hace | El comando que se ahorra |
|---|---|---|
| 1 | **Lee** el `docker-compose.yml` y entiende el sistema completo | — |
| 2 | **Descarga** las imágenes que usted no tiene todavía (las de `image:`) | `docker pull imagen` por cada una |
| 3 | **Construye** las imágenes propias siguiendo su `Dockerfile` (las de `build:`) | `docker build -t nombre ./carpeta` por cada una |
| 4 | **Crea la red** interna para que los contenedores se encuentren por su nombre | `docker network create red` |
| 5 | **Crea los volúmenes** nombrados donde viven los datos | `docker volume create nombre` |
| 6 | **Crea y enciende un contenedor por servicio**, con sus puertos, variables y volúmenes | `docker run -d --name … -p … -e … -v … imagen` por cada uno |
| 7 | **Respeta el orden**: espera a que la base RESPONDA antes de encender la API | No tiene equivalente: habría que mirarlo a ojo |

Y todo eso **es repetible**: quien lo corra mañana en otro computador obtiene
exactamente lo mismo, porque la secuencia no está en la cabeza de nadie sino
escrita en dos archivos — el `docker-compose.yml` y los `Dockerfile`.

---

### Lo mismo, pero escrito a mano

**Sin compose**, para levantar este proyecto —que tiene **4 servicios**— hay
que escribir esto, en este orden, cada vez:

```powershell
# 1. Crear la red, para que los contenedores se encuentren por su nombre
docker network create proyecto_php_gestion_mapa_conocimiento1_default

# 2. mariadb
docker run -d --name mariadb --network proyecto_php_gestion_mapa_conocimiento1_default --restart unless-stopped `
  -e "MARIADB_ROOT_PASSWORD=paradigmas123" `
  -e "MARIADB_DATABASE=mapa_php_local" `
  -e "MARIADB_USER=mapa" `
  -e "MARIADB_PASSWORD=paradigmas123" `
  -v mariadbdata:/var/lib/mysql `
  -v "${PWD}/db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro" `
  -p 13333:3306 mariadb:11

# 3. ESPERAR a que responda de verdad… mirándolo a ojo

# 4. Construir la imagen de api-mapa y encenderla
docker build -t api-mapa ./api_mapa
docker run -d --name api-mapa --network proyecto_php_gestion_mapa_conocimiento1_default --restart unless-stopped `
  -e "DB_DSN=mysql:host=mariadb;port=3306;dbname=mapa_php_local" `
  -e "DB_USUARIO=mapa" `
  -e "DB_CLAVE=paradigmas123" `
  -v "${PWD}/api_mapa:/app" `
  -p 8117:8117 api-mapa

# 5. Construir la imagen de front-php y encenderla
docker build -t front-php ./front_php
docker run -d --name front-php --network proyecto_php_gestion_mapa_conocimiento1_default --restart unless-stopped `
  -e "URL_API=http://api-mapa:8117" `
  -v "${PWD}/front_php:/app" `
  -p 8116:8116 front-php

# 6. phpmyadmin
docker run -d --name phpmyadmin --network proyecto_php_gestion_mapa_conocimiento1_default --restart unless-stopped `
  -e "PMA_HOST=mariadb" `
  -e "PMA_USER=mapa" `
  -e "PMA_PASSWORD=paradigmas123" `
  -p 8108:80 phpmyadmin:latest

```

**7 comandos**, con sus flags, en un orden que no se puede equivocar.
Con compose, todo eso es:

```powershell
docker compose up -d --build
```

**De dónde sale cada pedazo:**

| Lo que antes era un flag | Ahora vive en |
|---|---|
| `docker build -t … ./carpeta` | `build:` del compose, y el **`Dockerfile`** de esa carpeta dice cómo |
| `-p 8080:8080` | `ports:` |
| `-e VARIABLE=valor` | `environment:` |
| `-v origen:destino` | `volumes:` |
| `--network …` | Compose la crea sola y mete a todos adentro |
| `--name` | El nombre del servicio |
| El orden y la espera | `depends_on:` + `healthcheck:` |

Y las dos banderas del comando:

| Bandera | Qué hace | Cuándo se usa |
|---|---|---|
| `-d` | Lo deja corriendo **en segundo plano** y le devuelve la terminal | Casi siempre. Sin ella la terminal queda pegada |
| `--build` | **Reconstruye** las imágenes propias antes de encender | La primera vez, y cada vez que cambie un `Dockerfile` |

> **Por eso el curso dice «un solo comando».** No es comodidad: es que el
> sistema entero queda **escrito** en dos archivos en vez de vivir en la
> memoria de quien lo levantó la primera vez. Cualquiera lo reproduce igual,
> y eso es lo que hace que su proyecto sea entregable.


## 6. Kubernetes (y por qué este curso NO lo necesita)

Kubernetes (K8s) es el orquestador de contenedores **a escala de clúster**:
reparte contenedores entre muchas máquinas, escala réplicas según demanda,
reprograma lo que se cae y hace despliegues sin downtime. Compose y K8s no
compiten: Compose orquesta **en una máquina**; K8s orquesta **un clúster**.

| Kubernetes resuelve… | ¿Existe ese problema aquí? |
|---|---|
| Repartir contenedores entre muchas máquinas | No — todo corre en su PC |
| Escalar a N réplicas cuando sube el tráfico | No — el "tráfico" es usted con Swagger |
| Alta disponibilidad (un nodo muere → reprogramar) | No — si su PC se apaga, se acabó la clase |
| Despliegue continuo sin caída (rolling updates) | No — "actualizar" es guardar y que recargue |
| Secretos, RBAC, múltiples equipos | No — credenciales didácticas, un usuario |

Y su precio es alto: plano de control (API server, etcd, scheduler),
manifiestos YAML mucho más extensos, y conceptos nuevos (pods, ingress,
namespaces) que taparían lo que este curso sí enseña.

**La regla profesional:** Compose para desarrollo local y sistemas de un
host; Kubernetes cuando se necesita más de una máquina, réplicas elásticas o
sobrevivir a la caída de un nodo. **El puente conceptual:** ambos son YAML
declarativo describiendo estado deseado — quien domina un compose ya entiende
la mitad conceptual de K8s; le falta solo la parte de clúster.

## 7. Los comandos que este curso usa (el "pastel" — en inglés: cheat sheet)

```powershell
docker run -d --name X -p H:C -e VAR=v -v ruta:destino imagen   # crear y arrancar
docker ps                        # qué está corriendo (con -a: también lo detenido)
docker stop X / docker start X   # apagar / encender (los datos se conservan)
docker rm -f X                   # destruir (el "reset": con volumen anónimo, borra datos)
docker logs X                    # ver la salida del contenedor (errores incluidos)
docker exec X comando            # ejecutar algo DENTRO del contenedor
# … y los de todos los días en este proyecto:
docker compose up -d --build     # materializar el docker-compose.yml (con rebuild)
docker compose ps                # estado de los servicios del compose
docker compose logs api-registros # la salida de un servicio (errores incluidos)
docker compose down [-v]         # apagar todo (-v: borrar también los volúmenes)
docker compose up -d --remove-orphans  # además, borrar contenedores huérfanos (sección 5)
```

### Cómo se leen los comandos que encuentre por ahí

Fíjese en la `X` de arriba: **no es parte del comando**. Está puesta donde va
un valor suyo — el nombre de su contenedor. Y el `[-v]` va entre corchetes
cuadrados porque es **opcional**.

Esa forma de escribir no es de este documento: es la de toda la
documentación técnica. En la página de Docker, en la de Git y en cualquier
respuesta de internet va a encontrar comandos así:

```
docker stop <nombre>
docker logs <contenedor>
git clone <url>
```

**Los signos `<` y `>` NO se escriben.** Son una marca que quiere decir
*«aquí va un valor suyo»*, y lo de adentro dice qué clase de valor.

**Ejemplo completo.** La documentación dice:

```
docker stop <nombre>
```

Usted primero averigua el nombre:

```powershell
docker ps
```

```
NAMES                              PORTS
proyecto_php1-api-facturas-1       0.0.0.0:8022->8022/tcp
proyecto_php1-mariadb-1            0.0.0.0:13326->3306/tcp
```

Y después escribe **el nombre tal como aparece**, sin los signos:

```powershell
docker stop proyecto_php1-api-facturas-1
```

Lo que **no** se escribe:

| Mal | Por qué |
|---|---|
| `docker stop <nombre>` | Dejó la marca en vez de reemplazarla |
| `docker stop <proyecto_php1-api-facturas-1>` | Puso el valor, pero dejó los signos |
| `docker stop "proyecto_php1-api-facturas-1"` | Las comillas sobran aquí |

**Las tres marcas que verá siempre:**

| Marca | Significa |
|---|---|
| `<algo>` | Obligatorio. Reemplácelo por su valor, sin los signos |
| `[algo]` | Opcional. Puede omitirlo entero |
| `a\|b` | Escoja uno de los dos |

**¿Y de dónde sale el valor?** Casi siempre de un comando que lista lo que
hay: para contenedores es `docker ps`, y el nombre está en la columna
`NAMES`.


## 8. ¿Hace falta una cuenta de Docker?

**No.** Las imágenes que usa este proyecto son **públicas**: se descargan sin
registrarse, sin iniciar sesión y sin pagar nada.

Al abrir Docker Desktop puede aparecer una ventana pidiendo *Sign in* o
*Create an account*. **Ciérrela, o escoja «Continue without signing in».**
Todo funciona igual.

### ¿Y si ya tiene cuenta y entra con ella?

**También funciona**, y hasta ayuda un poco: Docker Hub le da un límite de
descargas más alto a quien tiene la sesión abierta que a quien descarga de
forma anónima.

Dicho eso, **para este proyecto no hace falta**: ni para descargar las
imágenes, ni para levantarlas, ni para trabajar.

### Lo único que sí es obligatorio

**Que Docker Desktop esté encendido.** Ábralo y espere a que termine de
arrancar: el icono de la ballena, abajo a la derecha, deja de moverse.

Si Docker está apagado, cualquier comando responde algo así:

```
error during connect: ... the docker daemon is not running
```

Ese mensaje **no es un problema del proyecto**: es Docker que no está
corriendo. Enciéndalo y repita el comando.

---

## 9. Referencias

1. Docker — *Docker overview* (documentación oficial):
   <https://docs.docker.com/get-started/docker-overview/>
2. Docker — conceptos de imágenes y contenedores:
   <https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/>
3. Docker — volúmenes y almacenamiento:
   <https://docs.docker.com/engine/storage/volumes/>
4. Docker Compose — documentación oficial:
   <https://docs.docker.com/compose/>
5. Kubernetes — *Overview* (documentación oficial):
   <https://kubernetes.io/es/docs/concepts/overview/>
6. En este repositorio: el `docker run` de la v1 en el
   [README](../README.md) y en el
   [modelo de datos de la v1](spec_kit/versiones/v1_proyecto/5_data_model.md).
