pipeline {
    agent any
    stages {
        stage('SonarQube Analysis') {
            steps {
                sh 'sonar-scanner -Dsonar.projectKey=myproject'
            }
        }
        stage('Docker Build') {
            steps {
                sh 'docker build -t myapp:latest .'
            }
        }
        stage('Trivy Scan') {
            steps {
                sh 'trivy image myapp:latest'
            }
        }
        stage('Deploy Locally') {
            steps {
                sh 'docker run -d -p 8080:8080 myapp:latest'
            }
        }
        stage('OWASP ZAP Scan') {
            steps {
                sh 'zap-cli quick-scan --self-contained http://localhost:8080'
            }
        }
    }
}
