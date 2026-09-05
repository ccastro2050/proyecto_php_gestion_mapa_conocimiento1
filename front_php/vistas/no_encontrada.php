<?php
/**
 * La pantalla de «no existe».
 *
 * Fíjese en lo que NO dice: el número 404. La respuesta HTTP sí lo lleva —lo
 * pone `index.php` con `http_response_code(404)`, porque eso es para el
 * navegador y para las herramientas—, pero al usuario se le habla en español.
 * Es la misma regla que aplica a los errores de la API.
 */
?>
<div class="text-center py-5">
  <h1 class="h2 mb-3">Esa página no existe</h1>
  <p class="text-body-secondary">
    La dirección <code><?= htmlspecialchars($ruta) ?></code> no corresponde a
    ninguna pantalla de este sistema.
  </p>
  <a class="btn btn-primary mt-2" href="/">Ir al inicio</a>
</div>
