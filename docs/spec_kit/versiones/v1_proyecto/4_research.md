# Investigación y decisiones — v1: `proyecto` (PHP)

Cada decisión con su alternativa descartada. Una decisión sin alternativa no
es una decisión: es lo primero que se le ocurrió a alguien.

## D-v1-1 — PHP puro, sin framework y sin Composer

**Alternativas.** (a) Laravel o Slim. (b) PHP puro con las extensiones que
trae de fábrica.

**Decisión: (b).** Un framework contesta solo las preguntas que este curso
quiere que el estudiante se haga: dónde va el enrutamiento, quién valida,
quién traduce un error del motor a un código HTTP.

**Consecuencias.** Más código escrito a mano, y hay que explicar cosas que un
framework escondería (`php://input`, `http_response_code`). A cambio, no hay
magia: todo lo que pasa está escrito en un archivo del repositorio.
**Estado:** vigente.

## D-v1-2 — MariaDB, y no PostgreSQL como el gemelo

**Contexto.** El mismo módulo existe en `proyecto_paradigmas_mapa_conocimiento1`,
sobre PostgreSQL.

**Alternativas.** (a) Usar PostgreSQL también, para que la única diferencia
entre los dos proyectos sea el lenguaje. (b) Usar MariaDB.

**Decisión: (b)**, por dos razones:

1. **El script que el curso entrega para este módulo es MySQL**:
   `ProyectosDeAula/db_scripts/mysql/mapa_conocimiento.sql`, y el modelo
   relacional viene en un `.mwb` — un archivo de MySQL Workbench. Derivar de
   ese script es partir del artefacto que el estudiante tiene en la mano.
2. La ruta de PHP del curso (`proyecto_php1` … `proyecto_php4`) empieza en
   MariaDB. Este proyecto es una v1, y la v1 de esa ruta es MariaDB.

**Consecuencias.** La comparación con el gemelo tiene **dos** variables, no
una: cambia el lenguaje y cambia el motor. Se anota aquí para que nadie
atribuya al lenguaje algo que era del motor — por ejemplo, `FOUND_ROWS`, que
es un detalle de MariaDB y no de PHP. **Estado:** vigente.

## D-v1-3 — La v1 se construye sobre `proyecto`

**Alternativas.** (a) Empezar por una tabla de catálogo pequeña. (b) La tabla
sin clave foránea con más campos del módulo.

**Decisión: (b).** Con 8 columnas, el contraste
entre PUT y PATCH se nota; con tres columnas no. Y sin claves foráneas, la
v1 no tiene que hablar de integridad referencial todavía: eso es la v3.

**Estado:** vigente.

## D-v1-4 — El borrado es LÓGICO, y el esquema dado no lo traía

**Contexto.** El script del curso no tiene ninguna columna para marcar una
fila retirada.

**Alternativas.** (a) Borrado físico, como en `proyecto_php1`. (b) Agregar
`activo` a las 18 tablas del módulo y borrar lógicamente.

**Decisión: (b).** En un sistema de gestión académica, borrar de verdad una
fila que otras referencian es perder información que alguien va a necesitar.
Y didácticamente da más: obliga a que **todas** las consultas filtren, que es
un error clásico cuando se agrega una consulta nueva meses después.

**Consecuencias.** El esquema dado se modifica, y por eso el cambio está
numerado como `[C4]` en la cabecera de `db/init.sql`. Y hay una asimetría que
conviene ver: la API responde 404 para una fila retirada, pero la fila está
ahí. **Para quien usa la API son lo mismo; para quien mira la base, no.**
**Estado:** vigente.

## D-v1-5 — El sobre del error se entrega tal como está documentado

**Contexto.** El contrato de este módulo (y el del gemelo) documenta un sobre
plano: `{"estado":…, "mensaje":…, "detalle":…}`, con `errores[]` en el 422.

**Lo que se descubrió al comparar.** El gemelo en FastAPI **no lo entrega
así**. Se comprobó pidiéndole una fila inexistente:

```json
{"detail":{"estado":404,"mensaje":"… no encontrado.","detalle":"…"}}
```

y un cuerpo incompleto devuelve el formato crudo de Pydantic, en inglés
(`"Field required"`). Su documentación describe un sobre que su API no
entrega, porque el framework envuelve todo en `detail`.

**Decisión.** Aquí se entrega **el sobre documentado, exactamente**. No por
purismo: es que sin framework de por medio, no hay nada que envuelva la
respuesta, así que cumplirlo no cuesta nada.

**Consecuencias.** El `cliente_api.php` del front es más simple que el del
gemelo: no tiene que desenvolver `detail` ni traducir del inglés. Ese ahorro
es real y se puede medir en líneas. **Estado:** vigente.

## D-v1-6 — El front no comparte una línea con la API, pudiendo

**Contexto.** Los dos están en PHP, en carpetas vecinas. Un
`require_once __DIR__ . '/../api_mapa/modelos/Proyecto.php'`
funcionaría.

**Alternativas.** (a) Compartir el modelo: menos código duplicado.
(b) Prohibirlo: el front trabaja con arrays.

**Decisión: (b).** Compartir el modelo haría que renombrar un método dentro
de la API rompiera la pantalla **sin que nadie tocara el contrato**. Dejarían
de ser dos procesos y serían uno repartido en dos carpetas.

**Consecuencias.** El front repite los nombres de los campos. Es duplicación
de verdad, y se acepta a cambio de que la separación sea real. Se comprueba
apagando la API: la pantalla queda en pie sin datos. **Estado:** vigente.

## D-v1-7 — El listado no muestra todas las columnas

**Contexto.** La ficha tiene 8 campos.

**Decisión.** El listado muestra 6 columnas
y el resto vive en el formulario. Una tabla con quince columnas no se lee, y
la pantalla que no se lee no sirve aunque tenga todos los datos.

**Estado:** vigente.
