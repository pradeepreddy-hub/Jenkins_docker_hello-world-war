FROM maven:3.8.2-openjdk-8 AS mavenbuilder
ARG TEST=/var/lib/
WORKDIR ${TEST}
COPY . .
RUN mvn clean package

FROM tomcat:jre8-temurin-focal
ARG TEST=/var/lib
COPY --from=mavenbuilder ${TEST}/target/*.war /usr/local/tomcat/webapps
