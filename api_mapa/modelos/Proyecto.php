<?php
/**
 * Proyecto — el MODELO de la v1: la clase que representa una fila de la tabla
 * `proyecto` como un objeto.
 *
 * Estilo clásico de P.O.O. (encapsulamiento):
 *   - las propiedades son PRIVADAS: nadie por fuera las toca directamente;
 *   - se LEEN con getters;
 *   - se CAMBIAN con setters;
 *   - `id` NO tiene setter: es la llave primaria — se fija al
 *     crear el objeto y no cambia nunca.
 *
 * Lo que este modelo NO tiene, y es a propósito: la columna `activo`. La
 * usa el repositorio para el borrado lógico, pero no es un dato del
 * proyecto — es cómo la base recuerda que ya no está. Si estuviera
 * aquí, alguien terminaría mandándola en un PUT.
 */

// Modo estricto de tipos (ver explicación completa en index.php):
declare(strict_types=1);

class Proyecto
{
    private int $id;  // El código del proyecto.
    private string $titulo;
    private string $resumen;
    private float $presupuesto;  // Un NÚMERO, no una cadena: si llega «mucho», es 422.
    private string $tipo_financiacion;  // Los valores del Excel: interna, externa, cofinanciado.
    private string $tipo_fondos;  // Los valores del Excel: Público, Privado, Mixto.
    private string $fecha_inicio;  // Fecha de verdad: la columna es DATE, no texto.
    private ?string $fecha_fin;  // El ÚNICO opcional: un proyecto en curso todavía no terminó.

    public function __construct(
        int $id,
        string $titulo,
        string $resumen,
        float $presupuesto,
        string $tipo_financiacion,
        string $tipo_fondos,
        string $fecha_inicio,
        ?string $fecha_fin,
    ) {
        $this->id = $id;
        $this->titulo = $titulo;
        $this->resumen = $resumen;
        $this->presupuesto = $presupuesto;
        $this->tipo_financiacion = $tipo_financiacion;
        $this->tipo_fondos = $tipo_fondos;
        $this->fecha_inicio = $fecha_inicio;
        $this->fecha_fin = $fecha_fin;
    }

    // ------------------------------------------------------------------
    // GETTERS — para LEER cada propiedad desde afuera
    // ------------------------------------------------------------------

    public function getId(): int
    {
        return $this->id;
    }

    public function getTitulo(): string
    {
        return $this->titulo;
    }

    public function getResumen(): string
    {
        return $this->resumen;
    }

    public function getPresupuesto(): float
    {
        return $this->presupuesto;
    }

    public function getTipoFinanciacion(): string
    {
        return $this->tipo_financiacion;
    }

    public function getTipoFondos(): string
    {
        return $this->tipo_fondos;
    }

    public function getFechaInicio(): string
    {
        return $this->fecha_inicio;
    }

    public function getFechaFin(): ?string
    {
        return $this->fecha_fin;
    }

    // ------------------------------------------------------------------
    // SETTERS — solo para lo que puede cambiar.
    // La llave no tiene: identificar y modificar son cosas distintas.
    // ------------------------------------------------------------------

    public function setTitulo(string $titulo): void
    {
        $this->titulo = $titulo;
    }

    public function setResumen(string $resumen): void
    {
        $this->resumen = $resumen;
    }

    public function setPresupuesto(float $presupuesto): void
    {
        $this->presupuesto = $presupuesto;
    }

    public function setTipoFinanciacion(string $tipo_financiacion): void
    {
        $this->tipo_financiacion = $tipo_financiacion;
    }

    public function setTipoFondos(string $tipo_fondos): void
    {
        $this->tipo_fondos = $tipo_fondos;
    }

    public function setFechaInicio(string $fecha_inicio): void
    {
        $this->fecha_inicio = $fecha_inicio;
    }

    public function setFechaFin(?string $fecha_fin): void
    {
        $this->fecha_fin = $fecha_fin;
    }

    // ------------------------------------------------------------------
    // Conversión para la respuesta JSON
    // ------------------------------------------------------------------

    /**
     * Devuelve el proyecto como array (columna => valor), listo
     * para que json_encode lo convierta en JSON. Hace falta porque las
     * propiedades son privadas: json_encode no las ve.
     */
    public function toArray(): array
    {
        return [
            'id'                     => $this->id,
            'titulo'                 => $this->titulo,
            'resumen'                => $this->resumen,
            'presupuesto'            => $this->presupuesto,
            'tipo_financiacion'      => $this->tipo_financiacion,
            'tipo_fondos'            => $this->tipo_fondos,
            'fecha_inicio'           => $this->fecha_inicio,
            'fecha_fin'              => $this->fecha_fin,
        ];
    }
}
