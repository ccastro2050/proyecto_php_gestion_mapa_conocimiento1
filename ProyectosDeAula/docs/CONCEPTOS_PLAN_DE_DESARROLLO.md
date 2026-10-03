# El plan de desarrollo de software — qué es y qué lleva

**Documento conceptual del curso**

---

## 1. Para qué sirve

El plan de desarrollo **no describe el sistema**: describe **el trabajo**.
El sistema está en el enunciado, en el modelo y en las historias de
usuario. El plan responde otras preguntas:

- ¿Qué se va a entregar, y en qué orden?
- ¿Quién responde por cada cosa?
- ¿Qué reglas no se pueden violar?
- ¿Cómo sabemos que una etapa terminó?

Un proyecto sin plan no es un proyecto ágil: es un proyecto sin plan.
**Lo ágil no es no planear, es planear de otra manera** —en versiones
cortas, con el plan sujeto a corrección— y eso está dicho desde el propio
Manifiesto Ágil: *«responder ante el cambio sobre seguir un plan»*
valorando **ambos**, no despreciando el segundo.

---

## 2. Las cuatro fases

Las fases que usa este curso —**inicio, elaboración, construcción,
transición**— vienen del **Proceso Unificado de Rational (RUP)**, tal como
lo formuló Philippe Kruchten. Su rasgo distintivo no son los nombres, sino
que **cada fase termina en un hito verificable**, no en una fecha:

| Fase | De qué se trata | Termina cuando |
|---|---|---|
| **Inicio** | Entender el problema y acotar el alcance | Hay acuerdo sobre qué se va a construir y qué no |
| **Elaboración** | Decidir cómo, y probar que la arquitectura se sostiene | El plan no contradice ninguna regla del proyecto |
| **Construcción** | Construirlo | Los criterios de aceptación se cumplen, uno por uno |
| **Transición** | Entregarlo | Alguien firma que está listo |

En este curso esos finales de fase se llaman **compuertas**, y son tres:
ninguna aclaración sin resolver antes de programar; chequeo contra la
constitución antes de programar; y la lista de chequeo firmada por una
persona al cerrar.

> **Un hito no es una fecha.** «15 de septiembre» no es un hito;
> «la API responde los seis endpoints con sus códigos de estado» sí.

---

## 3. Qué lleva un plan de desarrollo

La estructura del curso sigue la de la norma internacional para planes de
gestión de proyectos de software, **ISO/IEC/IEEE 16326**, que en su
edición de 2019 reemplazó a la de 2009 y a la vieja **IEEE 1058**:

| Sección | Qué responde |
|---|---|
| **1. Introducción** — propósito, alcance, resumen | ¿De qué trata este documento, y de qué no? |
| **2. Vista general** — objetivos, suposiciones, restricciones, entregables | ¿Qué se persigue, con qué límites, y qué se entrega? |
| **3. Organización** — participantes, roles, interfaces externas | ¿Quién hace qué, y con quién hay que hablar? |
| **4. Gestión del proceso** — plan de fases, calendario, seguimiento | ¿En qué orden, cuándo, y cómo se sabe si va bien? |
| **5. Referencias** | ¿De dónde salió lo que aquí se afirma? |

Tres de esas partes son las que más se descuidan, y son las que salvan el
proyecto:

**Las suposiciones.** Lo que se está dando por cierto sin haberlo
verificado. Escribirlas es barato; descubrirlas a mitad del proyecto, no.

**Las restricciones.** Las reglas que ninguna decisión posterior puede
violar. En este curso son cosas como *el borrado es lógico*, *toda
consulta va parametrizada*, *cada versión incluye su front*.

**Los entregables.** La lista de lo que se va a producir. Si algo no está
en esa lista, no se está construyendo — y conviene notarlo antes del
último día.

---

## 4. El calendario, y por qué se compara con lo real

El plan trae **horas estimadas** por entregable. El cronograma, además,
trae una columna de **horas reales** que se llena mientras se trabaja.

Esa segunda columna es la que enseña. Nadie estima bien al principio; lo
que se aprende es **cuánto se equivoca uno y en qué dirección**. Un equipo
que siempre subestima en un 40 % puede planear con ese número; un equipo
que nunca compara, se equivoca igual el semestre entero.

---

## 5. Cómo se sigue el proyecto

En este curso el seguimiento **es el historial de Git**:

- Un commit por cada fase del `8_tasks.md`, con su comprobación hecha.
- Cuando algo falla, el commit que lo arregla **dice qué falló, qué
  respondió el sistema y qué lo causaba**.
- El orden de los commits muestra si la especificación fue antes que el
  código, y si las capas se construyeron de abajo hacia arriba.

No hace falta una herramienta de gestión aparte: el repositorio ya
contiene la información, si los commits dicen la verdad.

---

## 6. Cómo se relaciona con lo demás

| Documento | Qué aporta |
|---|---|
| **Entrevista al cliente** (`CONCEPTOS_ELICITACION.md`) | De dónde salen las historias |
| **Historias de usuario** (`CONCEPTOS_HISTORIAS_DE_USUARIO.md`) | Qué se va a construir, y cómo se verifica |
| **Plan de desarrollo** (este) | En qué orden, quién responde, con qué reglas |
| **Spec kit** (`SDD_SPECKIT.md`) | La especificación de cada versión, y las compuertas |
| **Cronograma** | Las horas: estimadas contra reales |

El plan **no repite** las historias ni la especificación: las ordena en el
tiempo y les pone responsables.

---

## 7. Referencias

1. ISO/IEC/IEEE 16326:2019, *Systems and software engineering — Life
   cycle processes — Project management*. Es la norma vigente para planes
   de gestión de proyectos de software; **reemplazó a ISO/IEC/IEEE
   16326:2009 y a IEEE Std 1058**, que a su vez venía de la IEEE
   1058-1998 —
   `https://www.iso.org/standard/41977.html`
2. Kruchten, Philippe. *The Rational Unified Process: An Introduction*.
   3.ª ed., Addison-Wesley, 2003. — De aquí salen las cuatro fases y la
   idea de que cada una termina en un hito, no en una fecha.
3. Beck, Kent *et al.* **Manifiesto por el Desarrollo Ágil de Software**,
   2001 — `https://agilemanifesto.org/iso/es/manifesto.html`
4. Schwaber, Ken y Sutherland, Jeff. *La Guía de Scrum*, noviembre de
   2020 — `https://scrumguides.org/`
5. ISO/IEC/IEEE 29148:2018, *Requirements engineering*. — De donde sale
   la exigencia de que un requisito sea **verificable**.

> **Las normas ISO son de pago**, pero su alcance y su índice se consultan
> gratis en los enlaces. El Manifiesto Ágil y la Guía de Scrum son
> gratuitos y están en español.
