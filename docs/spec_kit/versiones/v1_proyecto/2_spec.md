# Especificación — v1: `proyecto` (PHP + MariaDB)

## 1. Qué construye esta versión

El CRUD completo de **`proyecto`**, la tabla sin clave foránea con más campos
del módulo de Mapa de conocimiento: **API en PHP puro** y **pantalla en PHP**, cada
una en su contenedor, sobre **MariaDB**.

## 2. Lo que esta versión NO incluye

- Las otras 20 tablas: llegan en la v2 y la v3, cada una
  con su ruta y su pantalla.
- Autenticación. Las tablas `usuario`, `rol` y `rol_usuario` **ya están
  creadas** —el esquema es artefacto dado— pero la v1 no las nombra.
- Consultas de varias tablas, informes y tableros.
- Reactivar una ficha retirada. El borrado es lógico y la fila se queda, pero
  **no hay ruta para devolverla**: eso es una decisión de negocio que nadie
  ha pedido todavía.

## 3. La ficha

| Campo | Tipo | | Nota |
|---|---|---|---|
| `id` | entero | obligatorio | El código del proyecto. |
| `titulo` | texto, hasta 70 | obligatorio | — |
| `resumen` | texto, hasta 256 | obligatorio | — |
| `presupuesto` | número | obligatorio | Un NÚMERO, no una cadena: si llega «mucho», es 422. |
| `tipo_financiacion` | texto, hasta 45 | obligatorio | Los valores del Excel: interna, externa, cofinanciado. |
| `tipo_fondos` | texto, hasta 45 | obligatorio | Los valores del Excel: Público, Privado, Mixto. |
| `fecha_inicio` | fecha `AAAA-MM-DD` | obligatorio | Fecha de verdad: la columna es DATE, no texto. |
| `fecha_fin` | fecha `AAAA-MM-DD` | opcional | El ÚNICO opcional: un proyecto en curso todavía no terminó. |

`activo` **no aparece** en esa lista a propósito: es de la base, no de la
ficha. Ver el §4 de [5_data_model.md](5_data_model.md).

## 4. Requisitos funcionales

### RF1 — Listar (GET + query string)
`GET /api/proyecto` → 200 con el sobre `{tabla, limite, total, datos:[…]}`.
- Devuelve **solo los activos**.
- Parámetro opcional `limite` (entero > 0; por defecto 1000).
- Sin filas activas → **204** sin cuerpo. Sigue en el contrato, pero **no es
  el estado inicial**: la tabla arranca con 14 filas.
- `limite` <= 0 → **400** (es una regla de negocio, no un problema de forma).

### RF2 — Obtener uno (GET + parámetro de ruta)
`GET /api/proyecto/{id}` → 200 con la ficha.
- Inexistente **o retirado** → 404. Para quien usa la API son lo mismo.

### RF3 — Crear (POST)
`POST /api/proyecto` con los 7 campos obligatorios y el opcional.
- Falta uno, o llega con el tipo equivocado → **422** con `errores[]`.
- La llave ya existe → **500** con el mensaje del motor en `detalle`.

### RF4 — Reemplazar (PUT)
`PUT /api/proyecto/{id}` con **todos** los campos. La llave va en la ruta,
no en el cuerpo.
- Falta uno → **422**. Ésa es la semántica de reemplazar.

### RF5 — Actualizar (PATCH)
`PATCH /api/proyecto/{id}` con **los que se quieran cambiar**.
- El mismo cuerpo que el PUT rechaza con 422, aquí responde 200.
- Cuerpo vacío `{}` → **400**, no 422: la forma está bien, lo que no tiene
  sentido es la operación.

### RF6 — Retirar (DELETE)
`DELETE /api/proyecto/{id}` → marca `activo = FALSE`.
- Un **segundo** DELETE sobre la misma llave → **404**.
- La fila **sigue en la base**, y eso se comprueba con una consulta directa.

### RF7 — Diagnóstico
`GET /` → 200 con `{"version":"v1", "tabla":"proyecto"}`.

## 5. Criterios de aceptación

1. **Un solo comando.** `docker compose up -d --build` deja corriendo MariaDB
   —con la base y sus 21 tablas—, la API y la pantalla.
   `GET http://localhost:8117/` responde `"version":"v1"`.
2. **El sistema arranca CON DATOS.** `GET /api/proyecto` responde **200** con
   `total: 14`.
3. **Crear y listar.** Un `POST` válido responde 200; después el listado
   responde `total: 15`.
4. **El ciclo de los cinco verbos.** `POST` crea `9001` → `PUT` lo
   reemplaza → `PATCH` le cambia **un** campo → `GET` lo confirma → `DELETE`
   lo retira, y un **segundo** `DELETE` responde **404**.
   Además: un `PUT` sin `titulo` responde **422** mientras el **mismo
   cuerpo** por `PATCH` responde **200**.
5. **El borrado es LÓGICO, y se verifica.** Tras el `DELETE` el `total` baja
   en uno, **y la fila sigue en la base** con `activo = 0` — comprobable con
   una consulta directa en MariaDB.
6. **La validación es la frontera.** Un `POST` sin `titulo` → **422** con
   `errores:[…]`; una llave duplicada → **500**. En ninguno se toca la base.
7. **Prueba de capas.** `pruebas/prueba_capas.php` ejecuta el servicio con un
   **repositorio falso en memoria** y todas sus verificaciones pasan **con
   MariaDB apagada**.

### Criterios de aceptación de la pantalla

| # | Criterio | Cómo se comprueba |
|---|---|---|
| P1 | La pantalla muestra las filas **que dio la API** | Se le piden a la API y se buscan en el texto visible de la pantalla |
| P2 | Cada pantalla tiene **dirección propia** | `/proyectos`, `/proyectos/nuevo`, `/proyectos/{clave}/editar` — ninguna con el nombre de la tabla como parámetro |
| P3 | **Las hojas de estilo llegan como `text/css`** | No basta el 200: con un router de `php -S` un CSS puede llegar como HTML y la pantalla sale sin estilos |
| P4 | La pantalla **no habla en jerga** | Ni `PUT`, ni `PATCH`, ni `422`, ni `/api/`, ni el nombre del motor |
| P5 | Los **dos botones de guardar** se comportan distinto | El mismo formulario a medio llenar: «la ficha completa» lo rechaza, «solo lo que cambié» lo guarda |
| P6 | Un error **no borra** lo que la persona escribió | Se reenvía el formulario con los valores puestos |
| P7 | **Con la API apagada la pantalla sigue en pie** | `docker compose stop api-mapa`: responde 200, con su aviso y **sin un solo dato** |

## 6. Clarificaciones

| # | Duda | Decisión | Dónde |
|---|---|---|---|
| C1 | `area_conocimiento.id` está declarado `INT` y los datos del Excel son códigos como `1A01` | **Mandan los datos: `VARCHAR(6)`.** Si no, el script no puede cargar su propio catálogo | `db/init.sql` [C1] |
| C2 | `area_conocimiento.disciplina` es `VARCHAR(60)` y el valor más largo tiene **124** | **Se agranda a `VARCHAR(150)`.** Recortar un catálogo oficial lo falsea | `db/init.sql` [C2] |
| C3 | El esquema dado no tiene columna para el borrado lógico | **Las 18 tablas del módulo ganan `activo BOOLEAN NOT NULL DEFAULT TRUE`.** En MariaDB `BOOLEAN` es alias de `TINYINT(1)`: se escribe `BOOLEAN` porque dice lo que la columna significa | `db/init.sql` [C4] |
| C4 | El catálogo trae **«Cienias Naturales»** en 48 filas | **Se corrige.** Es un error de digitación de la fuente; cargarlo tal cual lo deja a la vista en cada listado | `db/init.sql` [C5] |
| C5 | El gemelo en FastAPI devuelve sus errores envueltos en `{"detail": …}` y sus 422 en inglés. ¿Se imita? | **No.** El contrato documenta un sobre plano y en español, y aquí no hay framework que envuelva nada: se entrega **exactamente el sobre documentado**. Que el gemelo no pueda es parte de lo que hay que ver | [6_contracts.md](6_contracts.md) §0 |
| C6 | ¿La API valida que `id` no sea una llave ajena a la tabla? | **No hay claves foráneas en esta tabla**, así que no hay integridad referencial que imponer todavía. Llega en la v3 | [4_research.md](4_research.md) |
