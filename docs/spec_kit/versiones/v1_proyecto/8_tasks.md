# Tareas — v1: `proyecto` (PHP + MariaDB)

El orden importa: **de adentro hacia afuera**. Cada fase termina con algo que
se puede comprobar, no con «ya quedó».

## Fase 0 — El compose y la base

- [ ] `docker-compose.yml` con los cuatro servicios: `mariadb`, `api-mapa`,
      `front-php` y `phpmyadmin`.
- [ ] `db/init.sql` derivado del script del curso, con los cinco cambios
      numerados en su cabecera y las semillas al final.
- [ ] `front-php` **sin** credenciales de la base y **sin** `depends_on` que
      la mencione.

**Verificación:**

```powershell
docker compose up -d mariadb
docker compose exec mariadb mariadb -umapa -pparadigmas123 mapa_php_local `
  -e "SELECT COUNT(*) FROM proyecto"
#  → 14
```

## Fase 1 — El modelo

- [ ] `modelos/Proyecto.php`: propiedades privadas, getters, setters para todo
      **menos la llave**, y `toArray()`.
- [ ] **Sin** `activo`: no es un campo de la ficha (5_data_model §4).

## Fase 2 — Las interfaces

- [ ] `repositorios/IRepositorioProyecto.php` y `servicios/IServicioProyecto.php`.

**Verificación:** la prueba de capas de la Fase 7 ya se podría escribir; el
servicio todavía no existe pero su contrato sí.

## Fase 3 — El repositorio

- [ ] `repositorios/RepositorioProyectoMariaDB.php` con PDO y prepared statements.
- [ ] **Todas** las consultas filtran por `activo = TRUE`.
- [ ] El borrado lógico, en **una sola** consulta (`UPDATE … SET activo = FALSE`).
- [ ] `PDO::MYSQL_ATTR_FOUND_ROWS => true` y `bindValue(..., PDO::PARAM_INT)`
      para el `LIMIT`.

**Verificación:** desde el contenedor,

```powershell
docker compose exec api-mapa php -r "require 'servicios/ensamblador.php'; print_r(count(crearServicioProyecto()->listar(1000)));"
#  → 14
```

## Fase 4 — El servicio

- [ ] `servicios/ServicioProyecto.php`, que lanza `InvalidArgumentException` y
      `NoEncontradoExcepcion` — **nunca códigos HTTP**.
- [ ] `servicios/ensamblador.php`: el único `new` de clases concretas.

## Fase 5 — El controlador

- [ ] `controladores/ControladorProyecto.php` con la validación del cuerpo, la
      lista blanca de columnas y la traducción a códigos.
- [ ] `validarCampos($datos, $obligatorios)`: **un solo método** para PUT y
      PATCH, con el booleano decidiendo.

## Fase 6 — El enrutador

- [ ] `index.php` con las siete rutas y el 405 para los métodos que no van.
- [ ] El 404 de RUTA es distinto del 404 de «esa fila no existe».

**Verificación:** los pasos 1 a 6 de [7_quickstart.md](7_quickstart.md).

## Fase 7 — La prueba de capas

- [ ] `pruebas/prueba_capas.php` con un repositorio falso en memoria que
      **también borre lógicamente**. Si el falso borrara de verdad, la prueba
      pasaría con un comportamiento que el sistema real no tiene.

```powershell
docker compose exec api-mapa php pruebas/prueba_capas.php
```

## Fase 8 — LA PANTALLA (la otra mitad de la versión)

- [ ] `front_php/cliente_api.php`: una función por operación, y **cero** PDO.
- [ ] `front_php/index.php` con las pantallas y **el `return false`** para los
      archivos estáticos.
- [ ] `vistas/`: el marco, el inicio, el listado, el formulario y el 404.
- [ ] Bootstrap **descargado** en `publico/`, no por CDN.
- [ ] Los dos botones de guardar, que mandan cuerpos distintos.

**Verificación:**

```powershell
python pruebas_humo/humo_front.py
```

## Fase 9 — Cerrar

- [ ] La colección de Postman, en el orden del quickstart.
- [ ] El [9_checklist.md](9_checklist.md), **firmado por una persona**. El
      guion comprueba que responda; que se entienda lo comprueba alguien.
