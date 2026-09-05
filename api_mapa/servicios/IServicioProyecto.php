<?php
/**
 * IServicioProyecto — el CONTRATO de la capa de negocio.
 *
 * El controlador depende de esta interfaz: no sabe (ni debe saber) qué hay
 * detrás. Los métodos comunican problemas con excepciones de NEGOCIO que el
 * controlador traduce a códigos HTTP:
 *   InvalidArgumentException → 400 · NoEncontradoExcepcion → 404 ·
 *   PDOException y demás → 500.
 *
 * Fíjese en que aquí no aparece ni una vez la palabra HTTP. Ese es el punto.
 */

// Modo estricto de tipos (ver explicación completa en index.php):
declare(strict_types=1);

require_once __DIR__ . '/../modelos/Proyecto.php';

interface IServicioProyecto
{
    /**
     * Hasta $limite filas. InvalidArgumentException si limite <= 0.
     * @return Proyecto[]
     */
    public function listar(int $limite): array;

    /** Proyecto con esa llave. NoEncontradoExcepcion si no existe. */
    public function obtener(int $clave): Proyecto;

    /**
     * Crea. Recibe el array YA validado por el controlador; el servicio
     * construye con él la entidad del modelo.
     */
    public function crear(array $datos): void;

    /**
     * Escribe los campos enviados (PUT manda todos, PATCH un subconjunto).
     * InvalidArgumentException si no llegó ninguno ·
     * NoEncontradoExcepcion si la llave no existe · devuelve filas afectadas.
     */
    public function actualizar(int $clave, array $datos): int;

    /** Borrado lógico. NoEncontradoExcepcion si no existe. */
    public function eliminar(int $clave): int;
}
