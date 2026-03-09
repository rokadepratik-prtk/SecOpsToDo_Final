pipeline {
    agent any
    stages {
        stage('SonarQube Analysis') { ... }  // same as above

        stage('Docker Build') {
            steps {
                sh "docker build -t secopstodo:latest ."
            }
        }
    }
}
