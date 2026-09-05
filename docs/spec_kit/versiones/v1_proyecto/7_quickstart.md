# Quickstart — v1: `proyecto` (PHP + MariaDB)

Los siete criterios de aceptación de [2_spec.md](2_spec.md), comprobados a
mano. Si los siete pasan, la versión está terminada.

```powershell
docker compose up -d --build
```

## Antes de empezar: por qué aquí NO se usa `curl`

En **Windows PowerShell 5.1** —el que trae Windows de fábrica— `curl` **no es
curl**: es un alias de `Invoke-WebRequest`, que no entiende `-X` ni `-d` y
responde con un error que no tiene nada que ver con la API.

Y cambiarlo por `curl.exe` tampoco basta. PowerShell 5.1 **se come las
comillas dobles** al pasarle argumentos a un programa externo, así que el
JSON del cuerpo llega roto y la API contesta que faltan todos los campos
aunque usted los haya escrito. Para que funcionara habría que escribir cada
comilla doble como `\""`, y eso ya no lo lee nadie.

Así que estos comandos usan **`Invoke-RestMethod`**, que es de PowerShell, no
necesita escapes y además imprime la respuesta en una tabla legible. Este
ayudante se pega una vez en la consola y sirve para todos los pasos:

```powershell
$API = "http://localhost:8117"

function pedir($metodo, $ruta, $cuerpo) {
  try {
    Invoke-RestMethod -Method $metodo -Uri ($API + $ruta) `
      -ContentType "application/json" -Body $cuerpo
  } catch {
    # Invoke-RestMethod LANZA con 4xx y 5xx, así que el cuerpo del error hay
    # que sacarlo de la respuesta. Sin esto solo se vería el número, y el
    # mensaje en español —que es medio ejercicio— se perdería.
    $respuesta = $_.Exception.Response
    $lector = New-Object IO.StreamReader($respuesta.GetResponseStream())
    "HTTP " + [int]$respuesta.StatusCode + " -> " + $lector.ReadToEnd()
  }
}
```

> En **Git Bash**, en Linux o en macOS, `curl` sí es curl y nada de esto hace
> falta: `curl -s -X POST $API/api/proyecto -H "Content-Type: application/json" -d '…'`
> funciona tal cual.

## Los siete criterios

```powershell
# 1. Un solo comando: la API responde y dice qué versión es
pedir GET /
#    → mensaje: API de Mapa de conocimiento funcionando · version: v1 · tabla: proyecto

# 2. El sistema arranca CON DATOS: el init.sql sembró la tabla
(pedir GET /api/proyecto).total
#    → 14
#      El 204 sigue siendo la respuesta al listado VACÍO —y el front lo trata
#      como «todavía no hay»— pero no se llega ahí arrancando.

# 3. Crear y listar
pedir POST /api/proyecto '{"id": 9001, "titulo": "Mapa de saberes del oriente", "resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}'
#    → estado 200 · "Proyecto creado exitosamente."
(pedir GET /api/proyecto).total
#    → 15

# 4. El ciclo de los cinco verbos
pedir PUT /api/proyecto/9001 '{"titulo": "Mapa de saberes del oriente", "resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}'
#    → estado 200 · filasAfectadas 1

pedir PATCH /api/proyecto/9001 '{"fecha_inicio": "2026-02-01"}'
#    → estado 200 · filasAfectadas 1

pedir GET /api/proyecto/9001
#    → la ficha, con el valor nuevo

# 4b. La pareja que enseña la diferencia: MISMO cuerpo, dos verbos
pedir PUT /api/proyecto/9001 '{"resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}'
#    → HTTP 422: al PUT le falta 'titulo', y reemplazar exige todo

pedir PATCH /api/proyecto/9001 '{"resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}'
#    → estado 200: al PATCH le basta con lo enviado

# 5. El borrado es LÓGICO, y se comprueba
pedir DELETE /api/proyecto/9001
#    → estado 200 · filasAfectadas 1
(pedir GET /api/proyecto).total
#    → 14 otra vez
pedir DELETE /api/proyecto/9001
#    → HTTP 404: para la API ya no existe

#    …pero la fila SIGUE en la base. Comprobarlo:
docker compose exec mariadb `
  mariadb -umapa -pparadigmas123 mapa_php_local `
  -e "SELECT id, activo FROM proyecto WHERE id = 9001"
#    → 9001 | 0   ← sigue ahí, con activo en cero

# 6. La validación es la frontera: nada de esto llega a la base
pedir POST /api/proyecto '{"resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}'
#    → HTTP 422, y los errores VIENEN EN ESPAÑOL y nombran el campo:
#      "El campo id es obligatorio…", "El campo titulo es obligatorio."

pedir POST /api/proyecto '{"id": 9001, "titulo": "Mapa de saberes del oriente", "resumen": "Levantamiento participativo del conocimiento tradicional.", "presupuesto": 48000000.5, "tipo_financiacion": "interna", "tipo_fondos": "Publico", "fecha_inicio": "2026-02-01", "fecha_fin": null}'
#    → HTTP 500: esa llave YA EXISTE. Quedó de los pasos anteriores, y aunque
#      esté retirada sigue ocupando la llave primaria — el borrado es lógico.
#      Ese detalle también hay que verlo: retirar no libera la llave.

# 7. Prueba de capas: el servicio SIN base de datos
docker compose exec api-mapa php pruebas/prueba_capas.php
#    → todas las verificaciones en [OK]
```

## Y la pantalla

Los siete criterios de arriba son de la API. **La versión no está cerrada sin
su pantalla** (Artículo 1.1), y eso se comprueba de dos maneras.

### A mano, que es la que no se puede automatizar

Abrir **http://localhost:8116** y:

1. entrar a **Proyectos**: se ven las 14 filas;
2. **Agregar** una ficha y ver el aviso verde;
3. **Editar** esa ficha, borrar un campo obligatorio y oprimir **«Guardar la
   ficha completa»**: se rechaza, en español, y **lo que usted escribió sigue
   ahí**;
4. con el mismo formulario a medio llenar, oprimir **«Guardar solo lo que
   cambié»**: ahora sí guarda. Ésa es la diferencia entre PUT y PATCH, vista
   desde el lado del usuario;
5. **Retirar** la ficha: desaparece del listado. Y sigue en la base — el
   comando del criterio 5 la encuentra.

### Con el guion, que recorre todo eso solo

```powershell
python pruebas_humo/humo_front.py
```

Hace el mismo recorrido con los mismos POST que manda el navegador, y al
final **apaga la API** para comprobar lo que ningún clic demuestra: que la
pantalla sigue respondiendo, con su aviso, y **sin un solo dato**.

## Si algo sale mal

| Lo que ve | Qué pasó |
|---|---|
| `No se puede enlazar el parámetro 'Headers'` | Está usando `curl` en PowerShell 5.1, donde es un alias de `Invoke-WebRequest`. Use el ayudante `pedir` de arriba |
| La API contesta que faltan todos los campos, y usted los escribió | PowerShell se comió las comillas del JSON al pasárselas a `curl.exe`. Mismo remedio |
| La pantalla se ve **sin estilos** | El router de `php -S` se está tragando el CSS. Debe llevar el `return false` para los archivos que existen (`front_php/index.php`, §1.b) |
| `Connection refused` en el 8117 | La API no arrancó. `docker compose logs api-mapa` |
| El listado responde `total: 0` | El volumen se creó antes de que existiera `db/init.sql`. `docker compose down -v` y volver a levantar |
| Un `PUT` con los mismos datos responde **404** | Falta `PDO::MYSQL_ATTR_FOUND_ROWS => true`: MariaDB está contando filas *cambiadas* en vez de *encontradas* |
| El listado responde 200 con `total: 0` en vez de 204 | El controlador no está devolviendo 204 con la lista vacía (RF1) |
