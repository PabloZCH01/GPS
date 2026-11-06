# Etapa 1: Construcción
FROM gradle:8.5-jdk17 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
# Construye el ejecutable del servidor
RUN gradle :server:installDist --no-daemon

# Etapa 2: Ejecución
FROM openjdk:17-slim
EXPOSE 8080

# Copia los archivos compilados
COPY --from=build /home/gradle/src/server/build/install/server /app/

# Configura el directorio de trabajo y el comando de inicio
WORKDIR /app
CMD ["./bin/server"]
