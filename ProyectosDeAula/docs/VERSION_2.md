# Qué se espera de la VERSIÓN 2 del proyecto de aula

> Para el **equipo**. Qué tiene que estar listo al entregar la v2, cómo se
> comprueba y qué se entrega.
>
> **Entrega: 20%** — 10% de sustentación individual
> (incluidos sus commits) + 10% de entrega en equipo.
>
> **La fecha la fija su curso:** este repositorio es un ejemplo para las dos
> universidades, y cada una tiene su calendario.
>
> El método, el calendario y la rúbrica están en
> [0_METODOLOGIA.md](0_METODOLOGIA.md). Esto es **el detalle de la v2**.
>
> **Su stack:** la API en **PHP 8.3 puro con PDO** sobre **MariaDB**, y **el
> front también en PHP** —plantillas renderizadas en el servidor que hablan con
> la API por cURL—. Aquí el front no es elección del equipo: es el curso
> (§6 de la metodología). Y una versión no está cerrada si la API responde y la
> interfaz no.

---

## 0. Lo que queda al terminar

**Todas las tablas de su módulo operables desde la interfaz gráfica** —menos
las del control de acceso, que son de la v3—, con:

- **todo el CRUD pasando por procedimientos almacenados**,
- **al menos un disparador** funcionando,
- **ninguna clave foránea digitada a mano**,
- y los criterios de la v1 **todavía en verde**.

---

## 1. Primero se cierra la v1

**La v1 son las tablas SIN clave foránea de su módulo**, y el ejemplo que les
entregó el profesor construye **una sola** (`producto`), de punta a punta, para
mostrar el molde. Las demás son del equipo.

> **Por qué importa el orden.** Una tabla con clave foránea no se puede llenar
> si la tabla a la que apunta está vacía. Empezar la v2 sin cerrar la v1 es
> construir desplegables que no tienen de dónde sacar opciones.

Cuáles son: la fila **v1** de `docs/spec_kit/versiones/0_mapa_versiones.md`
**de su repositorio**.

> **Y antes de seguir, una cuenta que hay que tener hecha:** las tablas de su
> módulo **no traen la columna `activo`** —el script de `db_scripts/mysql/`
> solo la pone en `rol` y `usuario`—. Agregarla era trabajo de la v1
> (metodología §7.0). Si no se hizo, se hace ahora, porque la v2 entera
> —listados, desplegables, `sp_eliminar_*`— está montada sobre ella.

---

## 2. El alcance de la v2

**Las tablas CON clave foránea de su módulo**, y entre ellas varias **tablas
puente** —clave primaria compuesta, dos claves foráneas—.

> Las tablas no se copian aquí: el mapa de **su** repositorio es el único sitio
> donde están, y así este documento no miente el día que el mapa cambie.

> **Ojo con una confusión que cuesta una semana.** El **ejemplo de clase**
> (`proyecto_php1` … `php4`) tiene **su propio** mapa de versiones, y **no
> coincide** con el del proyecto de aula: allá la v2 son seis recursos sobre
> MariaDB y la v3 es otro motor. Dónde mirar del ejemplo para cada versión de
> ustedes está en el **§2.2 de la metodología**. Lo que manda para su entrega
> es el mapa de **su** repositorio.

---

## 3. Las relaciones MAESTRO-DETALLE

Las que cada módulo ya tiene en su esquema. **Busque las del suyo.**

| Módulo | Maestro | Su detalle |
|---|---|---|
| Gestión Profesoral | **`docente`** | estudios_realizados · evaluacion_docente · experiecia · reconocimiento |
|  | **`estudios_realizados`** | apoyo_profesoral · beca |
| Innovación Curricular | **`programa`** | acreditacion · activ_academica · pasantia · premio · registro_calificado |
|  | **`universidad`** | facultad |
|  | **`facultad`** | programa |
| Investigación | **`universidad`** | grupo_investigacion |
|  | **`grupo_investigacion`** | semillero |
|  | **`linea_investigacion`** | docente |
| Mapa de Conocimiento | **`proyecto`** | producto |
|  | **`tipo_producto`** | producto |
|  | **`linea_investigacion`** | docente |

> **Qué significa que algo sea detalle.** Un `estudios_realizados` **no existe
> sin su `docente`**. No se crea suelto y después se le busca padre.

**Lo que se espera en la interfaz:** al abrir un maestro, ver **su detalle ahí
mismo** y poder agregarle renglones sin salir de la pantalla. No un menú aparte
donde haya que volver a elegir de qué maestro se trata.

> **Y cuando se registran varios renglones de una, van en UN SOLO ENVÍO.** Tres
> renglones no son cuatro peticiones: si la tercera fallara quedaría medio
> registro guardado — y «medio» no es un estado que el negocio reconozca.
>
> En PHP eso se arma con campos de nombre `detalle_codigo[]` y
> `detalle_cantidad[]` en el formulario, que llegan como arreglos paralelos y
> se recorren a la vez. Está hecho así en
> `proyecto_php2/front_php/vistas/facturas_formulario.php`.

---

## 4. TODO el CRUD con procedimientos almacenados

**Listar, consultar, crear, modificar y eliminar: los cinco, de todas las
tablas, pasan por un procedimiento almacenado.**

| | |
|---|---|
| **Qué va en la base** | El SQL: los `SELECT`, los `INSERT`, los `JOIN` de los listados |
| **Qué va en su repositorio** | El **`CALL`** al procedimiento, con sus parámetros en `?` |
| **Qué NO va en su repositorio** | SQL escrito a mano, y mucho menos armado concatenando texto |

> **Por qué.** El SQL queda en **un solo sitio**, con nombre, versionado en el
> script de la base. Y los parámetros viajan como parámetros: una consulta
> armada pegando texto es por donde entra una inyección de SQL.

### Listar

```sql
DELIMITER $$

CREATE OR REPLACE PROCEDURE sp_listar_docente()
BEGIN
    -- la tabla tiene `activo` porque ustedes la agregaron: EL LISTADO LA FILTRA
    SELECT * FROM docente WHERE activo = 1 ORDER BY cedula;
END$$

DELIMITER ;
```

> **Para qué el `DELIMITER`.** El cuerpo del procedimiento lleva `;` adentro.
> Si no se cambia el separador, el cliente corta el procedimiento en el primer
> `;` y manda a la base un pedazo que no compila. `DELIMITER $$` dice «ahora el
> fin de sentencia es `$$`», y la última línea lo devuelve a la normalidad.
>
> **`CREATE OR REPLACE` es de MariaDB** (MySQL no lo tiene para
> procedimientos). Sirve para que el script se pueda volver a correr sin
> borrar nada a mano — y eso es lo que permite tenerlo versionado.

### Crear — devolviendo la fila nueva

```sql
DELIMITER $$

CREATE OR REPLACE PROCEDURE sp_crear_docente(
    IN p_cedula    INT,
    IN p_nombres   VARCHAR(200),
    IN p_apellidos VARCHAR(200)
)
BEGIN
    INSERT INTO docente (cedula, nombres, apellidos)
    VALUES (p_cedula, p_nombres, p_apellidos);

    -- MariaDB NO TIENE `RETURNING`: la fila se vuelve a leer
    SELECT * FROM docente WHERE cedula = p_cedula;
END$$

DELIMITER ;
```

> **El procedimiento devuelve la fila COMO QUEDÓ GUARDADA**, no como la mandó
> el formulario. Así su API responde con los valores por defecto que puso la
> base y con lo que el disparador haya calculado.
>
> **Y si la llave la genera la base** (`AUTO_INCREMENT`), el valor se lee con
> `LAST_INSERT_ID()` **ahí mismo, antes de cualquier otra sentencia**: cualquier
> `INSERT` posterior lo cambia. Guárdelo en una variable y use la variable.

**Un nombre por operación y por tabla**, para que se encuentren:
`sp_listar_<tabla>`, `sp_consultar_<tabla>`, `sp_crear_<tabla>`,
`sp_actualizar_<tabla>`, `sp_eliminar_<tabla>`.

### Cómo se llama desde el repositorio

```php
$sentencia = $this->conexion->prepare('CALL sp_crear_docente(?, ?, ?)');
$sentencia->execute([$cedula, $nombres, $apellidos]);
$fila = $sentencia->fetch(PDO::FETCH_ASSOC);

// IMPRESCINDIBLE: un CALL que devolvió filas deja el cursor abierto, y la
// siguiente consulta de esta misma conexión falla con el error 2014.
$sentencia->closeCursor();
```

### Y antes de escribir el de eliminar: su borrado es lógico

Sus tablas **tienen** la columna `activo` —ustedes la agregaron en la v1—, así
que `sp_eliminar_<tabla>` hace un `UPDATE ... SET activo = 0`, **no un
`DELETE`**, y **todos los listados filtran los inactivos**.

```sql
DELIMITER $$

CREATE OR REPLACE PROCEDURE sp_eliminar_docente(IN p_cedula INT)
BEGIN
    UPDATE docente SET activo = 0 WHERE cedula = p_cedula;
END$$

DELIMITER ;
```

> Si alguna tabla suya no la tiene y usted cree que debería, eso es una
> decisión de la v2 — tómenla, escriban el `ALTER` en el script y la razón en
> el `5_data_model.md`.

---

## 5. AL MENOS UN DISPARADOR — elija uno de estos

**Se exige mínimo uno, funcionando y comprobable.** Cinco propuestas; **elija
al menos una**, o proponga la suya si su módulo pide otra cosa.

| | Propuesta | Qué resuelve |
|---|---|---|
| **A** | **Contador en el maestro**: `docente.total_estudios` se mantiene solo | Saber cuántos hijos tiene sin contar en cada consulta |
| **B** | **Sello de modificación**: `fecha_modificacion` se pone sola en cada `UPDATE` | Nadie se puede olvidar de actualizarla |
| **C** | **Bitácora**: lo que se retira queda copiado en una tabla `bitacora` | Saber qué se retiró y cuándo |
| **D** | **Validación que un `CHECK` no puede hacer**: que la fecha del detalle caiga dentro del rango del maestro | Un `CHECK` solo ve su propia fila; esto mira otra tabla |
| **E** | **Estado derivado**: marcar el maestro como «con producción» al recibir su primer detalle | Un dato que se calcula, no que alguien recuerde marcar |

### La propuesta A, completa

**En MariaDB un disparador atiende UN SOLO evento.** No existe
`AFTER INSERT OR UPDATE OR DELETE` —eso es PostgreSQL—: son **tres
disparadores**. Y por eso el recálculo se escribe **una sola vez**, en un
procedimiento al que los tres llaman.

```sql
ALTER TABLE docente ADD COLUMN total_estudios INT NOT NULL DEFAULT 0;

DELIMITER $$

-- el recuento, escrito UNA vez
CREATE OR REPLACE PROCEDURE sp_recontar_estudios(IN p_docente INT)
BEGIN
    UPDATE docente SET total_estudios = (
        SELECT COUNT(*) FROM estudios_realizados
        WHERE docente = p_docente AND activo = 1
    )
    WHERE cedula = p_docente;
END$$

CREATE OR REPLACE TRIGGER trg_estudios_insert
AFTER INSERT ON estudios_realizados FOR EACH ROW
    CALL sp_recontar_estudios(NEW.docente)$$

CREATE OR REPLACE TRIGGER trg_estudios_update
AFTER UPDATE ON estudios_realizados FOR EACH ROW
BEGIN
    CALL sp_recontar_estudios(NEW.docente);
    -- si le cambiaron el padre, el de antes tambien queda mal
    IF OLD.docente <> NEW.docente THEN
        CALL sp_recontar_estudios(OLD.docente);
    END IF;
END$$

CREATE OR REPLACE TRIGGER trg_estudios_delete
AFTER DELETE ON estudios_realizados FOR EACH ROW
    CALL sp_recontar_estudios(OLD.docente)$$

DELIMITER ;
```

> **Fíjese en que el `UPDATE` también está.** Con borrado lógico, retirar un
> hijo **es un `UPDATE`** — y si solo se escriben los disparadores del `INSERT`
> y del `DELETE`, el contador queda mal justo cuando alguien retira algo, que
> es el caso que nadie prueba.
>
> **Y una regla de MariaDB que conviene saber antes de chocarse con ella:** un
> disparador **no puede modificar su propia tabla**. El de
> `estudios_realizados` puede actualizar `docente` sin problema; si intentara
> tocar `estudios_realizados`, la base responde el error **1442**.

**Cómo se comprueba:** se hace la operación **por la interfaz** y se mira que
el dato cambió **sin que la API lo haya enviado**. Si su código manda el total,
el disparador no está demostrando nada.

---

## 6. Las claves foráneas NO se digitan

**Nunca** un campo de texto donde va un código. Un desplegable **cargado desde
la API**, que **muestra el nombre** y **manda la clave**.

> **Por qué.** Un campo de texto obliga a la persona a adivinar qué códigos
> existen. Escribe uno que no está, el servidor responde un error, y **no hay
> forma de saber cuál era el bueno**.

### El ejemplo

Al crear un **`estudios_realizados`** hay que decir de qué **`docente`** es.

| | |
|---|---|
| **Lo que la persona VE** | `nombres` y `apellidos` del docente |
| **Lo que se MANDA** | `cedula`, la clave |
| **De dónde salen las opciones** | De la API: `GET /api/docente` |

```php
<!-- el desplegable: muestra el nombre, manda la clave -->
<select class="form-select" id="docente" name="docente">
  <option value="">— escoja —</option>
  <?php foreach ($docentes as $d): ?>
    <!-- el TEXTO es lo que la persona lee; el value es lo que viaja -->
    <option value="<?= (int) $d['cedula'] ?>"
      <?= (int) ($ficha['docente'] ?? 0) === (int) $d['cedula'] ? 'selected' : '' ?>>
      <?= htmlspecialchars($d['nombres'] . ' ' . $d['apellidos']) ?>
    </option>
  <?php endforeach; ?>
</select>
```

Si la persona elige **Ana Torres Gómez**, lo que viaja es su clave:

```json
{
  "docente": 1017245
}
```

> **Eso es lo que hay que ver:** en la pantalla se lee «Ana Torres Gómez»; en
> la petición viaja `1017245`. La persona reconoce nombres; la base necesita
> claves.
>
> **El `htmlspecialchars` no es adorno.** Un apellido con apóstrofo —O'Brien—
> o con un `<` rompe el HTML de la página sin dar ningún error: la opción
> simplemente sale cortada. Todo lo que venga de la base y se imprima en una
> plantilla pasa por ahí.
>
> **Y el desplegable solo ofrece los ACTIVOS**, porque el listado del que sale
> ya los filtra. Ofrecer un padre retirado es ofrecer una opción que la base va
> a rechazar.

**Si la clave foránea es opcional**, el desplegable lleva una opción
**«(ninguna)»** que manda `null`. Y aquí hay una conversión que en PHP hay que
escribir a mano:

```php
// Un <select> vacio NO llega ausente: llega como CADENA VACIA.
// Y (int) '' es 0 — que no es null: la base lo rechaza buscando el docente 0.
$docente = ($_POST['docente'] ?? '') === '' ? null : (int) $_POST['docente'];
```

---

## 7. La integridad referencial: 409, nunca 500

| Qué hace alguien | Qué dice MariaDB | Qué tiene que responder su API |
|---|---|---|
| Crear un hijo cuyo **padre no existe** | error **1452** (*cannot add or update a child row*) | **409** con mensaje en castellano |
| Repetir **la misma pareja** en una tabla puente | error **1062** (*duplicate entry*) | **409** |
| Borrar un padre con hijos **(solo si el borrado es físico)** | error **1451** (*cannot delete or update a parent row*) | **409** |
| Romper una regla que ustedes pusieron en el procedimiento | `SIGNAL SQLSTATE '45000'` — errno **1644** | **409**, con el mensaje del `SIGNAL` |

> Si responde **500**, lo que está diciendo es «me caí», y quien lo lea va a
> buscar un error que no existe.

**Y el detalle que decide si esto funciona o no:** los tres primeros llegan con
el **mismo SQLSTATE, `'23000'`**. El `getCode()` de PDO devuelve ese, así que
mirándolo **no se distingue** un padre inexistente de una pareja repetida. El
número del motor está en **`$e->errorInfo[1]`**:

```php
$codigo = $error->errorInfo[1] ?? 0;   // 1452, 1062, 1451…
```

**El cuarto se lee al revés, y conviene saberlo antes:** un `SIGNAL` propio
llega con el errno **genérico 1644**, y lo que lo identifica es el
**SQLSTATE `'45000'`**, que está en **`$e->errorInfo[0]`**. Si solo se mira el
`[1]`, las reglas de negocio que ustedes mismos escribieron en el
procedimiento acaban todas en el 500 — y son las que más van a usar.

```php
if (($error->errorInfo[0] ?? '') === '45000') {
    // el mensaje del SIGNAL ya esta en castellano: va al 409 tal cual
}
```

Las dos cosas están hechas y comentadas en el ejemplo:
`proyecto_php2/api_facturas/repositorios/errores_de_integridad.php` y
`proyecto_php2/api_facturas/repositorios/RepositorioFacturaMariaDB.php`.
Cópienlas y
adáptenlas a sus tablas.

**Y una decisión que el equipo tiene que tomar y escribir:** con borrado
lógico, ¿se puede **retirar** un maestro que todavía tiene detalle activo? La
base no lo impide —es un `UPDATE`—, así que es una **regla de negocio** suya.
Decídanla, pónganla en el servicio, y escríbanla en el `2_spec.md`.

---

## 8. Los criterios de aceptación

| # | Criterio | Cómo se comprueba |
|---|---|---|
| **1** | Las tablas de la v1 tienen CRUD completo y su interfaz | Se abre cada una: crear, editar, retirar |
| **2** | Las tablas de la v2, también | Lo mismo, una por una |
| **3** | **Los cinco verbos de todas las tablas pasan por procedimientos almacenados** | Se abre el repositorio: **no hay SQL escrito a mano**, solo `CALL` |
| **4** | **Al menos un disparador funciona** | Se hace la operación por la interfaz y el dato cambia solo (§5) |
| **5** | Cada clave foránea se elige de un **desplegable cargado de la API** | El desplegable está **lleno** y muestra nombres, no códigos |
| **6** | La clave foránea opcional acepta **«(ninguna)»** → `null` | Se crea un registro sin ella |
| **7** | Crear un hijo con un padre inexistente responde **409** en castellano | Desde la colección de pruebas. **Un 500 es criterio fallado** |
| **8** | Las tablas puente se asignan y se retiran **con sus dos claves**, y repetir la pareja da **409** | Se asigna, se repite y se retira |
| **9** | El detalle se ve y se agrega **desde el maestro** | Se abre un maestro y ahí está su detalle |
| **10** | El borrado es lógico y **los listados filtran** | Se retira un registro: desaparece de la lista, **sigue en la base** |
| **11** | La interfaz **no habla en jerga** | No dice «PUT», «PATCH», «422» ni «FK» en ninguna pantalla |
| **12** | **La regresión de la v1 pasa completa** | §9 |

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
| Consultas multitabla, dashboard con gráficos | **v4** |
| Imagen corporativa, páginas corporativas, publicación | **v4** |

> **Adelantarlos no suma, resta.** Una v2 que ya trae media sesión le quita a
> la v3 la mitad de su razón de ser. Si le sobra tiempo, cierre bien lo de la
> v2 — empezando por los criterios 4 y 7.

---

## 11. Qué se entrega

| | |
|---|---|
| **El spec kit de la v2** | `docs/spec_kit/versiones/v2_<nombre>/` con los mismos nueve documentos de la v1 **y la guía de IA**. Describe **solo el delta** |
| **El script de la base** | Con el `ALTER` de `activo`, **los procedimientos** y **el disparador**, versionados ahí |
| **El código** | Repositorios que **llaman** a los procedimientos |
| **La interfaz gráfica** | Las pantallas de los recursos nuevos. **Una versión no está cerrada si la API responde y la interfaz no** |
| **La colección de pruebas** | Con las peticiones nuevas, **incluidas las que tienen que fallar** |
| **LOS PROMPTS** | Los que **de verdad usaron** para generar el código a partir del spec kit — por chat o con el IDE agéntico—, **con lo que tuvieron que corregirle a la IA**. Van en la carpeta de la versión, al lado de su guía de IA |
| **El tag `v2`** | Sobre el commit que pasa los doce criterios |

> **El spec kit se escribe ANTES.** Si se escribe al final es un informe de lo
> que se hizo, y entonces no sirvió para decidir nada. Las tres compuertas
> están en [0_METODOLOGIA.md](0_METODOLOGIA.md) §3.1.

> **Y los prompts se entregan SIEMPRE**, en las dos modalidades: el del chat y
> el del IDE agéntico. No es burocracia — es el eslabón del medio.
>
> El spec kit dice **qué** construir. El código es **lo construido**. El prompt
> es **cómo se pasó de uno al otro**: entregar los dos extremos y no el medio
> es entregar un resultado sin su procedimiento.
>
> **Y lo que más vale es lo que tuvieron que corregirle a la IA.** Si pidieron
> algo y salió mal, la corrección que lo arregló dice más del equipo que el
> código final — y en la sustentación individual es lo que distingue a quien
> dirigió el trabajo de quien pegó una respuesta.

---

## 12. Las trampas de esta versión

| | Qué pasa | Cómo se nota |
|---|---|---|
| **El `DELIMITER` olvidado** | El script se parte en el primer `;` del cuerpo. Las **tablas sí se crean** y los procedimientos no | La API responde *PROCEDURE … does not exist* — y uno busca el error en el PHP |
| **El disparador de un solo evento** | En MariaDB cada disparador atiende uno. Escribir solo el del `INSERT` deja el contador mal | Retirar o editar un hijo no cambia el total |
| **El cursor sin cerrar** | Un `CALL` que devolvió filas deja resultados pendientes en la conexión | La **siguiente** consulta falla con el error **2014** — lejos de donde está la causa |
| **El SQLSTATE que no distingue** | 1452, 1062 y 1451 llegan todos como `'23000'` | Todos los rechazos responden el mismo mensaje, o todos caen en el 500 |
| **El `(int) ''` que vale 0** | Un desplegable opcional vacío llega como cadena vacía, y `(int) ''` es `0` | 409 hablando de un padre `0` que nadie eligió |
| **El 204 sin cuerpo** | La tabla vacía responde **204**, que no trae JSON. `json_decode('')` da `null` | `foreach` sobre `null` revienta la página en PHP 8 — y es el caso del primer día |
| **El listado que no filtra** | Se olvidó el `WHERE activo = 1` | Lo retirado sigue apareciendo |
| **El desplegable con inactivos** | El listado que lo llena no filtra | Se puede elegir un padre retirado |
| **El sobre de la respuesta** | La API devuelve `{tabla, limite, total, datos}`, no una lista pelada. Leerlo mal deja la pantalla **vacía sin ningún error** | Una tabla sin filas y sin mensaje |
| **La tabla puente con botón de editar** | Una pareja existe o no existe; no se edita | — |
| **El procedimiento que no devuelve la fila** | La interfaz no puede mostrar lo que acaba de crear | — |

---

## Dónde está cada cosa

| | |
|---|---|
| El método, el calendario y la rúbrica | [0_METODOLOGIA.md](0_METODOLOGIA.md) |
| El stack de PHP, y qué mirar del ejemplo | [0_METODOLOGIA.md](0_METODOLOGIA.md) §6 y §2.2 |
| Las tablas de cada versión | `docs/spec_kit/versiones/0_mapa_versiones.md` **de su repositorio** |
| Lo que su módulo tiene que hacer | los `modulo_*.md` de esta misma carpeta |
| Cómo encajan los módulos | [proyecto_completo.md](proyecto_completo.md) |
