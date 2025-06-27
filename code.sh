#!/bin/bash

mkdir -p hello-java-app/src/main/java/com/example && \
cd hello-java-app && \
cat > pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>hello-java-app</artifactId>
  <version>0.0.1</version>
  <packaging>jar</packaging>
  <properties>
    <java.version>11</java.version>
    <spring.boot.version>2.7.5</spring.boot.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
      <version>${spring.boot.version}</version>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > src/main/java/com/example/HelloApplication.java << 'EOF'
package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController
public class HelloApplication {
  public static void main(String[] args) {
    SpringApplication.run(HelloApplication.class, args);
  }

  @GetMapping("/")
  public String hello() {
    return "Hello from Jenkins + Docker!";
  }
}
EOF

cat > Dockerfile << 'EOF'
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

cat > Jenkinsfile << 'EOF'
pipeline {
  agent any
  stages {
    stage('Clone') {
      steps {
        // Already in workspace
      }
    }
    stage('Build') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }
    stage('Docker Build') {
      steps {
        sh 'docker build -t hello-java-app .'
      }
    }
    stage('Run Docker') {
      steps {
        sh 'docker run -d -p 8080:8080 hello-java-app'
      }
    }
  }
}
EOF

echo "Project setup complete. You can now commit to GitHub or use Jenkins to run."
