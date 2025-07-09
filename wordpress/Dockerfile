FROM wordpress:php8.4-fpm-alpine

# Instala extensión PHP Redis y herramientas adicionales
RUN apk add --no-cache \
    php-pecl-redis \
    bash \
    curl \
  && rm -rf /var/cache/apk/*

# Exponer el socket de PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
