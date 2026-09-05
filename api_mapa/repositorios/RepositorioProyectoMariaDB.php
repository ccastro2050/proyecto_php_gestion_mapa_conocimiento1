<?php
/**
 * RepositorioProyectoMariaDB — la capa de DATOS de la v1.
 *
 * Única clase del sistema que habla SQL y que conoce la conexión. Cumple el
 * contrato IRepositorioProyecto con `implements`.
 *
 * Reglas de la constitución que se cumplen aquí:
 * - SQL SIEMPRE en prepared statements de PDO (nunca concatenar valores).
 * - El SQL queda visible (PDO como ejecutor, sin ORM).
 * - El borrado es LÓGICO, y por eso **las cuatro lecturas y escrituras
 *   filtran por `activo = TRUE`**. Es la regla que más fácil se olvida en
 *   una consulta nueva, y por eso está escrita en cada una.
 */

// Modo estricto de tipos (ver explicación completa en index.php):
declare(strict_types=1);

require_once __DIR__ . '/IRepositorioProyecto.php';
require_once __DIR__ . '/../modelos/Proyecto.php';

class RepositorioProyectoMariaDB implements IRepositorioProyecto
{
    // La conexión viva. Arranca en null: no se abre al construir (perezosa).
    private ?PDO $conexion = null;

    public function __construct(
        private readonly string $dsn,
        private readonly string $usuario,
        private readonly string $clave,
    ) {
        // Nada más: este archivo no sabe de variables de entorno.
        // El DSN llega de afuera (lo arma el ensamblador).
    }

    // ------------------------------------------------------------------
    // Ayudantes privados
    // ------------------------------------------------------------------

    /** Abre la conexión PDO la primera vez y la reutiliza. */
    private function obtenerConexion(): PDO
    {
        if ($this->conexion === null) {
            $this->conexion = new PDO($this->dsn, $this->usuario, $this->clave, [
                // Errores como EXCEPCIONES; el controlador las traduce a 500:
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                // Prepared statements REALES del servidor, no emulados:
                PDO::ATTR_EMULATE_PREPARES => false,
                // Detalle de MariaDB: por defecto rowCount() de un UPDATE
                // cuenta filas CAMBIADAS — si el valor nuevo es igual al
                // viejo reporta 0, y parecería que la llave no existe. Con
                // FOUND_ROWS cuenta ENCONTRADAS, como los demás motores.
                // Sin esto, un PUT que reenvía los mismos datos daría 404.
                PDO::MYSQL_ATTR_FOUND_ROWS => true,
            ]);
        }
        return $this->conexion;
    }

    /**
     * Convierte una fila cruda de la BD en un objeto del MODELO.
     * El driver de MySQL entrega lo numérico "flojo" (un DECIMAL llega como
     * string): los casts dejan el tipo correcto AQUÍ, en un solo lugar.
     */
    private function armar(array $fila): Proyecto
    {
        return new Proyecto(
            (int) $fila['id'],
            $fila['titulo'],
            $fila['resumen'],
            (float) $fila['presupuesto'],
            $fila['tipo_financiacion'],
            $fila['tipo_fondos'],
            $fila['fecha_inicio'],
            $fila['fecha_fin'] === null ? null : $fila['fecha_fin'],
        );
    }

    // ------------------------------------------------------------------
    // Los 5 métodos del contrato
    // ------------------------------------------------------------------

    public function obtenerTodos(int $limite): array
    {
        // activo = TRUE: los inactivos existen en la base y NO se listan.
        $sql = 'SELECT id, titulo, resumen, presupuesto, tipo_financiacion, tipo_fondos, fecha_inicio, fecha_fin
                FROM proyecto WHERE activo = TRUE
                ORDER BY id LIMIT :limite';
        $sentencia = $this->obtenerConexion()->prepare($sql);
        // PARAM_INT es obligatorio: un LIMIT con string es error de sintaxis.
        $sentencia->bindValue(':limite', $limite, PDO::PARAM_INT);
        $sentencia->execute();

        $filas = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn(array $fila) => $this->armar($fila), $filas);
    }

    public function obtenerPorClave(int $id): ?Proyecto
    {
        $sql = 'SELECT id, titulo, resumen, presupuesto, tipo_financiacion, tipo_fondos, fecha_inicio, fecha_fin
                FROM proyecto WHERE id = :clave AND activo = TRUE';
        $sentencia = $this->obtenerConexion()->prepare($sql);
        $sentencia->bindValue(':clave', $id, PDO::PARAM_INT);
        $sentencia->execute();

        $fila = $sentencia->fetch(PDO::FETCH_ASSOC);
        // false (no hubo fila) → null, que es lo que promete el contrato.
        return $fila === false ? null : $this->armar($fila);
    }

    public function crear(Proyecto $proyecto): bool
    {
        $sql = 'INSERT INTO proyecto (id, titulo, resumen, presupuesto, tipo_financiacion, tipo_fondos, fecha_inicio, fecha_fin)
                VALUES (:id, :titulo, :resumen, :presupuesto, :tipo_financiacion, :tipo_fondos, :fecha_inicio, :fecha_fin)';
        $sentencia = $this->obtenerConexion()->prepare($sql);
        // Los valores salen del OBJETO, a través de sus getters:
        $sentencia->execute([
            'id'                     => $proyecto->getId(),
            'titulo'                 => $proyecto->getTitulo(),
            'resumen'                => $proyecto->getResumen(),
            'presupuesto'            => $proyecto->getPresupuesto(),
            'tipo_financiacion'      => $proyecto->getTipoFinanciacion(),
            'tipo_fondos'            => $proyecto->getTipoFondos(),
            'fecha_inicio'           => $proyecto->getFechaInicio(),
            'fecha_fin'              => $proyecto->getFechaFin(),
        ]);
        return $sentencia->rowCount() === 1;
    }

    public function actualizar(int $id, array $datos): int
    {
        // SET dinámico SOLO con las columnas que llegaron (PUT manda todas,
        // PATCH un subconjunto). Los NOMBRES de columna salen de la lista
        // blanca del controlador —nunca del cliente—, por eso es seguro
        // interpolarlos; los VALORES sí van siempre como parámetros.
        $asignaciones = [];
        foreach (array_keys($datos) as $columna) {
            $asignaciones[] = "$columna = :$columna";
        }
        // El marcador de la llave se llama distinto para no chocar si el
        // cuerpo trajera una columna con ese mismo nombre:
        $sql = 'UPDATE proyecto SET ' . implode(', ', $asignaciones)
             . ' WHERE id = :clave_de_la_fila AND activo = TRUE';

        $sentencia = $this->obtenerConexion()->prepare($sql);
        $sentencia->execute($datos + ['clave_de_la_fila' => $id]);
        // Filas afectadas (gracias a FOUND_ROWS: encontradas, no cambiadas):
        return $sentencia->rowCount();
    }

    public function eliminar(int $id): int
    {
        // AQUÍ ESTÁ EL BORRADO LÓGICO: es un UPDATE, no un DELETE. La fila
        // sigue en la base con activo = FALSE, y se puede comprobar con una
        // consulta directa — está en el paso 5 del 7_quickstart.md.
        //
        // El `AND activo = TRUE` no sobra: sin él, borrar dos veces la misma
        // fila respondería 200 las dos veces, y el segundo DELETE tiene que
        // dar 404.
        $sql = 'UPDATE proyecto SET activo = FALSE
                WHERE id = :clave AND activo = TRUE';
        $sentencia = $this->obtenerConexion()->prepare($sql);
        $sentencia->bindValue(':clave', $id, PDO::PARAM_INT);
        $sentencia->execute();
        return $sentencia->rowCount();
    }
}
