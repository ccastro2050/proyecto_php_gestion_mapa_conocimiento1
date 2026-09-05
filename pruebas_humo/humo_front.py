# -*- coding: utf-8 -*-
"""Prueba de humo del FRONT de Mapa de conocimiento (PHP, puerto 8116).

QUÉ COMPRUEBA, Y POR QUÉ AQUÍ SE PUEDE COMPROBAR TODO
=====================================================

Este front está hecho de formularios HTML corrientes: cada botón manda un
POST que un guion puede enviar igual que lo manda el navegador. Por eso esta
prueba llega **hasta el final** —agrega, guarda de las dos maneras y retira—
sin un navegador de por medio.

Lo que se comprueba:

  1. cada pantalla responde por su DIRECCIÓN PROPIA, y la hoja de estilos
     llega de verdad —que no es lo mismo—;
  2. el menú lleva a la pantalla, con una dirección que existe;
  3. lo que la pantalla muestra es lo que la API devolvió;
  4. la pantalla no le habla al usuario en jerga;
  5. el recorrido completo: agregar, los dos botones de guardar, y retirar;
  6. y lo que demuestra que son dos procesos: **con la API apagada la
     pantalla sigue en pie**, con su aviso adentro y sin un solo dato.

Uso:  python pruebas_humo/humo_front.py     (parado en la raíz del proyecto)
"""
import html
import http.cookiejar
import json
import random
import re
import string
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

# La consola de Windows no siempre usa UTF-8, y entonces imprimir una flecha
# revienta el guion con un error que no tiene NADA que ver con lo que se está
# probando. `errors="replace"` deja pasar un signo raro y sigue.
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

FRONT = "http://localhost:8116"
API = "http://localhost:8117"
SERVICIO_API = "api-mapa"
fallos = []

# Un sufijo distinto en cada corrida: si una se interrumpe a la mitad deja la
# ficha puesta, y la siguiente fallaría al crearla por llave duplicada — un
# rojo que no tiene que ver con lo que se está probando.
SUFIJO = "".join(random.choices(string.digits, k=3))
LLAVE = int("99" + SUFIJO)

# Las columnas que la tabla debe traer, en el idioma del usuario.
ETIQUETAS = ('Código', 'Título', 'Presupuesto', 'Tipo de financiación', 'Tipo de fondos', 'Fecha de inicio')

navegador = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))


def ver(url):
    """Un GET, como el que hace el navegador al escribir la dirección."""
    try:
        with navegador.open(url, timeout=20) as r:
            return r.status, r.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")
    except Exception as e:
        return 0, str(e)


def enviar(ruta, campos):
    """Un POST de formulario: exactamente lo que manda el botón.

    Fíjese en el tipo de contenido: `x-www-form-urlencoded`, que es como
    hablan los formularios. El JSON lo pone el front cuando le habla a la
    API — eso pasa del otro lado, y el usuario nunca lo escribe.
    """
    datos = urllib.parse.urlencode(campos).encode()
    peticion = urllib.request.Request(FRONT + ruta, data=datos)
    try:
        with navegador.open(peticion, timeout=20) as r:
            return r.status, r.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")
    except Exception as e:
        return 0, str(e)


def visible(pagina):
    """El texto que el usuario VE: sin etiquetas y con las tildes de verdad.

    Comprobar sobre el HTML crudo da falsos positivos de los dos lados: un
    «500» puede estar dentro de un número, y el aviso «no está disponible»
    llega escrito `est&#xE1;`, así que buscar la «á» literal no lo encuentra.
    Una prueba de pantalla comprueba **lo que se ve**, no el código fuente.
    """
    sin_script = re.sub(r"(?is)<(script|style)[^>]*>.*?</\1>", " ", pagina)
    sin_etiquetas = re.sub(r"<[^>]*>", " ", sin_script)
    return re.sub(r"\s+", " ", html.unescape(sin_etiquetas))


def revisar(nombre, condicion, detalle=""):
    marca = "[OK]    " if condicion else "[FALLO] "
    print(marca + nombre + " " + detalle[:140])
    if not condicion:
        fallos.append(nombre)


def api(ruta):
    """Una lectura directa a la API, para contrastar contra la pantalla."""
    codigo, texto = ver(API + ruta)
    if codigo not in (200, 204):
        return None
    return json.loads(texto) if texto else None


def esperar_api(segundos=180):
    """Acepta 200 y 204: un 204 es la API diciendo que la tabla está vacía,
    que es una respuesta válida — no una API a medio arrancar."""
    for _ in range(segundos // 3):
        if ver(API + "/api/proyecto?limite=1")[0] in (200, 204):
            return True
        time.sleep(3)
    return False


if not esperar_api():
    print("La API no respondió. ¿Está levantado el sistema?")
    print("   docker compose up -d --build")
    raise SystemExit(1)

# ======================================================================
print("=== 1. Las pantallas responden, cada una por su dirección ===")
# ======================================================================
PANTALLAS = [
    ("/", "Sistema del mapa de conocimiento"),
    ("/proyectos", "Proyectos"),
    ("/proyectos/nuevo", "Agregar"),
]
for ruta_, titulo in PANTALLAS:
    c, t = ver(FRONT + ruta_)
    revisar(ruta_.ljust(26) + " responde y dice «" + titulo + "»",
            c == 200 and titulo in visible(t))

c, t = ver(FRONT + "/pantalla-que-no-existe")
revisar("una dirección inventada da 404, con el marco de la aplicación",
        c == 404 and "no existe" in visible(t))

print()
print("=== 1.b LAS HOJAS DE ESTILO LLEGAN ===")
# Comprobar el TEXTO de una página no dice si la página se ve. Y aquí hay una
# trampa propia de `php -S`: con un router, PHP lo ejecuta para TODAS las
# peticiones, también para el .css — que caería en el 404 del router y
# llegaría como HTML. La pantalla saldría sin un solo estilo, con un 200 en
# el registro. Por eso se comprueba el TIPO DE CONTENIDO, no el código.
for hoja in ("/publico/bootstrap.min.css", "/publico/estilos.css"):
    try:
        with navegador.open(FRONT + hoja, timeout=20) as r:
            codigo, tipo = r.status, r.headers.get("Content-Type", "")
    except Exception as e:
        codigo, tipo = 0, str(e)
    revisar(hoja.ljust(30) + " llega como text/css",
            codigo == 200 and "css" in tipo, str(tipo))

# ======================================================================
print()
print("=== 2. El menú lleva a la pantalla, con una dirección de verdad ===")
# ======================================================================
c, inicio = ver(FRONT + "/")
revisar("el menú tiene el enlace", 'href="/proyectos"' in inicio)
revisar("y NINGUNA dirección tiene el nombre de la tabla como parámetro",
        "{tabla}" not in inicio and "?tabla=" not in inicio)

# ======================================================================
print()
print("=== 3. La pantalla trae los datos que dio la API ===")
# ======================================================================
sobre = api("/api/proyecto?limite=5")
filas = sobre["datos"] if sobre else []
c, t = ver(FRONT + "/proyectos")
if not filas:
    print("[--]    la tabla `proyecto` está vacía: no hay datos que comparar")
    revisar("y aun vacía, la pantalla responde y ofrece «Agregar»",
            "Agregar" in visible(t))
else:
    revisar("la API responde", True, str(len(filas)) + " filas")
    revisar("y esos mismos datos se ven en la pantalla",
            all(str(f["id"]) in visible(t) for f in filas[:3]))
    faltan = [e for e in ETIQUETAS if e not in visible(t)]
    revisar("la tabla trae sus columnas", not faltan, str(faltan))

# ======================================================================
print()
print("=== 4. Lo que la pantalla NO debe decirle al usuario ===")
# ======================================================================
# La jerga se busca como TOKEN TÉCNICO, no como palabra suelta: «proyecto» o
# «programa» son nombres de tabla Y palabras que el usuario dice todos los
# días. Jerga de verdad es la ruta de la API, los verbos y los motores.
JERGA = ["PUT", "PATCH", "DELETE", "/api/", "MariaDB", "SELECT", "PDO",
         "endpoint", "localhost:", "Fatal error", "Warning:", "Notice:"]
for ruta_, _ in PANTALLAS:
    c, t = ver(FRONT + ruta_)
    visto = [j for j in JERGA if j in visible(t)]
    revisar(ruta_.ljust(26) + " sin jerga", not visto, str(visto))

# ======================================================================
print()
print("=== 5. EL RECORRIDO COMPLETO, botón por botón ===")
# ======================================================================
COMPLETO = {
    "id": LLAVE,
    "titulo": ('Título ' + SUFIJO)[:70],
    "resumen": ('Resumen ' + SUFIJO)[:256],
    "presupuesto": float(SUFIJO) * 1000,
    "tipo_financiacion": ('Tipo de financiación ' + SUFIJO)[:45],
    "tipo_fondos": ('Tipo de fondos ' + SUFIJO)[:45],
    "fecha_inicio": '2026-02-01',
    "fecha_fin": '2026-02-01',
}

c, t = enviar("/proyectos/nuevo", COMPLETO)
revisar("agregar la ficha " + str(LLAVE), "Se agregó" in visible(t))
revisar("  y ya aparece en el listado", str(LLAVE) in visible(t))

# --- Guardar la ficha completa ---
renombrado = dict(COMPLETO, verbo="completa",
                  **{"titulo": "Corregido " + SUFIJO})
c, t = enviar("/proyectos/" + str(LLAVE) + "/editar", renombrado)
revisar("«Guardar la ficha completa» guarda", "Se guardó" in visible(t))
revisar("  y el valor nuevo se ve", "Corregido " + SUFIJO in visible(t))

# --- La ficha completa con un obligatorio en blanco: se rechaza ---
c, t = enviar("/proyectos/" + str(LLAVE) + "/editar",
              dict(COMPLETO, verbo="completa", **{"titulo": ""}))
texto = visible(t)
revisar("la ficha completa con «Título» en blanco se RECHAZA",
        "Se guardó" not in texto)
revisar("  y el motivo está EN ESPAÑOL y nombra el campo",
        "titulo" in texto and "should be" not in texto)
revisar("  sin números de estado ni jerga",
        not any(j in texto for j in ("422", "PUT", "/api/")))

# --- Solo lo que cambié: el MISMO formulario a medio llenar ---
vacios = {c: "" for c in COMPLETO if c != "id"}
c, t = enviar("/proyectos/" + str(LLAVE) + "/editar",
              dict(vacios, verbo="parcial",
                   **{"resumen": "Solo esto " + SUFIJO}))
revisar("«Guardar solo lo que cambié», con lo demás en blanco, SÍ guarda",
        "Se guardó" in visible(t))

# Y aquí está la lección, comprobada contra los datos: cambió un campo y el
# otro se quedó como estaba. Lo que no se envía, no se toca.
ficha = api("/api/proyecto/" + str(LLAVE))
revisar("  el campo enviado cambió",
        ficha and ficha.get("resumen") == "Solo esto " + SUFIJO,
        str(ficha and ficha.get("resumen")))
revisar("  y «Título» NO se borró: lo que no se envía, no se toca",
        ficha and ficha.get("titulo") == "Corregido " + SUFIJO,
        str(ficha and ficha.get("titulo")))

# --- Retirar ---
c, t = enviar("/proyectos/" + str(LLAVE) + "/retirar", {})
revisar("retirar la ficha", "Se retiró" in visible(t))

# Se pide la pantalla otra vez: en la segunda visita el aviso ya no está —se
# muestra una sola vez—, así que si la llave apareciera sería en la tabla de
# verdad. Dos comprobaciones por el precio de una.
c, t = ver(FRONT + "/proyectos")
revisar("  el aviso se muestra UNA vez y no se repite", "Se retiró" not in visible(t))
revisar("  y la ficha ya no está en el listado", str(LLAVE) not in visible(t))

# Y lo que hace distinto a este borrado: la fila SIGUE en la base. Se
# pregunta por la API, que también la filtra, así que responde 404 — pero el
# 7_quickstart.md trae la consulta directa que la encuentra con activo = 0.
revisar("  la API tampoco la entrega: para quien la usa, ya no está",
        api("/api/proyecto/" + str(LLAVE)) is None)

# ======================================================================
print()
print("=== 6. LA PRUEBA DE LOS DOS PROCESOS: se apaga la API ===")
print("    (esto tarda unos segundos)")
# ======================================================================
subprocess.run(["docker", "compose", "stop", SERVICIO_API],
               capture_output=True, text=True)
time.sleep(3)

c, t = ver(FRONT + "/proyectos")
texto = visible(t)
revisar("la pantalla SIGUE respondiendo con la API apagada", c == 200)
revisar("  y muestra el aviso dentro de la aplicación",
        "no está disponible" in texto)
revisar("  con su menú y su marco intactos",
        "Inicio" in texto and "Mapa de conocimiento" in texto)
# Ésta es LA comprobación de la constitución: MariaDB sigue encendida y con
# los datos ahí. Si el front pudiera llegar a la base por su cuenta, la tabla
# se seguiría viendo. No se ve.
revisar("  y SIN un solo dato: el front no puede llegar a la base solo",
        not any(str(f["id"]) in texto for f in filas[:3]) if filas else True)

subprocess.run(["docker", "compose", "start", SERVICIO_API],
               capture_output=True, text=True)
print("    API encendida otra vez; esperando a que responda…")
esperar_api(90)
c, t = ver(FRONT + "/proyectos")
revisar("y al volver la API, la pantalla vuelve a responder", c == 200)

print()
if fallos:
    print("=== RESULTADO: " + str(len(fallos)) + " FALLO(S) ===")
    for f in fallos:
        print("   -", f)
    raise SystemExit(1)

print("=== RESULTADO: TODO EN VERDE ===")
print()
print("Se recorrió el ciclo completo desde la PANTALLA, con los mismos POST")
print("que manda el navegador. Queda para una persona lo que un guion no ve:")
print("que se entienda.")
