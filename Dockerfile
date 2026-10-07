# Stage 1: Build stage
FROM maven:3.9-eclipse-temurin-21-alpine AS builder
WORKDIR /workspace

# Copy dependency definition first for optimal layer caching
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy source code and build clean artifact
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Minimal, hardened production runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Hardening: Run as least-privileged non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Hardening: Copy only compiled binary from builder stage
COPY --from=builder /workspace/target/*.jar app.jar
RUN chown -R appuser:appgroup /app

USER appuser

# Only expose the necessary application port
EXPOSE 8080

# Hardening: Explicit entrypoint array syntax without shell wrapping
ENTRYPOINT ["java", "-jar", "app.jar"]
