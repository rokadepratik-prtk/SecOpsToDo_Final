pipeline {
    agent any
    stages {
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeScanner') {
                    script {
                        def scannerHome = tool 'SonarQubeScanner'
                        sh "${scannerHome}/bin/sonar-scanner \
                           -Dsonar.projectKey=SecOpsToDo_Final \
                           -Dsonar.sources=frontend/src,backend \
                           -Dsonar.sourceEncoding=UTF-8"
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t secopstodo:latest ."
            }
        }
    }
}
