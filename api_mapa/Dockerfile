# ==============================================================
# API de Mapa de conocimiento v1 — PHP puro (puerto 8117)
#
# El servidor embebido de PHP con index.php como router: todas las
# peticiones pasan por el front controller sin configurar Apache ni
# nginx. En desarrollo el compose monta el código como volumen:
# guardar un .php = refrescar, porque PHP reinterpreta en cada petición.
# ==============================================================
FROM php:8.3-cli

# La extensión PDO para MySQL/MariaDB se compila en el build. Es la que
# el front NO tiene, y esa diferencia es la que hace imposible que la
# pantalla llegue a la base.
RUN docker-php-ext-install pdo_mysql

WORKDIR /app

COPY . .

EXPOSE 8117

CMD ["php", "-S", "0.0.0.0:8117", "index.php"]
