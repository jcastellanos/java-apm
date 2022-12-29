FROM gradle:7.4.2-jdk17-alpine as BUILD
WORKDIR /home/gradle/src
COPY . .
RUN gradle build --no-daemon
# Start with a base image containing Java runtime
FROM amazoncorretto:17-alpine
VOLUME /tmp
# Installing APM agent
RUN apk --no-cache add curl
RUN curl -L "https://search.maven.org/remotecontent?filepath=co/elastic/apm/elastic-apm-agent/1.34.1/elastic-apm-agent-1.34.1.jar" -o /elastic-apm-agent.jar
# Copy app
COPY --from=build /home/gradle/src/build/libs/java-apm.jar java-apm.jar
# Make port 8080 available to the world outside this container
# EXPOSE 8080
ENV JAVA_OPTS=" -XX:+UseContainerSupport -XX:MaxRAMPercentage=70 -Djava.security.egd=file:/dev/./urandom"
ENTRYPOINT [ "sh", "-c", "java -javaagent:/elastic-apm-agent.jar $JAVA_OPTS +-jar java-apm.jar" ]