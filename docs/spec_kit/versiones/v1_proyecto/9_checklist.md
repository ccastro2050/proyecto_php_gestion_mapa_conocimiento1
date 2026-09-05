# Checklist de cierre — v1: `proyecto` (PHP)

> Esto **no lo pasa un guion**. Las pruebas comprueban que el sistema
> responda; esta lista comprueba que esté bien hecho y que se entienda. La
> firma una persona.

## A. Funciona

- [ ] `docker compose up -d --build` levanta los cuatro servicios y la
      pantalla responde en el 8116.
- [ ] Los **7 criterios** de [2_spec.md](2_spec.md) pasan a mano, con los
      comandos de [7_quickstart.md](7_quickstart.md).
- [ ] Los **7 criterios de pantalla** (P1 a P7) pasan.
- [ ] `pruebas_humo/humo_front.py` termina **en verde**.
- [ ] `php pruebas/prueba_capas.php` termina **en verde**, y se corrió con
      MariaDB **apagada** al menos una vez.

## B. Las capas están de verdad cortadas

- [ ] **Ningún** archivo de `servicios/` menciona HTTP, códigos de estado o
      `$_GET`.
- [ ] **Ningún** archivo fuera de `repositorios/` menciona `PDO` o SQL.
- [ ] `ensamblador.php` es el **único** que hace `new` de una clase concreta.
- [ ] El front **no tiene** `pdo_mysql` en su Dockerfile, ni credenciales de
      base en el compose, ni `depends_on: mariadb`.
- [ ] El front **no hace `require`** de ningún archivo de la API. (Podría: los
      dos están en PHP y en carpetas vecinas. Ése es el punto.)

## C. El contrato y la documentación dicen lo mismo que el código

- [ ] Cada ruta de [6_contracts.md](6_contracts.md) documenta sus desenlaces
      de **ERROR**, no solo el feliz.
- [ ] Los ejemplos del contrato son coherentes entre sí: la llave que se crea
      en el `POST` es la que después se consulta, se reemplaza y se retira.
- [ ] Los comandos de [7_quickstart.md](7_quickstart.md) **se corrieron tal
      como están escritos**, y respondieron lo que dicen que responden.
- [ ] [5_data_model.md](5_data_model.md) dice de dónde salieron las
      14 filas con que arranca la tabla.
- [ ] Cada decisión de [4_research.md](4_research.md) tiene su alternativa
      descartada.

## D. La pantalla habla el idioma del usuario

- [ ] Ni `PUT`, ni `PATCH`, ni `422`, ni `/api/`, ni «MariaDB» aparecen en
      ninguna pantalla.
- [ ] Los dos botones de guardar se llaman **«Guardar la ficha completa»** y
      **«Guardar solo lo que cambié»**.
- [ ] Un error **no borra** lo que la persona había escrito.
- [ ] Sin filas, la pantalla dice «todavía no hay» y ofrece agregar: **vacío
      no es error**.
- [ ] La palabra que se usa es **«retirar»**, no «borrar»: el borrado es
      lógico y decir lo contrario sería mentirle al usuario.

## E. Comparado con el gemelo

- [ ] Se levantaron **los dos al tiempo** y se pusieron pantalla contra
      pantalla.
- [ ] El contrato es el mismo, y las diferencias que hay están **anotadas**
      en [4_research.md](4_research.md) D-v1-5 con su motivo.
- [ ] Alguien puede explicar, sin leer, **qué le costó a cada uno**: dónde el
      framework ahorró trabajo y dónde lo cobró.

---

**Revisó:** ________________________  **Fecha:** ______________

**Lo que quedó anotado para la v2:**

```
```
