# Constitución del proyecto — Módulo de Mapa de conocimiento, en PHP

> Las reglas que **no** cambian de una versión a otra. Cuando una decisión de
> versión choca con un artículo de aquí, gana el artículo — o se cambia el
> artículo, a la vista, con su motivo escrito.

Este repositorio construye el módulo de **Mapa de conocimiento** del proyecto de
aula, en **PHP puro sobre MariaDB**. Su gemelo,
[`proyecto_paradigmas_mapa_conocimiento1`](../../../proyecto_paradigmas_mapa_conocimiento1), construye el
**mismo módulo** en Python/FastAPI sobre PostgreSQL. Los dos entregan el
mismo contrato sobre la misma tabla, y esa duplicación es a propósito:
**es el material de comparación del curso**, no un descuido.

| | Este proyecto | El gemelo |
|---|---|---|
| Lenguaje | PHP 8.3, sin framework | Python 3.12 + FastAPI |
| Motor | MariaDB 11 | PostgreSQL 16 |
| Validación | Escrita a mano, `if` por `if` | Declarada en Pydantic |
| Front | PHP + Bootstrap | Flask + Jinja2 + CSS a mano |
| Puertos | front **8116** · API **8117** · MariaDB **13333** · phpMyAdmin **8108** | otros |

---

## Artículo 1 — Propósito didáctico ante todo

Este código se lee más de lo que se ejecuta. Por eso:

- **cada archivo dice qué hace y por qué está donde está**, en su cabecera;
- se prefiere lo explícito a lo ingenioso. Un `foreach` que se entiende vale
  más que una línea que hay que descifrar;
- los comentarios explican **decisiones**, no sintaxis obvia — salvo cuando
  la sintaxis es nueva para quien lee, que en PHP pasa seguido (la promoción
  de propiedades, el `?Tipo`, el `??`).

## Artículo 1.1 — Una versión incluye SU FRONT

**Cada versión entrega su parte de la API *y* su parte de la pantalla.** No
hay una versión «de back» y otra «de front».

> **La regla operativa: una versión NO está cerrada si la API responde y la
> pantalla no.** Media versión no es una versión.

| | |
|---|---|
| **Lo terminado se le puede mostrar a alguien** | Una versión que solo trae rutas se sustenta con Postman. Una que trae pantallas se le muestra a quien la pidió |
| **El contrato se ejercita de inmediato** | Uno descubre que el JSON es incómodo **cuando le toca pintarlo**. Si el front llega tres versiones después, el contrato lleva tres versiones equivocado |
| **Es lo que pide el curso** | `ProyectosDeAula/docs/0_METODOLOGIA.md` §2, textual: *«v1 — CRUD de las tablas sin FK del módulo — API REST + Frontend funcionando»* |

### El front es un TERCER PROCESO

En su propio contenedor, hablando con la API **solo por HTTP**. Tres cosas
que se comprueban, no que se prometen:

1. Su `Dockerfile` **no instala `pdo_mysql`**. La API sí lo necesita; el
   front no — y esa ausencia no es un olvido.
2. Su servicio en el compose **no depende de `mariadb`** ni recibe sus
   credenciales.
3. Y la prueba: **apagando la API, la pantalla sigue en pie**, con su aviso
   y **sin un solo dato**.

### Podría compartir código con la API, y precisamente por eso no lo hace

La API y el front están **los dos en PHP**, en carpetas vecinas. Bastaría un
`require_once __DIR__ . '/../api_mapa/modelos/Proyecto.php'` para usar
en la pantalla las clases de la API. **Funcionaría**, y está prohibido: los
dos dejarían de ser procesos independientes, y renombrar un método adentro
rompería la pantalla **sin que nadie tocara el contrato**.

> Una separación que el lenguaje impide se cumple sola y no enseña nada. Ésta
> hay que sostenerla, y por eso es la que se aprende.

## Artículo 2 — PHP puro: sin framework y sin Composer

Ni Laravel, ni Symfony, ni Slim. **Ni `composer.json`.** Todo lo que el
proyecto usa viene con PHP: `PDO`, `curl`, `json_encode`, `session_start`.

No es nostalgia. Un framework contesta solo las preguntas que este curso
quiere que el estudiante se haga: dónde va el enrutamiento, quién valida,
quién traduce un error del motor a un código HTTP. Con framework esas
respuestas llegan hechas y no se aprenden.

**Bootstrap sí se usa, pero descargado.** Está en `front_php/publico/`, no
en un CDN: un salón sin internet tiene que ver la pantalla igual.

## Artículo 3 — Arquitectura de 3 capas estricta

```
index.php (enruta)
   → controladores/   HTTP: valida la forma del cuerpo, traduce a códigos
      → servicios/    las reglas; lanza excepciones de NEGOCIO, no códigos
         → repositorios/   el SQL; PDO con prepared statements
            → MariaDB
```

- El **controlador** no sabe SQL. El **servicio** no sabe HTTP. El
  **repositorio** no sabe de reglas.
- El servicio depende de `IRepositorioProyecto`, **la interfaz**, nunca
  de la clase concreta. Eso es lo que permite la prueba de capas.
- El `ensamblador.php` es **el único archivo que hace `new` de clases
  concretas**.

## Artículo 4 — Un solo comando para arrancar

`docker compose up -d --build` y el sistema queda en pie: base con datos,
API y pantalla. Nada de «primero corra este script».

## Artículo 5 — El esquema de la base es ARTEFACTO DADO

El script de la base lo entrega el curso
(`ProyectosDeAula/db_scripts/mysql/mapa_conocimiento.sql`). Este proyecto
**no lo rediseña**. Le aplica los cambios mínimos que hacen falta para que
cargue su propio catálogo, y **los declara uno por uno** en la cabecera de
`db/init.sql`, numerados.

Cambiar el esquema sin anotarlo es la manera más rápida de que dos módulos
del mismo proyecto dejen de encajar.

## Artículo 6 — El borrado es LÓGICO

`DELETE` marca `activo = FALSE`. La fila **se queda en la base**.

Por eso las consultas del repositorio filtran por `activo = TRUE`, todas, y
por eso la pantalla dice **«retirar»** y no «borrar»: decirle al usuario que
algo se destruyó cuando sigue guardado es mentirle.

## Artículo 7 — Persistencia y recarga

- Los datos viven en un volumen de Docker: sobreviven a `docker compose down`.
  Para volver a cero: `down -v`.
- El código va **montado** como volumen: guardar un `.php` es refrescar. PHP
  reinterpreta en cada petición, así que no hay que reconstruir la imagen
  para ver un cambio.

## Artículo 8 — Convenciones fijas

| Qué | Convención |
|---|---|
| Idioma | **Todo en español**: clases, métodos, variables, comentarios, mensajes |
| Tipos | `declare(strict_types=1);` como primera instrucción de cada archivo |
| Clases | `PascalCase` · métodos y variables `camelCase` · columnas `snake_case`, como en la base |
| Interfaces | `I` delante: `IServicioProyecto` |
| JSON | Los nombres de campo son **los de las columnas**, tal cual. Sin traducción de por medio |

## Artículo 9 — Seguridad en su justa medida académica

- **Todo SQL va en prepared statements.** Los valores nunca se concatenan.
- Los nombres de columna que entran a un `UPDATE` dinámico salen de una
  **lista blanca** del controlador, jamás del cliente.
- Toda salida a HTML pasa por `htmlspecialchars`.
- **Y la excepción, declarada:** la contraseña de la base está escrita en el
  `docker-compose.yml`, que está versionado. Es una base local, de ejemplo,
  con datos de ejemplo, y esconderla en un `.env` que también hay que
  repartir no enseñaría nada. En un proyecto real esto sería una falta grave;
  aquí es una decisión tomada a la vista.

## Artículo 10 — La API es específica, nunca genérica

Una ruta por recurso: `/api/proyecto`. **No** existe ni existirá
`/api/{tabla}` con el nombre de la tabla como parámetro.

Una API genérica es más corta de escribir y más cara de vivir: no puede
validar (cada tabla tiene sus reglas), no puede documentar (¿qué campos pide
`/api/{tabla}`?), y convierte cualquier cambio de esquema en un cambio de
contrato silencioso. **Genérico es barato de escribir y caro de vivir.**

Lo mismo del lado del front: `listar_mapa()`, no `listar($tabla)`.

## Artículo 11 — El gemelo se compara, no se copia

Este módulo existe dos veces, en dos lenguajes. La regla al tocar uno:

- **el contrato es el mismo**, y si cambia en uno tiene que cambiar en el
  otro o quedar anotado por qué no;
- **el código no se traduce línea por línea.** Cada lenguaje resuelve a su
  manera, y eso es justamente lo que hay que ver: dónde el framework ahorra
  trabajo, dónde lo cobra, y qué queda igual porque no era del lenguaje sino
  del diseño.

Los dos se pueden levantar al tiempo —usan puertos distintos— y ponerse
pantalla contra pantalla.

## Artículo 12 — La identidad visual es ARTEFACTO DADO

El sistema se construye para la **Universidad Monte Verde**, y esa
institución **ya decidió cómo se ve**. Su Manual de Identidad Visual
Corporativa está en la raíz del repositorio:
[`MANUAL_DE_MARCA.md`](../../MANUAL_DE_MARCA.md).

Igual que el esquema de la base, **el manual no se discute: se cumple.**

| | |
|---|---|
| Los valores del manual viven en | `front_php/publico/marca.css` |
| Los estilos de la aplicación usan | `var(--umv-verde)`, nunca `#1F5E4C` |
| El logosímbolo está en | `marca/` |

**Tres reglas que salen del manual y son de obligado cumplimiento:**

1. **Los colores no se cambian.** El artículo tercero de la resolución que
   adopta el manual es explícito. Un color corporativo alterado es un
   defecto, no un detalle estético.
2. **El logosímbolo respeta su tamaño mínimo y su área de reserva**, y va
   sobre banda blanca: el manual no contempla versión negativa.
3. **Los colores de estado no son los institucionales.** Un error se marca
   en rojo alerta, no en ocre: un error en ocre se lee como decoración.

**Por qué `marca.css` está aparte de los estilos de la aplicación:** porque
son dos cosas distintas. Ahí van los **valores que fija el manual** —y que no
se pueden cambiar—; en el otro archivo, **cómo se usan**. El día que la
Universidad actualice su manual, se cambia un archivo y nada más.

> **Universidad Monte Verde es una institución inventada para el curso.** El
> manual está escrito como uno real porque el ejercicio es aprender a
> trabajar con una restricción de marca, que es lo que va a encontrar en
> cualquier organización.
>
> El porqué de todo esto, con la fórmula del contraste y las referencias,
> está en [`CONCEPTOS_IDENTIDAD_VISUAL.md`](../CONCEPTOS_IDENTIDAD_VISUAL.md).
