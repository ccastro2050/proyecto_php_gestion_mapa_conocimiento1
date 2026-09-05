<?php
/**
 * El listado de proyectos.
 *
 * Las columnas están escritas aquí, con sus nombres. Cuando la v2 traiga más
 * tablas, cada una tendrá su vista — no una genérica que recorra una
 * descripción, porque entonces esta pantalla no podría decir lo que solo vale
 * para proyectos.
 *
 * No están las 2 columnas restantes de la
 * ficha: un listado con todo no se lee. Están todas en el formulario.
 */
?>
<div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-4">
  <div>
    <h1 class="h3 mb-1">Proyectos</h1>
    <p class="text-body-secondary mb-0">
      Retirar una ficha NO la borra: se queda en la base marcada como
      inactiva y deja de aparecer aquí.
    </p>
  </div>
  <a class="btn btn-primary" href="/proyectos/nuevo">Agregar</a>
</div>

<?php if (!empty($filas)): ?>
  <div class="card shadow-sm">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th scope="col">Código</th>
            <th scope="col">Título</th>
            <th scope="col" class="text-end">Presupuesto</th>
            <th scope="col">Tipo de financiación</th>
            <th scope="col">Tipo de fondos</th>
            <th scope="col">Fecha de inicio</th>
            <th scope="col" class="text-end">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($filas as $fila): ?>
            <tr>
              <td>
                <span class="badge text-bg-secondary font-monospace">
                  <?= htmlspecialchars((string) $fila['id']) ?>
                </span>
              </td>
              <td><?= htmlspecialchars((string) ($fila['titulo'] ?? '—')) ?></td>
              <td class="text-end">
                $ <?= htmlspecialchars(number_format((float) $fila['presupuesto'], 2, ',', '.')) ?>
              </td>
              <td><?= htmlspecialchars((string) ($fila['tipo_financiacion'] ?? '—')) ?></td>
              <td><?= htmlspecialchars((string) ($fila['tipo_fondos'] ?? '—')) ?></td>
              <td><?= htmlspecialchars((string) ($fila['fecha_inicio'] ?? '—')) ?></td>
              <td class="text-end text-nowrap">
                <a class="btn btn-sm btn-outline-secondary"
                   href="/proyectos/<?= rawurlencode((string) $fila['id']) ?>/editar">Editar</a>

                <?php /* POST y no un enlace: un GET que retira lo puede
                         disparar el navegador solo al precargar la página. */ ?>
                <form class="d-inline" method="post"
                      action="/proyectos/<?= rawurlencode((string) $fila['id']) ?>/retirar"
                      onsubmit="return confirm('¿Retirar la ficha <?= htmlspecialchars((string) $fila['id']) ?>?');">
                  <button class="btn btn-sm btn-outline-danger" type="submit">Retirar</button>
                </form>
              </td>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>

  <p class="text-body-secondary small mt-3 mb-0">
    <?= count($filas) ?> ficha(s).
  </p>

<?php else: ?>
  <?php /* Vacío NO es un error, y la pantalla lo distingue: si la API está
           caída, arriba hay además un aviso rojo. */ ?>
  <div class="card shadow-sm">
    <div class="card-body text-center py-5">
      <p class="fs-5 mb-1">Todavía no hay proyectos</p>
      <p class="text-body-secondary">Use «Agregar» para crear la primera ficha.</p>
      <a class="btn btn-primary" href="/proyectos/nuevo">Agregar</a>
    </div>
  </div>
<?php endif; ?>
