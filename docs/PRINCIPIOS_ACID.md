# Los principios ACID, vistos en este proyecto

> Documento conceptual del curso. Qué garantiza una base de datos
> transaccional, por qué este módulo la necesita, y **dónde se ve cada una
> de las cuatro letras en el código que hay aquí** — no en un ejemplo de
> libro.

---

## 1. Qué es una transacción

Una transacción es **un grupo de operaciones que el motor trata como una
sola**: o pasan todas, o no pasa ninguna. No es una idea abstracta: es lo
que evita que la base quede a medio camino cuando algo falla en la mitad.

`MariaDB` las trae de fábrica. Las cuatro garantías que ofrece se conocen
por sus iniciales en inglés: **A**tomicity, **C**onsistency,
**I**solation, **D**urability.

## 2. Las cuatro letras, con lo que hay en este repositorio

### A — Atomicidad: todo o nada

**Dónde se ve aquí:** en `db/init.sql`. Ese script crea las tablas del
módulo y carga las 14 filas de la tabla `proyecto`. Si el motor fallara a la
mitad, no quedaría media base: quedaría **ninguna**, y el contenedor
volvería a intentarlo desde cero en el siguiente arranque.

Y en cada escritura de la API, aunque sea una sola instrucción: un
`UPDATE` que toca cinco columnas las toca **todas o ninguna**. Nunca deja
tres cambiadas y dos como estaban.

```sql
BEGIN;
UPDATE proyecto SET activo = 0 WHERE id = …;
ROLLBACK;          -- la fila vuelve a estar activa: no pasó nada
```

### C — Consistencia: la base no acepta quedar mal

**Dónde se ve aquí:** en las restricciones que el esquema ya declara. La
llave primaria de `proyecto` impide dos fichas con el mismo `id` —
pruébelo: un `POST` repetido responde **500** con el mensaje del motor, y
**la fila no se duplica**.

Las claves foráneas del módulo hacen lo mismo con las tablas que las
tienen. La v1 no las usa todavía, pero **ya están creadas**: el esquema es
artefacto dado, y la v3 las va a necesitar.

> Ojo con la palabra: «consistencia» aquí NO significa «los datos son
> correctos». Significa que la base **no se deja llevar a un estado que
> viole sus propias reglas**. Que un dato sea verdadero es problema de
> quien lo escribe.

### I — Aislamiento: dos personas a la vez

**Dónde se ve aquí:** dos personas abren la pantalla y retiran el mismo
proyecto al tiempo. Sin aislamiento, las dos leen «está activo» y las dos
escriben; con aislamiento, el motor las ordena: la primera lo retira y la
segunda recibe **404**, porque el `UPDATE` del repositorio lleva
`AND activo = TRUE` y ya no encuentra la fila.

Ese `AND` no es decoración: es lo que convierte «retirar dos veces» en un
404 honesto en vez de en dos 200 mentirosos.

### D — Durabilidad: lo confirmado no se pierde

**Dónde se ve aquí:** el volumen de Docker. Los datos viven en un volumen,
no dentro del contenedor:

```powershell
docker compose down     # se lleva el contenedor…
docker compose up -d    # …y las fichas siguen ahí
docker compose down -v  # ESTO sí las borra: la -v borra el volumen
```

Una escritura confirmada sobrevive a que el contenedor se caiga, a que se
reinicie el computador y a un `down` sin `-v`. Esa es la promesa.

## 3. Qué NO hace esta versión, y por qué

| | |
|---|---|
| **No abre transacciones a mano** | Cada operación de la v1 toca **una fila de una tabla**, y el motor ya la envuelve en su propia transacción. Escribir `BEGIN`/`COMMIT` alrededor de un solo `UPDATE` no agrega ninguna garantía: da la impresión de rigor sin aportarlo |
| **No usa niveles de aislamiento** | Ninguna operación lee y escribe en dos pasos, así que no hay ventana entre leer y decidir |
| **No tiene disparadores ni cálculos en la base** | Nada se calcula a partir de otra tabla todavía |

**Y eso cambia en la v3.** Cuando aparezcan las tablas con clave foránea y
haya que escribir un maestro con su detalle —una fila padre y varias
hijas—, ahí sí hará falta una transacción explícita: si la tercera hija
falla, el padre no puede quedar solo. Ese será el momento de volver a este
documento.

## 4. ACID contra BASE, en una tabla

| | ACID (`MariaDB`, y este proyecto) | BASE (muchas bases NoSQL) |
|---|---|---|
| Cuándo cuadran los datos | **Al confirmar**, siempre | «En algún momento» (*eventual consistency*) |
| Qué prioriza | Que nunca se vea un estado inválido | Estar disponible y responder rápido |
| Cuándo conviene | Datos que tienen que cuadrar: matrículas, notas, nóminas | Datos que toleran ir atrasados: un contador de visitas, un caché |

Un módulo académico está del lado izquierdo: un proyecto no puede existir a
medias, y una ficha retirada no puede seguir apareciendo en un listado y
en otro no.

## 5. Para comprobarlo usted mismo

```powershell
# Atomicidad: lo que no se confirma, no queda
docker compose exec mariadb …
```

El comando exacto para su motor está en el paso 5 de
[7_quickstart.md](spec_kit/versiones/v1_proyecto/7_quickstart.md), que
además comprueba que **la fila retirada sigue en la base**. Esa es la
durabilidad y el borrado lógico, en la misma consulta.
