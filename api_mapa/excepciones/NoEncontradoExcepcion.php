<?php
/**
 * NoEncontradoExcepcion — la excepción de negocio "esa fila no existe".
 *
 * La lanza el SERVICIO, y el CONTROLADOR la traduce al código HTTP 404. Así
 * el servicio comunica problemas sin saber nada de HTTP.
 */

// Modo estricto de tipos (ver explicación completa en index.php):
declare(strict_types=1);

// El cuerpo va vacío a propósito: lo único que aporta esta clase es su
// NOMBRE, que permite atraparla por separado.
//   catch (NoEncontradoExcepcion $e)  → 404
//   catch (Throwable $e)              → 500
class NoEncontradoExcepcion extends Exception
{
}
