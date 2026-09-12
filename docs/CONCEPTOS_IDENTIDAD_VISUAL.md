# Identidad visual corporativa — qué es y por qué obliga al software

**Documento conceptual del curso**

---

## 1. Por qué esto aparece en un curso de programación

Porque la pantalla que usted construye **representa a una institución**, y
esa institución ya decidió cómo se ve. No es una decisión de quien programa.

El caso de este proyecto de aula es el normal en cualquier organización:
existe un **manual de identidad visual** —aquí,
[`MANUAL_DE_MARCA.md`](../MANUAL_DE_MARCA.md)— adoptado por una resolución,
y el sistema tiene que cumplirlo igual que cumple cualquier otro requisito.

**Un color corporativo cambiado es un defecto**, no un detalle estético.

---

## 2. Los términos, que se confunden todo el tiempo

| Término | Qué es | En este proyecto |
|---|---|---|
| **Isotipo** | La parte **gráfica**, sin texto | El monte |
| **Logotipo** | La parte **escrita**: el nombre en su tipografía | «UNIVERSIDAD MONTE VERDE» |
| **Logosímbolo** | Los dos juntos | Lo que se usa normalmente |
| **Imagotipo** | Los dos juntos pero **separables** | — |
| **Isologo** | Los dos **fundidos**, inseparables | — |
| **Identidad visual** | El sistema completo: marca, colores, tipografías, reglas | El manual entero |
| **Imagen de marca** | Lo que la gente **percibe**. No se diseña: se gana | — |

La distinción entre **identidad** (lo que la organización emite) e **imagen**
(lo que el público percibe) viene de la literatura de identidad corporativa
y es la que explica por qué un manual no garantiza nada por sí solo:
ordena lo que se emite.

---

## 3. Qué lleva un manual de identidad visual

No hay una norma ISO que lo fije, pero los manuales reales coinciden en el
mismo conjunto, y el de este proyecto los tiene todos:

| Sección | Qué resuelve | Si falta |
|---|---|---|
| **Versiones del logosímbolo** | Horizontal, vertical, isotipo solo | Cada quien recorta el logo a su gusto |
| **Paleta** | Los valores exactos, en hex y RGB | «El verde de la universidad» pasa a ser cinco verdes |
| **Tipografía** | Familias autorizadas | Cada pantalla con una fuente distinta |
| **Tamaño mínimo** | Debajo de cuánto deja de leerse | Logos ilegibles en el pie de página |
| **Área de reserva** | Cuánto espacio libre alrededor | El logo pegado al borde o a otro logo |
| **Usos incorrectos** | Lo que está prohibido, con ejemplos | Discusiones sin final |
| **Escala de grises** | Qué hacer a una tinta | Conversiones automáticas que borran la marca |

El **área de reserva** y el **tamaño mínimo** son los dos que más se ignoran
y los que más delatan a un sistema hecho sin mirar el manual.

---

## 4. La accesibilidad no es opcional: el contraste se calcula

Un manual puede fijar colores bonitos que **no se pueden leer**. Por eso, en
software, la paleta se comprueba contra un criterio verificable.

Las **WCAG 2.2** —recomendación del W3C, versión vigente del 12 de diciembre
de 2024— fijan en su criterio **1.4.3 (Contraste mínimo, nivel AA)**:

| Qué | Relación mínima |
|---|---|
| Texto normal | **4.5:1** |
| Texto grande | **3:1** |
| Elementos que no son texto: bordes, iconos, controles (criterio 1.4.11) | **3:1** |

**«Texto grande» lo define la norma en puntos**, no en píxeles: desde
**18 pt**, o **14 pt en negrita**. En pantalla eso equivale a unos 24 px y
18,66 px respectivamente.

La relación se calcula con la **luminancia relativa** de los dos colores:

```
razón = (L_claro + 0.05) / (L_oscuro + 0.05)
```

donde `L` se obtiene linealizando cada canal y pesándolos
`0.2126·R + 0.7152·G + 0.0722·B`. La fórmula completa está en las WCAG y
**cualquiera puede rehacer la cuenta** — por eso es un requisito verificable
y no una opinión.

> **En el manual de este proyecto la cuenta está hecha y publicada.** El ocre
> institucional da **3,13:1** sobre blanco: sirve para líneas, iconos y
> títulos grandes, pero **no para texto normal**. Por eso el manual define un
> «ocre oscuro» de **4,67:1** para cuando el ocre tenga que llevar texto.
>
> Un manual que dice «nuestros colores son accesibles» sin el número no dice
> nada.

Y una regla que se deduce de lo anterior: **el color nunca es el único
portador de la información** (criterio 1.4.1). Un campo con error se marca en
rojo **y** con un mensaje; si solo cambia de color, quien no distingue ese
color no se entera.

---

## 5. Cómo se lleva un manual al código

**La regla es una sola: los valores del manual van en un archivo aparte.**

En este proyecto, `marca.css`:

```css
:root {
  --umv-verde:   #1F5E4C;   /* manual, punto 2 */
  --umv-ocre:    #C9822B;
  --umv-grafito: #232323;
}
```

Y los estilos de la aplicación **usan la variable, nunca el valor**:

```css
/* bien */
.barra { background: var(--umv-verde); }

/* mal */
.barra { background: #1F5E4C; }
```

Por qué importa:

| | Con el valor regado por todo el CSS | Con `marca.css` |
|---|---|---|
| La universidad cambia su verde | Buscar y reemplazar, y rezar | Se cambia una línea |
| ¿De dónde salió este color? | Nadie sabe | Del manual, punto 2 |
| ¿Está permitido usar este otro? | Se discute | Si no está en `marca.css`, no |

Es la misma idea que sostiene el resto del curso: **separar lo que es una
restricción de lo que es una decisión**. El manual manda; el CSS de la
aplicación obedece.

---

## 6. Lo que se evalúa en este proyecto

La **versión 4** pide imagen corporativa. Concretamente:

1. Los colores y las tipografías salen de `marca.css`, y `marca.css` sale del
   manual.
2. El logosímbolo respeta **tamaño mínimo** y **área de reserva**.
3. Ningún color institucional aparece cambiado.
4. Los estados del sistema —correcto, error— usan los colores de apoyo, no
   los institucionales.
5. El contraste cumple AA donde hay texto.

Lo que **no** se evalúa es el gusto. No se trata de que la pantalla sea
bonita: se trata de que **cumpla un documento que alguien firmó**.

---

## 7. Referencias

1. **WCAG 2.2** — *Web Content Accessibility Guidelines 2.2*, recomendación
   del W3C; versión vigente del 12 de diciembre de 2024. Criterios 1.4.1 (uso del color),
   1.4.3 (contraste mínimo) y 1.4.11 (contraste de elementos no textuales) —
   `https://www.w3.org/TR/WCAG22/`
2. **Cómo se calcula la razón de contraste** — definición de luminancia
   relativa y de la fórmula, en el propio glosario de las WCAG —
   `https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum`
3. **Wheeler, Alina y Meyerson, Rob.** *Designing Brand Identity: A
   Comprehensive Guide to the World of Brands and Branding.* 6.ª ed., Wiley,
   2024. ISBN 978-1-119-98481-8. — De aquí sale la estructura estándar de un
   manual y la distinción entre identidad e imagen —
   `https://www.wiley.com/en-us/9781119984825`
4. **Airey, David.** *Logo Design Love: A Guide to Creating Iconic Brand
   Marks.* 3.ª ed., New Riders, 2026. ISBN 978-0-13-547675-8. — Versiones del
   logo, tamaño mínimo y usos incorrectos.
5. **Google Fonts** — de donde se obtienen Merriweather, Inter y Lato, las
   familias secundarias autorizadas por el manual de este proyecto —
   `https://fonts.google.com/`
6. **ISO 9241-112:2017**, *Ergonomics of human-system interaction — Part
   112: Principles for the presentation of information.* — Norma vigente
   sobre presentación de la información, incluida la codificación por color
   — `https://www.iso.org/standard/64840.html`
7. En este repositorio: [`MANUAL_DE_MARCA.md`](../MANUAL_DE_MARCA.md) y el
   archivo `marca.css` del front.

> Las normas ISO son de pago, pero su alcance y su índice se consultan gratis
> en el enlace. Las WCAG son públicas y gratuitas, y están traducidas.
