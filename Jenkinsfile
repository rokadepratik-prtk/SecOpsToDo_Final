pipeline {
    agent any
    stages {
        stage('Docker Build') {
            steps {
                sh "docker build -t secopstodo:latest ."
            }
        }

        stage('Security Scan') {
            steps {
                sh '''
                echo "Running Trivy scan..."
                trivy image --severity HIGH,CRITICAL --format json -o trivy-report.json secopstodo:latest
                '''
                archiveArtifacts artifacts: 'trivy-report.json', fingerprint: true
            }
        }

            stage('Convert Trivy Report') {
                steps {
                    sh 'node trivy-json-to-html.js trivy-report.json trivy-report.html'
                    publishHTML([
                        reportDir: '.',
                        reportFiles: 'trivy-report.html',
                        reportName: 'Trivy Security Report',
                        keepAll: true,
                        alwaysLinkToLastBuild: true,
                        allowMissing: false
                    ])
                }
            }


                    stage('Deploy to VM') {
                steps {
                    sshagent(['vm-ssh-credentials-id']) {
                        sh 'ssh -o StrictHostKeyChecking=no admin@172.31.44.50 "docker ps"'
                    }
                }
            }

    }
}
