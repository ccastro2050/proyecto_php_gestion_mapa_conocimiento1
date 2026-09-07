# Arreglos y variables superglobales en PHP

> Documento conceptual del curso. Dos temas, en este orden:
>
> 1. **Los arreglos (`array`)** — qué son en PHP, en qué se diferencian de los
>    de Java o C#, cómo se hace un CRUD sobre uno, y las funciones de arreglo
>    que **este proyecto usa de verdad**, con el conteo real.
> 2. **Las variables superglobales** — `$_GET`, `$_POST`, `$_SERVER`,
>    `$_SESSION` y las demás: arreglos que PHP crea y llena solo, antes de que
>    su código arranque, y por los que entra **todo** lo que manda el usuario.
>
> Todos los ejemplos están tomados del código de este repositorio. Si uno no
> le cuadra, ábralo: la ruta está al lado.

---

## 1. Qué es un `array` en PHP (y por qué no se parece al de Java)

En Java o en C#, un arreglo es **una fila de casillas numeradas, todas del
mismo tipo, con un tamaño fijo**. En PHP no es nada de eso.

> **El `array` de PHP es una tabla asociativa ordenada:** una lista de parejas
> **llave → valor**, que recuerda el orden en que usted las metió, donde las
> llaves pueden ser números o textos, los valores pueden ser de cualquier
> tipo, y no hay tamaño fijo.

```php
$mezcla = [
    0        => 'un texto',
    'nombre' => 'otro texto',
    7        => 42,
    'lista'  => [1, 2, 3],   // un array DENTRO de otro array
];
```

Eso es legal, y ahí está la trampa: **PHP usa el mismo tipo para tres cosas
que en otros lenguajes son tres tipos distintos.**

| Cómo se usa | En otro lenguaje sería | Ejemplo de este proyecto |
|---|---|---|
| **Lista** — llaves 0,1,2… | `List<T>`, `T[]` | La lista de proyectos que devuelve `obtenerTodos()` |
| **Diccionario** — llaves de texto | `Dictionary<string,T>`, `Map` | `$datos` en el `UPDATE` dinámico: columna → valor |
| **Registro** — llaves fijas y conocidas | una `struct`, una clase | La fila que devuelve PDO: `['id' => …, 'titulo' => …]` |

Saber **cuál de las tres** está usando en cada línea es la mitad de entender
código PHP ajeno. La otra mitad es la sección 4.

### 1.1 Cómo se escriben

```php
$vacio  = [];                          // la forma moderna
$viejo  = array();                     // la de PHP 4; se sigue viendo
$lista  = ['a', 'b', 'c'];             // llaves 0, 1, 2 automáticas
$dicc   = ['id' => 10101, 'activo' => true];

$lista[] = 'd';                        // agregar al final: la llave 3 sale sola
$dicc['titulo'] = 'Algo';     // agregar o reemplazar por llave
```

El `[]` sin llave **no es «la posición vacía»**: es «la siguiente llave
numérica que no se haya usado». Si borró la 2 de una lista de 5, el siguiente
`[]` escribe en la 5, no en la 2. Los huecos no se rellenan solos.

---

## 2. El CRUD completo sobre un arreglo

Un arreglo es una base de datos en miniatura: se puede **crear, leer,
actualizar y borrar** sin motor, sin conexión y sin SQL. Aquí está dos veces
— primero a mano, con arreglos pelados, y después como está escrito en este
proyecto.

### 2.1 A mano, sin clases: un CRUD en catorce líneas

Copie esto en un archivo `prueba.php` y córralo con `php prueba.php`. No
necesita Docker ni base de datos.

```php
<?php
// El "almacén": la llave de cada ficha como índice, la ficha como valor.
// Es un arreglo de arreglos — un diccionario de registros.
$proyectos = [];

// ---------- CREATE: meter una ficha ----------
$proyectos[10101] = ['id' => 10101, 'titulo' => 'Primera'];
$proyectos[10102] = ['id' => 10102, 'titulo' => 'Segunda'];

// ---------- READ: una sola, y todas ----------
echo $proyectos[10101]['titulo'], "
";        // Primera
echo $proyectos[99999]['titulo'] ?? 'no existe', "
";   // no existe

foreach ($proyectos as $llave => $ficha) {
    echo $llave, ' -> ', $ficha['titulo'], "
";
}

// ---------- UPDATE: cambiar un campo ----------
$proyectos[10101]['titulo'] = 'Corregida';
echo $proyectos[10101]['titulo'], "
";        // Corregida

// ---------- DELETE: quitar la ficha ----------
unset($proyectos[10101]);
echo count($proyectos), "
";                                    // 1

// ¿Y cómo se ve el arreglo por dentro? Con print_r:
print_r($proyectos);
```

Sale esto:

```
Primera
no existe
10101 -> Primera
10102 -> Segunda
Corregida
1
Array
(
    [10102] => Array
        (
            [id] => 10102
            [titulo] => Segunda
        )

)
```

Cuatro cosas de esas catorce líneas:

- **`print_r()`** imprime un arreglo completo, anidados incluidos. Es la
  herramienta con la que se depura en PHP. Su hermana `var_dump()` muestra
  además el **tipo** y el tamaño de cada valor: use `var_dump` cuando la duda
  sea si algo es `"5"` o `5`, que en este proyecto pasa seguido.
- **El UPDATE de arriba SÍ funciona**, y es importante entender por qué:
  `$proyectos[…]['titulo'] = 'Corregida'` escribe **directo en el
  almacén**. Si en cambio hubiera hecho `$ficha = $proyectos[…];` y luego
  `$ficha['titulo'] = 'Corregida';`, **no habría pasado nada** —
  `$ficha` sería una copia. Ésa es la sección 4, y es el error de arreglos
  más común que hay.
- **Leer una llave que no existe da un aviso**, no un error fatal. El `??`
  del ejemplo es lo que lo evita.
- **`unset` borra la pareja completa**, llave incluida. No deja un hueco que
  se pueda volver a llenar con `[]`.

Y fíjese en el paralelo, porque es exacto:

| En el arreglo | En SQL |
|---|---|
| `$a[$llave] = $ficha` | `INSERT` … o `UPDATE`, porque pisa sin avisar |
| `$a[$llave] ?? null` | `SELECT … WHERE llave = ?` |
| `foreach ($a as …)` con un contador | `SELECT … LIMIT n` |
| `$a[$llave]['campo'] = $v` | `UPDATE … SET campo = ? WHERE llave = ?` |
| `unset($a[$llave])` | `DELETE FROM … WHERE llave = ?` |

La diferencia que **no** aparece en esa tabla: el arreglo vive en memoria y
se muere cuando termina la petición. Por eso hay una base de datos.

### 2.2 Y ahora, el mismo CRUD dentro del proyecto

Este proyecto tiene esa misma idea escrita en serio, en
**`api_mapa/pruebas/prueba_capas.php`**. Ahí adentro hay una clase que cumple
el mismo contrato que el repositorio de MariaDB pero guarda todo en un array
— y es, línea por línea, un CRUD sobre un arreglo. La diferencia con el de
arriba es que **guarda objetos en vez de arreglos**, y eso cambia una cosa
importante que se ve en la sección 4.

```php
class RepositorioFalsoEnMemoria implements IRepositorioProyecto
{
    /** El "almacén": la llave como índice, el objeto como valor. */
    private array $datos = [];
```

### CREATE — meter

```php
public function crear(Proyecto $entidad): bool
{
    $this->datos[$entidad->getId()] = $entidad;
    return true;
}
```

Una asignación por llave. Si la llave ya existía, **reemplaza en silencio** —
no hay «llave duplicada» en un array, eso lo aporta la base de datos.

### READ — sacar

```php
public function obtenerPorClave($clave): ?Proyecto
{
    return $this->datos[$clave] ?? null;   // ← el ?? evita el aviso
}

public function obtenerTodos(int $limite): array
{
    return array_slice(array_values($this->datos), 0, $limite);
}
```

`array_values` bota las llaves y deja una lista limpia (0,1,2…); `array_slice`
corta los primeros `$limite`, que es exactamente lo que hace el `LIMIT` del
SQL. **Leer un array con una llave que no existe no revienta**: da `null` y un
aviso. El `??` se traga el aviso y devuelve el `null` a propósito.

### UPDATE — cambiar

```php
public function actualizar($clave, array $datos): int
{
    if (!isset($this->datos[$clave])) {
        return 0;                       // 0 filas = "no existía"
    }
    $fila = $this->datos[$clave];
    if (array_key_exists('titulo', $datos)) {
        $fila->setTitulo($datos['titulo']);
    }
    // … un `if` por cada campo que pueda llegar
    return 1;
}
```

Se escriben **solo los campos que llegaron**, que es lo mismo que hace el
`SET` dinámico del repositorio de verdad. Y fíjese en lo que **no** hay: no
hay `$this->datos[$clave] = $fila;` al final. Eso funciona por una razón que
tiene su propia sección — la 4.

### DELETE — sacar del todo

```php
public function eliminar($clave): int
{
    if (!isset($this->datos[$clave])) {
        return 0;
    }
    unset($this->datos[$clave]);        // borra la LLAVE, no deja hueco
    return 1;
}
```

`unset` quita la pareja completa. **No reindexa**: si borra la llave 1 de una
lista de tres, quedan las llaves 0 y 2, y un `foreach` recorrerá dos
elementos con esas llaves. Si necesita una lista limpia otra vez,
`array_values`.

> **Ojo con este proyecto:** en el sistema de verdad el borrado es **lógico**
> —`UPDATE … SET activo = FALSE`, la fila se queda—, así que el repositorio
> falso **tampoco borra**: lleva una lista aparte de llaves retiradas y
> `unset` no aparece. Se hizo así a propósito: si el falso borrara de verdad,
> la prueba pasaría probando un comportamiento que el sistema real no tiene, y
> eso es peor que no probar. Ábralo y compárelo con lo de arriba.

---

## 3. Recorrer: `foreach`, y por qué casi nunca se usa un `for`

```php
foreach ($lista as $elemento)          { … }   // solo los valores
foreach ($diccionario as $llave => $valor) { … }   // los dos
```

En este proyecto no hay **ni un solo** `for ($i = 0; …)` sobre un array, y no
es por gusto: con llaves de texto un contador no sirve, y con llaves numéricas
con huecos, tampoco. `foreach` recorre lo que hay, en el orden en que está.

Ejemplo real, del controlador (`api_mapa/controladores/ControladorProyecto.php`):

```php
$datos = [];
foreach ($filas as $fila) {
    $datos[] = $fila->toArray();       // objeto → array, para el JSON
}
```

---

## 4. Copia por valor: la diferencia con Java y C# que más sorpresas da

Ésta es **la** diferencia de PHP con Java, C# o Python, y la que más
sorpresas da:

> **Los arreglos se copian por VALOR. Los objetos, por referencia.**

```php
$a = ['x' => 1];
$b = $a;            // COPIA COMPLETA
$b['x'] = 99;
echo $a['x'];       // 1  ← $a no se enteró

$o = new Proyecto(…);
$p = $o;            // NO copia: las dos variables señalan al MISMO objeto
$p->setTitulo('otro');
echo $o->getTitulo();   // 'otro'  ← sí se enteró
```

Vuelva ahora al `actualizar()` de la sección 2:

```php
$fila = $this->datos[$clave];      // $fila y el almacén son el MISMO objeto
$fila->setTitulo(…);  // por eso esto SÍ modifica lo guardado
```

**Funciona porque el almacén guarda objetos.** Si guardara arrays —que es lo
primero que uno escribe— esa misma línea haría una copia, la modificaría, y la
tiraría a la basura al terminar el método. El método devolvería `1` y no habría
cambiado nada. Es un error que no da mensaje: da silencio.

Y si de verdad quiere modificar un array dentro de un `foreach`, hay que
pedirlo con `&`:

```php
foreach ($lista as &$elemento) { $elemento = strtoupper($elemento); }
unset($elemento);   // ← SIEMPRE: si no, $elemento queda apuntando al último
```

En este proyecto **no hay ni un `foreach` por referencia**, a propósito:
transformar con `array_map` (sección 5.2) dice lo mismo sin dejar esa mina.

---

## 5. Las funciones que este proyecto usa DE VERDAD

No es la lista del manual: es el conteo de este repositorio, comentarios
aparte.

| Función | Veces |
|---|---|
| `array_key_exists` | **21** |
| `array_map` | **3** |
| `isset` | **3** |
| `empty` | **3** |
| `array_values` | **2** |
| `count` | **2** |
| `array_keys` | **1** |
| `array_merge` | **1** |
| `array_slice` | **1** |
| `array_filter` | **1** |
| `in_array` | **1** |
| `implode` | **1** |
| `unset` | **1** |
| `extract` | **1** |

Vale la pena mirar quién ganó: **`array_key_exists`**. No es casualidad, y la
sección 5.1 explica por qué.

### 5.1 «¿Vino ese campo?» — cuatro maneras que NO son la misma

Esta es la sección que más rinde de todo el documento, porque los cuatro se
parecen y hacen cosas distintas:

| | ¿Existe la llave con valor `null`? | ¿Existe con valor `0`, `''` o `false`? | ¿Avisa si no existe? |
|---|---|---|---|
| `isset($a['x'])` | **false** ← ¡ojo! | true | no |
| `array_key_exists('x', $a)` | **true** | true | no |
| `empty($a['x'])` | true (o sea: «vacío») | **true** ← ¡ojo! | no |
| `$a['x'] ?? 'defecto'` | devuelve `'defecto'` | devuelve el valor | no |

Y ahora el ejemplo real, del controlador, que es exactamente el caso en que la
diferencia importa:

```php
if (array_key_exists('titulo', $datos)) {
    // el campo VINO: se valida lo que trae
} elseif ($obligatorios) {
    $errores[] = 'El campo titulo es obligatorio.';
}
```

**¿Por qué `array_key_exists` y no `isset`?** Porque un cliente puede mandar un
campo **explícitamente en `null`**, y eso no es lo mismo que no mandarlo:

```json
{"titulo": null}   ← lo mandó, y dice "sin valor"
{}                          ← no lo mandó, "déjelo como estaba"
```

Con `isset` los dos casos se verían iguales, y un `PATCH` que quiere borrar un
campo opcional sería indistinguible de un `PATCH` que no lo menciona. **Esa
distinción es media semántica de PUT contra PATCH**, así que la función tenía
que ser `array_key_exists`.

`empty` sirve para otra cosa: preguntar si algo «no tiene contenido». En las
vistas se usa así:

```php
<?php if (!empty($filas)): ?>     <!-- hay filas: pinta la tabla -->
<?php else: ?>                    <!-- no hay: "todavía no hay proyectos" -->
```

Pero **cuidado**: `empty('0')` es `true`, y `'0'` es un texto perfectamente
válido. Nunca use `empty` para preguntar si un campo llegó.

### 5.2 Transformar: `array_map` y `array_filter`

`array_map` aplica una función a cada elemento y devuelve **un array nuevo**
del mismo tamaño. El repositorio lo usa para convertir filas crudas en
objetos del modelo (`api_mapa/repositorios/RepositorioProyectoMariaDB.php`):

```php
$filas = $sentencia->fetchAll(PDO::FETCH_ASSOC);
return array_map(fn(array $fila) => $this->armar($fila), $filas);
```

`fn(...) => ...` es una **función flecha**: una función de una sola expresión
que además **ve las variables de afuera sin que uno se las pase** — por eso
`$this` funciona ahí adentro. Con la sintaxis vieja (`function () use ($this)`)
habría que declararlo.

Lo mismo con un `foreach` sería:

```php
$objetos = [];
foreach ($filas as $fila) { $objetos[] = $this->armar($fila); }
return $objetos;
```

Cuatro líneas contra una, y las cuatro dicen lo mismo. Se prefiere
`array_map` cuando la transformación cabe en una expresión; el `foreach`
cuando adentro hay `if`s.

`array_filter` **quita** los que no cumplen. En el front
(`front_php/cliente_api.php`):

```php
$partes = array_filter([
    $cuerpo['mensaje'] ?? '',
    $cuerpo['detalle'] ?? '',
], static fn ($t) => trim((string) $t) !== '');
```

> **La trampa de `array_filter`:** conserva las llaves originales. Si de tres
> elementos sobrevive el del medio, el resultado tiene **la llave 1**, no la
> 0 — y `$resultado[0]` no existe. Por eso la línea siguiente en ese archivo
> es `array_values(...)`: para volver a tener una lista de verdad.

### 5.3 Las llaves, los valores y el pegado: `array_keys`, `array_values`, `implode`

El sitio donde se ven los tres trabajando juntos es el `UPDATE` dinámico del
repositorio, y es la mejor página de este proyecto para entender arreglos:

```php
$asignaciones = [];
foreach (array_keys($datos) as $columna) {
    $asignaciones[] = "$columna = :$columna";
}
$sql = 'UPDATE proyecto SET ' . implode(', ', $asignaciones)
     . ' WHERE id = :clave_de_la_fila';
```

Con `$datos = ['titulo' => 'X', 'presupuesto' => 9]` sale:

```sql
UPDATE proyecto SET titulo = :titulo, presupuesto = :presupuesto WHERE id = :clave_de_la_fila
```

- `array_keys($datos)` → los **nombres de columna**;
- `implode(', ', …)` → los pega con comas (`explode` hace lo contrario:
  parte un texto en un array);
- y los **valores** no se pegan nunca: viajan como parámetros de PDO. Ésa es
  la línea que separa una consulta segura de una inyección de SQL.

> **Por qué es seguro interpolar `$columna` ahí.** Porque esas llaves no
> vienen del cliente: vienen de la **lista blanca** del controlador
> (`filtrarColumnas`), que solo deja pasar los nombres que este proyecto
> conoce. Si se armara el SQL con las llaves que mande el usuario, ese
> `"$columna = :$columna"` sería una puerta abierta.

### 5.4 Unir dos arreglos: `array_merge` y el operador `+` **no son lo mismo**

Ésta se equivoca todo el mundo. En el repositorio:

```php
$sentencia->execute($datos + ['clave_de_la_fila' => $clave]);
```

| | Llaves de texto repetidas | Llaves numéricas |
|---|---|---|
| `$a + $b` | gana **`$a`** (el de la izquierda) | **conserva** las llaves; no reindexa |
| `array_merge($a, $b)` | gana **`$b`** (el de la derecha) | **reindexa** desde 0: `[0,1,2…]` |

```php
['x' => 1] + ['x' => 2]            // ['x' => 1]
array_merge(['x' => 1], ['x' => 2]) // ['x' => 2]

[5 => 'a'] + [5 => 'b']            // [5 => 'a']
array_merge([5 => 'a'], [5 => 'b']) // [0 => 'a', 1 => 'b']  ← ¡las llaves se perdieron!
```

Ese último renglón es el que muerde: `array_merge` sobre listas **renumera**.
Si sus llaves significan algo (un código de catálogo, un id), `array_merge`
se las borra.

Y `array_merge` sí se usa aquí, donde renumerar es justo lo que se quiere —
juntar dos listas de errores en una sola:

```php
$errores = array_merge(
    $this->validarClave($cuerpo),
    $this->validarCampos($cuerpo, true),
);
```

### 5.5 Contar, cortar, buscar

```php
count($datos)                       // cuántos elementos: el `total` del JSON
array_slice($lista, 0, $limite)     // los primeros N — el LIMIT en memoria
in_array($valor, $lista, true)      // ¿está este VALOR? (el true = comparación estricta)
array_fill(0, $n, '?')              // un array de N copias del mismo valor
```

Dos advertencias:

- **`in_array` busca valores, no llaves.** Para llaves es
  `array_key_exists`. Y el tercer parámetro en `true` no es opcional en la
  práctica: sin él, `in_array(0, ['hola'])` puede dar `true` en versiones
  viejas por conversión de tipos.
- **`count` de un array anidado cuenta el primer nivel.** `count([[1,2],[3]])`
  es 2, no 3.

### 5.6 `extract`, y por qué aquí no es peligroso

En `front_php/index.php`:

```php
function pintar(string $vista, array $datos = []): void
{
    $datos += ['errores' => [], 'ruta' => $GLOBALS['ruta'] ?? '/'];
    $datos['aviso'] = aviso_pendiente();

    extract($datos);          // ['filas' => …] crea la variable $filas
    $contenido = __DIR__ . "/vistas/$vista.php";
    require __DIR__ . '/vistas/plantilla.php';
}
```

`extract` **convierte cada llave del array en una variable**, para que la
vista escriba `$filas` y no `$datos['filas']`.

Es una función con mala fama, y con razón: `extract($_POST)` deja que
cualquiera cree o pise cualquier variable de su programa. **Aquí es seguro por
una razón concreta:** el array que se extrae lo arma el enrutador con llaves
que están escritas en el código, no con lo que mandó el usuario. Cambie eso y
deja de serlo.

Fíjese también en el `+=` de la primera línea: es el operador de la sección
5.4. Pone `errores` y `ruta` **solo si la vista no los mandó** — porque en un
`+`, gana el de la izquierda.
---

## 6. Las variables superglobales: los arreglos que PHP llena solo

Aquí está lo que hace a PHP raro y cómodo a la vez.

> Una **superglobal** es un array que **PHP crea y llena solo**, antes de que
> su código empiece, y que se puede leer **desde cualquier parte del programa
> sin declararlo `global`**.

De ahí el nombre: son globales, y además «súper» porque se saltan la regla de
que una función no ve las variables de afuera.

Son **nueve**, y ninguna más — no se pueden crear:

| Superglobal | Qué trae | ¿La usa este proyecto? |
|---|---|---|
| `$_SERVER` | El sobre de la petición: método, ruta, encabezados, y datos del servidor | **Sí** |
| `$_GET` | Lo que viene en la dirección, después del `?` | **Sí** |
| `$_POST` | Lo que mandó un formulario por POST | **Sí** |
| `$_SESSION` | Lo que usted guardó para la petición siguiente de ESE usuario | **Sí** |
| `$GLOBALS` | Todas las variables globales del programa | **Sí**, una vez |
| `$_FILES` | Los archivos que subió un formulario | No |
| `$_COOKIE` | Las galletas que mandó el navegador | No |
| `$_REQUEST` | `$_GET` + `$_POST` + `$_COOKIE`, revueltos | **No, y a propósito** |
| `$_ENV` | Variables de entorno | **No, y a propósito** |

### 6.1 `$_SERVER` — el sobre de la petición

Es el más grande (trae decenas de llaves) y aquí se usan dos, en el enrutador
(`api_mapa/index.php`):

```php
$metodo = $_SERVER['REQUEST_METHOD'];                          // "GET", "POST", "PUT"…
$ruta   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);    // "/api/proyecto"
```

**`REQUEST_URI` trae la dirección COMPLETA**, con el `?limite=5` pegado. Por
eso pasa por `parse_url(..., PHP_URL_PATH)`: para quedarse solo con la ruta.
Si se comparara `$_SERVER['REQUEST_URI'] === '/api/proyecto'`, la petición
`/api/proyecto?limite=5` **no coincidiría con ninguna ruta** y daría 404.

Hay una tercera, en el front, y es de otro tipo:

```php
if (PHP_SAPI === 'cli-server') { … }
```

`PHP_SAPI` no es superglobal sino una constante, pero cumple el mismo papel:
decir en qué está corriendo el programa. Ahí sirve para tratar los archivos
estáticos solo cuando se usa el servidor embebido de PHP.

### 6.2 `$_GET` — lo que viene en la dirección

```php
$limite = isset($_GET['limite']) ? (int) $_GET['limite'] : 1000;
```

Una línea, tres lecciones:

1. **Todo lo que hay en `$_GET` es TEXTO.** `?limite=5` llega como `"5"`, no
   como `5`. El `(int)` convierte, y convierte **en la frontera** — el resto
   del programa ya recibe un entero.
2. **`isset` primero.** Si nadie mandó `limite`, leerlo da un aviso. Aquí se
   pregunta antes y se pone el valor por defecto.
3. **`(int) "abc"` da `0`**, sin error. Por eso el servicio rechaza el 0 con
   un 400: convertir no es validar.

### 6.3 `$_POST` — lo que mandó el formulario

Es la superglobal más usada del front, y siempre con la misma forma
(`front_php/index.php`):

```php
'titulo' => trim($_POST['titulo'] ?? ''),
```

- **`?? ''`** porque si el campo no venía en el formulario, leerlo daría un
  aviso; así queda cadena vacía.
- **`trim`** porque un campo con tres espacios **no está vacío** para PHP, y sí
  lo está para una persona.
- Y otra vez: **`$_POST` solo trae texto**. El «12» que la persona escribió
  llega como `"12"`. Como el contrato de la API pide un número, el front lo
  convierte antes de mandarlo — eso es lo que hace la función `a_numero`.

> **`$_POST` se llena solo cuando el cuerpo llega como formulario**
> (`application/x-www-form-urlencoded`). Un cliente que manda JSON —como el
> front cuando le habla a la API— **deja `$_POST` vacío**, y por eso la API no
> lo usa: lee el cuerpo crudo con
> `json_decode(file_get_contents('php://input'), true)`. Es la confusión que
> más tiempo cuesta cuando se empieza: «mandé el JSON y `$_POST` está vacío».

### 6.4 `$_SESSION` — lo que sobrevive a la redirección

```php
session_start();                       // ← sin esto, $_SESSION no existe

function redirigir_con(string $destino, string $tipo, $mensaje): void
{
    $_SESSION['aviso'] = ['tipo' => $tipo, 'mensajes' => (array) $mensaje];
    header("Location: $destino");
    exit;
}

function aviso_pendiente(): ?array
{
    $aviso = $_SESSION['aviso'] ?? null;
    unset($_SESSION['aviso']);         // se muestra UNA vez
    return $aviso;
}
```

**Por qué hace falta.** Después de guardar, el front **redirige** al listado.
Una redirección es una petición nueva: el programa arranca de cero y todo lo
que había en memoria se perdió. La sesión es el único sitio donde el aviso
«Se agregó…» puede esperar a la pantalla siguiente.

Y el `unset` es la mitad del asunto: sin él, el aviso saldría en **todas** las
pantallas siguientes. La prueba de humo lo comprueba — pide el listado dos
veces y exige que la segunda ya no lo traiga.

Fíjese también en `(array) $mensaje`: el **casting a array**. Si llega un
texto, lo vuelve `['ese texto']`; si ya es una lista, la deja igual. Así la
plantilla siempre recorre una lista y no tiene que preguntar de qué tipo es.

### 6.5 `$GLOBALS` — el que se usa una vez y con motivo

```php
function pintar(string $vista, array $datos = []): void
{
    $datos += ['errores' => [], 'ruta' => $GLOBALS['ruta'] ?? '/'];
```

`$ruta` se calculó en el **cuerpo** de `index.php`. Una función normal de PHP
**no ve las variables de afuera** —al revés que en JavaScript o Python—, así
que dentro de `pintar()` la variable `$ruta` sencillamente no existe.

Tres salidas había: pasarla como parámetro a cada llamada, declarar
`global $ruta` adentro, o leerla de `$GLOBALS`. Se escogió la tercera y **está
comentada en el código**, porque es la que menos ruido mete en las quince
llamadas a `pintar()`. No es la más elegante; es la que se declaró.

### 6.6 Las que este proyecto NO usa, y por qué

- **`$_REQUEST`** revuelve `$_GET`, `$_POST` y `$_COOKIE` en un solo array.
  Suena cómodo y es una mala idea: uno deja de saber **por dónde entró** el
  dato, y el orden en que se mezclan depende de la configuración del
  servidor. Un `PATCH` no debería poder llegar por la barra de direcciones.
- **`$_COOKIE`** no hace falta: la única cosa que se recuerda entre peticiones
  es el aviso, y eso va en `$_SESSION`. (La sesión sí usa una galleta por
  debajo, pero eso lo maneja PHP.)
- **`$_FILES`** llegará cuando alguna versión suba archivos. Hoy no hay.
- **`$_ENV`** es el caso interesante. El ensamblador necesita la cadena de
  conexión, que el `docker-compose.yml` le pasa como variable de entorno, y la
  lee así:

  ```php
  getenv('DB_DSN') ?: 'mysql:host=localhost;…'
  ```

  **`getenv()` y no `$_ENV`**, porque `$_ENV` solo se llena si la
  configuración de PHP lo pide (`variables_order` con una `E`), y por defecto
  **no la trae**: en la mayoría de instalaciones `$_ENV` está vacío. `getenv()`
  pregunta al sistema operativo directamente y siempre funciona.

  Y el `?:` de ahí no es el `??`: **`?:` mira si el valor es "vacío"**
  (`false`, `''`, `0`), que es justo lo que devuelve `getenv()` cuando la
  variable no existe. El `??` solo mira si es `null`, y no serviría.

### 6.7 La regla que vale para las cinco

> **Todo lo que hay en `$_GET`, `$_POST`, `$_COOKIE`, `$_REQUEST` y buena
> parte de `$_SERVER` lo escribió alguien del otro lado de la red.** No es un
> dato: es una afirmación de un desconocido.

De ahí salen las tres reglas que este proyecto cumple en todas partes:

| Riesgo | Lo que se hace | Dónde verlo |
|---|---|---|
| Inyección de SQL | Los valores **nunca** se pegan al SQL: van como parámetros de PDO | `api_mapa/repositorios/RepositorioProyectoMariaDB.php` |
| Inyección de SQL por el **nombre** de columna | Lista blanca: solo pasan las columnas conocidas | `filtrarColumnas()` en el controlador |
| XSS (meter HTML en la pantalla) | Todo lo que se pinta pasa por `htmlspecialchars` | `front_php/vistas/lista.php` |

Y una cuarta que no es de seguridad sino de honestidad: **la validación de la
forma se hace en la frontera**, en el controlador, antes de que el dato toque
una regla de negocio o una consulta.

---

## 7. Dónde aparecen los arreglos en la arquitectura de este proyecto

Cierre el documento con esto, que es lo que amarra todo:

```
MariaDB  ──fila cruda──►  repositorio  ──objeto──►  servicio  ──objeto──►  controlador  ──array──►  JSON
   (array asociativo)      armar()                                          toArray()
```

1. **PDO devuelve arreglos.** `fetchAll(PDO::FETCH_ASSOC)` entrega cada fila
   como `['id' => …, 'titulo' => …]`, con **todo como texto**
   (un número de la base llega como `"42"`).
2. **El repositorio los vuelve objetos**, y ahí mismo arregla los tipos con
   los casts. De ese punto en adelante, el dato viaja tipado.
3. **El controlador los vuelve arreglos otra vez** con `toArray()`, porque
   `json_encode` no ve las propiedades privadas de un objeto.
4. **Y el front trabaja con arreglos a propósito**, nunca con las clases de la
   API. Está escrito en `front_php/cliente_api.php`: podría hacer un `require`
   del modelo —los dos están en PHP y en carpetas vecinas— y está prohibido.
   Lo único que comparten los dos procesos es el JSON, y un JSON decodificado
   es un array.

El «sobre» que devuelven todas las funciones del front es, otra vez, un array
con llaves fijas:

```php
['ok' => bool, 'datos' => mixed, 'errores' => string[]]
```

Una vista pregunta `if ($r['ok'])`, no «¿fue 200 o 204?». **El array es el
contrato entre las dos.**

---

## 8. Diez errores clásicos (los que va a cometer)

| # | El error | Qué pasa | El arreglo |
|---|---|---|---|
| 1 | `if (isset($d['x']))` para saber si el campo vino | Un `null` explícito se ve como «no vino» | `array_key_exists('x', $d)` |
| 2 | `if (empty($d['x']))` para lo mismo | El texto `"0"` se ve como vacío | igual que arriba |
| 3 | Guardar arrays en el almacén y modificarlos por variable | Modifica una copia; no cambia nada y no avisa | Guardar objetos, o reasignar `$a[$k] = $v` |
| 4 | `array_merge` sobre listas con llaves que significan algo | Renumera desde 0 y las pierde | El operador `+` |
| 5 | `$a + $b` esperando que gane `$b` | Gana `$a` | `array_merge` si quiere que mande el derecho |
| 6 | `foreach ($x as &$v)` sin `unset($v)` al final | La última vuelta se repite y sobrescribe | `unset($v)`, o `array_map` |
| 7 | `foreach ($x['y'] as …)` sin `?? []` | Si `y` no vino, la página se cae entera | `$x['y'] ?? []` |
| 8 | Leer `$_POST` cuando el cliente mandó JSON | Sale vacío y parece que no llegó nada | `json_decode(file_get_contents('php://input'), true)` |
| 9 | Tratar `$_GET['n']` como número | Es texto: `"5" + 1` funciona, pero `is_int("5")` es `false` | Convertir en la frontera: `(int) $_GET['n']` |
| 10 | Usar `$_SESSION` sin `session_start()` | El array existe pero no se guarda nada | Llamarlo antes de tocarla |

---

## 9. Para practicar, con este código en la mano

1. Abra `api_mapa/pruebas/prueba_capas.php`, busque en el repositorio falso
   la línea `$fila = $this->datos[$clave];` y póngale **una palabra**:

   ```php
   $fila = clone $this->datos[$clave];
   ```

   Corra la prueba. `actualizar` **sigue diciendo `[OK]`** —devuelve 1, como
   siempre— y la que falla es la de más abajo, la que comprueba que el campo
   cambió. Ahí está la sección 4 en una palabra: `clone` hizo una copia, los
   setters escribieron en la copia, y la copia se botó al terminar el método.
   **Devolver 1 sin haber cambiado nada** es exactamente el silencio del que
   habla esa sección. Quite el `clone` y vuelve a pasar.
2. En el controlador, cambie **un** `array_key_exists` por `isset` y mande un
   `PATCH` con ese campo en `null`. Mire qué cambia en la respuesta.
3. En la vista del listado, quite el `htmlspecialchars` de una columna y cree
   un registro cuyo texto sea `<b>hola</b>`. Verá el HTML interpretado: eso es
   XSS, en pequeño.
4. En el `UPDATE` dinámico, imprima `$sql` con dos campos y con uno solo.
   Compare las dos consultas y vuelva a leer la sección 5.3.
5. Cuente usted mismo cuántas veces aparece `array_key_exists` en el
   código de este repositorio:

   ```powershell
   Get-ChildItem -Recurse -Filter *.php -Exclude ProyectosDeAula |
     Select-String "array_key_exists" | Measure-Object
   ```

   **Le va a dar un número distinto al de la tabla**, y eso no es un error de
   ninguno de los dos: la tabla cuenta **llamadas**, y ese comando cuenta
   **apariciones del texto**, comentarios incluidos. Encuentre la diferencia
   —está en un comentario— y de paso vea por qué contar código con una
   búsqueda de texto siempre miente un poco.

   Si la diferencia es mayor que eso, entonces sí: **el documento quedó
   desactualizado y usted acaba de encontrarlo**. Dígalo.

---

## 10. Para seguir leyendo

| | |
|---|---|
| [3_plan.md](spec_kit/versiones/v1_proyecto/3_plan.md) | Las capas de esta versión y por qué están cortadas ahí |
| [6_contracts.md](spec_kit/versiones/v1_proyecto/6_contracts.md) | El sobre del JSON: qué array recibe el front en cada respuesta |
| Manual de PHP — [Arrays](https://www.php.net/manual/es/language.types.array.php) | La definición oficial, en español |
| Manual de PHP — [Variables superglobales](https://www.php.net/manual/es/language.variables.superglobals.php) | Las nueve, con lo que trae cada una |
