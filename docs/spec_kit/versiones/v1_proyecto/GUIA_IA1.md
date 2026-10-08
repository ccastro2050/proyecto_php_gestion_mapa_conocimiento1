# Cómo construir la v1 con IA — por chat o con un IDE agéntico

**Módulo Mapa de Conocimiento · `proyecto` · PHP 8.3 + MariaDB**

> Los dos caminos para construir esta versión con ayuda de IA. La clave es la
> misma en ambos: **la IA no inventa, sigue el spec kit.** Usted verifica; la
> IA propone (chat) o ejecuta bajo su supervisión (IDE).
>
> Antes de abrir cualquiera de los dos, el [9_checklist.md](9_checklist.md)
> tiene que estar en verde. Construir sobre una spec sin revisar es
> multiplicar el error.

## 0. Los dos caminos

| | **Camino A: chat web** | **Camino B: IDE agéntico** |
|---|---|---|
| Herramientas | Gemini, DeepSeek, ChatGPT, Claude | Antigravity, Cursor, Claude Code, Copilot agente |
| ¿Cómo conoce la spec? | Usted le **sube los 8 archivos** | El agente **lee `docs/spec_kit/`** |
| ¿Quién escribe los archivos? | Usted pega lo que la IA propone | El agente los escribe |
| ¿Quién ejecuta? | Usted, y pega la salida | El agente, pidiendo permiso |
| Su papel | Operador: pegar, ejecutar y reportar | Supervisor: revisar diffs y aprobar |
| Riesgo típico | La IA pierde el contexto en chats largos | El agente avanza de más: hace tres fases de un tirón |

---

## Camino A — Chat web

### A.1 Qué subirle: 8 archivos

| # | Archivo |
|---|---|
| 1 | `docs/spec_kit/1_constitution.md` |
| 2 | `2_spec.md` |
| 3 | `3_plan.md` |
| 4 | `4_research.md` |
| 5 | `5_data_model.md` |
| 6 | `6_contracts.md` |
| 7 | `7_quickstart.md` |
| 8 | `8_tasks.md` |

**No suba nada más.** El `0_mapa_versiones.md` le revelaría lo que viene, y la
regla es que la v1 no anticipa.

> **¿Y el `9_checklist.md`?** Tampoco: no es material para la IA. Es la lista
> con la que **usted** revisó la spec antes de llegar aquí.
>
> **¿Y `db/init.sql`?** Tampoco. Es un artefacto **dado** (Artículo 5): la base
> ya existe con sus 14 filas. Si la IA intenta escribirle un `CREATE TABLE`,
> recuérdele ese artículo.

### A.2 El prompt (cópielo tal cual como PRIMER mensaje)

```text
Actúa como mi asistente de programación para construir la VERSIÓN 1 de un
módulo de un proyecto de aula, partiendo de cero. Te adjunto 8 documentos: una
constitución (reglas permanentes) y el spec kit de la versión 1 (spec, plan,
research con las decisiones, modelo de datos, contratos, quickstart y tareas).

El proyecto es PHP 8.3 PURO sobre MariaDB — así lo fija 3_plan.md. Si en tu
respuesta aparece OTRO lenguaje o framework, significa que no leíste los
adjuntos: detente y dímelo en vez de continuar.

REGLAS DE TRABAJO (no negociables):

1. La especificación manda. No agregues NADA que los documentos no pidan: ni
   paquetes, ni Composer, ni tablas de más, ni "mejoras" de tu cosecha. Si
   crees que falta algo, o si un documento admite dos lecturas, PREGÚNTAME
   antes: no lo resuelvas por tu cuenta ni "asumas" nada. Yo anotaré la
   respuesta en la sección de Clarificaciones de mi 2_spec.md.

2. Vamos a seguir 8_tasks.md FASE POR FASE, en orden, y son DIEZ (0 a 9).
   En cada fase:
   a. Me explicas en 3-5 líneas qué vamos a hacer y por qué.
   b. Me entregas los archivos DE A UNO: primero la ruta exacta y el
      contenido COMPLETO de UN solo archivo, con los comentarios en español
      que exige la constitución: explican POR QUE está hecho así, no qué hace
      cada palabra del lenguaje. Esperas mi "listo" y solo entonces me das el
      siguiente.
   c. Al cerrar la fase me dices su comando de verificación y qué salida
      esperar.
   NO ME DES VARIOS ARCHIVOS EN UNA SOLA RESPUESTA, ni siquiera si son
   cortos, ni siquiera si te parece más eficiente. Un archivo, mi "listo",
   el siguiente.
   NOTA: la estructura de carpetas y los archivos vacíos YA EXISTEN en mi
   proyecto — no me des comandos para crearlos; tu trabajo es dictarme el
   CONTENIDO de cada archivo.

3. Los errores NO nos frenan. Si te pego un error, lo diagnosticas y me das
   el archivo completo corregido; si no sale rápido, seguimos con las fases
   siguientes y lo retomamos al final. Al terminar todas las fases me guías
   para correr el smoke test de 7_quickstart.md y corregimos juntos lo que
   salga.

4. PHP 8.3 PURO. Sin framework y SIN COMPOSER. Solo lo que trae PHP: PDO,
   curl, json_encode, session_start. Si te dan ganas de instalar algo, no.
   declare(strict_types=1); como primera instrucción de cada archivo.

5. TRES CAPAS ESTRICTAS, y cada una ignora a las otras dos:
     controladores/  HTTP: valida la FORMA del cuerpo (422) y traduce
                     excepciones a códigos. Cero SQL, cero reglas.
     servicios/      Las reglas. Lanza InvalidArgumentException y
                     NoEncontradoExcepcion. La palabra HTTP no aparece.
     repositorios/   El SQL, en prepared statements de PDO. Nada más.
   El servicio recibe la INTERFAZ del repositorio por constructor, nunca la
   clase concreta. El ensamblador es el ÚNICO archivo que hace `new`.

6. La tabla es `proyecto`, con llave `id` y estos campos:
   id (entero), titulo (texto), resumen (texto), presupuesto (número), tipo_financiacion (texto), tipo_fondos (texto), fecha_inicio (fecha), fecha_fin (fecha, opcional)
   La base YA VIENE DADA en db/init.sql: no la modifiques ni escribas SQL de
   creación de tablas. Arranca con 14 filas sembradas.

7. EL BORRADO ES LÓGICO: DELETE marca activo = FALSE y la fila se queda.
   TODAS las consultas del repositorio filtran por activo = TRUE, incluida la
   del propio DELETE — sin eso, retirar dos veces respondería 200 las dos.

8. Cumple 6_contracts.md AL PIE DE LA LETRA: mismas rutas, mismos códigos,
   mismo sobre. Incluido el contraste PUT (reemplazo: falta un campo → 422)
   contra PATCH (parcial: el MISMO cuerpo → 200), y el cuerpo vacío del
   PATCH, que es 400 y no 422.

9. Todo en español: clases, métodos, variables, comentarios y mensajes.
   Comenta explicando DECISIONES, y también la sintaxis de PHP que un
   estudiante de segundo semestre no ha visto: la promoción de propiedades
   del constructor, `?Tipo`, `??`, las arrow functions.

10. Trabajo en Windows con VS Code (terminal integrada de PowerShell) y
    Docker Desktop. Dame los comandos para ese entorno. La API publica el
    puerto 8117, el FRONT el 8116, MariaDB el 13333 y phpMyAdmin el 8108.

11. LA VERSIÓN INCLUYE SU PANTALLA, y es la mitad del trabajo, no un añadido.
    Un FRONT en PHP, en su propia aplicación y en su propio contenedor:

    · una pantalla por recurso, con DIRECCIÓN PROPIA (/proyectos),
      nunca una ruta con el nombre de la tabla como parámetro;
    · una FUNCIÓN POR OPERACIÓN —listar_proyectos, crear_proyecto…—, nunca un cliente
      genérico con la tabla como parámetro;
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

Al final, la versión 1 está TERMINADA solo cuando pasan los criterios de
aceptación de 2_spec.md —TODOS, incluidos los de la pantalla—, verificados
con el smoke test de 7_quickstart.md.

Y hay un criterio que se comprueba apagando un contenedor: con la API
apagada, la pantalla tiene que SEGUIR RESPONDIENDO, con su menú y su aviso, y
SIN UN SOLO DATO. Si sigue mostrando las filas, el front está leyendo de
donde no debe.

Empieza: resume en máximo 10 líneas qué vamos a construir (para confirmar que
entendiste el alcance) y luego arranca con la Fase 0.
```

### A.3 El método de la conversación

1. **Pegue primero, ejecute cuando quiera.** Lo obligatorio es pegar cada
   archivo en su ruta y responder "listo". Las verificaciones de cada fase
   puede correrlas en el momento o dejarlas para el final.
2. **Si le entrega varios archivos de golpe, párela.** Es lo que va a intentar
   —le parece más eficiente— y es justo lo que arruina el método: usted deja
   de revisar y empieza a copiar. Dígale: *«te di la regla 2: un archivo,
   espera mi listo»*, y vuelva al último que sí revisó.
3. **No se quede varado.** Si algo falla y no sale rápido, anótelo, siga con
   las fases siguientes y retómelo al final: muchos errores desaparecen cuando
   el sistema está completo.
4. **El punto de control real es el smoke test** de
   [7_quickstart.md](7_quickstart.md), corrido por usted.
5. **Si la primera respuesta llega en otro lenguaje**, la IA no leyó los
   adjuntos: cierre ese chat, verifique que los 8 cargaron y empiece de nuevo.
6. **Si la IA ASUME algo que la spec no dice, párela.** Lo va a mencionar de
   pasada —"asumo que el borrado es físico", "por defecto devuelvo 409"— y ahí
   está el peligro, porque suena a detalle y es una **ambigüedad de la
   especificación**. Decida usted y **anote la respuesta en la sección de
   Clarificaciones de [2_spec.md](2_spec.md)**, no solo en el chat. El chat se
   cierra; la spec queda.

---

## Camino B — IDE agéntico

### B.1 El prompt

```text
Construye la VERSIÓN 1 de este proyecto.

Primero lee, en este orden, los documentos que están bajo docs/spec_kit/
(1_constitution.md en la raíz; los demás en versiones/v1_proyecto/):
1_constitution, 2_spec, 3_plan, 4_research, 5_data_model, 6_contracts,
7_quickstart y 8_tasks. Lee también ProyectosDeAula/docs/0_METODOLOGIA.md.
Después resume en máximo 10 líneas qué vas a construir y espera mi
confirmación antes de tocar nada.

El código va en api_mapa/ y front_php/ según la estructura de
3_plan.md. docs/ y db/ son SOLO LECTURA: no los modifiques. La base de datos
YA VIENE DADA en db/init.sql — se monta tal cual en el compose.

REGLAS (no negociables):

1. La especificación manda. No agregues nada que los documentos no pidan. Si
   crees que falta algo, o si un documento admite dos lecturas, PREGÚNTAME
   antes: no lo resuelvas por tu cuenta ni "asumas" nada. Yo anotaré la
   respuesta en la sección de Clarificaciones de 2_spec.md.

2. Sigue 8_tasks.md fase por fase — son DIEZ (0 a 9). Al terminar cada fase
   EJECUTA su verificación, muéstrame la salida real, y espera mi OK antes de
   seguir. NO ENCADENES FASES: si terminas la 3, paras en la 3.

3. PHP 8.3 PURO, sin framework y SIN COMPOSER. declare(strict_types=1); en
   cada archivo. Tres capas estrictas: el controlador no habla SQL, el
   servicio no sabe que existe HTTP, el repositorio no decide reglas. El
   ensamblador es el único archivo que hace `new`.

4. El borrado es LÓGICO (activo = FALSE) y TODAS las consultas del
   repositorio filtran activo = TRUE, incluida la del DELETE.

5. Cumple 6_contracts.md al pie de la letra, incluido PUT=422 vs PATCH=200
   con el mismo cuerpo, y el cuerpo vacío del PATCH que es 400.

6. Todo en español. API en el puerto 8117, front en el 8116, MariaDB en el
   13333, phpMyAdmin en el 8108.

7. La versión incluye su PANTALLA: front en PHP, en su propio contenedor, con
   una función por operación (no un cliente genérico), Bootstrap descargado
   en front_php/publico/ (no por CDN), y SIN compartir código con la API
   —aunque el require_once funcionaría desde la carpeta vecina—.

8. Al final, corre el smoke test completo de 7_quickstart.md y muéstrame la
   evidencia de cada criterio de aceptación. La versión no está terminada
   hasta que todos estén en verde, incluido el de apagar la API y comprobar
   que la pantalla sigue en pie, sin datos.
```

### B.2 Cómo supervisar

- **Revise cada diff** antes de aprobar: ¿el archivo está donde dice
  [3_plan.md](3_plan.md)? ¿Los comentarios explican por qué, no qué? ¿No
  apareció un `composer.json`?
- **Freno de emergencia:** si hace varias fases de un tirón, deténgalo y
  pídale *«vuelve a la fase N y muéstrame su verificación»*. Con PHP pasa más
  que con otros lenguajes, porque no hay compilador que lo frene: escribe diez
  archivos y todos "parecen" bien hasta que se ejecutan.
- **Cace las suposiciones:** cuando diga "asumo que…" o "por defecto voy a…",
  pare. Eso va a las Clarificaciones de `2_spec.md`.
- **No le crea "terminado":** pídale la salida real de los comandos. El
  criterio de cierre es el smoke test en verde.

---

## Cuando la IA se equivoca: los tres destinos

Se va a equivocar. Lo que decide si el trabajo mejora o se pudre es **a dónde
va cada corrección**, y hay tres destinos posibles:

| Si el error es… | La corrección va a… | Cómo se reconoce |
|---|---|---|
| **La IA no podía saberlo**: la spec no lo dice, o lo dice de dos maneras | **La spec**, como una Clarificación nueva | Usted mismo duda al contestarle. Si tiene que pensar la respuesta, no estaba escrita |
| **La spec lo dice, la IA lo ignoró — y vuelve a pasar** | **El prompt** | Se repite con otra IA, en otro chat, después de empezar de cero |
| **La spec lo dice claro y la IA falló una vez** | **Usted**: le señala el documento y sigue | Al corregirlo, no vuelve a ocurrir |

**La pregunta que separa el segundo del tercero es una sola: ¿se repite?** Un
error que aparece siempre viene del prompt —la regla existe pero no está
visible—. Uno que aparece una vez es ruido, y corregirlo es su trabajo de
supervisor: para eso está mirando.

> **Por qué importa no confundirlos.** Si por cada tropiezo se agrega una regla
> al prompt, el prompt termina con treinta reglas y **nadie lo lee** — ni la
> IA, que se pierde entre ellas, ni el siguiente estudiante.

**Y hay un cuarto camino que NUNCA se toma:** arreglar el código para que
"funcione" sin tocar la spec ni el prompt. Eso deja el documento diciendo una
cosa y el sistema haciendo otra — que es exactamente la deuda de
especificación contra la que existe este método.

---

## Lo que la IA propone con más naturalidad, y está mal

| Qué | Por qué pasa | Qué revisar |
|---|---|---|
| **Volcar diez archivos en una respuesta** | Le parece más eficiente, y usted deja de revisar | ¿Le dio más de un archivo? Regla 2: uno, su "listo", el siguiente |
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

**Y una pregunta que hay que hacerle siempre, porque no la contesta sola:**

> «Apaga la API con `docker compose stop api-mapa` y dime qué muestra
> la pantalla.»

Si la respuesta no es «sigue en pie, con un aviso y sin datos», el front está
leyendo de donde no debe — o no maneja el caso de que la API no responda, que
es el mismo problema visto de otro lado.

---

## Antes de abrir el chat: prepare SU proyecto

**Ojo: NO se construye dentro de la carpeta clonada.** El repositorio clonado
es el **material de referencia**; su trabajo de reconstrucción va en una
**carpeta nueva y vacía**, fuera de él.

### 1. La carpeta y las subcarpetas

Cree la carpeta de su proyecto, ábrala en VS Code (*File → Open Folder*) y, en
la terminal integrada (*Terminal → New Terminal*, PowerShell), parado en ella:

```powershell
mkdir docs\spec_kit\versiones\v1_proyecto, db, front_php\publico, api_mapa, api_mapa\controladores, api_mapa\excepciones, api_mapa\modelos, api_mapa\pruebas, api_mapa\repositorios, api_mapa\servicios, front_php, front_php\vistas, pruebas_humo
```

### 2. Los archivos VACÍOS

**Usted los va llenando** uno a uno, pegando en cada uno el código que la IA
le entregue. Que nazcan vacíos y con su nombre puesto es lo que le da forma al
trabajo: se ve de una vez cuántas piezas son y dónde va cada una.

```powershell
New-Item .gitattributes, .gitignore, api_mapa\Dockerfile, api_mapa\controladores\ControladorProyecto.php, api_mapa\excepciones\NoEncontradoExcepcion.php, api_mapa\index.php, api_mapa\modelos\Proyecto.php, api_mapa\pruebas\prueba_capas.php, api_mapa\repositorios\IRepositorioProyecto.php, api_mapa\repositorios\RepositorioProyectoMariaDB.php, api_mapa\servicios\IServicioProyecto.php, api_mapa\servicios\ServicioProyecto.php, api_mapa\servicios\ensamblador.php, docker-compose.yml, front_php\Dockerfile, front_php\cliente_api.php, front_php\index.php, front_php\vistas\formulario.php, front_php\vistas\inicio.php, front_php\vistas\lista.php, front_php\vistas\no_encontrada.php, front_php\vistas\plantilla.php, pruebas_humo\humo_front.py
```

> **Fíjese en lo que la lista tiene y en lo que no.**
>
> **Tiene** los archivos de `front_php\` porque **la versión incluye su
> pantalla**. Son la mitad del trabajo, no un añadido, y por eso nacen vacíos
> junto a los de la API.
>
> **No tiene** `db\init.sql`: ese no nace vacío, se copia (paso 3).
>
> **No tiene** nada dentro de `front_php\publico\`: ahí van Bootstrap y sus
> estilos, **descargados una vez del sitio oficial**. No se generan y no van
> por CDN.

### 3. Los archivos que vienen DADOS: cópielos del repositorio del curso

Con el explorador de Windows (Ctrl+C, Ctrl+V), cada uno a la misma ruta:

| Del clon del curso | A su proyecto |
|---|---|
| `db\init.sql` | `db\` |
| `docs\spec_kit\1_constitution.md` | `docs\spec_kit\` |
| Los `.md` de `docs\spec_kit\versiones\v1_proyecto\` | la misma ruta |
| `ProyectosDeAula\` completo | la raíz |

Estos vienen dados y **la IA no los genera**: los documentos se le SUBEN al
chat, y `db\init.sql` es la base de datos ya escrita.

### 4. Compruebe antes de empezar

- [ ] `docs\spec_kit\1_constitution.md` existe y tiene contenido.
- [ ] `docs\spec_kit\versiones\v1_proyecto\` tiene **9 archivos**.
- [ ] `db\init.sql` tiene contenido, no está vacío.
- [ ] `front_php\` existe con sus carpetas, aunque los archivos estén vacíos:
      si no está, la versión va a nacer sin la mitad que se ve.
- [ ] `front_php\publico\` tiene Bootstrap descargado.

Si algo está vacío o falta, es el paso 3.

> **La estructura queda lista ANTES de hablar con la IA**, y es la que describe
> `3_plan.md`. Así el chat entrega código para archivos que ya existen, en vez
> de proponerle a usted dónde ponerlos.

---

## Y lo que la IA no va a hacer sola

Comparar con el gemelo. Este mismo módulo está en
`proyecto_paradigmas_mapa_conocimiento1` (Python + FastAPI) y `proyecto_mapa_conocimiento1` (C# + ASP.NET Core). Levante dos, póngalos lado a
lado, y responda dos preguntas:

1. **¿Qué le costó a cada uno?** Cuente las líneas de validación de los dos
   controladores. Después pídale a cada API una fila que no exista y compare
   los dos cuerpos de error.
2. **¿Qué quedó igual?** Las tres capas, las dos interfaces, el ensamblador,
   el borrado lógico. Nada de eso era del lenguaje: era del diseño.

Ésa es la parte que no se automatiza, y es la que se evalúa.
