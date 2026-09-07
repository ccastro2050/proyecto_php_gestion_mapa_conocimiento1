# SDD y Spec Kit — desarrollo guiado por especificaciones

> Documento conceptual del curso. Aquí está el **porqué** de la forma en que se
> trabaja este proyecto: primero la especificación, después el código, versión
> por versión.

---

## 🎬 Antes de leer: el video del método

[![Video: Spec Kit de GitHub — el desarrollo guiado por especificaciones está matando al vibe coding](https://img.youtube.com/vi/_MmsQMLg6yU/maxresdefault.jpg)](https://youtu.be/_MmsQMLg6yU)

> **▶️ [Spec Kit de GitHub: cómo el SDD está matando al "vibe coding"](https://youtu.be/_MmsQMLg6yU)**
> — episodio del podcast *BIM Praxis* (~16 min; voces generadas con
> NotebookLM). Cuenta, con otras palabras, EXACTAMENTE el método de este
> repositorio. **Resumen:**
>
> 1. **El "vibe coding" no tiene cimientos:** pedirle a la IA "hazme una
>    app" en dos líneas parece magia las primeras iteraciones, pero a la
>    tercera o cuarta el proyecto colapsa — dependencias circulares,
>    lógica destrozada. La causa técnica es la **degradación del
>    contexto**: el modelo prioriza lo último que usted dijo y pierde la
>    estrategia global.
> 2. **La constitución es el ancla:** un archivo con las leyes
>    innegociables del proyecto que se inyecta en CADA llamada a la IA.
>    Neutraliza el sesgo estadístico del modelo ("a la mínima te quiere
>    meter un React y una base de datos") y bloquea lo prohibido aunque
>    la conversación sea larga.
> 3. **La spec define el QUÉ sin tecnología** (historias de usuario y
>    criterios de aceptación), y la IA no asiente como un ejecutor
>    servicial: busca ambigüedades y casos límite que usted no pensó —
>    se pone la gorra de arquitecto.
> 4. **El plan y las tareas** convierten la spec en arquitectura técnica
>    y en un grafo de dependencias (qué depende de qué, qué puede ir en
>    paralelo), con la disciplina de escribir la prueba ANTES del código.
> 5. **El código pasa a ser un subproyecto:** si toda la lógica vive en
>    los `.md`, cambiar de stack es regenerar — lo que vale oro es la
>    especificación. La competencia clave del profesional deja de ser
>    memorizar sintaxis y pasa a ser **claridad de pensamiento
>    estructural**: definir arquitecturas y comunicarse sin ambigüedades.
>
> **La traducción a este repositorio:** la "constitución" del video es
> nuestro `1_constitution.md`; su *specify* es `2_spec.md` (con historias
> y criterios de aceptación); su *plan* es `3_plan.md`; sus *tasks* son
> `8_tasks.md` con las fases verificables. Usted ya está trabajando así.

## 1. El problema que resuelve: el "vibe coding"

Programar con IA (o sin ella) improvisando — pedir "hazme una API", aceptar lo
que salga, parchar sobre lo parchado — produce software que *parece* funcionar
pero nadie puede explicar, verificar ni extender. El síntoma clásico: nadie
sabe decir si el sistema está "terminado", porque nunca se dijo qué debía hacer.

**SDD ataca ese problema invirtiendo el orden: la especificación es el
artefacto principal y el código es su expresión.** Si el código hace algo que
la spec no dice, uno de los dos está mal — y se corrige.

## 2. ¿Qué es SDD (Spec-Driven Development)?

Una práctica de ingeniería (Thoughtworks la señala como una de las prácticas
clave de la era de la IA) con una regla central y una cadena de artefactos:

```
CONSTITUCIÓN  →  ESPECIFICACIÓN  →  PLAN  →  TAREAS  →  CÓDIGO  →  VERIFICACIÓN
(reglas         (QUÉ y para        (CÓMO    (en qué    (el        (¿cumple los
 permanentes)    quién)             técnico) orden)     resultado)  criterios?)
```

- La spec dice **QUÉ**, sin tecnología; el plan dice **CÓMO**; las tareas dicen
  **EN QUÉ ORDEN**, en fases verificables.
- La spec **se versiona con git igual que el código** y siempre refleja el
  estado actual. Si el código cambió y la spec no, hay **deuda de
  especificación** — tan grave como la deuda técnica.
- No es la cascada (waterfall) de vuelta: las specs se escriben **por
  incrementos pequeños** que se implementan y verifican de inmediato, no un
  documentote de 200 páginas antes de la primera línea de código.

## 3. ¿Qué es GitHub Spec Kit?

Un toolkit open source (MIT) de GitHub que **operacionaliza** SDD para
trabajar con agentes de IA: el CLI `specify` crea la estructura y los comandos
guían el flujo:

```
/speckit.constitution → /speckit.specify → /speckit.clarify
→ /speckit.plan → /speckit.checklist → /speckit.tasks
→ /speckit.analyze → /speckit.implement → /speckit.converge
```

Sus artefactos (constitution, spec, plan, research, data-model, contracts,
quickstart, tasks) son los mismos que este curso replica **a mano** con
numeración didáctica (`1_constitution.md` … `8_tasks.md`), con dos
adaptaciones que conviene tener claras: allá `contracts` es un
**directorio** de contratos legibles por máquina, y las aclaraciones no
son un documento aparte sino una sección **dentro** de `spec.md` (§3.2).

**La distinción para el examen:** SDD es la *metodología* (el "qué hacer");
Spec Kit es una *herramienta* que la implementa (el "con qué"). La misma
relación que hay entre "control de versiones" y "Git". Se puede hacer SDD sin
Spec Kit — este curso lo demuestra — pero no tiene sentido Spec Kit sin SDD.

### 3.1 El enlace oficial: qué hay ahí

**<https://github.github.com/spec-kit/>** es el **manual** del toolkit (el
código vive aparte, en <https://github.com/github/spec-kit>). Vale la pena
abrirlo aunque nunca lo instale:

| Sección | Qué encuentra |
|---|---|
| **Quick Start** | El flujo completo, comando por comando, con el archivo que produce cada uno |
| **Installation** | Requisitos y el comando de instalación del CLI `specify` |
| **Reference** | Qué hace cada comando, qué archivo escribe y cuál NO |
| Extensiones y presets | Variantes del proceso aportadas por la comunidad |

Cítelo cuando alguien afirme "Spec Kit hace X": el toolkit cambia rápido
—los comandos `clarify`, `checklist`, `analyze` y `converge` no existían
en las primeras versiones— y el sitio es lo único que está al día.

### 3.2 Qué significa "instalarlo"

Spec Kit **no es una librería que se importe en el código**: no aparece en
`index.php` ni en el `Dockerfile`, y no cambia en nada cómo corre la API.
Es
un CLI (`specify`) que deposita **plantillas y comandos dentro del
proyecto** para que su agente de IA los ejecute. Requiere Python 3.11 o
superior, `uv` (o `pipx`) y un agente compatible (Claude Code, Copilot,
Gemini CLI…).

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
specify init mi_v1_proyecto --integration copilot
specify version
```

Hecho eso, dentro del agente aparecen los comandos `/speckit.*`. El flujo
completo, con las tres compuertas que a mano no existen marcadas aparte:

```mermaid
flowchart LR
    A["constitution"] --> B["specify"]
    B --> C["clarify"]
    C --> D["plan"]
    D --> E["checklist"]
    E --> F["tasks"]
    F --> G["analyze"]
    G --> H["implement"]
    H --> I["converge"]
    classDef compuerta fill:#fde7c8,stroke:#c07a24,stroke-width:2px
    class C,E,G compuerta
```

Y lo que deja cada comando en el disco:

| # | Comando | Qué produce |
|---|---|---|
| 1 | `/speckit.constitution` | `.specify/constitution.md` |
| 2 | `/speckit.specify` | `specs/<funcionalidad>/spec.md` |
| 3 | `/speckit.clarify` | **modifica** `spec.md`: pliega adentro las respuestas a sus preguntas |
| 4 | `/speckit.plan` | `plan.md` y —cuando la funcionalidad lo pide— `research.md`, `data-model.md`, `contracts/` y `quickstart.md` |
| 5 | `/speckit.checklist` | `checklists/requirements.md` |
| 6 | `/speckit.tasks` | `tasks.md`, ordenado por dependencias |
| 7 | `/speckit.analyze` | **nada**: un reporte de inconsistencias entre spec, plan y tareas |
| 8 | `/speckit.implement` | el código |
| 9 | `/speckit.converge` | agrega tareas a `tasks.md` si el código quedó corto frente a la spec |

Documento por documento, así se corresponde con NUESTRO kit numerado:

```mermaid
flowchart LR
    subgraph MANO["Nuestro kit — escrito a mano"]
        direction TB
        N1["1_constitution.md"]
        N2["2_spec.md"]
        N3["3_plan.md"]
        N4["4_research.md"]
        N5["5_data_model.md"]
        N6["6_contracts.md"]
        N7["7_quickstart.md"]
        N8["8_tasks.md"]
        N9["9_checklist.md"]
    end
    subgraph KIT["Spec Kit — generado por comandos"]
        direction TB
        S1["constitution.md"]
        S2["spec.md — con las Clarifications adentro"]
        S3["plan.md"]
        S4["research.md"]
        S5["data-model.md"]
        S6["contracts — un DIRECTORIO, OpenAPI"]
        S7["quickstart.md"]
        S8["tasks.md"]
        S9["checklists de requirements"]
    end
    N1 --- S1
    N2 --- S2
    N3 --- S3
    N4 --- S4
    N5 --- S5
    N6 --- S6
    N7 --- S7
    N8 --- S8
    N9 --- S9
```

Dos diferencias de forma que conviene ver: `contracts` es un
**directorio** de contratos legibles por máquina (OpenAPI, esquemas) y no
un `.md` en prosa como nuestro `6_contracts.md`; y las aclaraciones no son
un documento aparte — viven **dentro** de `spec.md`.

### 3.3 Los tres comandos que NO producen documento, con ejemplo

Esto es lo que más confunde al principio: de los nueve comandos, solo
cinco dejan un archivo. **`clarify`, `analyze` y `converge` no crean
ningún `.md`** — y son, justamente, los que más valor agregan. Van los
tres con un ejemplo armado sobre la v1 de este repositorio.

#### `clarify` — pregunta ANTES de que usted planee

Lee la spec, detecta lo que está a medio definir y **pregunta**, una cosa
a la vez. Cuando usted responde, no le devuelve un texto para que lo
pegue: **edita `spec.md`** y deja la respuesta adentro.

```text
La spec dice:
    RF6 — Eliminar proyecto
    DELETE /api/proyecto/{codigo}. Devuelve filasEliminadas;
    inexistente -> 404.

clarify pregunta:
    El borrado de proyecto, ¿es físico o lógico?
      a) Físico: la fila desaparece de la tabla.
      b) Lógico: se marca inactiva y deja de listarse.
    Impacto si es (b): cambia el contrato del DELETE, obliga a una
    columna de estado en 5_data_model y reescribe el criterio 4.

Usted responde:  b

clarify NO crea un archivo: escribe dentro de 2_spec.md
    ## Clarificaciones
    C5 — DELETE, ¿físico o lógico? -> Físico: la tabel proyecto no
    tiene columna de estado. El borrado lógico llega con la anulación
    de registros, en una versión posterior.
```

**A mano, en este curso:** eso es exactamente la
[la sección de Clarificaciones de 2_spec.md](spec_kit/versiones/v1_proyecto/2_spec.md),
y el marcador `[NECESITA ACLARACIÓN: …]` (§4.4) hace las veces de
pregunta. La diferencia no es el resultado, es **quién detecta la
ambigüedad**: allá la busca el agente; aquí la busca usted — que es
justamente el músculo que el curso quiere entrenar.

#### `analyze` — le dice dónde se contradicen sus documentos

Se corre con la spec, el plan y las tareas ya escritos. **No toca nada**:
lee los tres y reporta. Es la revisión de coherencia de la compuerta 2,
hecha por máquina. Un reporte sobre una v1 mal armada se vería así:

| # | Severidad | Dónde | Qué encontró |
|---|---|---|---|
| 1 | ALTA | `2_spec` RF7 ↔ `6_contracts` | RF7 (diagnóstico) no tiene contrato: ningún endpoint lo describe |
| 2 | ALTA | `6_contracts` §7 ↔ `8_tasks` | El `DELETE` tiene contrato, pero ninguna fase lo construye |
| 3 | MEDIA | `2_spec` criterio 3 ↔ `7_quickstart` | El criterio 3 no tiene comando en el smoke test: no hay forma de verificarlo |
| 4 | MEDIA | `3_plan` §2 ↔ `8_tasks` | El plan lista `excepciones/NoEncontradoExcepcion.php` y ninguna tarea lo crea |
| 5 | BAJA | `6_contracts` §4 ↔ `5_data_model` | El ejemplo del POST usa `PR009`, y las semillas llegan hasta `PR008` — correcto, pero conviene decir que es un código nuevo a propósito |

Fíjese en algo: **ningún hallazgo es sobre el código**. Todos son
contradicciones entre documentos. Y la corrección no se escribe en el
reporte sino **en el documento dueño del problema**: el 1 y el 3 se
arreglan en la spec, el 2 y el 4 en las tareas. Con hallazgos de
severidad ALTA no se sigue.

**A mano, en este curso:** es la tabla de trazabilidad de §4.5 recorrida
fila por fila. **Cada hueco de esa tabla es un hallazgo de `analyze`.**

#### `converge` — compara el código TERMINADO contra la spec

Se corre al final, cuando usted ya cree que acabó. Revisa el código
contra la spec, el plan y las tareas; y si algo quedó corto **no lo
arregla**: agrega al final de `tasks.md` las tareas que faltan y le dice
que vuelva a implementar. Nunca borra ni edita código.

```text
Convergencia — v1

    Criterio 2  OK    GET /api/proyecto devuelve las 8 filas semilla
    Criterio 4  OK    el ciclo de los 5 verbos pasa completo
    Criterio 5  FALLA POST con stock 7.5 responde 400; la spec pide 422
    Criterio 6  FALLA no existe pruebas/prueba_capas.php

Se agregan a 8_tasks.md:
    ## Convergencia
    - [ ] T15 Mover la validación de tipo a la petición (int?) -> 422
    - [ ] T16 Crear pruebas/prueba_capas.php con el repositorio FALSO

Estado: NO convergido. Vuelva a implement y corra converge otra vez.
```

**A mano, en este curso:** es la última fase de
[8_tasks.md](spec_kit/versiones/v1_proyecto/8_tasks.md) —el
cierre— corriendo el smoke test del
[7_quickstart.md](spec_kit/versiones/v1_proyecto/7_quickstart.md).
Si un criterio no pasa, la versión **no se cierra ni se le pone el tag**:
se agregan tareas y se sigue. La regla del curso —"no se avanza con una
fase en rojo"— y `converge` dicen exactamente lo mismo.

> **Lo que revelan los tres juntos:** el trabajo de verdad no es *escribir*
> los documentos, sino **mantenerlos de acuerdo entre ellos y de acuerdo
> con el código**. Spec Kit automatiza esa vigilancia; a mano la hacemos
> con las tres compuertas (§4.3). Por eso un kit que nadie revisa es peor
> que no tener kit: da la ilusión de que hay una fuente de verdad.

### 3.4 Qué mejora frente a nuestro kit a mano — y qué no

| | A mano (este curso) | Con Spec Kit instalado |
|---|---|---|
| Redactar los documentos | Usted escribe cada `.md` | El agente los genera; usted corrige |
| Ambigüedades de la spec | Se descubren programando (tarde) | `/speckit.clarify` pregunta ANTES de planear |
| Calidad de los requisitos | Criterio del profesor | `checklists/requirements.md`: los requisitos se revisan como si fueran código |
| Coherencia entre documentos | Usted la vigila leyendo | `/speckit.analyze` la revisa y reporta |
| Orden de las tareas | Usted ordena las fases a mano | `tasks.md` sale ordenado por dependencias |
| "¿Ya está terminado?" | El smoke test del `7_quickstart.md` | `/speckit.converge` compara el código contra la spec y agrega lo que falte |
| Qué hace falta para usarlo | Un navegador y un editor | Python, `uv`, un agente de IA y permiso para instalar |
| Si la herramienta cambia | Nada: son `.md` | Hay que actualizarse (ya pasó: cuatro comandos nuevos) |

En una frase: **Spec Kit quita el trabajo mecánico —redactar, ordenar,
cotejar— y agrega tres compuertas que a mano no existen**: `clarify`,
`checklist` y `analyze`. La mejora es real y es grande.

Lo que NO mejora: **la calidad de sus decisiones**. Una spec generada a
partir de una idea vaga sigue siendo vaga — solo que bien formateada y con
más páginas. La herramienta acelera el pensamiento que usted ya hizo; no
lo reemplaza.

> **El detalle más interesante, el `checklist`:** es control de calidad
> sobre la ESPECIFICACIÓN, no sobre el código — ¿cada requisito es
> medible?, ¿hay ambigüedad?, ¿algún criterio no se puede verificar? Y las
> casillas las marca **una persona**: la documentación oficial dice que el
> agente puede ayudar a evaluar pero **no puede auto-aprobarse**, y que
> `implement` se frena si quedan casillas sin marcar.

### 3.5 Entonces, ¿por qué en este curso se hace a mano?

Cuatro razones, en orden de peso:

1. **Spec Kit automatiza la escritura, no la decisión.** Quien nunca
   redactó un criterio de aceptación no puede juzgar si el que generó la
   IA sirve — y termina aceptando specs sin leerlas, igual que se acepta
   código sin leerlo. Sería cambiar el *vibe coding* por **vibe
   speccing**: el mismo vicio, un piso más arriba.
2. **Los artefactos sobreviven a la herramienta.** Las decisiones con sus
   alternativas (ADR), el modelo de datos, el contrato, los criterios de
   aceptación y la trazabilidad son ingeniería de requisitos de hace
   décadas. Spec Kit es de 2025 y ya cambió bajo los pies de todos: aquí
   se aprende lo permanente, y la herramienta se demuestra.
3. **Corre donde usted está.** El kit a mano funciona con un chat web
   gratuito, sin CLI, sin agente, sin llave de API y sin permisos de
   instalación en la sala de la universidad.
4. **Es evaluable y comparable.** Los `.md` se leen y se califican, y los
   cursos comparten la misma estructura sobre la misma `mapa_php_local` con
   stacks distintos.

> **El experimento de cierre:** al terminar la ruta de versiones,
> regenerar la v1 con `specify init` y los comandos reales, y comparar el
> kit generado con el que usted escribió a mano. La prueba de que aprendió
> no es que la IA lo genere: es que usted pueda leerlo y decir qué le
> falta.

## 4. Cómo lo aplica ESTE curso (ejemplo resumido)

El proyecto se construye **por versiones**, cada una con su propia spec:

- **Constitución permanente:** [spec_kit/1_constitution.md](spec_kit/1_constitution.md)
  — las reglas que ninguna versión puede violar.
- **Mapa de versiones:** [spec_kit/versiones/0_mapa_versiones.md](spec_kit/versiones/0_mapa_versiones.md)
  — la ruta v1→v6 y las reglas de avance.
- **La versión en curso:** [spec_kit/versiones/v1_proyecto/](spec_kit/versiones/v1_proyecto/2_spec.md)
  — la spec de la v1 ES el documento que se le entrega a la IA (o al
  estudiante) para construirla.

Un fragmento real de la spec de la v1 (note el estilo: verificable, con
criterios medibles):

```markdown
### RF5 — Actualizar parcialmente (PATCH + body parcial)
`PATCH /api/proyecto/{codigo}` con body parcial (campos opcionales):
solo se modifican los enviados. Devuelve filasAfectadas; inexistente → 404.

## Criterios de aceptación
4. … un `PUT` sin el campo `nombre` responde 422 (reemplazo completo)
   mientras el mismo body en `PATCH` responde 200 (parcial).
```

### 4.1 Los 8 documentos del kit, en una tabla

| # | Documento | Pregunta que responde | Qué encuentra adentro |
|---|---|---|---|
| 1 | `1_constitution.md` | ¿Qué reglas NUNCA se negocian? | Los artículos permanentes (capas, SQL parametrizado con :parametros, español, "un solo comando", cierre por tags). Es UNO para todas las versiones. |
| 2 | `2_spec.md` | ¿QUÉ se construye y cómo se sabe que quedó bien? | Propósito, alcance (incluye / NO incluye), requisitos funcionales y los **criterios de aceptación** medibles que definen "terminada". |
| 3 | `3_plan.md` | ¿CÓMO: stack, estructura, diseño? | Inventario de archivos (nuevos y los que CRECEN), estructura de carpetas y el diseño aterrizado a código. |
| 4 | `4_research.md` | ¿POR QUÉ así y no de otra forma? | Las decisiones numeradas (D1, D2…) con las **alternativas descartadas** — la memoria del proyecto. |
| 5 | `5_data_model.md` | ¿Qué datos hay y qué puede tocar esta versión? | Tablas, llaves y semillas; y la frontera: qué calcula la BD y qué tiene PROHIBIDO escribir la API. |
| 6 | `6_contracts.md` | ¿Cuáles son los endpoints EXACTOS? | Cada endpoint con verbo, URL, body y TODOS sus códigos con el JSON exacto — exigible sin leer el código. |
| 7 | `7_quickstart.md` | ¿Cómo se arranca y se valida rápido? | El arranque en un comando y el **smoke test**: los comandos que recorren los criterios con el valor esperado al lado. |
| 8 | `8_tasks.md` | ¿En qué ORDEN se construye? | Fases verificables, cada una con su "**Verificar:**" — no se avanza con una fase en rojo. |

A esos ocho se suma un noveno archivo, `9_checklist.md`, que **no describe
la versión: la revisa**. Es la compuerta que se pasa antes de escribir
código (§4.3), y por eso no se le entrega a la IA junto con los demás.

### 4.2 Los 8 documentos: qué es, para qué sirve y cómo se hace cada uno

**1. `1_constitution.md` — la ley permanente.**
**Qué es:** los artículos innegociables del proyecto; se escribe UNA vez y
rige TODAS las versiones (en Spec Kit lo genera `/speckit.constitution`;
aquí se escribe a mano).
**Para qué sirve:** ancla el proyecto — y a la IA. Cuando alguien (humano o
agente) proponga "metamos tal cosa", la constitución responde ANTES de
discutir; por eso neutraliza el sesgo del modelo hacia lo que más vio en su
entrenamiento.
**Cómo se hace:** liste las decisiones que NO van a cambiar en el semestre
(capas, seguridad, idioma, forma de cerrar versiones); redáctelas como
artículos numerados, cortos y verificables; si un artículo no se puede
violar "por accidente", no necesita estar.


**Esqueleto:** encabezado con **la versión de la constitución y su
fecha** · `Artículo 1` … `Artículo N`, uno por regla, cortos y
verificables · y como último, el **artículo de enmiendas**: cómo se cambia
una regla (se propone en el `4_research.md` de la versión que la necesita,
y la constitución sube de versión). Una regla que nadie puede violar por
accidente no merece artículo.


```markdown
## Artículo 3 — SQL siempre parametrizado
Los valores viajan como :parametros de PDO->prepare(); JAMÁS se
concatenan. `"WHERE codigo = '$codigo'"` es inyección esperando turno.
```

**2. `2_spec.md` — el QUÉ.**
**Qué es:** la especificación funcional de UNA versión: propósito, alcance,
requisitos funcionales (RF numerados) y criterios de aceptación.
**Para qué sirve:** define "terminada" de forma MEDIBLE — es el documento
que se le entrega a la IA o al estudiante para construir la versión, y el
que decide si pasó o no.
**Cómo se hace:** propósito en dos frases; RFs numerados SIN tecnología
(qué, no cómo); por cada RF, criterios con valores concretos (cuántas
filas, qué código HTTP, qué mensaje); y un "NO incluye" explícito — frena
la anticipación, que es el vicio favorito de la IA.


**Esqueleto:** `1. Propósito` (dos frases) · `2. Alcance`, con su **NO
incluye** explícito · `3. Requisitos funcionales` (RF1, RF2…) ·
`4. Requisitos no funcionales` · `5. Criterios de aceptación`, numerados y
medibles · `Clarificaciones` — **la compuerta 1** (§2.2): cada pregunta
con su respuesta, la fecha y qué RF cambió · `7. Definición de TERMINADA`.


```markdown
### RF5 — Actualizar parcialmente (PATCH + body parcial)
PATCH /api/proyecto/{codigo} con campos opcionales: solo se
modifican los enviados. Inexistente → 404; body vacío → 400.

## Criterios de aceptación
4. Un PUT sin el campo nombre responde 422 (reemplazo completo)
   mientras el MISMO body en PATCH responde 200 (parcial).
```

**3. `3_plan.md` — el CÓMO.**
**Qué es:** la traducción técnica de la spec: stack, inventario de archivos
y diseño de capas ya aterrizado a código.
**Para qué sirve:** que la arquitectura no se decida "sobre la marcha"
mientras se programa; una IA con plan no inventa estructura.
**Cómo se hace:** estructura de carpetas; tabla de archivos NUEVOS con su
papel; tabla de archivos que CRECEN y qué les crece (los intocables también
se declaran); y las decisiones de diseño de la versión — en la familia
diseño, con sus diagramas Mermaid.


**Esqueleto:** `1. Stack` · `2. Estructura de carpetas` ·
`3. Arquitectura`, con sus diagramas Mermaid · `4. Decisiones de diseño` ·
`5. Inventario`: tabla de archivos NUEVOS y tabla de los que CRECEN (los
intocables también se declaran; desde la v2, que es cuando ya hay algo que
crezca) · y como **última sección, el Chequeo de constitución** —
**la compuerta 2** (§2.2): artículo por artículo, cómo lo cumple ESTA
versión, y las desviaciones justificadas si las hubo, cada una con la
alternativa más simple que se descartó.


```markdown
**Crecen (los únicos existentes que se tocan):**
| Archivo | Qué crece |
|---|---|
| `index.php` | ★ las rutas de la rebanada nueva |
| `servicios/ensamblador.php` | ★ el cableado de la rebanada nueva |
```

**4. `4_research.md` — el PORQUÉ.**
**Qué es:** el registro de decisiones (D1, D2…) con sus alternativas
descartadas — lo que la industria llama ADRs (Architecture Decision
Records).
**Para qué sirve:** memoria del proyecto: no se re-discute lo decidido, y
quien llegue después (incluida la IA) entiende por qué el sistema es así y
no de otra forma.
**Cómo se hace:** por cada decisión: contexto (el problema) → opciones
consideradas (a, b, c) → decisión con su razón → consecuencias que se
aceptan. Se escribe CUANDO se decide, no semanas después.


**Esqueleto:** una sección por decisión, numerada **sin repetir entre
versiones** (`D-v2-1`, `D-v2-2`… — si la v1 y la v3 tienen ambas un "D4",
la trazabilidad se rompe), y cada una con: contexto → alternativas
(a, b, c) → decisión y su razón → consecuencias que se aceptan →
**estado**: *vigente* o *superada por vN*.


```markdown
## D4 — ¿Por qué PUT y PATCH separados?
**Alternativas:** (a) un solo endpoint "actualizar" · (b) PUT
(reemplazo completo) y PATCH (parcial) con peticiones distintas.
**Decisión: (b)** — la pareja enseña la semántica HTTP: el MISMO
body da 422 en PUT y 200 en PATCH.
```

**5. `5_data_model.md` — los datos y sus fronteras.**
**Qué es:** las tablas, columnas, llaves y semillas que ESTA versión usa, y
la frontera de responsabilidades entre la API y la BD.
**Para qué sirve:** evita el clásico "la API recalcula lo que la BD ya
calcula" — deja escrito qué columnas tiene PROHIBIDO tocar la API.
**Cómo se hace:** tabla por tabla (columna, tipo, regla); anote qué escribe
la BD sola (defaults, autonuméricos, triggers); semillas con valores
EXACTOS, porque el smoke test depende de ellas.


**Esqueleto:** `1. Las tablas que esta versión puede nombrar` (columna,
tipo, regla) · `2. Semillas exactas` — los valores que el smoke test da por
ciertos · `3. Invariantes`: tabla de quién es **dueño** de cada dato
calculado y quién tiene **prohibido** escribirlo · `4. Estados` de la
entidad, si los tiene, como diagrama Mermaid. Una versión que no agrega
datos propios igual llena el punto 3: dice de qué depende y qué no puede
tocar.


```markdown
| Tabla | PK | Semilla |
|---|---|---|
| proyecto | codigo | 8 filas (PR001 "Laptop…", stock 17, …) |

El stock lo mueve el TRIGGER al registror: la API tiene PROHIBIDO
escribirlo directamente.
```

**6. `6_contracts.md` — el contrato HTTP exacto.**
**Qué es:** endpoint por endpoint: verbo, URL, body de ejemplo y TODOS los
códigos de respuesta con su JSON exacto.
**Para qué sirve:** es lo que un cliente (el front de esta misma versión,
Postman, el profesor) puede EXIGIR sin leer el código; al cerrar la versión,
estos contratos se congelan.

**Y una sección más, del lado de la pantalla:** como cada versión incluye su
front (Artículo 1.1 de la constitución), este documento cierra con la tabla
de **qué pantalla existe, qué le pide a la API y cómo traduce lo que recibe**
— incluido lo que se ve cuando la API no responde. Sin esa tabla, el contrato
solo cuenta la mitad: lo que la API devuelve, pero no lo que la persona
termina leyendo.
**Cómo se hace:** un bloque por endpoint; incluya los desenlaces de ERROR
(404, 422, 500) con su formato — el error también es contrato; los valores
de ejemplo salen de las semillas del 5_data_model.


**Esqueleto:** `0. Convenciones` — el sobre de respuesta y el catálogo de
errores, una sola vez · después un bloque por endpoint: verbo, URL, body y
**todos** sus códigos con el JSON exacto · y, cuando exista, el enlace al
contrato **legible por máquina**: en PHP puro no hay Swagger, así que ese
papel lo cumple la colección de Postman del repositorio. Enlazarla es lo
que acerca nuestro `.md` en prosa al `contracts/` del Spec Kit real, que
es un directorio de contratos y no un texto (§3.2).


```markdown
POST /api/proyecto
body { "codigo": "PR009", "nombre": "Webcam", "stock": 10,
       "valorunitario": 350000 }
→ 200 {estado, mensaje} · 422 si falta un campo o stock < 0 (con
  errores[]) · 500 si el código ya existe (PK duplicada, en detalle)
```

**7. `7_quickstart.md` — la validación en minutos.**
**Qué es:** el arranque en un comando más el smoke test: la lista de
comandos que recorre los criterios de aceptación con el valor esperado al
lado de cada uno.
**Para qué sirve:** "me funciona" deja de ser una opinión — cualquiera
valida la versión en minutos; y en las versiones siguientes se convierte en
la REGRESIÓN (lo viejo debe seguir pasando).
**Cómo se hace:** el comando de arranque; un comando por criterio, en
orden, con el resultado esperado como comentario; y una tabla "Si algo
falla" con las causas probables.


**Esqueleto:** `1. Arranque` (un comando) · `2. Smoke test` — un comando
por criterio, **numerado igual que los criterios de `2_spec.md`**, con el
valor esperado al lado · `3. Regresión` — desde la v2: los smokes de las
versiones anteriores, que deben seguir pasando · `4. Si algo falla`, con
las causas probables.


```bash
curl http://localhost:8117/api/proyecto        # total: 8
curl -i http://localhost:8117/api/proyecto/PR999   # → 404
```

**8. `8_tasks.md` — el orden, por fases verificables.**
**Qué es:** el plan de construcción dividido en fases, cada una con su
lista de tareas y su compuerta "**Verificar:**".
**Para qué sirve:** convierte el plan en un camino sin saltos: la compuerta
impide avanzar con una fase rota — es la versión artesanal del grafo de
dependencias que `/speckit.tasks` genera.
**Cómo se hace:** ordene de lo que no depende de nada hacia lo que depende
de todo (modelo → repositorio → servicio → controlador); cada fase termina
en un estado COMPROBABLE (`php -l` (sintaxis) y la API respondiendo); la verificación se escribe
como comando concreto, no como "revisar que funcione".


**Esqueleto:** `Fase 0` … `Fase N`, cada una con: casillas `- [ ]` por
tarea · la marca `[P]` donde dos tareas de verdad no dependen una de otra
(en una construcción por capas la mayoría son secuenciales, y está bien) ·
a qué **RF** sirve cada bloque · y su compuerta **Verificar:** con un comando concreto.
La última fase es siempre el cierre: regresión, criterios y tag.


```markdown
## Fase 2 — El modelo y las peticiones
- [ ] modelos/Proyecto.php (la entidad: 4 propiedades)
- [ ] peticiones/ProyectoCrear.php (validación: todo obligatorio)

**Verificar:** `php -l` en cada archivo, sin errores de sintaxis.
```

### 4.3 El orden de armado y las tres compuertas

Los ocho documentos se escriben **en su orden numerado**: la constitución
primero (una sola vez), después la spec de la versión, después la
planeación, y de última las tareas. Lo que hay que agregarle a ese camino
—y es lo que separa un kit que sirve de una carpeta con ocho archivos— son
**tres compuertas**: puntos donde uno se detiene, revisa y no sigue hasta
que quede en verde.

```mermaid
flowchart TD
    A["1_constitution — una sola vez, para todo el curso"] --> B["2_spec — el QUE de la version"]
    B --> C{"Compuerta 1<br/>Clarificaciones"}
    C -->|"queda una ambigüedad, se pregunta y se responde en 2_spec"| B
    C -->|"sin ambigüedades"| D["La planeación de la versión<br/>3_plan · 4_research · 5_data_model<br/>6_contracts · 7_quickstart"]
    D --> E{"Compuerta 2<br/>Chequeo de constitución<br/>y coherencia entre los cinco"}
    E -->|"algo se contradice o viola un artículo"| D
    E -->|"todo cuadra"| F["8_tasks — el orden de construcción"]
    F --> G{"Compuerta 3<br/>Lista de requisitos"}
    G -->|"algún criterio no es medible"| B
    G -->|"lista en verde"| H["RECIEN AQUI se escribe código"]
    classDef compuerta fill:#fde7c8,stroke:#c07a24,stroke-width:2px
    class C,E,G compuerta
```

Fíjese en el bloque del medio: los documentos **3 a 7 se escriben en
orden, pero se revisan juntos**. Se contradicen entre ellos con una
facilidad pasmosa — el contrato promete un campo que el modelo de datos no
tiene, el quickstart valida un criterio que la spec nunca pidió, el plan
inventa un archivo que ninguna tarea construye. Por eso la compuerta 2 no
revisa "el plan": revisa **los cinco a la vez**.

Las tres compuertas, en detalle:

| | Vive en | La pregunta que hace | Si falla |
|---|---|---|---|
| **1. Clarificaciones** | La sección de Clarificaciones de `2_spec.md` | ¿Hay algo que dos personas leerían distinto? | Se pregunta al dueño del problema y la respuesta se pliega DENTRO de la spec — no se resuelve improvisando en el código |
| **2. Chequeo de constitución** | Última sección de `3_plan.md` | ¿El plan respeta los artículos, uno por uno? ¿Los cinco documentos dicen lo mismo? | O se corrige el plan, o se enmienda la constitución (y sube de versión). Nunca "se deja pasar por esta vez" |
| **3. Lista de requisitos** | `9_checklist.md` de la versión | ¿Cada requisito es medible, único y verificable? | Se devuelve a la spec. **No se escribe código con la lista en rojo** |

> **La tercera vive en el `9_checklist.md` de cada versión**, junto a los
> otros documentos. Es control de calidad **sobre la ESPECIFICACIÓN, no
> sobre el código**: *¿cada criterio de aceptación dice un número o un
> código HTTP concreto? · ¿algún requisito usa "rápido", "amigable" o
> "eficiente" sin definirlos? · ¿hay dos requisitos que se contradicen? ·
> ¿algún criterio no se puede verificar con un comando?* Y las casillas
> las marca **una persona** (§3.4). Es, además, la mejor actividad de aula
> del método: los estudiantes se revisan la spec entre ellos con la lista,
> antes de escribir una línea de código.

### 4.4 Cómo se escribe un requisito que sirve

La mitad del valor del kit se juega aquí. Cuatro reglas:

1. **Sin tecnología en la spec.** El QUÉ no menciona Dapper, ni nombres de
   clase, ni archivos. Eso vive en el plan. Si el RF no se entiende sin
   saber el stack, está mal escrito.
2. **Medible o no es criterio.** Un criterio dice un número, un código de
   estado o un texto exacto. "Responde rápido" no es criterio; "responde
   200 con las 14 filas semilla" sí.
3. **Una cosa por requisito.** Si un RF necesita un "y" para explicarse,
   casi siempre son dos.
4. **La ambigüedad se MARCA, no se rellena.** Cuando algo no está
   definido, se escribe el marcador y se resuelve en la compuerta 1 —
   jamás se inventa la respuesta:

```markdown
### RF6 — Eliminar proyecto
DELETE /api/proyecto/{codigo} elimina el proyecto.
[NECESITA ACLARACIÓN: ¿borrado físico, o lógico como la anulación
de registros? Afecta al criterio 5 y al contrato del DELETE.]
```

Esa costumbre —marcar en vez de rellenar— es la vacuna contra el vicio
central de la IA: **cuando no sabe, no pregunta; completa**. Y completa con
lo más frecuente en su entrenamiento, no con lo que su proyecto necesita.

| Así NO | Así SÍ |
|---|---|
| "El sistema debe validar correctamente los datos" | "Un POST sin el campo `nombre` responde **422** con `errores[]` y no toca la BD" |
| "Debe ser rápido" | "El listado responde en menos de 1 s con las 14 filas semilla" |
| "Manejar los errores adecuadamente" | "Código inexistente → **404** con `{estado, mensaje, detalle}`" |

### 4.5 La trazabilidad: de la historia al smoke test

Un kit bien armado permite seguir **una misma idea** a través de los ocho
documentos. Si una fila de esta tabla tiene un hueco, ahí hay un defecto:
un requisito sin contrato es una promesa vaga; un contrato sin tarea no lo
va a construir nadie; una tarea sin smoke test no se puede dar por
terminada.

| RF (`2_spec`) | Contrato (`6_contracts`) | Tarea (`8_tasks`) | Smoke (`7_quickstart`) | Criterio |
|---|---|---|---|---|
| RF1 — listar | §2 `GET /api/proyecto` | Fase 5 · controlador | §2 comando 2 | 1 y 2 |
| RF5 — actualizar parcial | §6 `PATCH` | Fase 5 · controlador | §2 comando 4b | 4 |
| RF6 — eliminar | §7 `DELETE` | Fase 5 · controlador | §2 comando 4 | 4 |

**La prueba de fuego del kit:** tape el código y entregue solo estos
documentos. Si alguien —una persona o una IA— reconstruye la versión
completa y la valida, el kit está bien armado. Ese es, literalmente, el
experimento que hace la `GUIA_IA` de cada versión.

### 4.6 Cuándo un documento está TERMINADO

| Documento | Está terminado cuando… |
|---|---|
| `1_constitution.md` | Cada artículo se puede citar para ganar una discusión sin abrir el código |
| `2_spec.md` | No queda ni un `[NECESITA ACLARACIÓN]` y cada criterio tiene un valor concreto |
| `3_plan.md` | El chequeo de constitución está completo y el inventario nombra TODOS los archivos que se van a tocar |
| `4_research.md` | Cada decisión tiene al menos una alternativa descartada con su razón (si no hubo alternativa, no era una decisión) |
| `5_data_model.md` | Están las semillas exactas y dice quién tiene prohibido escribir cada dato calculado |
| `6_contracts.md` | Cada endpoint tiene sus desenlaces de ERROR, no solo el feliz |
| `7_quickstart.md` | Sus comandos recorren, en orden, TODOS los criterios de aceptación — y la regresión de las versiones anteriores |
| `8_tasks.md` | Cada fase termina en un comando que se puede correr, no en "revisar que funcione" |
| `9_checklist.md` | Todas las casillas marcadas **por una persona** — solo entonces empieza el código |

### 4.7 Orden y nombres: cómo se llama cada archivo

El **número del prefijo es el orden**, de lectura y de armado. El nombre
que va después del número es el del artefacto equivalente en Spec Kit —por
eso está en inglés (`spec`, `plan`, `research`, `data_model`, `contracts`,
`quickstart`, `tasks`)— mientras que el CONTENIDO va todo en español. Así,
quien pase de este curso a la herramienta real reconoce cada documento por
su nombre.

| Archivo | Dónde vive | Alcance |
|---|---|---|
| `1_constitution.md` | `docs/spec_kit/` | Todo el curso — hay UNO solo |
| `0_mapa_versiones.md` | `docs/spec_kit/versiones/` | La ruta completa de versiones (no es de Spec Kit: es la brújula del curso) |
| `2_spec.md` … `8_tasks.md` | `docs/spec_kit/versiones/vN_tema/` | UNA versión |
| `9_checklist.md` | `docs/spec_kit/versiones/vN_tema/` | UNA versión — la compuerta 3 |
| `GUIA_IAN.md` | `docs/spec_kit/versiones/vN_tema/` | Cómo reconstruir ESA versión con ayuda de IA. No es un artefacto de Spec Kit sino material del curso: por eso va sin número y con el número de la versión al final |

Tres reglas de nombre que no se rompen:

1. La carpeta de la versión es `vN_tema`, en minúsculas y con guion bajo
   (`v1_proyecto`). El tema dice qué agrega la versión.
2. **El número de un documento nunca cambia entre versiones:** el
   `6_contracts.md` de la v3 se llama igual que el de la v1. Se compara de
   una versión a otra sin buscar equivalencias.
3. Un documento no se renumera ni se renombra al cerrar la versión. Lo que
   está bajo un tag es historia: se lee, no se toca.

**La regla que une a los ocho:** si está en la spec y no en el código, el
código está incompleto; si está en el código y no en la spec, sobra — o
falta especificarlo.

**El ciclo de una versión:** leer la spec → seguir las tareas fase por fase →
correr el quickstart → si los criterios pasan, commit + tag (`v1`) → solo
entonces se escribe la spec de la siguiente versión.

## 5. Justificación (por qué molestarse)

1. **Verificabilidad:** "terminado" deja de ser una opinión — son los
   criterios de aceptación pasando.
2. **Comunicación:** la spec es el contrato entre profesor, estudiante e IA;
   los tres leen el mismo documento.
3. **IA dirigida:** un agente con una spec precisa produce código consistente;
   un agente con un prompt vago produce vibe coding con más pasos.
4. **Incrementalidad honesta:** cada versión es pequeña, entregable y deja el
   terreno listo — el crecimiento del sistema queda documentado, no adivinado.

**Advertencia honesta (estado del arte 2026):** SDD no es magia. Specs vagas o
desactualizadas devuelven el vibe coding con burocracia encima; y para cambios
triviales, el ceremonial completo es sobrecarga. El criterio profesional es
saber cuándo la spec paga — en este curso, siempre, porque el objetivo es
aprender la disciplina.

## 6. Referencias (verificadas)

1. GitHub — *Spec-driven development with AI: Get started with a new open
   source toolkit* (blog oficial, sep. 2025):
   <https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/>
2. Repositorio oficial `github/spec-kit` (MIT):
   <https://github.com/github/spec-kit>
3. Documentación oficial de Spec Kit: <https://github.github.com/spec-kit/>
4. Thoughtworks — *Spec-driven development: Unpacking one of 2025's key new
   AI-assisted engineering practices*:
   <https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices>
5. Thoughtworks Technology Podcast — *What is spec-driven development?*:
   <https://www.thoughtworks.com/insights/podcasts/technology-podcasts/what-is-spec-driven-development>
6. AWS Kiro — documentación de specs (EARS, requirements/design/tasks):
   <https://kiro.dev/docs/specs/>
7. En este repositorio: la [constitución](spec_kit/1_constitution.md), el
   [mapa de versiones](spec_kit/versiones/0_mapa_versiones.md) y el
   [spec kit de la v1](spec_kit/versiones/v1_proyecto/2_spec.md).
