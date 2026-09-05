# ==============================================================
# Front de Mapa de conocimiento v1 — PHP puro (puerto 8116)
#
# El mismo servidor embebido que la API, con index.php como router: todas las
# peticiones pasan por el front controller sin configurar Apache ni nginx.
#
# FÍJESE EN LO QUE NO ESTÁ: no se instala `pdo_mysql`. La API sí lo necesita,
# el front NO — y esa ausencia no es un olvido: es la comprobación de que este
# proceso no puede llegar a MariaDB ni queriendo.
# ==============================================================
FROM php:8.3-cli

WORKDIR /app

COPY . .

EXPOSE 8116

CMD ["php", "-S", "0.0.0.0:8116", "index.php"]
