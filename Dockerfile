# Multi-stage build for security hardening

# Stage 1: Build stage with Java 21
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Minimal hardened runtime stage with Java 21 JRE
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create dedicated non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the compiled JAR artifact from builder
COPY --from=builder /build/target/*.jar app.jar

# Grant ownership to non-root user
RUN chown -R appuser:appgroup /app

# Drop root privileges
USER appuser

# Expose only the application port
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
