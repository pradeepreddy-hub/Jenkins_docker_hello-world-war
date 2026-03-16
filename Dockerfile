FROM maven:3.8.2-openjdk-8 AS builder

WORKDIR /build
COPY . .
RUN mvn clean package

FROM tomcat:9-jre8-temurin

COPY --from=builder /build/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh","run"]
