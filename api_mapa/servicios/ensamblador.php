<?php
/**
 * Ensamblador — el ÚNICO lugar del sistema que conoce clases concretas.
 *
 * Una sola función, sin arrays de motores ni selección: la v1 tiene UN motor
 * y el código lo dice. El día que haya un segundo, SOLO este archivo se
 * convierte en una fábrica de verdad — controladores y servicios no se
 * tocan: ese es el examen del principio abierto/cerrado.
 */

// Modo estricto de tipos (ver explicación completa en index.php):
declare(strict_types=1);

require_once __DIR__ . '/ServicioProyecto.php';
require_once __DIR__ . '/../repositorios/RepositorioProyectoMariaDB.php';

// Fíjese en el tipo de retorno: promete LA INTERFAZ, no la clase concreta.
// Quien la llame (index.php) no sabrá qué hay dentro.
function crearServicioProyecto(): IServicioProyecto
{
    // Aquí — y SOLO aquí — se hace `new` de clases concretas.
    // La configuración llega por variables de entorno:
    //   getenv('X')  → la variable X del entorno (el compose las inyecta)
    //   ?:           → "si vino vacía o no existe, use este valor"
    // Los valores por defecto apuntan a localhost:13333, que es el puerto
    // PUBLICADO de la base: así se puede correr la API sin Docker mientras
    // la base sí está en Docker.
    $repositorio = new RepositorioProyectoMariaDB(
        getenv('DB_DSN')     ?: 'mysql:host=localhost;port=13333;dbname=mapa_php_local',
        getenv('DB_USUARIO') ?: 'mapa',
        getenv('DB_CLAVE')   ?: 'paradigmas123',
    );

    // Se ARMA la cadena de capas: el servicio recibe el repositorio ya
    // construido (inyección de dependencias hecha a mano, sin frameworks):
    return new ServicioProyecto($repositorio);
}
