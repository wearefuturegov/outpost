# Base image declaration
FROM nginx:1.20.2-alpine as base_image

# Development image declaration
FROM base_image as development
ARG PROJECT_NAME=$PROJECT_NAME
COPY ./environment/containers/nginx/config/nginx-dev.conf /etc/nginx/conf.d/default.conf
RUN sed -i -r "s/PROJECT_NAME.localhost;/${PROJECT_NAME}.localhost;/g" /etc/nginx/conf.d/default.conf \
    && chmod 644 /etc/nginx/conf.d/default.conf

