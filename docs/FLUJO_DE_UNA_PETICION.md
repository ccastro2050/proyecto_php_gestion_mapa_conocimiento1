# El flujo de una petición — dónde está el GET, dónde se captura el POST

> Documento para leer CON el código abierto. Responde las preguntas que todo
> el mundo se hace la primera vez: ¿dónde "está" el GET? ¿quién captura el
> body del POST? ¿cómo termina ejecutándose mi método del controlador?

---

## 1. Lo primero: el verbo NO lo pone su código — lo manda el cliente

Cuando el navegador (o PowerShell, o Thunder Client) hace una petición, por
la red viaja un texto que empieza así:

```
GET /api/proyecto HTTP/1.1          ← un GET: verbo + ruta, sin body
```

```
POST /api/proyecto HTTP/1.1         ← un POST: verbo + ruta...
Content-Type: application/json

{"codigo":"PR009","nombre":"Webcam","stock":10,"valorunitario":350000}   ← ...y body
```

El verbo (GET, POST, PUT, PATCH, DELETE) **viene de afuera**. Su código no
lo declara: lo **lee** y decide qué hacer con él.

> El navegador solo sabe mandar GET desde la barra de direcciones. Para
> mandar POST/PUT/PATCH/DELETE se usa PowerShell (`Invoke-RestMethod`),
> `curl` o una extensión como Thunder Client en VS Code.

## 2. Las tres capturas (todas en `index.php`)

PHP recibe la petición y deja sus piezas listas en variables especiales.
`index.php` las captura al comienzo:

| Qué se captura | Línea de `index.php` | Queda en |
|---|---|---|
| **El verbo** | `$metodo = $_SERVER['REQUEST_METHOD'];` | `$metodo` vale `"GET"`, `"POST"`… |
| **La ruta** | `$ruta = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);` | `$ruta` vale `"/api/proyecto"` |
| **El body** | `$body = json_decode(file_get_contents('php://input'), true) ?? [];` | `$body` es un array con el JSON (o `[]` si no había) |

- `$_SERVER` es un array que PHP llena solo, con los datos de la petición.
- `php://input` es el canal donde PHP deja el body crudo; `json_decode` lo
  convierte a array de PHP.
- En un GET no hay body → `$body` queda `[]` y nadie lo usa.

## 3. El enrutador: comparar y despachar

Con el verbo y la ruta capturados, `index.php` hace comparaciones simples:

```php
if ($ruta === '/api/proyecto') {          // ¿pidieron la colección?
    if ($metodo === 'GET') {
        $controlador->listar();           // GET  → listar
    } elseif ($metodo === 'POST') {
        $controlador->crear($body);       // POST → crear (y le PASA el body)
    } else {
        responderNoPermitido();           // otro verbo aquí → 405
    }
    return;
}
```

**Esto es "el GET" y "el POST" funcionando**: una comparación de texto
contra lo que el cliente mandó. El método `listar()` del controlador es "el
GET de la colección" únicamente porque el enrutador SOLO lo llama cuando
`$metodo` vale `"GET"`.

> En los frameworks (FastAPI, ASP.NET, Laravel…) esta comparación existe
> igual, pero la hace el framework por dentro y usted solo ve un decorador
> o anotación sobre la función. En PHP puro la comparación queda a la
> vista — esa es la gracia didáctica.

## 4. El viaje completo de un POST, capa por capa

`POST /api/proyecto` con `{"codigo":"PR009","nombre":"Webcam","stock":10,"valorunitario":350000}`:

```
1. index.php        captura  $metodo="POST", $ruta="/api/proyecto", $body=[...]
2. index.php        compara  y llama $controlador->crear($body)
3. ControladorProyecto::crear
      valida el body (los ifs de validarCodigo + validarCampos)
      ├─ ¿errores?  → responde 422 con la lista y AQUÍ TERMINA
      └─ ¿limpio?   → try { $this->servicio->crear($datos) } …
4. ServicioProyecto::crear
      construye el objeto del modelo (new Proyecto(...))
      y se lo pasa al repositorio (por la interfaz)
5. RepositorioProyectoMariaDB::crear
      INSERT INTO proyecto (...) VALUES (:codigo, :nombre, ...)  ← PDO preparado
6. MariaDB           inserta la fila (y aplica SUS reglas: PK, NOT NULL…)
7. La respuesta sube: el controlador responde 200 {estado, mensaje}
```

Si algo falla en 4, 5 o 6, la excepción sube hasta el `try/catch` del
método del controlador, que la traduce a un código HTTP:

| Qué pasó | Excepción | Código |
|---|---|---|
| El body venía mal formado | (no es excepción: lo detectan los ifs) | **422** |
| Regla de negocio rota (límite ≤ 0, PATCH sin campos) | `InvalidArgumentException` | **400** |
| El código no existe en la tabla | `NoEncontradoExcepcion` | **404** |
| La BD rechazó (código duplicado, conexión caída…) | `PDOException` u otra | **500** |


**El mismo viaje, como diagrama de flujo** — fíjese en que la gracia son
las SALIDAS TEMPRANAS: cada capa puede terminar la película sin molestar a
las de abajo:

```mermaid
flowchart TD
    A["1. php -S / php-fpm recibe<br/>el texto HTTP"] --> B["2. index.php encuentra<br/>POST /api/proyecto<br/>en la tabla de rutas"]
    B --> C{"3. ¿el body pasa la<br/>validación A MANO<br/>del controlador?"}
    C -->|"NO"| E422["422 con la lista de errores.<br/>AQUÍ TERMINA: su código de<br/>negocio nunca se enteró"]
    C -->|"sí"| D["4. el controlador<br/>(con su try/catch)"]
    D --> E["5. el SERVICIO:<br/>reglas de negocio<br/>(no conoce HTTP)"]
    E -->|"regla rota:<br/>InvalidArgumentException"| E400["400 con su sobre:<br/>estado, mensaje, detalle"]
    E -->|"pasa"| F["6. el REPOSITORIO:<br/>INSERT parametrizado<br/>con PDO y :codigo, ..."]
    F --> G{"7. ¿la base de<br/>datos aceptó?"}
    G -->|"PK duplicada · NOT NULL<br/>· conexión caída"| E500["500 con el error del<br/>motor en el detalle"]
    G -->|"sí"| OK["8. la respuesta SUBE<br/>por las mismas capas:<br/>200 estado, mensaje"]
```

**Guía de lectura:** el camino feliz es la columna del centro; cada rombo
es una defensa y cada salida lateral, un código HTTP distinto. Por eso el
error también es contrato: se sabe QUIÉN lo decide (la frontera → 422, el
servicio → 400, la BD → 500) y QUIÉN le pone el número (el controlador).


## 5. El viaje de un GET (más corto: no hay body ni validación de forma)

`GET /api/proyecto/PR001`:

```
1. index.php        captura  $metodo="GET", $ruta="/api/proyecto/PR001"
2. index.php        recorta  el código con substr → "PR001"
                    y llama  $controlador->obtener("PR001")
3. ControladorProyecto::obtener   try { responder(200, servicio->obtener(...)) }
4. ServicioProyecto::obtener      pide al repositorio; si llega null → lanza
                                  NoEncontradoExcepcion (el catch la vuelve 404)
5. RepositorioProyectoMariaDB     SELECT ... WHERE codigo = :codigo
6. La fila vuelve convertida en objeto Proyecto y sale como JSON
```


**Y el del GET, en diagrama de flujo** (la defensa aquí es una sola: ¿existe?):

```mermaid
flowchart LR
    A["GET /api/<br/>proyecto/PR001"] --> B["controlador"] --> S["servicio"] --> R["repositorio:<br/>SELECT ... WHERE<br/>codigo = :codigo"]
    R --> E{"¿hay fila?"}
    E -->|"sí"| OK["200: el proyecto<br/>en JSON"]
    E -->|"no"| N["el servicio lanza<br/>'no existe'<br/>(NoEncontradoExcepcion)"] --> C404["el controlador<br/>la traduce: 404"]
```


## 6. Véalo usted mismo (5 minutos)

En la terminal de VS Code (PowerShell), con el proyecto corriendo:

```powershell
# GET (el navegador también sirve para estos dos)
Invoke-RestMethod "http://localhost:8117/api/proyecto"
Invoke-RestMethod "http://localhost:8117/api/proyecto/PR001"

# POST — crear
Invoke-RestMethod -Method Post -Uri "http://localhost:8117/api/proyecto" -ContentType "application/json" -Body '{"codigo":"PR009","nombre":"Webcam","stock":10,"valorunitario":350000}'

# PUT con body incompleto → error 422 (PUT exige TODO)
Invoke-RestMethod -Method Put -Uri "http://localhost:8117/api/proyecto/PR009" -ContentType "application/json" -Body '{"stock":25}'

# PATCH con el MISMO body → 200 (PATCH es parcial)
Invoke-RestMethod -Method Patch -Uri "http://localhost:8117/api/proyecto/PR009" -ContentType "application/json" -Body '{"stock":25}'

# DELETE — limpiar
Invoke-RestMethod -Method Delete -Uri "http://localhost:8117/api/proyecto/PR009"
```

La pareja PUT/PATCH con el mismo body es la lección más importante del
flujo: el MISMO dato, dos verbos, dos resultados — porque cada verbo tiene
su semántica y la API la hace cumplir.
