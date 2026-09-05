<?php
/**
 * plantilla.php — el MARCO de todas las pantallas.
 *
 * Todo lo que se repite vive aquí una sola vez: la cabecera, el menú, los
 * avisos y el pie. Cada vista aporta solo su parte, y `index.php` la mete en
 * el hueco del `require $contenido`.
 *
 * El aspecto lo pone **Bootstrap**, y la hoja está en `publico/`, no en
 * internet: el salón puede quedarse sin red y la pantalla se sigue viendo
 * igual. `estilos.css` va después y solo trae los pocos retoques del
 * proyecto — el orden importa, porque lo último que se carga es lo que manda.
 */
?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mapa de conocimiento</title>
  <link rel="stylesheet" href="/publico/bootstrap.min.css">
  <link rel="stylesheet" href="/publico/estilos.css">
</head>
<body class="d-flex flex-column min-vh-100 bg-body-tertiary">

  <nav class="navbar navbar-expand navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-semibold" href="/">
        Mapa de conocimiento
        <span class="fs-6 fw-normal text-white-50 ms-2 d-none d-sm-inline">
          Universidad de Ejemplo
        </span>
      </a>

      <?php /* La clase `active` marca dónde está parado el usuario. Sale de
               $ruta, que es la dirección de verdad — no de una variable que
               alguien tenga que acordarse de cambiar. */ ?>
      <ul class="navbar-nav ms-auto">
        <li class="nav-item">
          <a class="nav-link <?= $ruta === '/' ? 'active' : '' ?>" href="/">Inicio</a>
        </li>
        <li class="nav-item">
          <a class="nav-link <?= str_starts_with($ruta, '/proyectos') ? 'active' : '' ?>"
             href="/proyectos">Proyectos</a>
        </li>
      </ul>
    </div>
  </nav>

  <main class="container flex-grow-1 py-4">

    <?php /* ==============================================================
         LOS AVISOS

         Dos fuentes distintas, y el usuario no tiene por qué notar la
         diferencia:

           · $aviso   — lo que dejó la pantalla ANTERIOR («Se agregó…»),
                        que viajó en la sesión porque hubo una redirección;
           · $errores — lo que acaba de responder la API en ESTA petición.

         Los dos se pintan igual: en español y sin números de estado.
         ============================================================== */ ?>

    <?php if (!empty($aviso)): ?>
      <?php foreach ($aviso['mensajes'] as $mensaje): ?>
        <div class="alert alert-<?= $aviso['tipo'] === 'exito' ? 'success' : 'danger' ?> alert-dismissible fade show">
          <?= htmlspecialchars((string) $mensaje) ?>
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
        </div>
      <?php endforeach; ?>
    <?php endif; ?>

    <?php if (!empty($errores)): ?>
      <div class="alert alert-danger">
        <p class="fw-semibold mb-1">No se pudo completar la operación:</p>
        <ul class="mb-0">
          <?php foreach ($errores as $error): ?>
            <li><?= htmlspecialchars((string) $error) ?></li>
          <?php endforeach; ?>
        </ul>
      </div>
    <?php endif; ?>

    <?php require $contenido; ?>

  </main>

  <footer class="border-top bg-white py-3">
    <div class="container">
      <p class="text-body-secondary small mb-0">
        Módulo de mapa de conocimiento — ejemplo del curso ·
        versión 1: <code>proyecto</code> de punta a punta, en PHP
      </p>
    </div>
  </footer>

  <?php /* Lo ÚNICO de JavaScript en todo el front, y solo para que la «x» de
           los avisos los cierre. Las pantallas funcionan completas sin él:
           quítelo y todo sigue andando, solo que los avisos no se cierran a
           mano. Eso es lo que quiere decir que el front no dependa de JS. */ ?>
  <script src="/publico/bootstrap.bundle.min.js"></script>

</body>
</html>
