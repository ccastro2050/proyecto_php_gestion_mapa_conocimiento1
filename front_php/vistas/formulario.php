<?php
/**
 * El formulario de una ficha: sirve para agregar y para editar.
 *
 * La diferencia entre los dos usos está en $editando, y se ve en dos sitios:
 * la llave va de solo lectura al editar, y aparecen DOS botones de guardar
 * en vez de uno.
 */
?>
<div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-4">
  <div>
    <h1 class="h3 mb-1"><?= $editando ? 'Editar la ficha' : 'Agregar el proyecto' ?></h1>
    <p class="text-body-secondary mb-0">
      <?php if ($editando): ?>
        La llave identifica la ficha y no se cambia. Si está mal, se agrega
        otra y se retira ésta.
      <?php else: ?>
        La llave la escribe usted y no se podrá cambiar después.
      <?php endif; ?>
    </p>
  </div>
  <a class="btn btn-outline-secondary" href="/proyectos">Volver al listado</a>
</div>

<div class="card shadow-sm" style="max-width: 46rem;">
  <div class="card-body p-4">
    <form method="post">

      <div class="mb-3">
        <label class="form-label" for="id">Código</label>
        <input class="form-control font-monospace" type="number" id="id" name="id" min="0"
               value="<?= htmlspecialchars((string) ($ficha['id'] ?? '')) ?>"
               <?= $editando ? 'readonly' : 'required autofocus' ?>>
      </div>

      <div class="mb-3">
        <label class="form-label" for="titulo">Título</label>
        <input class="form-control" type="text" id="titulo" name="titulo"
               maxlength="70"
               value="<?= htmlspecialchars((string) ($ficha['titulo'] ?? '')) ?>">
      </div>

      <div class="mb-3">
        <label class="form-label" for="resumen">Resumen</label>
        <textarea class="form-control" id="resumen" name="resumen" rows="3"
                maxlength="256"><?= htmlspecialchars((string) ($ficha['resumen'] ?? '')) ?></textarea>
      </div>

      <div class="mb-3">
        <label class="form-label" for="presupuesto">Presupuesto</label>
        <div class="input-group">
          <span class="input-group-text">$</span>
          <input class="form-control" type="number" id="presupuesto" name="presupuesto" step="0.01" min="0"
                 value="<?= htmlspecialchars((string) ($ficha['presupuesto'] ?? '')) ?>">
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label" for="tipo_financiacion">Tipo de financiación</label>
        <input class="form-control" type="text" id="tipo_financiacion" name="tipo_financiacion"
               maxlength="45"
               value="<?= htmlspecialchars((string) ($ficha['tipo_financiacion'] ?? '')) ?>">
        <div class="form-text">Uno de tres: interna, externa o cofinanciado.</div>
      </div>

      <div class="mb-3">
        <label class="form-label" for="tipo_fondos">Tipo de fondos</label>
        <input class="form-control" type="text" id="tipo_fondos" name="tipo_fondos"
               maxlength="45"
               value="<?= htmlspecialchars((string) ($ficha['tipo_fondos'] ?? '')) ?>">
        <div class="form-text">Uno de tres: Público, Privado o Mixto.</div>
      </div>

      <div class="mb-3">
        <label class="form-label" for="fecha_inicio">Fecha de inicio</label>
        <input class="form-control" type="date" id="fecha_inicio" name="fecha_inicio"
               value="<?= htmlspecialchars((string) ($ficha['fecha_inicio'] ?? '')) ?>">
      </div>

      <div class="mb-3">
        <label class="form-label" for="fecha_fin">Fecha de fin <span class="text-body-secondary fw-normal">(opcional)</span></label>
        <input class="form-control" type="date" id="fecha_fin" name="fecha_fin"
               value="<?= htmlspecialchars((string) ($ficha['fecha_fin'] ?? '')) ?>">
        <div class="form-text">Déjela en blanco si el proyecto sigue en curso.</div>
      </div>

      <hr class="my-4">

      <?php /* ==============================================================
           LOS DOS BOTONES, QUE NO HACEN LO MISMO

             · «Guardar la ficha completa» manda todo, así que un dato
               obligatorio en blanco se rechaza.
             · «Guardar solo lo que cambié» manda únicamente lo diligenciado,
               así que el mismo formulario a medio llenar sí se guarda.

           El mismo formulario, dos comportamientos, y la diferencia no la
           decide ningún `if` de negocio: la decide QUÉ SE ENVÍA.
           ============================================================== */ ?>
      <?php if ($editando): ?>
        <div class="d-flex flex-wrap gap-2">
          <button class="btn btn-primary" type="submit" name="verbo" value="completa">
            Guardar la ficha completa
          </button>
          <button class="btn btn-outline-primary" type="submit" name="verbo" value="parcial">
            Guardar solo lo que cambié
          </button>
        </div>
        <div class="form-text mt-3">
          <strong>«La ficha completa»</strong> exige que todos los datos
          obligatorios estén diligenciados. <strong>«Solo lo que cambié»</strong>
          guarda lo que usted escribió y deja lo demás como estaba.
        </div>
      <?php else: ?>
        <button class="btn btn-primary" type="submit">Agregar</button>
      <?php endif; ?>

    </form>
  </div>
</div>
