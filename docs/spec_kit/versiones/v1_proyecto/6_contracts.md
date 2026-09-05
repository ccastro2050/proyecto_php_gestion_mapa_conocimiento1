# Contratos de la API — v1: `proyecto`

Base: `http://localhost:8117`

## §0. El sobre, siempre el mismo

**Éxito de lectura:**
```json
{ "tabla": "proyecto", "limite": 1000, "total": 3, "datos": [ … ] }
```

**Éxito de escritura:**
```json
{ "estado": 200, "mensaje": "…", "filasAfectadas": 1 }
```

**Error:**
```json
{ "estado": 422, "mensaje": "Datos inválidos.",
   "errores": ["El campo titulo es obligatorio."] }
```

`errores[]` aparece **solo** en el 422. Los demás traen `detalle` con el
motivo en una frase.

> **Y una comparación que vale la pena hacer.** El gemelo de este módulo
> ([`proyecto_paradigmas_mapa_conocimiento1`](../../../../../proyecto_paradigmas_mapa_conocimiento1))
> documenta **este mismo sobre** y no lo entrega: FastAPI lo envuelve en
> `{"detail": …}`, y sus 422 salen en el formato crudo de Pydantic, en
> inglés. Compruébelo pidiéndole una fila que no exista. Aquí no hay
> framework de por medio, así que el sobre sale como está escrito. Ese es el
> precio y la ventaja de cada camino, y está medido, no supuesto.

### La traducción de excepciones a códigos

| Qué pasa | Quién lo detecta | Código |
|---|---|---|
| El cuerpo no tiene la forma | El **controlador**, antes de tocar nada | **422** |
| Una regla de negocio no se cumple (`limite` <= 0, cuerpo vacío) | El **servicio** (`InvalidArgumentException`) | **400** |
| Esa fila no existe o está retirada | El **servicio** (`NoEncontradoExcepcion`) | **404** |
| La ruta existe pero no con ese método | El **enrutador** | **405** |
| Cualquier otra cosa (llave duplicada, base caída) | `Throwable` | **500** |

---

## 1. `GET /` — diagnóstico

```
→ 200 { "mensaje":"API de Mapa de conocimiento funcionando", "version":"v1",
         "tabla":"proyecto", "contratos":"…" }
```

## 2. `GET /api/proyecto` — listar

Parámetro opcional: `limite` (entero > 0, por defecto 1000).

```
→ 200 { "tabla":"proyecto", "limite":1000, "total":14, "datos":[…] }
→ 204 sin cuerpo            (no hay filas ACTIVAS)
→ 400 { "estado":400, "mensaje":"Parámetros inválidos.",
         "detalle":"El límite debe ser un entero mayor que cero." }
```

**Solo devuelve las activas.** Una ficha retirada no aparece aquí aunque
siga en la base.

## 3. `GET /api/proyecto/{id}` — obtener una

```
→ 200 {"id": 9001, "titulo": "Mapa de saberes del oriente", "resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}
→ 404 { "estado":404, "mensaje":"Proyecto no encontrado.",
         "detalle":"No existe el proyecto con id = …" }
```

## 4. `POST /api/proyecto` — crear

Cuerpo: **todos** los campos, incluida la llave.

```json
{"id": 9001, "titulo": "Mapa de saberes del oriente", "resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}
```

```
→ 200 { "estado":200, "mensaje":"Proyecto creado exitosamente." }
→ 422 { "estado":422, "mensaje":"Datos inválidos.",
         "errores":["El campo titulo es obligatorio."] }
→ 500 { "estado":500, "mensaje":"Error interno.", "detalle":"…Duplicate entry…" }
```

La llave duplicada es **500 y no 409** a propósito: la v1 no interpreta los
códigos del motor, los reporta. Traducirlos a 409 es trabajo de una versión
posterior, cuando haya claves foráneas y valga la pena distinguir «se rompió
algo» de «su petición no cabe en los datos que hay».

## 5. `PUT /api/proyecto/{id}` — reemplazar

Cuerpo: **todos** los campos **menos la llave**, que va en la ruta.

```json
{"titulo": "Mapa de saberes del oriente", "resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}
```

```
→ 200 { "estado":200, "mensaje":"Proyecto reemplazado.", "filasAfectadas":1 }
→ 422 { …, "errores":["El campo titulo es obligatorio."] }
→ 404 { "estado":404, "mensaje":"Proyecto no encontrado.", … }
```

**Este cuerpo da 422** —le falta `titulo`— y es el mismo que el PATCH de
abajo acepta:

```json
{"resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}
```

## 6. `PATCH /api/proyecto/{id}` — actualizar

Cuerpo: **los campos que se quieran cambiar**.

```json
{"fecha_inicio": "2026-02-01"}
```

```
→ 200 { "estado":200, "mensaje":"Proyecto actualizado.", "filasAfectadas":1 }
→ 400 { "estado":400, "mensaje":"Parámetros inválidos.",
         "detalle":"No se envió ningún campo para actualizar." }
→ 404 { … }
```

El cuerpo vacío `{}` es **400, no 422**: la forma está bien; lo que no
tiene sentido es la operación. Forma y negocio, cada cosa en su capa.

## 7. `DELETE /api/proyecto/{id}` — retirar

```
→ 200 { "estado":200, "mensaje":"Proyecto eliminado.", "filasAfectadas":1 }
→ 404 { … }   ← el SEGUNDO delete sobre la misma llave
```

**El borrado es lógico.** La fila se queda con `activo = 0`; el paso 5 del
[7_quickstart.md](7_quickstart.md) trae la consulta que la encuentra ahí.

---

## Cómo traduce el front estos desenlaces

| Lo que responde la API | Lo que ve el usuario |
|---|---|
| `200` en una lectura | La tabla con sus filas |
| `204` | «Todavía no hay proyectos» y el botón de agregar — **no es un error** |
| `200` en una escritura | Un aviso verde: «Se agregó…», «Se guardó…», «Se retiró…» |
| `404` | Un aviso rojo con la frase de la API, sin el número |
| Un cuerpo inválido, con `errores[]` | Un aviso rojo por cada error, con el texto que mandó la API |
| **La API no responde** | «El servicio no está disponible» — y la pantalla **sigue en pie** |

Ningún número de estado, ningún verbo y ninguna ruta de la API llegan a la
pantalla. Eso lo comprueba el paso 4 de `pruebas_humo/humo_front.py`.
