pipeline {
    agent any

    stages {
        stage('Cleanup') {
            steps {
                sh 'docker rm -f secopstodo || true'
            }
        }

        stage('Docker Build') {
            steps {
                // Build from repo root where Dockerfile + backend + frontend exist
                sh "docker build -t secopstodo:latest -f SecOpsToDo_Final/Dockerfile SecOpsToDo_Final"
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
                    sh '''
                    ssh -o StrictHostKeyChecking=no admin@35.154.141.97 "
                        docker rm -f secopstodo || true &&
                        docker run -d --name secopstodo -p 8081:8080 secopstodo:latest
                    "
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def retries = 10
                    def success = false
                    for (int i = 0; i < retries; i++) {
                        try {
                            sh 'curl -s --fail http://35.154.141.97:8081 > /dev/null'
                            success = true
                            break
                        } catch (Exception e) {
                            echo "Health check failed, retrying in 15s..."
                            sleep 15
                        }
                    }
                    if (!success) {
                        error("SecOpsToDo app did not respond on port 8081")
                    }
                }
            }
        }
    }
}
