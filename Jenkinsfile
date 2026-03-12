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
                    sh "docker build --no-cache -t secopstodo:latest -f ${WORKSPACE}/Dockerfile ${WORKSPACE}"
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
                        docker run -d --name secopstodo -p 8081:5000 secopstodo:latest
                    "
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def status = sh(script: "ssh -o StrictHostKeyChecking=no admin@35.154.141.97 'docker inspect --format={{.State.Health.Status}} secopstodo'", returnStdout: true).trim()
                    if (status != "healthy") {
                        error("SecOpsToDo container is not healthy: ${status}")
                    }
                }
            }
        }
    }
}
