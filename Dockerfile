#stage 1
#Start with a base image containing Java runtime
FROM openjdk:11-slim as build

# Add Maintainer Info
LABEL maintainer="sbzorro"

# The application's jar file
# ARG JAR_FILE

# Add the application's jar to the container
COPY /target/*.jar /app.jar

#unpackage jar file
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf /app.jar)

#stage 2
#Same Java runtime
FROM openjdk:11-slim

#Add volume pointing to /tmp
VOLUME /tmp

#Copy unpackaged application to new container
ARG DEPENDENCY=/target/dependency

COPY --from=build ${DEPENDENCY}/BOOT-INF/lib 		/app/lib
COPY --from=build ${DEPENDENCY}/META-INF 			/app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes 	/app

HEALTHCHECK --start-period=30s --interval=5s --timeout=3000s CMD curl -f http://localhost:$PORT/actuator/health || exit 1

#execute the application
ENTRYPOINT ["java","-cp","app:app/lib/*","com.github.sbzorro.configserver.ConfigserverApplication"]

EXPOSE 8071
