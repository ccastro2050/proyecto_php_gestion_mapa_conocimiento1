# Guía de IA — v1: `proyecto` (PHP + MariaDB)

Cómo reconstruir esta versión desde cero con ayuda de una IA, y **qué
revisarle**, que es la mitad que se suele saltar.

## 1. El andamiaje: carpetas y archivos vacíos

La IA escribe mejor cuando el esqueleto ya existe. Estos comandos se corren
en PowerShell, parado en la carpeta del proyecto:

```powershell
# Las carpetas
mkdir docs\spec_kit\versiones\v1_proyecto, db, front_php\publico, api_mapa, api_mapa\controladores, api_mapa\excepciones, api_mapa\modelos, api_mapa\pruebas, api_mapa\repositorios, api_mapa\servicios, front_php, front_php\vistas, pruebas_humo

# Los archivos, vacíos: la IA los llena, uno por uno, y usted los revisa
New-Item .gitattributes, .gitignore, api_mapa\Dockerfile, api_mapa\controladores\ControladorProyecto.php, api_mapa\excepciones\NoEncontradoExcepcion.php, api_mapa\index.php, api_mapa\modelos\Proyecto.php, api_mapa\pruebas\prueba_capas.php, api_mapa\repositorios\IRepositorioProyecto.php, api_mapa\repositorios\RepositorioProyectoMariaDB.php, api_mapa\servicios\IServicioProyecto.php, api_mapa\servicios\ServicioProyecto.php, api_mapa\servicios\ensamblador.php, docker-compose.yml, front_php\Dockerfile, front_php\cliente_api.php, front_php\index.php, front_php\vistas\formulario.php, front_php\vistas\inicio.php, front_php\vistas\lista.php, front_php\vistas\no_encontrada.php, front_php\vistas\plantilla.php, pruebas_humo\humo_front.py
```

Fíjese en dos ausencias:

- **`db/init.sql` no está en la lista.** La base es artefacto dado
  (Artículo 5): se deriva del script del curso, no se pide.
- **`front_php/publico/` tampoco.** Ahí van Bootstrap y sus estilos,
  descargados una vez del sitio oficial. No se generan y no van por CDN.


Y `ProyectosDeAula/` se copia tal cual del material del curso: es la fuente,
no algo que se genere.

## 2. El prompt

```text
Vas a construir la versión 1 de un módulo de un proyecto de aula, en PHP.
Lee primero estos archivos del repositorio y respétalos por encima de lo que
tú creas mejor:

  · docs/spec_kit/1_constitution.md            las reglas que no se negocian
  · docs/spec_kit/versiones/v1_proyecto/2_spec.md    qué hay que construir
  · docs/spec_kit/versiones/v1_proyecto/6_contracts.md   cada ruta, exacta
  · ProyectosDeAula/docs/0_METODOLOGIA.md      la metodología del curso

1. PHP 8.3 PURO. Sin framework y SIN COMPOSER. Solo lo que trae PHP: PDO,
   curl, json_encode, session_start. Si te dan ganas de instalar algo, no.

2. TRES CAPAS ESTRICTAS, y cada una ignora a las otras dos:
     controladores/  HTTP: valida la FORMA del cuerpo (422) y traduce
                     excepciones a códigos. Cero SQL, cero reglas.
     servicios/      Las reglas. Lanza InvalidArgumentException y
                     NoEncontradoExcepcion. La palabra HTTP no aparece.
     repositorios/   El SQL, en prepared statements de PDO. Nada más.
   El servicio recibe la INTERFAZ del repositorio por constructor, nunca la
   clase concreta. El ensamblador es el ÚNICO archivo que hace `new`.

3. La tabla es `proyecto`, con llave `id` y estos campos:
   id (entero), titulo (texto), resumen (texto), presupuesto (número), tipo_financiacion (texto), tipo_fondos (texto), fecha_inicio (fecha), fecha_fin (fecha, opcional)

4. EL BORRADO ES LÓGICO: DELETE marca activo = FALSE y la fila se queda.
   TODAS las consultas del repositorio filtran por activo = TRUE, incluida
   la del propio DELETE — sin eso, retirar dos veces respondería 200 las dos.

5. Cumple 6_contracts.md AL PIE DE LA LETRA: mismas rutas, mismos códigos,
   mismo sobre. Incluido el contraste PUT (reemplazo: falta un campo → 422)
   contra PATCH (parcial: el MISMO cuerpo → 200), y el cuerpo vacío del
   PATCH, que es 400 y no 422.

6. La base YA VIENE DADA en db/init.sql. No la modifiques ni escribas SQL de
   creación de tablas. La tabla `proyecto` arranca con 14
   filas sembradas.

7. Todo en español: clases, métodos, variables, comentarios y mensajes.
   declare(strict_types=1); como primera instrucción de cada archivo.

8. Comenta explicando DECISIONES, y también la sintaxis de PHP que un
   estudiante de segundo semestre no ha visto: la promoción de propiedades
   del constructor, `?Tipo`, `??`, las arrow functions.

9. LA VERSIÓN INCLUYE SU PANTALLA, y es la mitad del trabajo, no un añadido.
   Un FRONT en PHP, en su propia aplicación y en su propio contenedor,
   publicando el puerto 8116:

   · una pantalla por recurso, con DIRECCIÓN PROPIA (/proyectos),
     nunca una ruta con el nombre de la tabla como parámetro;
   · una FUNCIÓN POR OPERACIÓN —listar_mapa, crear_mapa…—,
     nunca un cliente genérico con la tabla como parámetro;
   · la pantalla NO le habla al usuario en jerga: ni PUT, ni PATCH, ni 422,
     ni rutas de la API. Los dos botones de guardar se llaman "Guardar la
     ficha completa" y "Guardar solo lo que cambié";
   · un error de la API NO borra lo que la persona había escrito;
   · sin filas, un recuadro que diga que todavía no hay: vacío no es error;
   · y como el borrado es lógico, la palabra es RETIRAR, no borrar.

   CUATRO COSAS QUE VAS A QUERER HACER Y NO DEBES:

   a) Servir las páginas desde la misma API. NO: son dos procesos, y hay que
      poder demostrarlo apagando uno.
   b) Un cliente genérico. NO: una función por operación y por recurso.
   c) Meter Bootstrap por CDN. NO: va descargado en front_php/publico/. Un
      front que necesita internet para verse bien no arranca en un salón sin
      red.
   d) Y NO compartas código entre la API y el front. Las dos están en PHP y
      en carpetas vecinas, así que un
      require_once __DIR__ . '/../api_mapa/modelos/Proyecto.php'
      FUNCIONARÍA. Está prohibido: son dos procesos, y lo único que comparten
      es el JSON. El front trabaja con arrays, no con las clases de la API.
      Que aquí sí se pueda y no se haga es el punto: una separación que el
      lenguaje impide se cumple sola; ésta hay que sostenerla.

Y hay un criterio que se comprueba apagando un contenedor: con la API
apagada, la pantalla tiene que SEGUIR RESPONDIENDO, con su menú y su aviso, y
SIN UN SOLO DATO. Si sigue mostrando las filas, el front está leyendo de
donde no debe.
```

## 3. Lo que la IA propone con más naturalidad, y está mal

| Qué | Por qué pasa | Qué revisar |
|---|---|---|
| **Instalar Composer «solo para el autoload»** | Es lo normal en PHP moderno | ¿Apareció un `composer.json`? Los `require_once` a mano son parte del ejercicio |
| **Un `DELETE FROM`** | Es lo que uno escribe sin pensar | ¿`eliminar()` hace `UPDATE … SET activo = FALSE`? ¿Y filtra `AND activo = TRUE`? |
| **Olvidar el `activo = TRUE` en una consulta** | La primera se escribe bien; la cuarta se copia mal | Las **cuatro** consultas del repositorio deben filtrarlo |
| **`MYSQL_ATTR_FOUND_ROWS` faltando** | Nadie lo conoce hasta que muerde | Reenvíe un `PUT` con los MISMOS datos: si responde 404, falta esa opción |
| **Bootstrap por CDN** | Es lo que hace todo el mundo | ¿`vistas/plantilla.php` tiene un `<link>` a un dominio externo? |
| **Tratar el 204 como error** | Un 204 no trae cuerpo y el código que espera JSON revienta | ¿Qué muestra la pantalla con la tabla vacía? Debe decir «todavía no hay» |
| **El CSS servido por el router** | `php -S` con router ejecuta el router para TODO | Abra la pantalla: si se ve sin estilos, falta el `return false` |
| **`activo` en el modelo o en la lista blanca** | Es una columna de la tabla, parece un campo más | ¿`Proyecto::toArray()` lo devuelve? No debe |
| **Un cliente genérico en el front** | Es más corto, y con una sola tabla ni se nota | ¿Las funciones se llaman `listar_mapa` o `listar($recurso)`? |
| **`require` del modelo de la API en el front** | Están ahí al lado y ahorra escribirlos | ¿Hay algún `require` que apunte a `../api_mapa/`? |

## 4. Y lo que la IA no va a hacer sola

Comparar con el gemelo. Este mismo módulo está en
`proyecto_paradigmas_mapa_conocimiento1`, en Python y FastAPI. Levante los dos,
póngalos lado a lado, y responda dos preguntas:

1. **¿Qué le costó a cada uno?** Cuente las líneas de validación de los dos
   controladores. Después pídale a cada API una fila que no exista y compare
   los dos cuerpos de error.
2. **¿Qué quedó igual?** Las tres capas, las dos interfaces, el ensamblador,
   el borrado lógico. Nada de eso era del lenguaje: era del diseño.

Ésa es la parte que no se automatiza, y es la que se evalúa.
