FROM eclipse-temurin:8-jre

LABEL org.opencontainers.image.authors="2692387543@qq.com"

RUN mkdir -p /testapp

WORKDIR /testapp

COPY target/*.jar app.jar

ENV TZ=Asia/Shanghai JAVA_OPTS="-Xms128m -Xmx256m"

EXPOSE 8080

CMD java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar