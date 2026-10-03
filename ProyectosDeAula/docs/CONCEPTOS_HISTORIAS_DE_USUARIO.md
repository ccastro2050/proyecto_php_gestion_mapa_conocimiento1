# Historias de usuario — qué son y cómo se escriben

**Documento conceptual del curso**

---

## 1. Lo que una historia de usuario no es

**No es un requisito escrito de otra manera.** Es una **promesa de
conversación**.

Esa definición es de Ron Jeffries, uno de los tres creadores de
Programación Extrema, y la formuló en 2001 con las que se conocen como
**las tres C**:

| | Qué es |
|---|---|
| **Card** (tarjeta) | Lo que se escribe. Cabe en una ficha, y **no contiene toda la información**: es una ficha que identifica el requisito |
| **Conversation** (conversación) | El intercambio entre el cliente y quien construye. Es donde de verdad se aclara el requisito, y es sobre todo hablado |
| **Confirmation** (confirmación) | Las **pruebas de aceptación**: cómo se demuestra que la historia quedó hecha |

> Jeffries insiste en que la tarjeta es un **recordatorio**, no un
> contrato. Quien escribe treinta párrafos en la tarjeta y no conversa
> con nadie, tiene un documento, no una historia.

---

## 2. La forma

La plantilla que se usa desde hace veinte años:

> **Como** [rol], **quiero** [acción], **para** [beneficio].

Los tres pedazos no son adorno:

| Pedazo | Qué evita que pase |
|---|---|
| **Como [rol]** | Que la historia sea de «el usuario», que no existe. Un rol se puede entrevistar, y sus prioridades se pueden contrastar con las de otro rol |
| **Quiero [acción]** | Que se pida una pantalla en vez de una capacidad |
| **Para [beneficio]** | **Es el más importante y el que más se omite.** Sin él, nadie puede decidir si la historia vale lo que cuesta, ni proponer una forma más barata de lograr lo mismo |

En este curso se escribe en primera persona y con nombre —«Yo, Marcela
Ruiz, como coordinadora, quiero…»— porque obliga a que el rol sea alguien
concreto y no una etiqueta.

### Una variante que vale la pena conocer

Cuando el rol no explica el comportamiento, hay quien usa **job stories**,
de Alan Klement: *«**Cuando** [situación], **quiero** [motivación], **para
poder** [resultado esperado]»*. Cambia el rol por la **situación**, y
funciona mejor cuando la misma persona se comporta distinto según el
momento.

---

## 3. Los criterios de aceptación

Son la tercera C: la **confirmación**. Responden a una sola pregunta:
**¿cómo sabemos que quedó hecha?**

**Un criterio de aceptación tiene que poder fallar.** Si no hay forma de
que dé «no cumple», no es un criterio:

| Esto no es un criterio | Esto sí |
|---|---|
| «El sistema debe ser rápido» | «El listado responde en menos de un segundo con diez mil registros» |
| «Los datos deben validarse» | «Crear un tipo sin valor por kilo responde **422** e indica cuál campo falta» |
| «Debe ser fácil de usar» | «El operario registra una entrega de tres tipos en menos de un minuto» |
| «El borrado funciona» | «El segundo `DELETE` sobre el mismo registro responde **404**» |

La regla corta: **un número o un código de estado**. Si el criterio no
tiene ninguno de los dos, casi siempre está mal escrito.

---

## 4. Cómo revisar una historia: INVEST

Seis letras, de Bill Wake (2003): *Independent, Negotiable, Valuable,
Estimable, Small, Testable*.

| Letra | Qué pregunta | Señal de que falla |
|---|---|---|
| **I**ndependiente | ¿Se puede construir sin esperar a otra? | «Esta va después de la 3, que va después de la 5…» |
| **N**egociable | ¿Es una conversación, o ya trae la solución impuesta? | La historia describe la pantalla, campo por campo |
| **V**aliosa | ¿A quién le sirve, y para qué? | El «para» está vacío o dice «para tener el sistema completo» |
| **E**stimable | ¿Se puede decir cuánto costaría? | Nadie entiende de qué se trata lo suficiente para estimarla |
| **S**mall (pequeña) | ¿Cabe en una iteración? | «Como usuario quiero administrar todo el sistema» |
| **T**estable (probable) | **¿Se puede probar que quedó hecha?** | No tiene criterios, o los tiene sin números |

> Wake escribió el artículo en 2003 y de paso propuso **SMART** para las
> tareas —*Specific, Measurable, Achievable, Relevant, Time-boxed*—, que
> es otra cosa: INVEST evalúa **historias**; SMART evalúa **tareas**.

---

## 5. Cómo se parte una historia grande

Cuando una historia no pasa la **S** de INVEST, hay que partirla. Las
formas que funcionan, en orden de utilidad:

1. **Por operación**: crear / consultar / corregir / retirar. Es la más
   usada en este curso, y por eso las historias de la versión 1 vienen
   separadas así.
2. **Por regla de negocio**: primero el caso normal, después las
   excepciones.
3. **Por tipo de dato**: primero un solo catálogo, después todos.
4. **Por esfuerzo**: la versión que funciona a mano, y luego la
   automática.

**Lo que no se debe hacer es partir por capas.** «Como desarrollador
quiero el repositorio» no es una historia: nadie fuera del equipo recibe
valor de eso. Las capas son tareas dentro de una historia, no historias.

---

## 6. Estimación: puntos, no horas

En las historias de este curso hay dos campos: **puntos estimados** y
**horas estimadas**.

- Los **puntos** miden tamaño relativo: esta historia es como el doble de
  aquella. No se convierten a horas; se comparan entre sí.
- Las **horas** son una estimación de calendario, y sirven para el
  cronograma.

Se piden los dos porque hacen preguntas distintas: los puntos preguntan
**qué tan grande es**, las horas preguntan **cuándo estará**. Cuando las
dos columnas se contradicen —una historia de 1 punto con 14 horas— hay
algo mal entendido, y conviene mirarlo antes de programar.

---

## 7. De dónde salen las historias

No se inventan: salen de una conversación con quien tiene el problema.
Cómo se conduce esa conversación está en
**`CONCEPTOS_ELICITACION.md`**, y los cuatro ejemplos completos —las
entrevistas respondidas de las que salieron las historias de cada
módulo— están en los archivos `entrevista_*.md` de esta misma carpeta.

---

## 8. Referencias

1. Jeffries, Ron. «Essential XP: Card, Conversation, Confirmation».
   30 de agosto de 2001 —
   `https://ronjeffries.com/xprog/articles/expcardconversationconfirmation/`
2. Wake, Bill. «INVEST in Good Stories, and SMART Tasks». XP123,
   17 de agosto de 2003 —
   `https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/`
3. Cohn, Mike. *User Stories Applied: For Agile Software Development*.
   Addison-Wesley, 2004. — El libro que fijó el formato «como… quiero…
   para…» y la idea de los roles de usuario.
4. Patton, Jeff. *User Story Mapping: Discover the Whole Story, Build the
   Right Product*. O'Reilly, 2014.
5. Klement, Alan. «Replacing The User Story With The Job Story», 2013 —
   la variante «cuando… quiero… para poder…».
6. Wynne, Matt. «Introducing Example Mapping». Cucumber, 2015 —
   `https://cucumber.io/blog/bdd/example-mapping-introduction/`

> **Las tres primeras son las fuentes originales**, no resúmenes: el
> artículo de Jeffries de 2001 y el de Wake de 2003 están publicados y se
> pueden abrir en los enlaces. Conviene leerlos: entre los dos suman
> quince minutos.
