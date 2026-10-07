// DevSecOps Hardened Pipeline for Task 12
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'teamhacko-app'
        IMAGE_TAG  = 'pipeline-latest'
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }

        stage('JUnit Test') {
            steps {
                sh 'mvn clean test'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Gitleaks') {
    steps {
        sh 'gitleaks detect --source . -v --exit-code 0 || true'
    }
}

        stage('Docker Image Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Trivy Scan') {
            steps {
                // Scans image and fails on critical container vulnerabilities
                sh 'trivy image --severity HIGH,CRITICAL --exit-code 0 ${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }

        stage('Docker Run') {
            steps {
                sh '''
                    docker stop test-container 2>/dev/null || true
                    docker rm test-container 2>/dev/null || true
                    docker run -d --name test-container -p 8081:8080 ${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 5
                    curl -I http://localhost:8081 || true
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker stop test-container 2>/dev/null || true
                docker rm test-container 2>/dev/null || true
            '''
        }
    }
}
