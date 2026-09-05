# La colección de Postman

`mapa_v1.postman_collection.json` trae los siete endpoints de la v1 **en el orden del
[quickstart](../docs/spec_kit/versiones/v1_proyecto/7_quickstart.md)**: si se
corren de arriba abajo, cuentan la historia completa — crear, leer,
reemplazar, actualizar y retirar la misma ficha.

Cada petición trae su descripción con **lo que debe responder** y, cuando es
el caso, qué hay que romperle para ver el error. La octava está ahí a
propósito: es el mismo cuerpo de la sexta enviado por PUT, y responde 422.
Esa pareja es la lección de la versión.

**Importar:** Postman → *Import* → arrastrar el archivo.
