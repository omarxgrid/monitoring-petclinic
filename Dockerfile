# Stage 1: Build the application using Maven
FROM maven:3.8.4-openjdk-17-slim AS build
WORKDIR /app

# Copy the pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package

# Stage 2: Create the final Docker image with the built JAR file
FROM openjdk:17-slim
WORKDIR /app

# Copy the JAR file and the JMX Prometheus agent
COPY --from=build /app/target/*.jar app.jar
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.1/jmx_prometheus_javaagent-0.16.1.jar /app/jmx_prometheus_javaagent.jar

# Add the configuration file for JMX Exporter
COPY jmx_exporter_config.yaml /app/jmx_exporter_config.yaml

# Expose the application port and JMX metrics port
EXPOSE 8083 5555

# Run the JAR file with the Java Agent for JMX exporter
ENTRYPOINT ["java", "-javaagent:/app/jmx_prometheus_javaagent.jar=5555:/app/jmx_exporter_config.yaml", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar", "--server.port=8083"]
