# Proyecto de aula en PHP — Metodología de trabajo
### (SDD, versiones, Git, secretos y el stack del curso)

> **Léame primero.** Este documento define CÓMO se trabaja el proyecto de
> aula — la misma metodología del ejemplo que construimos en clase, **y con
> el mismo stack: PHP**. Lo QUE construye cada equipo está en el documento
> de su módulo:
> [Gestión Profesoral](modulo_gestion_profesoral.md) ·
> [Investigación](modulo_investigacion.md) ·
> [Innovación Curricular](modulo_innovacion_curricular.md) ·
> [Mapa de Conocimiento](modulo_mapa_conocimiento.md) ·
> [Proyecto Completo](proyecto_completo.md).

---

## 1. El método: SDD por versiones (igual que en clase)

El proyecto de aula se trabaja con **Spec-Driven Development (SDD)**:
primero la especificación, después el código, **versión por versión** —
exactamente como el ejemplo del curso:

| Ejemplo de clase | Qué demuestra |
|---|---|
| [proyecto_php1](https://github.com/ccastro2050/proyecto_php1) | La v1: una rebanada vertical con capas —API **y su pantalla**—, especificada antes de codificar |
| [proyecto_php2](https://github.com/ccastro2050/proyecto_php2) | Crecer SOBRE la v1 sin romperla: llaves foráneas, el 409 y maestro-detalle |
| [proyecto_php3](https://github.com/ccastro2050/proyecto_php3) | La fábrica: un segundo motor de base de datos sin tocar las capas de arriba |
| [proyecto_php4](https://github.com/ccastro2050/proyecto_php4) | Un tercer motor, y que el sistema **siga** abierto |

Los cuatro son PHP puro con PDO, y están construidos con el mismo método que
se les pide a ustedes. **Estudien el `docs/spec_kit/` de esos repos: ese es
el molde.**

Lo que se replica del ejemplo **es el MÉTODO, no el contenido**: la
constitución permanente, una carpeta de specs por versión con sus documentos
numerados, su lista de chequeo y su guía, los criterios de aceptación como
definición de "terminado", el cierre con tag, y la regla de que una versión
cerrada no se reabre.

### 1.1 Las reglas de oro (del mapa de versiones del curso)

1. **La especificación manda**: no se programa nada que la spec de la
   versión en curso no pida.
2. **No se anticipa**: nada de una versión futura se construye "de una
   vez" (ni JWT en la v1, ni dashboard en la v2).
3. **Una versión está TERMINADA** solo cuando pasan sus criterios de
   aceptación → commit + **tag `vN`** en main → solo entonces se escribe
   la spec de la siguiente.
4. **Una versión cerrada no se reabre**: los ajustes van en la siguiente.
5. **Regresión obligatoria**: al cerrar la vN, los criterios de TODAS las
   versiones anteriores deben seguir pasando (las versiones son
   acumulativas).

## 2. Las 4 versiones del proyecto de aula

Las antiguas "entregas" ahora son **versiones** con spec kit propio:

| Versión | Qué agrega (acumulativo) | Cierre |
|---|---|---|
| **v1** | CRUD de las **tablas sin FK** del módulo — API REST + Frontend funcionando | Criterios en verde + tag `v1` |
| **v2** | CRUD de **TODAS las tablas** (FK con listas desplegables cargadas desde la API; tablas puente) | Regresión v1 + criterios + tag `v2` |
| **v3** | **JWT + sesiones + control de acceso por roles** + CRUD de usuario/rol/rol_usuario (solo admin) | Regresión v1-v2 + criterios + tag `v3` |
| **v4** | Aplicativo completo: **10 consultas multitabla** (4+ tablas c/u), **dashboard**, **imagen corporativa**, páginas corporativas, responsive/PWA y **publicación** en servidor gratuito | Regresión total + criterios + tag `v4` |

### 2.1 Calendario y evaluación del semestre (100%)

Las fechas generales aplican a todos los grupos; la **fecha exacta** de su
grupo la fija el profesor en clase (anótela en el espacio en blanco).

| Momento | Fecha general | Fecha exacta (su grupo) | Evaluación |
|---|---|---|---|
| **Evaluación individual teórico-práctica** | Segunda semana de **septiembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** individual |
| **Entrega versión 1** | Última semana de **septiembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |
| **Entrega versión 2** | Última semana de **octubre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |
| **Entrega versión 3** | Segunda semana de **noviembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |
| **Entrega versión 4** | Última semana de **noviembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |

> **"Incluidos los commits"** significa que en la sustentación individual
> cada estudiante responde por SU rama: qué hizo, por qué, y sus commits
> lo respaldan (frecuentes, descriptivos, propios). Una rama sin commits —
> o con un solo commit gigante la noche anterior — es una sustentación
> sin evidencia.

### 2.2 Qué versión del ejemplo sirve para qué versión de ustedes

El ejemplo de clase tiene cuatro versiones y el proyecto de aula tiene otras
cuatro, **y no se corresponden una a una**. Esta tabla dice dónde mirar
cuando se atasquen — y, con la misma honestidad, dónde no hay a quién mirar.

| Su versión | Qué mirar del ejemplo | Qué buscar exactamente |
|---|---|---|
| **v1** — CRUD de las tablas sin FK | [`proyecto_php1`](https://github.com/ccastro2050/proyecto_php1) completo, y de [`php2`](https://github.com/ccastro2050/proyecto_php2) los recursos `empresa` y `persona` | Las capas con interfaces, el front controller, el 204 de la tabla vacía, el contraste PUT/PATCH, y cómo el front y la API se construyen a la vez |
| **v2** — CRUD de las tablas con FK | [`proyecto_php2`](https://github.com/ccastro2050/proyecto_php2), que es exactamente eso | Los desplegables cargados de la API, el **409** cuando la base dice que no, las llaves que genera la base, y el maestro-detalle de `factura` |
| **v3** — JWT, roles y control de acceso | **No hay ejemplo.** Está el §6.4 de este documento, y las tablas `usuario`/`rol`/`rol_usuario` que su script ya trae | Aquí van solos, y es a propósito: la v3 es donde se ve si entendieron el método o solo copiaron |
| **v4** — consultas, dashboard, publicación | De [`php3`](https://github.com/ccastro2050/proyecto_php3) y [`php4`](https://github.com/ccastro2050/proyecto_php4), el `docker-compose.yml` completo y cómo se lee la configuración del entorno | Para el despliegue. Las consultas, los gráficos y la imagen corporativa **no tienen ejemplo** |

**Dos avisos que evitan perder tiempo:**

- El ejemplo usa **una sola base de datos** (`bdfacturas`) que viene dada y no
  se toca. Ustedes tienen la suya (`db_scripts/mysql/<su_modulo>.sql`), que
  también viene dada y **tampoco se toca**.
- El ejemplo **no hace borrado lógico** (su `DELETE` borra la fila de
  verdad), y el proyecto de aula **sí lo exige**. Es de las pocas cosas donde
  copiar el ejemplo tal cual los deja mal: en su sistema, `DELETE` marca
  `activo = 0` y los listados filtran los inactivos.

## 3. El spec kit que cada equipo ESCRIBE (por versión)

Antes de programar cada versión, el equipo escribe su especificación en
`docs/spec_kit/` del repositorio de la API (el mismo formato del curso):

```
docs/spec_kit/
├── 1_constitution.md            ← UNA vez (los principios del equipo: stack
│                                   elegido, capas, español, borrado lógico,
│                                   secretos por variables de entorno…)
└── versiones/
    ├── 0_mapa_versiones.md      ← la tabla de la sección 2, con estados
    ├── v1_<nombre>/             ← 2_spec.md · 3_plan.md · 4_research.md ·
    │                              5_data_model.md · 6_contracts.md ·
    │                              7_quickstart.md · 8_tasks.md ·
    │                              9_checklist.md · GUIA_IA1.md*
    ├── v2_<nombre>/             ← los mismos, para el delta de la v2
    └── …
```

\* La `GUIA_IA<N>.md` es opcional pero recomendada: si van a construir con
ayuda de IA, escriban el prompt y las reglas COMO en las guías del curso —
la IA sigue la spec, no improvisa. Copien la estructura de los repos de
clase y adáptenla; eso ES el ejercicio.

### 3.1 Las tres compuertas

Escribir los documentos no basta: lo que separa un spec kit de una carpeta
con archivos son **tres puntos donde el equipo se detiene, revisa y no sigue
hasta que quede en verde**. Están explicados con ejemplos en el
[SDD_SPECKIT.md del ejemplo de clase](https://github.com/ccastro2050/proyecto_php1/blob/main/docs/SDD_SPECKIT.md).

| | Dónde vive | Qué pregunta | Si falla |
|---|---|---|---|
| **1. Clarificaciones** | Una sección dentro de `2_spec.md` | ¿Hay algo que dos personas del equipo leerían distinto? | Se decide en equipo (o se le pregunta al profesor) y la respuesta se escribe DENTRO de la spec — no se resuelve improvisando en el código |
| **2. Chequeo de constitución** | La última sección de `3_plan.md` | ¿El plan respeta la constitución del equipo, artículo por artículo? | O se corrige el plan, o se enmienda la constitución. Nunca "se deja pasar por esta vez" |
| **3. Lista de requisitos** | `9_checklist.md` de la versión | ¿Cada requisito es medible, único y verificable? | Se vuelve a la spec. **No se escribe código con la lista en rojo** |

> **La tercera es la mejor actividad de equipo del método:** antes de repartir
> el trabajo, cada quien revisa con la lista la parte de la spec que escribió
> otro. Las ambigüedades que uno no ve, el otro las tropieza de una — y salen
> antes de costar código. Las casillas las marca una persona: una IA puede
> ayudar a evaluar, pero no puede auto-aprobarse.

Y una regla que vale oro cuando se trabaja con IA: **la ambigüedad se MARCA,
no se rellena.** Cuando algo no está definido, se escribe
`[NECESITA ACLARACIÓN: …]` en la spec y se resuelve en la compuerta 1, antes
de planear. Si una IA les dice "asumo que…" o "por defecto voy a…",
**párenla**: eso es una ambigüedad de la especificación disfrazada de detalle
de implementación, y la respuesta va a la spec — no solo al chat. El chat se
cierra; la spec queda.

**La spec es parte de la nota**: en cada versión se evalúa que el spec kit
exista, esté completo y **coincida con lo construido** (si el código hace
algo que la spec no dice, uno de los dos está mal).

## 4. Los dos repositorios (y las reglas de GitHub)

El sistema son **DOS proyectos separados**, cada uno con su repositorio:

| Repositorio | Qué es | Regla de oro |
|---|---|---|
| `<equipo>-api` | El backend: REST + JSON, conecta a la BD | NO genera HTML |
| `<equipo>-frontend` | La interfaz: consume la API por HTTP | NO se conecta a la BD |

**Requisitos obligatorios de ambos repositorios:**

1. **Privados.** El código del equipo no es público.
2. **Invitar al profesor** como colaborador desde el primer día:
   *Settings → Collaborators → Add people* → **`ccastro2050`**.
   Sin acceso del profesor, la entrega no existe.
3. El spec kit vive en el repo de la API (`docs/spec_kit/`).

> **¿Por qué dos repositorios, si el ejemplo de clase tiene uno solo con dos
> carpetas?** Porque son dos cosas distintas: el ejemplo separa **procesos**
> —la API y el front corren en contenedores separados, y por eso la pantalla
> sigue en pie cuando la API se cae—, y el proyecto de aula separa además
> **repositorios**, para que cada equipo practique el flujo de ramas y Pull
> Requests en los dos lados.
>
> La regla que importa es la misma en los dos casos, y es la de la fila de
> arriba: **el front jamás toca la base de datos.** En el ejemplo eso se hace
> cumplir en el `docker-compose.yml` —el servicio del front no recibe las
> credenciales de la base ni depende de ella— y vale la pena que lo copien.

### 4.1 El flujo de ramas (obligatorio desde la v1)

- **NADIE trabaja en `main`. Nunca.** Ni un commit directo.
- **Cada estudiante tiene SU rama** (nómbrela con su nombre:
  `rama-mariana`, `rama-jorge`) y trabaja siempre ahí.
- El equipo designa **UN encargado del main** (el integrador). Ese
  estudiante TAMBIÉN tiene su propia rama para su trabajo — su rol extra
  es ser el único que integra.
- Todo llega a `main` por **Pull Request**: el autor abre el PR desde su
  rama, el encargado del main lo revisa (¿compila? ¿cumple la spec? ¿los
  criterios siguen pasando?) y SOLO el encargado hace el merge.
- El cierre de cada versión es un **tag `vN` sobre main** (lo pone el
  encargado cuando los criterios de aceptación pasan).
- Commits pequeños, frecuentes y con mensajes descriptivos en español —
  "avances" no es un mensaje.

```
rama-mariana ──●──●──●──╮ PR
rama-jorge   ──●──●─────┤ PR      (revisa y hace merge: SOLO el encargado)
rama-andres  ──●──●──●──┤ PR
                        ▼
main         ────────●──●──●── tag v1 ──●──●── tag v2 ──…
```

## 5. Secretos: variables de entorno, SIEMPRE

**Regla innegociable:** ningún secreto va escrito en el código ni en
archivos versionados. Son secretos: la **cadena de conexión** a la BD (y
su contraseña), el **secreto de firma del JWT**, y cualquier clave de
servicios externos.

> **Aclaración importante del profesor:** en los repositorios del curso
> (`proyecto_php1`…`php4`) las credenciales están escritas a la vista **a
> propósito y solo por didáctica** — el Artículo 9 de su constitución lo
> dice con todas las letras: es un entorno de juguete que corre en su PC y
> jamás se despliega. El proyecto de aula es distinto: **se publica en un
> servidor real (v4)**, así que ahí la regla aplica completa desde la v1.
>
> Copien del ejemplo la ESTRUCTURA (un solo sitio que lee la configuración,
> el front sin credenciales de base), no los valores.

Cómo cumplirla **en PHP**:

1. El código lee los secretos con **`getenv()`**, nunca escritos en el
   archivo. En el ejemplo de clase es exactamente así, y todo pasa por un
   solo sitio (`servicios/ensamblador.php`):

   ```php
   $dsn     = getenv('DB_DSN')     ?: 'mysql:host=localhost;port=3306;dbname=investigacion';
   $usuario = getenv('DB_USUARIO') ?: 'root';
   $clave   = getenv('DB_CLAVE')   ?: '';
   ```

   > El `?:` de la derecha es un valor por defecto **para desarrollo local**,
   > y solo puede serlo si no es un secreto de verdad. Una contraseña real
   > ahí es lo mismo que quemarla en el código.

2. **Con Docker**, las variables las pone el compose y no hay archivo que se
   pueda subir por error:

   ```yaml
   api:
     environment:
       DB_DSN: mysql:host=mariadb;port=3306;dbname=investigacion
       DB_USUARIO: ${DB_USUARIO}      # ← sale del .env del compose
       DB_CLAVE: ${DB_CLAVE}
       JWT_SECRET: ${JWT_SECRET}
   ```

3. **Sin Docker** (XAMPP, o PHP directo), hace falta cargar el `.env` a
   mano. PHP no lo hace solo, y **no hace falta una librería**: son diez
   líneas, y escribirlas es mejor que no entender de dónde salen las
   variables.

   ```php
   // config/cargar_env.php — se llama UNA vez, al principio de index.php
   function cargarEnv(string $ruta): void
   {
       if (!is_file($ruta)) {
           return;   // en producción las variables ya vienen del servidor
       }
       foreach (file($ruta, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $linea) {
           if (str_starts_with(trim($linea), '#')) {
               continue;                      // un comentario
           }
           [$nombre, $valor] = array_pad(explode('=', $linea, 2), 2, '');
           putenv(trim($nombre) . '=' . trim($valor));
       }
   }
   ```

4. El archivo **`.env` NUNCA se sube a git** — va en el `.gitignore` desde el
   primer commit.
5. El repo SÍ incluye un **`.env.example`**: las mismas variables con valores
   de mentira, para que cualquier integrante (o el profesor) sepa qué
   configurar.
6. En el servidor de la v4, los secretos se configuran en el panel de
   variables de entorno del servicio — jamás en el código desplegado.
7. **Si un secreto se subió por error**: cambiarlo (rotarlo) de inmediato;
   borrarlo del último commit no basta — quedó en la historia.

En la rúbrica: un secreto quemado en el código **anula el criterio de
seguridad de la versión**.

## 6. El stack: PHP

**El proyecto de aula se hace en PHP**, con el mismo stack del ejemplo de
clase. No es una elección de cada equipo: es el curso.

| Pieza | Qué se usa | Dónde verlo hecho |
|---|---|---|
| Lenguaje | **PHP 8.3+**, con `declare(strict_types=1)` en todo archivo | cualquier `.php` del ejemplo |
| Enrutamiento | Un **front controller** (`index.php`) con comparaciones de ruta legibles | `api_facturas/index.php` |
| Acceso a datos | **PDO** con *prepared statements*. El SQL queda a la vista | `repositorios/Repositorio*MariaDB.php` |
| Base de datos | **MySQL / MariaDB** — los scripts de su módulo están en `db_scripts/mysql/` | `db/mariadb/init.sql` |
| Capas | controlador → servicio → repositorio, comunicados por `interface` nativas de PHP | las carpetas de `api_facturas/` |
| Frontend | **PHP también**: plantillas renderizadas en el servidor, que hablan con la API por **cURL** | `front_php/` |
| Estilos | Bootstrap **guardado en el repositorio**, no traído de un CDN | `front_php/publico/` |

### 6.1 Sin framework y sin Composer (y qué hacer si necesitan una librería)

El ejemplo de clase es **PHP puro**: cero dependencias, cero `composer.json`,
cero `vendor/`. Y el proyecto de aula empieza igual, por la misma razón:
**lo que se está evaluando es que ustedes entiendan qué hace cada capa**, y
un framework que resuelve el enrutamiento, la validación y el acceso a datos
esconde exactamente lo que hay que aprender.

Eso **no** significa que una librería esté prohibida para siempre. Significa
que se decide como se decide todo en este método:

1. el equipo lo escribe en **su constitución**, con la razón;
2. el profesor lo aprueba;
3. y queda registrado en el `4_research.md` de la versión donde entró, con la
   alternativa que se descartó.

Una dependencia declarada y justificada es una decisión de arquitectura. Una
dependencia que apareció en el `composer.json` sin que nadie sepa quién la
puso es deuda.

> **Antes de pedir una librería, mire cuánto cuesta no pedirla.** El JWT de
> la v3 —que es el caso donde más se pide— son unas treinta líneas de PHP, y
> están abajo en §6.4.

### 6.2 Frontend en PHP: qué significa exactamente

El front del ejemplo es PHP que **renderiza HTML en el servidor** y habla con
la API por HTTP. No es JavaScript llamando a la API desde el navegador, y la
diferencia importa:

- con render en el servidor, **quien llama a la API es el proceso del
  front** — que es justo el dibujo de la arquitectura que se está enseñando;
- con JavaScript, quien llama es el navegador, y aparecen CORS, promesas y
  errores asíncronos antes de haber entendido qué es una capa.

**JavaScript sí se usa**, pero para lo que es: interacción en la pantalla.
En la v4 van a necesitarlo para los gráficos del dashboard, y está bien.

Y la regla que no se negocia: **en el repo del frontend no puede haber un
solo `new PDO(...)`.** Si el front puede llegar a la base, la separación es
un dibujo, no una arquitectura.

> **Cómo comprobarlo, que es más convincente que prometerlo:** apaguen la API
> con la base de datos encendida y abran el front. Tiene que seguir en pie,
> con su menú y un aviso de que el servicio no está disponible, **y sin una
> sola fila**. Si sigue mostrando datos, alguien abrió una conexión que no
> debía. Está hecho así en el ejemplo (`pruebas_humo/humo_front.py`).

### 6.3 Una versión incluye SU FRONT

Ésta es la regla que más cuesta al principio y la que más se agradece
después: **una versión no está terminada si la API responde y la pantalla
no.** El front de lo que esa versión construye se hace **al mismo tiempo**
que la API, no al final del semestre.

Por qué, con la razón concreta: los desajustes entre lo que la API devuelve y
lo que la pantalla necesita —el número que viaja como texto, el campo que se
llama distinto, la lista vacía que nadie sabía interpretar— aparecen **el día
que alguien pinta una tabla**. Descubrirlos en la v1, con seis tablas de
catálogo, es corregir en diez minutos. Descubrirlos en la v4 es rehacer.

Es el Artículo 1.1 de la constitución del ejemplo, y aplica igual aquí.

### 6.4 El JWT de la v3, en PHP puro

Un JWT firmado con HS256 son tres partes en base64 separadas por puntos, y la
tercera es un HMAC de las dos primeras. PHP trae todo lo que hace falta:

```php
function firmarToken(array $datos, string $secreto, int $minutos = 60): string
{
    $cabecera = ['alg' => 'HS256', 'typ' => 'JWT'];
    $datos['exp'] = time() + $minutos * 60;      // cuándo caduca

    $a = base64UrlCodificar(json_encode($cabecera));
    $b = base64UrlCodificar(json_encode($datos));
    $firma = hash_hmac('sha256', "$a.$b", $secreto, true);

    return "$a.$b." . base64UrlCodificar($firma);
}

function verificarToken(string $token, string $secreto): ?array
{
    $partes = explode('.', $token);
    if (count($partes) !== 3) {
        return null;
    }
    [$a, $b, $firmaRecibida] = $partes;

    // hash_equals compara en tiempo constante: con == se puede adivinar la
    // firma midiendo cuánto tarda en fallar. No es paranoia, es el ataque.
    $firmaEsperada = base64UrlCodificar(hash_hmac('sha256', "$a.$b", $secreto, true));
    if (!hash_equals($firmaEsperada, $firmaRecibida)) {
        return null;
    }

    $datos = json_decode(base64UrlDecodificar($b), true);
    if (($datos['exp'] ?? 0) < time()) {
        return null;                              // caducó
    }
    return $datos;
}
```

(`base64UrlCodificar` es `rtrim(strtr(base64_encode($x), '+/', '-_'), '=')`, y
la inversa hace lo contrario.)

**Las contraseñas NO se hashean a mano.** Para eso PHP trae
`password_hash($clave, PASSWORD_DEFAULT)` y `password_verify($clave, $hash)`,
que usan bcrypt, ponen la sal solos y se actualizan con las versiones del
lenguaje. Escribir eso a mano sí sería un error.

> **Y el `JWT_SECRET` va por variable de entorno**, como todo lo demás (§5).
> Un secreto de firma quemado en el código anula el criterio de seguridad de
> la versión.

### 6.5 La publicación de la v4

PHP se publica en más sitios que casi cualquier stack, y hay dos caminos:

| Camino | Qué es | Cuándo conviene |
|---|---|---|
| **Hosting compartido con PHP + MySQL** | Se sube por FTP o Git y ya. La base de datos la crean en su panel | Es el más simple, y suele alcanzar |
| **Plataforma con contenedores** | Se publica el `Dockerfile` / `docker-compose.yml` que ya escribieron | Si trabajaron con Docker y quieren desplegar lo mismo que probaron |

**Los planes gratuitos cambian todo el tiempo**, así que este documento no
nombra proveedores: la lista vigente la valida el profesor cuando se acerque
la v4. Lo que sí se exige, sea cual sea el sitio:

- **el front y la API publicados por separado**, como en desarrollo;
- **los secretos en el panel de variables de entorno del servicio**, jamás en
  el código desplegado;
- y que el sitio **funcione**, no que exista: la sustentación se hace sobre
  la URL publicada.

## 7. Reglas técnicas del sistema (aplican a todos los módulos)

- **API REST**: JSON siempre; códigos HTTP correctos (200/201, 400, 401,
  403, 404, 422, 500); y **un juego de endpoints ESPECÍFICO por cada tabla**:

  ```
  GET /api/sede          GET /api/sede/{id}          POST /api/sede
  PUT /api/sede/{id}     PATCH /api/sede/{id}        DELETE /api/sede/{id}

  GET /api/modalidad     GET /api/modalidad/{id}     POST /api/modalidad
  ...  y así con cada tabla del módulo
  ```

  El borrado es **lógico** (`activo = 0`) y los listados filtran los
  inactivos.

### 7.0 El borrado lógico y la columna que falta (léalo ANTES de la v1)

Aquí hay algo que conviene saber antes de escribir el primer repositorio, y
no a mitad de camino:

> **Los scripts de `db_scripts/mysql/` traen la columna `activo` únicamente
> en las tablas `rol` y `usuario`.** En las demás —las 17, 19 o 23 tablas de
> su módulo— **no está**.

Es decir: la regla del borrado lógico y el script que se les entrega **no
coinciden todavía**. No es una trampa ni un descuido que haya que disimular;
es material que hay que ajustar, y ajustarlo es parte del trabajo de la v1.

**Lo que hace cada equipo:**

1. Agrega la columna a las tablas de la versión que esté construyendo:

   ```sql
   ALTER TABLE area_conocimiento
       ADD COLUMN activo TINYINT(1) NOT NULL DEFAULT 1;
   ```

2. **Lo documenta en su `5_data_model.md`**, con esta misma razón. Un
   artefacto dado que cambia sin que nadie diga por qué es peor que uno que
   no cambia.
3. Y deja el `ALTER` (o el script completo ya corregido) **en el repositorio**,
   para que cualquiera pueda levantar la base desde cero.

> **Esto no es una excepción al método: es el método.** El ejemplo de clase
> hizo exactamente lo mismo con su propia base: encontró dos defectos en los
> procedimientos almacenados que venían dados —uno no devolvía un campo que
> la pantalla necesitaba, otro dejaba modificar una factura ya anulada—, los
> corrigió, y lo dejó escrito en el `4_research.md` de la versión donde
> apareció. Búsquenlo como «D6» en `proyecto_php2`.
>
> Lo que separa una corrección de un parche es que la corrección **está
> escrita con su motivo**.

**Y el detalle que decide si el borrado lógico sirve de algo:** no basta con
marcar `activo = 0` al eliminar. Los listados tienen que **filtrar**
(`WHERE activo = 1`), y los desplegables de la v2 también — si un catálogo
inactivo sigue apareciendo como opción, el borrado lógico no está haciendo
nada. En la rúbrica se revisan las dos mitades.

### 7.1 Por qué el proyecto pide endpoints específicos y no una API genérica

Al ver ocho o diez tablas parecidas, la idea aparece sola: **una sola ruta con
el nombre de la tabla como parámetro** —`GET /api/{tabla}`, `POST
/api/{recurso}`— atendida por un controlador, un servicio y un repositorio
únicos que sirven para todo.

Es una buena idea en su lugar, y **en este proyecto no es el lugar**. Vale la
pena explicar por qué, porque el argumento sirve mucho más allá del curso.

#### La distinción que hay que entender: prototipo contra producción

Una API genérica **sirve para un prototipo**. Es más corta, se escribe en una
tarde y demuestra que la idea funciona. El problema no es que esté mal escrita:
es que **un prototipo y un sistema en producción se optimizan para cosas
distintas**.

| | Un prototipo | Producción |
|---|---|---|
| **¿Cuántas veces se escribe?** | Una | Una |
| **¿Cuántas veces se LEE y se cambia?** | Casi ninguna: se tira | Durante años, y casi siempre por alguien que no lo escribió |
| **¿Quién lo consume?** | Quien lo escribió, ese mismo día | Otro equipo, otro sistema, y usted mismo seis meses después |

Genérico es **barato de escribir y caro de vivir**. Específico es **caro de
escribir una vez y barato de vivir**. En un prototipo gana el primero porque
no hay «vivir». En producción gana el segundo, y por goleada.

De ahí salen seis consecuencias concretas:

| # | Lo que pasa en producción | Por qué el molde genérico no aguanta |
|---|---|---|
| 1 | **El contrato hay que LEERLO, no recordarlo** | Swagger muestra `/api/{tabla}`: un hueco. Quien abre la API no sabe qué recursos hay ni qué campos lleva cada uno. Y este proyecto se sustenta proyectando Swagger: **si no dice qué hay, no hay qué sustentar** |
| 2 | **Las tablas se van diferenciando** | Toda tabla que sobrevive acumula reglas propias: una no se borra, otra audita, otra tiene un campo calculado. El molde obliga a meter condiciones «si la tabla es X…», y ahí el ahorro se acabó: queda un intérprete escrito a mano, peor que los diez controladores que se querían evitar |
| 3 | **Los permisos son POR RECURSO** | «El coordinador ve sedes pero no roles» no cabe en una ruta única: o se autoriza de más, o se agrega un mapa de reglas por tabla — que es la lista de controladores otra vez, hecha a mano y sin ayuda del compilador |
| 4 | **Hay que operar el sistema** | Métricas, registros, límites de tasa, alertas: todo se agrupa por ruta. Con `/api/{tabla}` todo el tráfico es **una sola línea** en el tablero, y nunca se puede decir «el endpoint de sedes está lento» |
| 5 | **Hay que cambiar un recurso sin tocar los demás** | Agregar un campo, cambiar una validación, deprecar algo. Con un molde compartido, **cada cambio pequeño toca las diez tablas**: el riesgo se multiplica por diez |
| 6 | **Los errores en ejecución cuestan incidentes** | Con clases de petición tipadas, un campo mal escrito no compila. Con un diccionario genérico, se descubre en la sustentación o, peor, en producción |

#### Y la excepción honesta, para que esto no sea dogma

**Sí existen APIs genéricas en producción**, y buenas: PostgREST, Hasura, los
paneles de administración que exponen tablas. La diferencia es que en esos
casos **lo genérico es el producto entero**: publican un esquema completo
—generado de la base—, tienen su modelo de permisos por fila y por columna, y
su contrato *es* «esto expone la base de datos».

Lo que no funciona es **la mitad**: una API de dominio, escrita a mano, con un
pedazo genérico adentro. Ahí se pagan los costos de las dos formas y no se
cobra la ventaja de ninguna.

> **De dónde sale esto.** No es una preferencia de nadie: sale de haberlo
> hecho de las dos formas. El ejemplo de referencia del curso se construyó
> primero con una ruta genérica — quedó más corto, funcionaba y pasaba sus
> pruebas —, y al abrir Swagger para sustentarlo no se veía un solo recurso
> con nombre. Se rehízo con endpoints específicos.
>
> Se cuenta aquí para que usted no tenga que pagar la misma tarde.
- **Separación estricta**: el frontend consume la API; si el frontend toca
  la BD, la arquitectura está rota (criterio de rúbrica).
- **v3 — seguridad**: `POST /api/login` entrega el JWT (§6.4); comprobación
  de autenticación y de rol **antes de llegar al controlador**, en el front
  controller de la API; el frontend guarda el token en la sesión de PHP, lo
  envía en `Authorization: Bearer`, arma el menú según roles, y solo el
  administrador ve el CRUD de usuarios/roles. Contraseñas **hasheadas con
  `password_hash()`**, nunca en texto plano.

  > La base de datos de su módulo ya trae las tablas `usuario`, `rol` y
  > `rol_usuario`. La del ejemplo de clase trae además unos procedimientos
  > almacenados de control de acceso que el curso dejó sin usar a propósito —
  > mírenlos si quieren ver una forma de resolverlo desde la base.
- **v4 — cierre**: 10 consultas multitabla (mínimo 4 tablas cada una)
  expuestas como endpoints y presentadas en el dashboard con gráficos;
  páginas corporativas (Home, Productos/Servicios, Soporte, Contacto,
  Sobre Nosotros) con imagen corporativa de la empresa hipotética; diseño
  responsive (PWA si es posible); publicación en un servidor real (§6.5).
- **Datos iniciales**: las tablas de catálogo se cargan con los datos de
  referencia del Excel del `Mapa_conocimiento/` (los conteos por tabla
  están en el documento del módulo).
- **Stack**: **PHP**, según la sección 6. Lo que cada equipo sí decide —y
  escribe en su constitución— son las cosas de adentro: cómo organiza sus
  carpetas, si usa Docker o XAMPP, cómo nombra sus clases, y si pide alguna
  librería con su justificación.
- **Scripts de la base**: el de su módulo está en
  `db_scripts/mysql/<su_modulo>.sql`, en dialecto MySQL/MariaDB — el mismo
  motor del ejemplo de clase. Se ejecuta tal cual: **no se reescribe la base
  de datos**, igual que en el curso.

## 8. Rúbrica de evaluación

Aplica en cada versión; el profesor asigna el peso por criterio. Cada
criterio se califica en una de dos franjas: **Cumple (de 3.0 a 5.0**,
según la calidad de lo entregado**)** o **No cumple (de 0 a 2.9)**.

| Criterio | Cumple (3.0 – 5.0) | No cumple (0 – 2.9) |
|---|---|---|
| **Especificación (SDD)** | Spec kit de la versión completo ANTES del código, **con sus tres compuertas pasadas**: ningún `[NECESITA ACLARACIÓN]` pendiente, chequeo de constitución hecho y `9_checklist.md` firmado; criterios de aceptación verificables; lo construido coincide con la spec | No hay spec, se escribió después "para cumplir", contradice lo construido, o el `9_checklist.md` está sin pasar |
| **Funcionalidad de la API** | Los endpoints de la versión funcionan con JSON y códigos correctos | Endpoints caídos o sin JSON |
| **Funcionalidad del Frontend** | Las interfaces consumen la API y son usables. **El front de la versión se entrega CON ella**, no después | No funcionan, van directo a la BD, o "el front lo hacemos al final" |
| **Separación API/Front** | El front jamás toca la BD: ni un `new PDO(...)` en su repositorio. **Se comprueba apagando la API con la base encendida**: la pantalla sigue en pie y sin datos | No hay separación, o la pantalla sigue mostrando datos con la API apagada |
| **Stack** | PHP según la §6: capas con interfaces, PDO con prepared statements, front controller. Las librerías que haya, declaradas en la constitución | Framework o librerías que la constitución no declara; SQL concatenado en vez de prepared statements |
| **Seguridad (v3+) y secretos (todas)** | JWT + roles funcionando; contraseñas hasheadas; **cero secretos en el código**, `.env.example` presente | Sin autenticación, contraseñas o secretos quemados/en texto plano |
| **Borrado lógico** | En las tablas de la versión: `DELETE` marca `activo = 0`, **y los listados y los desplegables filtran los inactivos**. La columna agregada donde faltaba, documentada en el `5_data_model.md` | Borrado físico, o se marca pero los listados siguen mostrando los inactivos |
| **Git y GitHub** | Repos privados con el profesor invitado; cada estudiante en su rama; TODO por PR; solo el encargado hace merge; tags v1…vN; commits descriptivos | Commits directos a main, repo público o sin el profesor, "un solo commit con todo" |
| **Dashboard y consultas (v4)** | 10 consultas de 4+ tablas con gráficos claros | Menos de 10 consultas, consultas de menos de 4 tablas, o sin dashboard |
| **Imagen corporativa y responsive (v4)** | Identidad coherente; todo responsive | Sin identidad o no responsive |
| **Publicación (v4)** | Publicado, funcional, con secretos en variables de entorno del servidor, y **front y API por separado** | No publicado, con secretos expuestos, o todo en un solo servicio |

Dentro de la franja "Cumple", la nota (3.0 a 5.0) refleja la calidad:
completitud, solidez ante errores, claridad del código y de la spec, y la
sustentación individual.

**Entregar en cada versión:** enlaces a los 2 repos (con el tag `vN`
puesto) + evidencia del quickstart de su spec pasando. En la v4, además:
URL del sitio publicado.
