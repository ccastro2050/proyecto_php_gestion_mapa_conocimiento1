# SOLID, programación por capas y patrones de diseño

> Documento conceptual del curso. Los cinco principios SOLID, la arquitectura
> por capas y los patrones de diseño que este código usa: qué son, por qué
> importan, y dónde se ven (o se verán) en cada versión del proyecto.

---

## 1. Programación por capas

Organizar el sistema en **niveles con responsabilidades distintas**, donde
cada capa solo conoce a la inmediatamente inferior y siempre a través de un
contrato. Así se ve el **viaje de UNA petición** por dentro de la API — el
"diagrama de palitos" del curso:

```
            EL CLIENTE (navegador, Postman, curl)
                 │
                 │  ① GET /api/proyecto/PR001
                 ▼
┌─────────────────────────────────────────────────────┐
│ CAPA 1 — CONTROLADOR (HTTP)                         │
│ controladores/ControladorProyecto.php               │
│ Recibe la petición, valida la ENTRADA y traduce el  │
│ resultado a códigos HTTP y JSON. NO tiene negocio.  │
│ NO tiene SQL.                                       │
└────────────────┬────────────────────────────────────┘
                 │  ② $servicio->obtenerPorCodigo("PR001")
                 ▼
┌─────────────────────────────────────────────────────┐
│ CAPA 2 — SERVICIO (negocio)                         │
│ servicios/ServicioProyecto.php                      │
│ Las reglas del dominio: qué se puede y qué no (el   │
│ 404 "no existe" NACE aquí). NO conoce HTTP.         │
│ NO sabe qué motor hay debajo.                       │
└────────────────┬────────────────────────────────────┘
                 │  ③ $repositorio->obtenerPorCodigo("PR001")
                 │     — a través de la INTERFAZ IRepositorioProyecto
                 ▼
┌─────────────────────────────────────────────────────┐
│ CAPA 3 — REPOSITORIO (datos)                        │
│ repositorios/RepositorioProyectoMariaDB.php         │
│ El SQL con PDO: traduce filas ↔ objetos Proyecto.   │
│ NO conoce HTTP. NO decide negocio.                  │
└────────────────┬────────────────────────────────────┘
                 │  ④ SELECT … FROM proyecto WHERE codigo = :codigo
                 ▼
          ┌───────────────┐
          │ BASE DE DATOS │  MariaDB — mapa_php_local
          └───────┬───────┘
                  │
   y la respuesta hace el viaje DE VUELTA:
   fila → objeto Proyecto (repositorio) → objeto (servicio)
        → JSON + 200 (controlador) → cliente
```

Qué hace — y qué tiene PROHIBIDO — cada capa:

| Capa | Su trabajo | Prohibido para ella | En la v1 |
|---|---|---|---|
| **Controlador** | HTTP: validar el body, códigos de estado, JSON | SQL y reglas de negocio | `controladores/ControladorProyecto.php` |
| **Servicio** | Las reglas del negocio (¿existe? ¿se puede?) | Saber de HTTP o del motor de BD | `servicios/ServicioProyecto.php` |
| **Repositorio** | El SQL y el mapeo fila ↔ objeto | Saber de HTTP o decidir negocio | `repositorios/RepositorioProyectoMariaDB.php` |

**La regla de oro:** las dependencias apuntan en una sola dirección y cruzan
por **interfaces**. El controlador conoce al servicio; el servicio conoce la
interfaz del repositorio; **nadie** conoce dos capas hacia abajo (el
controlador no sabe que existe MariaDB).

**El mismo viaje cuando algo sale mal** — `GET /api/proyecto/PR999`:

1. El **repositorio** no encuentra la fila y devuelve `null` — un HECHO,
   sin opinión.
2. El **servicio** decide qué significa ese hecho: "ese proyecto no
   existe" — y lo dice lanzando `NoEncontradoExcepcion` (una DECISIÓN de
   negocio).
3. El **controlador** captura la excepción y la traduce al idioma HTTP:
   **404** con su JSON.

Cada capa aportó exactamente lo suyo: datos → hecho, negocio → decisión,
HTTP → código de estado.

**Justificación:** cada capa se puede cambiar, probar o reemplazar sin tocar
las otras. La prueba viva es el criterio 6 de la v1: el servicio se prueba con
un repositorio falso (`pruebas/prueba_capas.php`), sin base de datos.

Y el SISTEMA repite el patrón a lo grande — **desde la v1**, no como meta:

```
CAPA 1: FRONT (:8116)   → solo pinta y llama la API; nunca toca la BD
CAPA 2: API   (:8117)   → solo JSON
CAPA 3: DATOS           → MariaDB → +PostgreSQL (v3) → +SQL Server (v4)
```

Y aquí la separación tampoco es una promesa: se apaga la API **con la base de
datos encendida** y la pantalla sigue respondiendo, con su aviso y sin una
sola fila. Si el front pudiera llegar a la base por su cuenta, los datos
seguirían apareciendo. Ésa es la prueba, y solo se puede hacer si la versión
trae su front.

### 1.1 ¿Y los MODELOS? ¿Por qué no aparecen como capa?

Pregunta legítima: la carpeta de modelos (`modelos/Proyecto.php`) existe en el
proyecto, pero la tabla de capas no la menciona. ¿Se olvidó? No — **el
modelo NO es una capa, y la diferencia ES la lección:**

- Las **capas son las ESTACIONES del viaje**: cada una le HACE algo a la
  petición (el controlador traduce HTTP, el servicio decide, el
  repositorio consulta).
- El **modelo es LO QUE VIAJA entre estaciones**: el repositorio arma un
  `Proyecto` desde la fila, el servicio lo razona, el controlador lo
  vuelve JSON. No procesa nada: ES el paquete. Por eso el diagrama de
  palitos no lo pinta como caja — el modelo va implícito en las flechas.

```mermaid
flowchart LR
    subgraph CAPAS["Las ESTACIONES (sí son capas)"]
        C["Controlador<br/>(HTTP)"] --> S["Servicio<br/>(negocio)"] --> R["Repositorio<br/>(datos)"]
    end
    M["MODELO Proyecto<br/>el paquete que viaja"]
    C -.->|"lo conoce"| M
    S -.->|"lo conoce"| M
    R -.->|"lo conoce"| M
    M -.->|"y él NO conoce a NADIE:<br/>ni HTTP, ni SQL, ni framework"| NADA(( ))
```

**Guía de lectura:** las tres estaciones lo conocen y él no conoce a
ninguna — a eso se le llama un elemento **transversal**. No viola la regla
de dependencias ("cada capa solo conoce a la de abajo") porque conocer un
modelo no acopla a nada: el modelo no arrastra dependencias, solo trae
datos con tipos.

**¿Entonces para qué se necesita?** Es el **idioma común** del sistema —
el contrato interno entre capas. Sin modelo, las capas se pasarían
diccionarios sueltos sin tipos, y el error de escribir `stok` en vez de
`presupuesto` no lo atraparía nadie hasta producción. Con modelo, lo atrapa el
lenguaje. En PHP el modelo es la clase con propiedades tipadas — el `presupuesto` que
SIEMPRE es entero, gracias a `declare(strict_types=1)`.

**La regla del modelo** (tan estricta como las de las capas): el modelo
tiene PROHIBIDO importar cosas del proyecto — ni HTTP, ni SQL, ni
conexiones. Sus flechas de dependencia solo ENTRAN; jamás SALEN.

## 2. Los cinco principios SOLID

SOLID (Robert C. Martin) son cinco reglas de diseño orientado a objetos para
que el software **aguante el cambio**. Este proyecto está diseñado para que
cada principio tenga su momento de demostración en la ruta de versiones:

### S — Responsabilidad Única (*Single Responsibility*)
> Una clase debe tener UNA sola razón para cambiar.

**En la v1:** el controlador cambia si cambia el HTTP; el servicio si cambian
las reglas de negocio; el repositorio si cambia el SQL; el modelo si
cambian las reglas de forma. Cuatro archivos, cuatro razones de cambio, cero
mezcla.

```php
// ❌ Sin S: un index.php que hace TODO (HTTP + negocio + SQL revueltos)
if ($ruta === '/api/proyecto' && $metodo === 'GET') {
    $pdo = new PDO(...);                          // SQL aquí = mezcla
    $filas = $pdo->query('SELECT ...');
    if (!$filas) { http_response_code(404); }     // negocio aquí = mezcla
}

// ✅ Con S (la v1): un archivo por razón de cambio
//   controladores/  → cambia solo si cambia el HTTP
//   servicios/      → cambia solo si cambian las reglas
//   repositorios/   → cambia solo si cambia el SQL
//   modelos/        → cambia solo si cambia la forma del dato
```

### O — Abierto/Cerrado (*Open/Closed*)
> Abierto a extensión, cerrado a modificación: agregar sin romper lo que hay.

**Su momento es la v3:** agregar PostgreSQL será escribir UNA clase nueva
(`RepositorioProyectoPostgreSQL implements IRepositorioProyecto`) y ajustar el
ensamblador — controladores y servicios no se tocan. Si en la v3 hay que
modificar el servicio, el diseño de la v1 estuvo mal (por eso la v1 deja las
interfaces listas).

```php
// La v3 AGREGARÁ sin modificar: una clase nueva con la misma interfaz...
class RepositorioProyectoPostgreSQL implements IRepositorioProyecto { /* … */ }

// ...y el ensamblador (ÚNICO archivo tocado) elegirá el motor:
$repositorio = $motor === 'postgres'
    ? new RepositorioProyectoPostgreSQL($dsn, $usuario, $clave)
    : new RepositorioProyectoMariaDB($dsn, $usuario, $clave);
```

### L — Sustitución de Liskov (*Liskov Substitution*)
> Donde sirve el tipo base, debe servir CUALQUIER implementación, sin sorpresas.

**Ya se ve en la v1** (¡antes de tiempo!): `RepositorioFalsoEnMemoria` y
`RepositorioProyectoMariaDB` son indistinguibles para el servicio — por eso la
prueba de capas funciona. En v3/v4, los repositorios de cada motor deben
mantener esa indistinguibilidad: mismos métodos, misma semántica, mismos
resultados.

```php
// El repositorio FALSO de la prueba (criterio 6): sin BD, misma interfaz
class RepositorioFalsoEnMemoria implements IRepositorioProyecto
{
    public function obtenerPorCodigo(string $codigo): ?Proyecto
    {
        return $this->datos[$codigo] ?? null;   // un array en memoria
    }
    // ...los otros 4 métodos...
}

$servicio = new ServicioProyecto(new RepositorioFalsoEnMemoria());
// ← y el servicio NI SE ENTERA de que no hay MariaDB
```

### I — Segregación de Interfaces (*Interface Segregation*)
> Muchas interfaces pequeñas y específicas, no una gigante que obligue a
> implementar lo que no se usa.

**En la v1:** `IRepositorioProyecto` tiene exactamente los 5 métodos del CRUD
de proyecto — no un `IRepositorioUniversal` con 40 métodos. Cuando la v2
agregue persona, tendrá SU interfaz.

```php
// ✅ La interfaz de la v1: SOLO los 5 métodos del CRUD de proyecto
interface IRepositorioProyecto
{
    public function obtenerTodos(int $limite): array;
    public function obtenerPorCodigo(string $codigo): ?Proyecto;
    public function crear(Proyecto $proyecto): bool;
    public function actualizar(string $codigo, array $datos): int;
    public function eliminar(string $codigo): int;
}

// ❌ El anti-ejemplo: un IRepositorioUniversal de 40 métodos donde cada
//    clase queda llena de cuerpos vacíos que PHP la obliga a escribir.
```

### D — Inversión de Dependencias (*Dependency Inversion*)
> Depender de abstracciones, no de implementaciones concretas.

**En la v1:** `ServicioProyecto` recibe **la interfaz** por constructor
(`private readonly IRepositorioProyecto $repositorio`); solo
`ensamblador.php` (una función) conoce la clase concreta. En la v3 ese
ensamblador se convierte en la fábrica real — el único archivo que sabe qué
motores existen.

## 3. Cómo se refuerzan entre sí (el resumen para el examen)

| Sin este principio… | …pasa esto |
|---|---|
| Sin S | El `index.php` de 800 líneas que hace HTTP + negocio + SQL: cambiar cualquier cosa arriesga todo |
| Sin O | Cada motor nuevo = editar el servicio con otro `if ($motor == …)`: el archivo crece y se rompe |
| Sin L | El motor nuevo "casi" funciona igual → ifs especiales por motor → se perdió O |
| Sin I | Interfaces obesas → clases llenas de métodos vacíos que PHP obliga a escribir |
| Sin D | El servicio hace `new PDO(...)` adentro → no hay repositorio falso, no hay pruebas, no hay v3 |

Y las **capas** son SOLID a escala de arquitectura: S reparte responsabilidades
entre capas, D las comunica por contratos, O/L permiten reemplazar una capa
entera (otro motor, otro front) sin tocar las demás.

## 4. Ejemplo resumido de la v1 (todo junto)

```php
// D: el servicio depende de la ABSTRACCIÓN, recibida por constructor
class ServicioProyecto implements IServicioProyecto
{
    public function __construct(
        private readonly IRepositorioProyecto $repositorio,  // ← interfaz, no clase
    ) {
    }
}

// El ÚNICO lugar que conoce la clase concreta (v3 lo convertirá en fábrica):
function crearServicioProyecto(): IServicioProyecto
{
    $repositorio = new RepositorioProyectoMariaDB(
        getenv('DB_DSN'), getenv('DB_USUARIO'), getenv('DB_CLAVE')
    );
    return new ServicioProyecto($repositorio);
}
```

Unas pocas líneas que compran, sin costo extra hoy, toda la ruta v3–v4.

## 5. Patrones de diseño (los que trabajan en este proyecto)

**¿Qué es un patrón de diseño?** Una solución **con nombre**, probada y
reutilizable, para un problema de diseño que aparece una y otra vez. No es
código para copiar y pegar: es la FORMA de una solución — qué clases y qué
interfaces participan, y quién conoce a quién — que cada proyecto escribe
en su propio código. El catálogo clásico es el del "Gang of Four" (GoF,
1994): 23 patrones en tres familias — **creacionales** (cómo se construyen
los objetos), **estructurales** (cómo se componen) y **de comportamiento**
(cómo colaboran). Otros, como Repositorio y DTO, vienen del catálogo de
arquitectura empresarial de Fowler (PoEAA, 2002).

La relación con lo anterior: **SOLID dice qué cualidades debe tener el
diseño; los patrones son recetas concretas que las consiguen; las capas
son el plano general donde unos y otras viven.** Y el nombre importa:
decir "esto es una fábrica abstracta" comunica un diseño completo en tres
palabras.

Los que trabajan en este código:

| Patrón | Familia | Dónde vive aquí |
|---|---|---|
| **Controlador frontal** (Front Controller) | arquitectónico (PoEAA) | `index.php`: TODAS las peticiones entran por un solo punto que enruta |
| **Repositorio** (Repository) | arquitectónico (PoEAA) | `repositorios/`: todo el acceso a datos (PDO) detrás de una interfaz |
| **Inyección de dependencias** | creacional (IoC) | los constructores + el ensamblador |
| **Fábrica** (Factory) | creacional (GoF) | hoy proto-fábrica; se vuelve fábrica real cuando lleguen más motores (v3 del mapa) |
| **Estrategia** (Strategy) | comportamiento (GoF) | implícito: implementaciones intercambiables tras cada interfaz |

### Controlador frontal — una sola puerta de entrada

```php
// index.php: el servidor manda TODA petición aquí; este archivo enruta
// hacia el controlador que corresponda. Nadie más conoce las URLs.
match (true) {
    $ruta === '/api/proyecto' && $metodo === 'GET' => $controlador->listar(),
    // …
};
```

### Repositorio — el negocio pide datos a un contrato, no a un motor

```php
// El contrato (repositorios/IRepositorioProyecto.php):
public function obtenerPorCodigo(string $codigo): ?Proyecto;

// ServicioProyecto lo usa SIN saber si detrás hay MariaDB o un array
// en memoria (pruebas/prueba_capas.php).
```

### Inyección de dependencias — nadie construye lo que necesita

```php
class ServicioProyecto implements IServicioProyecto
{
    public function __construct(
        private readonly IRepositorioProyecto $repositorio,  // ← llega armado
    ) {
    }
}
```

### Fábrica — UNA decisión de motor, en un solo lugar

```php
// La proto-fábrica de la v1 (el ensamblador) se convertirá en fábrica
// real cuando lleguen más motores (v3 del mapa):
function crearRepositorioProyecto(string $motor): IRepositorioProyecto
{
    return $motor === 'postgres'
        ? new RepositorioProyectoPostgreSQL($dsnPg, $usuario, $clave)
        : new RepositorioProyectoMariaDB($dsnMaria, $usuario, $clave);
}
// Agregar un motor = UNA clase nueva y UNA rama aquí — nada más se toca.
```

### Estrategia — el patrón que va de regalo

La pareja "interfaz + implementaciones intercambiables"
(`RepositorioProyectoMariaDB`, `RepositorioFalsoEnMemoria` — y los motores
que vengan) es la esencia de Strategy: quien usa la interfaz jamás
pregunta cuál implementación le tocó.

## 6. Referencias

1. Robert C. Martin — *Design Principles and Design Patterns* (el artículo
   original de los principios, 2000):
   <https://web.archive.org/web/20150906155800/http://www.objectmentor.com/resources/articles/Principles_and_Patterns.pdf>
2. Robert C. Martin — *Clean Architecture* (2017): capas, la regla de
   dependencia y SOLID aplicado a arquitectura.
3. Martin Fowler — *PresentationDomainDataLayering*:
   <https://martinfowler.com/bliki/PresentationDomainDataLayering.html>
4. PHP — interfaces de objetos:
   <https://www.php.net/manual/es/language.oop5.interfaces.php>
5. Gamma, Helm, Johnson y Vlissides — *Design Patterns* (GoF, 1994): el
   catálogo original de los 23 patrones.
6. Martin Fowler — *Patterns of Enterprise Application Architecture*
   (PoEAA, 2002): Repositorio, DTO, Front Controller y compañía.
7. En este repositorio: el [plan de la v1](spec_kit/versiones/v1_proyecto/3_plan.md)
   (§3 capas, §4.1 interfaces, §4.3 la proto-fábrica) y el
   [mapa de versiones](spec_kit/versiones/0_mapa_versiones.md) (dónde entra
   cada principio).
