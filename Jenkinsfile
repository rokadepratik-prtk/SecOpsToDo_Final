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

stage('Security Scan') {
    steps {
        sh '''
        echo "Running Trivy scan..."
        trivy image --severity HIGH,CRITICAL --format table secopstodo:latest > trivy-report.txt
        '''
        archiveArtifacts artifacts: 'trivy-report.txt', fingerprint: true
    }
}


    }
}
