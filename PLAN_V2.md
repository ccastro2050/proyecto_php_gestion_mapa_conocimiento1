# Qué se espera de la VERSIÓN 2 — módulo Mapa de Conocimiento

> Para el **equipo**. Dice qué tiene que estar listo, cómo se comprueba y qué
> se entrega.
>
> **Entrega: última semana de octubre · 20%** — 10% de sustentación individual
> (incluidos sus commits) + 10% de entrega en equipo. La fecha exacta de su
> grupo la fija el profesor en clase.
>
> **Su stack:** PHP + PHP sobre **MariaDB 11**.

---

## 0. Lo que queda al terminar

**Las 21 tablas del módulo operables desde la interfaz gráfica** —menos las
tres del control de acceso, que son de la v3—, con **todo el CRUD pasando por
procedimientos almacenados**, **al menos un disparador** funcionando, y los
criterios de la v1 **todavía en verde**.

---

## 1. Antes de empezar: cerrar la v1

**La v1 son 8 tablas —las que no tienen clave foránea— y el ejemplo del
profesor construyó UNA.** Le faltan **7**, cada una con su CRUD y su
interfaz. Están en la fila **v1** de
[`0_mapa_versiones.md`](docs/spec_kit/versiones/0_mapa_versiones.md).

> **Por qué importa el orden.** Una tabla con clave foránea no se puede llenar
> si la tabla a la que apunta está vacía. Empezar la v2 sin cerrar la v1 es
> construir desplegables que no tienen de dónde sacar opciones.

---

## 2. El alcance de la v2

| | |
|---|---|
| **Tablas nuevas** | **10**, todas **con clave foránea** |
| **De ellas, tablas PUENTE** | **8** — clave primaria compuesta, dos claves foráneas |
| **Cuáles exactamente** | La fila **v2** de [`0_mapa_versiones.md`](docs/spec_kit/versiones/0_mapa_versiones.md) |

Las tablas no se copian aquí a propósito: el mapa es el único sitio donde
están, y así este documento no miente el día que el mapa cambie.

---

## 3. LAS RELACIONES MAESTRO-DETALLE DE SU MÓDULO

Estas son las que su esquema ya tiene. **3 tablas** son el «detalle» de
otra: no existen por sí solas.

| Maestro | Su detalle | Cuántas |
|---|---|---|
| **`proyecto`** | `producto` | 1 |
| **`tipo_producto`** | `producto` | 1 |
| **`linea_investigacion`** | `docente` | 1 |

> **Qué significa que algo sea detalle.** Un `producto` **no existe sin su
> `proyecto`**. No se crea suelto y después se le busca padre: se crea
> **desde** el maestro, y si el maestro se va, su detalle se va con él.

**Lo que se espera en la interfaz:** al abrir un `proyecto`, ver **su
detalle ahí mismo** y poder agregarle renglones sin salir de la pantalla. No
un menú aparte donde haya que volver a elegir de qué `proyecto` se trata.

> **Y cuando se registran varios renglones de una, van en UN SOLO ENVÍO.** Tres
> renglones no son cuatro peticiones: si la tercera fallara, quedaría medio
> registro guardado — y «medio» no es un estado que el negocio reconozca.

---

## 4. TODO EL CRUD CON PROCEDIMIENTOS ALMACENADOS

**Listar, consultar, crear, modificar y eliminar: los cinco, de las 21
tablas, pasan por un procedimiento almacenado.** Hoy su proyecto no tiene
ninguno — eso es parte de lo que la v2 agrega.

| | |
|---|---|
| **Qué va en la base** | El SQL: los `SELECT`, los `INSERT`, los `JOIN` de los listados |
| **Qué va en su repositorio** | La **llamada** al procedimiento, con sus parámetros |
| **Qué NO va en su repositorio** | SQL escrito a mano, y mucho menos armado concatenando texto |

> **Por qué.** El SQL queda en **un solo sitio**, con nombre, versionado en el
> script de la base. Y los parámetros viajan como parámetros: una consulta
> armada pegando texto es por donde entra una inyección de SQL.

### Ejemplo — listar

```sql
DELIMITER //
CREATE PROCEDURE sp_listar_proyecto()
BEGIN
    SELECT * FROM proyecto ORDER BY id;
END //
DELIMITER ;
```

### Ejemplo — crear, devolviendo la fila nueva

```sql
DELIMITER //
CREATE PROCEDURE sp_crear_proyecto(
    IN p_id INT, IN p_titulo VARCHAR(200), IN p_tipo_financiacion VARCHAR(200))
BEGIN
    INSERT INTO proyecto (id, titulo, tipo_financiacion) VALUES (p_id, p_titulo, p_tipo_financiacion);
    -- devuelve la fila COMO QUEDO GUARDADA
    SELECT * FROM proyecto WHERE id = p_id;
END //
DELIMITER ;
```

> **El procedimiento devuelve la fila COMO QUEDÓ GUARDADA**, no como la mandó
> el formulario. Así su API responde con el registro completo: con los valores
> por defecto que puso la base y con lo que el disparador haya calculado.
>
> **En su módulo la clave la escribe la persona** —una cédula, un código— y por
> eso el procedimiento la recibe. Si alguna clave suya **sí** la generara la
> base, la forma de recuperarla cambia con el motor: `SCOPE_IDENTITY()` en SQL
> Server, `RETURNING` en PostgreSQL, `LAST_INSERT_ID()` en MariaDB. Es una de
> las cosas que **no son portables**.

**Un nombre por operación y por tabla**, para que se encuentren:
`sp_listar_proyecto`, `sp_consultar_proyecto`, `sp_crear_proyecto`,
`sp_actualizar_proyecto`, `sp_eliminar_proyecto`.

---

## 5. AL MENOS UN DISPARADOR — elija uno de estos

**Se exige mínimo uno, funcionando y comprobable.** Aquí van cinco propuestas
sobre las tablas que su módulo ya tiene. **Elija al menos una** — o proponga la
suya, si su módulo pide otra cosa.

| | Propuesta | Qué resuelve |
|---|---|---|
| **A** | **Contador en el maestro**: `proyecto.total_producto` se mantiene solo | Saber cuántos hijos tiene sin contar en cada consulta |
| **B** | **Sello de modificación**: `fecha_modificacion` se pone sola en cada `UPDATE` | Nadie se puede olvidar de actualizarla |
| **C** | **Bitácora de borrados**: lo que se elimina queda copiado en una tabla `bitacora` | Saber qué se borró y cuándo, después de borrado |
| **D** | **Validación que un `CHECK` no puede hacer**: que la fecha del detalle caiga dentro del rango del maestro | Un `CHECK` solo ve su propia fila; esto mira otra tabla |
| **E** | **Estado derivado**: marcar el maestro como «con producción» al recibir su primer detalle | Un dato que se calcula, no que alguien recuerde marcar |

### Ejemplo completo de la propuesta A

Primero la columna donde se guarda la cuenta:

```sql
ALTER TABLE proyecto ADD total_producto INT DEFAULT 0;
```

Y el disparador:

```sql
DELIMITER //
CREATE TRIGGER trg_contar_producto_ins AFTER INSERT ON producto
FOR EACH ROW
BEGIN
    UPDATE proyecto SET total_producto = (
        SELECT COUNT(*) FROM producto WHERE proyecto = NEW.proyecto
    ) WHERE id = NEW.proyecto;
END //

CREATE TRIGGER trg_contar_producto_del AFTER DELETE ON producto
FOR EACH ROW
BEGIN
    UPDATE proyecto SET total_producto = (
        SELECT COUNT(*) FROM producto WHERE proyecto = OLD.proyecto
    ) WHERE id = OLD.proyecto;
END //
DELIMITER ;
```

> **Fíjese en que reacciona al INSERT Y al DELETE.** Un contador que solo sube
> es el error clásico: funciona toda la demostración y queda mal el día que
> alguien borra algo. **Si elige la A, su prueba tiene que incluir un borrado.**

**Cómo se comprueba un disparador:** se hace la operación **por la interfaz** y
se mira que el dato cambió **sin que la API lo haya enviado**. Si su código
manda el total, el disparador no está demostrando nada.

---

## 6. LAS CLAVES FORÁNEAS NO SE DIGITAN

**Nunca** un campo de texto donde va un código. Un desplegable **cargado desde
la API**, que **muestra el nombre** y **manda el id**.

> **Por qué no se digita.** Un campo de texto obliga a la persona a adivinar
> qué códigos existen. Escribe uno que no está, el servidor responde un error,
> y **no hay forma de saber cuál era el bueno**.

### El ejemplo de su módulo

Al crear un **`producto`** hay que decir a qué **`proyecto`** pertenece.

| | |
|---|---|
| **Lo que la persona VE** | `titulo` de la tabla `proyecto` |
| **Lo que se MANDA** | `id`, la clave |
| **De dónde salen las opciones** | De la API: `GET /api/proyecto` |

```html
<!-- el desplegable: muestra el nombre, manda la clave -->
<select name="proyecto">
  <option value="">— seleccione —</option>
  <!-- una opción por cada fila que devolvió GET /api/proyecto:
       el TEXTO es lo que la persona lee, el value es lo que viaja -->
  <option value="12">Mapa de conocimiento institucional</option>
  <option value="18">Observatorio de egresados</option>
</select>
```

Si la persona elige **Mapa de conocimiento institucional**, lo que viaja a la API es su **clave**, no su
nombre:

```json
{
  "proyecto": 12
}
```

> **Eso es lo que hay que ver:** en la pantalla se lee «Mapa de conocimiento institucional»; en la petición
> viaja `12`. La persona reconoce nombres; la base necesita claves.

> **Si la clave foránea es opcional**, el desplegable lleva una opción
> **«(ninguna)»** que manda `null` — que **no** es lo mismo que mandar cadena
> vacía. Una cadena vacía donde va un número hace que el servidor responda un
> error de conversión en inglés, en vez de aceptar que no hay valor.

---

## 7. La integridad referencial: 409, nunca 500

Cuando alguien intente **borrar un maestro que tiene detalle**, o **crear un
detalle cuyo maestro no existe**, la base lo va a rechazar. Eso es correcto:
está haciendo su trabajo.

> **Lo que se espera:** que su API traduzca ese rechazo a un **409** con un
> mensaje en castellano. Si responde **500**, lo que está diciendo es «me caí»,
> y quien lo lea va a buscar un error que no existe.

---

## 8. Los criterios de aceptación

| # | Criterio | Cómo se comprueba |
|---|---|---|
| **1** | Las 8 tablas de la v1 tienen CRUD completo y su interfaz | Se abre cada una: crear, editar, retirar |
| **2** | Las 10 tablas de la v2, también | Lo mismo, una por una |
| **3** | **Los cinco verbos de las 21 tablas pasan por procedimientos almacenados** | Se abre el repositorio: **no hay SQL escrito a mano** |
| **4** | **Al menos un disparador funciona** | Se hace la operación por la interfaz y el dato cambia solo (§5) |
| **5** | Cada clave foránea se elige de un **desplegable cargado de la API** | El desplegable está **lleno** y muestra nombres, no códigos |
| **6** | La clave foránea opcional acepta **«(ninguna)»** → `null` | Se crea un registro sin ella |
| **7** | Borrar un maestro con detalle responde **409** en castellano | Se intenta. **Un 500 es criterio fallado** |
| **8** | Las 8 tablas puente se asignan y se retiran **con sus dos claves** | Se asigna, se repite —409— y se retira |
| **9** | El detalle se ve y se agrega **desde el maestro** | Se abre un `proyecto` y ahí están sus `producto` |
| **10** | La interfaz **no habla en jerga** | No dice «PUT», «PATCH», «422» ni «FK» en ninguna pantalla |
| **11** | **La regresión de la v1 pasa completa** | §9 |

> **El 7 es el que separa una v2 terminada de una que lo parece.** Todo lo demás
> se ve funcionando por el camino feliz; ese solo aparece cuando algo sale mal,
> que es cuando importa.

---

## 9. La regresión, que es obligatoria

**Los criterios de la v1, completos, el día de la entrega.** No «deberían
seguir funcionando»: se corren.

> **La v2 incluye la v1.** No la reemplaza: lo construido sigue en pie, con su
> código y su interfaz, y sus criterios se vuelven a correr.

---

## 10. Lo que NO es de la v2

| | Es de la |
|---|---|
| Iniciar sesión, contraseñas, tokens, permisos por rol | **v3** |
| CRUD de `usuario`, `rol` y `rol_usuario` | **v3** |
| Consultas multitabla, tablero con gráficos | **v4** |
| Imagen corporativa, páginas corporativas, publicación | **v4** |

> **Adelantarlos no suma, resta.** Una v2 que ya trae media sesión le quita a la
> v3 la mitad de su razón de ser. Si le sobra tiempo, cierre bien lo de la v2 —
> empezando por el criterio 7.

---

## 11. Qué se entrega

| | |
|---|---|
| **El spec kit de la v2** | `docs/spec_kit/versiones/v2_<nombre>/` con los mismos nueve documentos de la v1 **y la guía de IA**. Describe **solo el delta** |
| **El script de la base** | Con **los procedimientos** y **el disparador**, versionados ahí |
| **El código** | Repositorios que **llaman** a los procedimientos |
| **La interfaz gráfica** | Las pantallas de los recursos nuevos. **Una versión no está cerrada si la API responde y la interfaz no** |
| **La colección de pruebas** | Con las peticiones nuevas, **incluidas las que tienen que fallar** |
| **El tag `v2`** | Sobre el commit que pasa los once criterios |

> **El spec kit se escribe ANTES.** Si se escribe al final es un informe de lo
> que se hizo, y entonces no sirvió para decidir nada.

---

## 12. Las trampas de esta versión

| | Qué pasa | Cómo se nota |
|---|---|---|
| **El sobre de la respuesta** | La API devuelve `{tabla, limite, total, datos}`, no una lista pelada. Leerlo mal deja la pantalla **vacía sin ningún error** | Una tabla sin filas y sin mensaje |
| **El disparador que solo sube** | Reacciona al `INSERT` y no al `DELETE` | El contador queda mal el día que alguien borra |
| **El procedimiento que no devuelve la fila** | Su API responde sin el `id` que la base acaba de asignar | La interfaz no puede mostrar lo que acaba de crear |
| **El desplegable vacío** | Se construyó la tabla hija antes que la padre | El formulario abre sin opciones |
| **El 500 que debía ser 409** | No se tradujo el error de la base | Criterio 7 |
| **La tabla puente con botón de editar** | Una pareja existe o no existe; no se edita | — |

---

## Dónde está cada cosa

| | |
|---|---|
| Las tablas de cada versión | [`0_mapa_versiones.md`](docs/spec_kit/versiones/0_mapa_versiones.md) |
| Las reglas que no se negocian | [`1_constitution.md`](docs/spec_kit/1_constitution.md) |
| El ejemplo de la v1, documento por documento | [`v1_proyecto/`](docs/spec_kit/versiones/v1_proyecto/) |
| La metodología y el calendario | [`0_METODOLOGIA.md`](ProyectosDeAula/docs/0_METODOLOGIA.md) |
