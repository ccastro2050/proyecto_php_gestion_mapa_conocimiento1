# Módulo de Mapa de conocimiento — versión 1, en PHP

El módulo de **mapa de conocimiento** del proyecto de aula, construido en
**PHP puro sobre MariaDB**, con su pantalla propia. Un solo comando lo
levanta entero.

```powershell
docker compose up -d --build
```

| Dónde mirar | Dirección |
|---|---|
| **La pantalla** — empiece por aquí | **http://localhost:8116** |
| La API — diagnóstico | http://localhost:8117/ |
| La API — el listado | http://localhost:8117/api/proyecto |
| phpMyAdmin (mirar la base por dentro) | http://localhost:8108 |
| MariaDB (HeidiSQL, DBeaver…) | `localhost:13333` · usuario `mapa` |

## Qué trae la v1

El CRUD completo de **`proyecto`** de punta a punta: enrutador,
controlador, servicio, repositorio, interfaces, modelo, la pantalla y una
prueba que corre **sin base de datos**.

**La tabla arranca con 14 filas**, así que la pantalla
tiene qué mostrar desde el primer arranque. De dónde salió cada columna está
escrito en `db/init.sql`, encima del `INSERT`.

Y el **borrado es lógico**: retirar una ficha la marca `activo = FALSE` y la
saca de los listados, pero **la fila se queda en la base**. El paso 5 del
[quickstart](docs/spec_kit/versiones/v1_proyecto/7_quickstart.md) trae la
consulta que la encuentra ahí.

### La ficha

| Campo | Tipo | |
|---|---|---|
| `id` | entero | obligatorio |
| `titulo` | texto (70) | obligatorio |
| `resumen` | texto (256) | obligatorio |
| `presupuesto` | número | obligatorio |
| `tipo_financiacion` | texto (45) | obligatorio |
| `tipo_fondos` | texto (45) | obligatorio |
| `fecha_inicio` | fecha | obligatorio |
| `fecha_fin` | fecha | opcional |

## El gemelo en Python

Este mismo módulo, con el mismo contrato sobre la misma tabla, está también
en [`proyecto_paradigmas_mapa_conocimiento1`](../proyecto_paradigmas_mapa_conocimiento1) — pero en
**Python con FastAPI sobre PostgreSQL**. Los dos se pueden levantar al
tiempo, en puertos distintos, y compararse pantalla contra pantalla.

No es repetición por repetición: es el material con el que se ve **qué parte
del diseño era del lenguaje y qué parte era del diseño**. Un ejemplo
concreto, que se puede comprobar en dos minutos: FastAPI valida sin que uno
escriba un `if`, y a cambio envuelve todos sus errores en `{"detail": …}` y
los redacta en inglés. Aquí cada validación es un `if` escrito a mano, y a
cambio el sobre del error sale **exactamente como lo documenta el contrato**,
en español.

## El árbol

```
api_mapa/                     LA API: PHP puro + PDO
├── index.php                    el front controller: ruta → método del controlador
├── controladores/               HTTP: valida la forma, traduce a códigos
├── servicios/                   las reglas + el ensamblador (el único `new`)
├── repositorios/                el SQL, en prepared statements
├── modelos/                     la fila como objeto
├── excepciones/                 las de negocio, sin HTTP adentro
└── pruebas/prueba_capas.php     el servicio SIN base de datos

front_php/                       LA PANTALLA: PHP + Bootstrap descargado
├── index.php                    el front controller del front
├── cliente_api.php              lo ÚNICO que habla HTTP con la API
├── vistas/                      el marco y las pantallas
└── publico/                     Bootstrap y los estilos, servidos del disco

db/init.sql                      las 21 tablas + las semillas, derivado del script del curso
docs/ARRAYS_Y_SUPERGLOBALES.md   arreglos y superglobales, con el código de aquí
docs/spec_kit/                   la constitución y los documentos de la v1
postman/                         la colección, en el orden del quickstart
pruebas_humo/humo_front.py       el recorrido completo desde la pantalla
ProyectosDeAula/                 el material que entrega el curso
```

## Las pruebas

```powershell
# 1. El servicio, sin base de datos (polimorfismo e inversión de dependencias)
docker compose exec api-mapa php pruebas/prueba_capas.php

# 2. El recorrido completo desde la PANTALLA, con los mismos POST del navegador
python pruebas_humo/humo_front.py
```

La segunda apaga la API a propósito y comprueba que la pantalla siga en pie
**sin un solo dato**. Es la prueba de que son dos procesos y no uno.

## Documentación

| | |
|---|---|
| [Constitución](docs/spec_kit/1_constitution.md) | Las reglas que no cambian entre versiones |
| [Mapa de versiones](docs/spec_kit/versiones/0_mapa_versiones.md) | Qué trae cada una |
| [Especificación de la v1](docs/spec_kit/versiones/v1_proyecto/2_spec.md) | Requisitos y criterios de aceptación |
| [Contratos](docs/spec_kit/versiones/v1_proyecto/6_contracts.md) | Cada ruta con sus desenlaces, incluidos los de error |
| [Quickstart](docs/spec_kit/versiones/v1_proyecto/7_quickstart.md) | Los siete criterios, comprobados a mano |
| [Guía de IA](docs/spec_kit/versiones/v1_proyecto/GUIA_IA1.md) | El prompt para reconstruir esta versión desde cero |
| [Arreglos y superglobales en PHP](docs/ARRAYS_Y_SUPERGLOBALES.md) | Qué es un `array` en PHP y en qué se diferencia del de Java; el CRUD sobre un arreglo; las funciones de arreglo que este proyecto usa, con el conteo real; y las superglobales —`$_GET`, `$_POST`, `$_SERVER`, `$_SESSION`— con la línea del proyecto donde aparece cada una |
| [Metodología del curso](ProyectosDeAula/docs/0_METODOLOGIA.md) | El documento que manda sobre todo lo demás |

## Material conceptual del curso

Los conceptos del curso, **con el código de este repositorio como material**: los ejemplos hablan de `proyecto`, no de un proyecto de otro módulo.

| Documento | Qué cubre |
|---|---|
| [Flujo de una peticion](docs/FLUJO_DE_UNA_PETICION.md) | El viaje completo de una petición por las capas, de la ruta al SQL y de vuelta |
| [Paradigma poo](docs/PARADIGMA_POO.md) | Qué es un paradigma, los cuatro pilares de la P.O.O., y dónde vive cada paradigma en este proyecto |
| [Solid capas patrones](docs/SOLID_CAPAS_PATRONES.md) | Los cinco principios SOLID y las tres capas — con el archivo de este repositorio donde se ve cada uno |
| [Principios acid](docs/PRINCIPIOS_ACID.md) | Las cuatro garantías transaccionales, cada una señalada en el código y en la base de ESTE módulo |
| [Arrays y superglobales](docs/ARRAYS_Y_SUPERGLOBALES.md) | Qué es un `array` en PHP, el CRUD sobre un arreglo, y las superglobales con la línea de este repositorio donde aparece cada una |
| [Programacion asincronica](docs/PROGRAMACION_ASINCRONICA.md) | Qué resuelve el asincronismo en la web, qué se daña sin él, y cómo se ve en este código |
| [Conceptos docker](docs/CONCEPTOS_DOCKER.md) | Imagen, contenedor, volumen y compose, con el `docker-compose.yml` de aquí explicado línea por línea |
| [Calidad de pruebas](docs/PRUEBAS_Y_CALIDAD_DE_PRUEBAS.md) | Cobertura, la métrica CRAP y las pruebas de mutación: cómo saber si sus pruebas de verdad protegen |
| [Sdd speckit](docs/SDD_SPECKIT.md) | La metodología con la que se trabaja este curso: la especificación manda sobre el código |

> Los tutoriales de administración de la base de datos (pgAdmin, SSMS, phpMyAdmin, SQLTools) **no están todavía**: llevan capturas de pantalla que hay que tomar contra la base de este módulo.

---

## La identidad visual

Este proyecto se construye para la **Universidad Monte Verde**, una
institución **inventada para el curso**, que tiene su manual de marca como lo
tendría cualquier organización real.

| Archivo | Qué es |
|---|---|
| [`MANUAL_DE_MARCA.md`](MANUAL_DE_MARCA.md) | El Manual de Identidad Visual Corporativa: logosímbolo, paleta, tipografía, tamaño mínimo, área de reserva y usos incorrectos |
| [`docs/CONCEPTOS_IDENTIDAD_VISUAL.md`](docs/CONCEPTOS_IDENTIDAD_VISUAL.md) | Qué es una identidad visual, por qué obliga al software y cómo se calcula el contraste — con referencias verificables |
| [`front_php/publico/marca.css`](front_php/publico/marca.css) | Los valores del manual, en un archivo aparte de los estilos de la aplicación |
| [`marca/`](marca/) | El logosímbolo en sus cuatro versiones |

**Los colores no se cambian.** El artículo tercero de la resolución que
adopta el manual es explícito, y la **versión 4** del proyecto evalúa que la
pantalla lo cumpla.
