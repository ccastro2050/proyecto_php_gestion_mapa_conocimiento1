<?php
/**
 * index.php — el FRONT CONTROLLER del front.
 *
 * Sí: el front también tiene uno, y es el mismo patrón que la API. Todas las
 * peticiones entran aquí, este archivo mira el método y la ruta, y decide qué
 * pantalla pintar. Nada de SQL, nada de negocio, nada de HTML: eso está en
 * `vistas/`.
 *
 * Las pantallas de la v1:
 *   GET  /                              → el inicio
 *   GET  /proyectos                 → el listado
 *   GET  /proyectos/nuevo           → el formulario vacío
 *   POST /proyectos/nuevo           → guarda el nuevo
 *   GET  /proyectos/{clave}/editar  → el formulario con la ficha
 *   POST /proyectos/{clave}/editar  → guarda, completo o parcial según el botón
 *   POST /proyectos/{clave}/retirar → retira la ficha
 *
 * **Cada pantalla tiene su dirección propia**, no una con el nombre de la
 * tabla como parámetro: se puede guardar como marcador, mandar por correo y
 * poner en un menú (sección 6.1 de la metodología).
 */

declare(strict_types=1);

require_once __DIR__ . '/cliente_api.php';

// ----------------------------------------------------------------------
// 1. CAPTURAR la petición
// ----------------------------------------------------------------------
$metodo = $_SERVER['REQUEST_METHOD'];
$ruta   = rtrim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/') ?: '/';

// ----------------------------------------------------------------------
// 1.b LOS ARCHIVOS ESTÁTICOS (y una trampa que cuesta una pantalla fea)
// ----------------------------------------------------------------------
//
// El servidor embebido de PHP, cuando se le da un router —que es lo que
// hacemos con `php -S ... index.php`—, **lo ejecuta para TODAS las
// peticiones**. También para `/publico/estilos.css`. Y como este archivo no
// tiene una ruta que se llame así, la hoja de estilos caería en el 404 de
// abajo: el navegador recibiría una página HTML donde espera CSS, y la
// pantalla saldría sin un solo estilo.
//
// La solución es la que el propio PHP documenta: **devolver `false`** desde
// el router. Eso le dice «yo no me encargo de ésta, entrégala tal cual», y
// el servidor sirve el archivo del disco.
if (PHP_SAPI === 'cli-server') {
    $archivo = __DIR__ . $ruta;
    if ($ruta !== '/' && is_file($archivo)) {
        return false;
    }
}

// Los avisos que una pantalla le deja a la siguiente. Van en la sesión porque
// después de guardar se REDIRIGE, y una redirección pierde lo que hubiera en
// memoria.
session_start();

/** Deja un aviso para la pantalla siguiente y redirige. */
function redirigir_con(string $destino, string $tipo, $mensaje): void
{
    $_SESSION['aviso'] = ['tipo' => $tipo, 'mensajes' => (array) $mensaje];
    header("Location: $destino");
    exit;
}

/** Saca el aviso pendiente (y lo borra: se muestra una sola vez). */
function aviso_pendiente(): ?array
{
    $aviso = $_SESSION['aviso'] ?? null;
    unset($_SESSION['aviso']);
    return $aviso;
}

/**
 * Pinta una vista dentro del marco común.
 *
 * Las tres variables que el MARCO siempre necesita se ponen aquí con un valor
 * por defecto, para que ninguna vista tenga que acordarse de mandarlas:
 *
 *   · $aviso   — lo que dejó la pantalla anterior (o nada);
 *   · $errores — lo que respondió la API en esta petición (o nada);
 *   · $ruta    — la dirección actual, que el menú usa para marcar dónde está
 *                parado el usuario.
 *
 * La de $ruta hace falta por algo que no se ve a simple vista: **esto es una
 * función**, así que la $ruta del cuerpo del archivo no entra aquí sola. Sin
 * pasársela, el menú no marcaría nada.
 */
function pintar(string $vista, array $datos = []): void
{
    $datos += ['errores' => [], 'ruta' => $GLOBALS['ruta'] ?? '/'];
    $datos['aviso'] = aviso_pendiente();

    extract($datos);
    $contenido = __DIR__ . "/vistas/$vista.php";
    require __DIR__ . '/vistas/plantilla.php';
}

/** Los campos del formulario, ya recortados. */
function campos_del_formulario(): array
{
    return [
        'titulo'                 => trim($_POST['titulo'] ?? ''),
        'resumen'                => trim($_POST['resumen'] ?? ''),
        'presupuesto'            => trim($_POST['presupuesto'] ?? ''),
        'tipo_financiacion'      => trim($_POST['tipo_financiacion'] ?? ''),
        'tipo_fondos'            => trim($_POST['tipo_fondos'] ?? ''),
        'fecha_inicio'           => trim($_POST['fecha_inicio'] ?? ''),
        'fecha_fin'              => trim($_POST['fecha_fin'] ?? ''),
    ];
}

// ----------------------------------------------------------------------
// 2. ENRUTAR
// ----------------------------------------------------------------------

// ---- El inicio ----
if ($ruta === '/' && $metodo === 'GET') {
    pintar('inicio');
    exit;
}

// ---- El listado ----
if ($ruta === '/proyectos' && $metodo === 'GET') {
    $r = listar_mapa();
    // Aun con error se pinta la pantalla: el usuario ve el aviso DENTRO de la
    // aplicación, no una página de error de PHP.
    pintar('lista', ['filas' => $r['datos'], 'errores' => $r['errores']]);
    exit;
}

// ---- Agregar ----
if ($ruta === '/proyectos/nuevo') {
    if ($metodo === 'GET') {
        pintar('formulario', ['ficha' => null, 'editando' => false]);
        exit;
    }

    // Los formularios SOLO producen texto: el «12» que la persona escribió
    // llega como "12". El contrato pide un número, y un número entre comillas
    // no es un número. `a_numero` ajusta la FORMA del dato —trabajo del
    // front— y no juzga su VALOR, que es trabajo de la API.
    $datos = [
        'id'                     => a_numero(trim($_POST['id'] ?? ''), 'entero'),
        'titulo'                 => trim($_POST['titulo'] ?? ''),
        'resumen'                => trim($_POST['resumen'] ?? ''),
        'presupuesto'            => a_numero(trim($_POST['presupuesto'] ?? ''), 'decimal'),
        'tipo_financiacion'      => trim($_POST['tipo_financiacion'] ?? ''),
        'tipo_fondos'            => trim($_POST['tipo_fondos'] ?? ''),
        'fecha_inicio'           => trim($_POST['fecha_inicio'] ?? ''),
        'fecha_fin'              => trim($_POST['fecha_fin'] ?? ''),
    ];

    $r = crear_mapa($datos);
    if ($r['ok']) {
        redirigir_con('/proyectos', 'exito',
            "Se agregó el proyecto {$datos['id']}.");
    }

    // Se devuelve el formulario CON lo que la persona había escrito: perder
    // lo digitado por un error de validación es castigarla dos veces.
    pintar('formulario', ['ficha' => $_POST, 'editando' => false,
                          'errores' => $r['errores']]);
    exit;
}

// ---- Editar ----
if (preg_match('#^/proyectos/([^/]+)/editar$#', $ruta, $coincidencias)) {
    $clave = urldecode($coincidencias[1]);

    if ($metodo === 'GET') {
        $r = obtener_mapa($clave);
        if (!$r['ok']) {
            redirigir_con('/proyectos', 'error', $r['errores']);
        }
        pintar('formulario', ['ficha' => $r['datos'], 'editando' => true]);
        exit;
    }

    $f = campos_del_formulario();

    // ==================================================================
    // AQUÍ ESTÁ LA LECCIÓN DEL FORMULARIO
    //
    // Qué botón se oprimió decide qué se envía. La diferencia NO está en un
    // `if` de negocio: está en el CUERPO de la petición.
    // ==================================================================
    if (($_POST['verbo'] ?? '') === 'completa') {
        // Ficha completa: todos los campos viajan aunque estén vacíos, y por
        // eso un obligatorio en blanco se rechaza. Es reemplazar.
        $cuerpo_completo = [
            'titulo'             => $f['titulo'],
            'resumen'            => $f['resumen'],
            'presupuesto'        => a_numero($f['presupuesto'], 'decimal'),
            'tipo_financiacion'  => $f['tipo_financiacion'],
            'tipo_fondos'        => $f['tipo_fondos'],
            'fecha_inicio'       => $f['fecha_inicio'],
            'fecha_fin'          => $f['fecha_fin'],
        ];
    // `fecha_fin` es el único campo opcional de la tabla, y en el reemplazo hay que
    // decidir qué significa dejarlo en blanco. Aquí significa «no tiene», que
    // es null — no la cadena vacía, que la API rechazaría.
    if ($cuerpo_completo['fecha_fin'] === '') {
        $cuerpo_completo['fecha_fin'] = null;
    }
        $r = reemplazar_mapa($clave, $cuerpo_completo);
    } else {
        // Solo lo que cambió: viaja únicamente lo diligenciado. El mismo
        // formulario a medio llenar que el reemplazo rechaza, aquí funciona.
        $cuerpo = [];
        if ($f['titulo'] !== '') { $cuerpo['titulo'] = $f['titulo']; }
        if ($f['resumen'] !== '') { $cuerpo['resumen'] = $f['resumen']; }
        if ($f['presupuesto'] !== '') { $cuerpo['presupuesto'] = a_numero($f['presupuesto'], 'decimal'); }
        if ($f['tipo_financiacion'] !== '') { $cuerpo['tipo_financiacion'] = $f['tipo_financiacion']; }
        if ($f['tipo_fondos'] !== '') { $cuerpo['tipo_fondos'] = $f['tipo_fondos']; }
        if ($f['fecha_inicio'] !== '') { $cuerpo['fecha_inicio'] = $f['fecha_inicio']; }
        if ($f['fecha_fin'] !== '') { $cuerpo['fecha_fin'] = $f['fecha_fin']; }
        $r = actualizar_mapa($clave, $cuerpo);
    }

    if ($r['ok']) {
        redirigir_con('/proyectos', 'exito', "Se guardó la ficha $clave.");
    }

    pintar('formulario', [
        'ficha'    => $f + ['id' => $clave],
        'editando' => true,
        'errores'  => $r['errores'],
    ]);
    exit;
}

// ---- Retirar ----
// Se exige POST a propósito: un enlace GET que borra lo puede disparar el
// navegador solo, al precargar la página.
if (preg_match('#^/proyectos/([^/]+)/retirar$#', $ruta, $coincidencias) && $metodo === 'POST') {
    $clave = urldecode($coincidencias[1]);
    $r = eliminar_mapa($clave);

    $r['ok']
        ? redirigir_con('/proyectos', 'exito', "Se retiró la ficha $clave.")
        : redirigir_con('/proyectos', 'error', $r['errores']);
}

// ---- Cualquier otra cosa ----
http_response_code(404);
pintar('no_encontrada', ['ruta' => $ruta]);

/**
 * El texto convertido a número si lo es; si no, el texto tal cual.
 *
 * Parece una validación en el front, y hay que ser preciso porque no lo es.
 * Un formulario HTML **solo produce texto**. El contrato pide un número, y
 * mandarlo entre comillas haría que la API lo rechazara **incluso siendo
 * correcto**.
 *
 * Así que esto ajusta la FORMA del dato, que es trabajo del front, y no juzga
 * su VALOR, que es trabajo de la API: si alguien escribió «doce», eso viaja
 * como «doce» y la API dice que no sirve.
 */
function a_numero(string $texto, string $tipo)
{
    $texto = trim($texto);
    if ($texto === '') {
        return '';
    }
    if ($tipo === 'entero') {
        return ctype_digit(ltrim($texto, '-')) ? (int) $texto : $texto;
    }
    return is_numeric($texto) ? (float) $texto : $texto;
}
