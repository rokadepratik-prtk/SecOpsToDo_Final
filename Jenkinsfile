pipeline {
    agent any

    stages {
        stage('Cleanup') {
            steps {
                sh 'docker rm -f secopstodo || true'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh """
                    /opt/sonar-scanner/bin/sonar-scanner \
                      -Dsonar.projectKey=SecOpsToDo \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=$SONAR_HOST_URL \
                      -Dsonar.login=$SONAR_AUTH_TOKEN
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build --no-cache -t secopstodo:latest -f ${WORKSPACE}/Dockerfile ${WORKSPACE}"
            }
        }

stage('Security Scan - Trivy') {
    steps {
        sh '''
        echo "Running Trivy scan..."
        mkdir -p /var/lib/trivy-cache
        trivy clean --cache-dir /var/lib/trivy-cache || true
        trivy image --cache-dir /var/lib/trivy-cache \
          --severity HIGH,CRITICAL \
          --format json -o trivy-report.json secopstodo:latest
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

        stage('Smoke Test - WAF Proxy') {
            steps {
                sshagent(['vm-ssh-credentials-id']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no admin@35.154.141.97 "
                            for i in {1..5}; do
                                curl -s -o /dev/null -w '%{http_code}' http://localhost:8082/ | grep 200 && exit 0
                                echo 'Waiting for WAF-protected app...'
                                sleep 5
                            done
                            exit 1
                        "
                    '''
                }
            }
        }

stage('OWASP ZAP DAST') {
    steps {
        sshagent(['vm-ssh-credentials-id']) {
            sh '''
                ssh -o StrictHostKeyChecking=no admin@35.154.141.97 "
                    docker pull owasp/zap2docker-stable:2.14.0 &&
                    docker run --rm --network host \
                      -v /home/admin:/zap/wrk/:rw \
                      owasp/zap2docker-stable:2.14.0 \
                      zap-baseline.py -t http://localhost:8082 \
                      -r /zap/wrk/zap-report.html
                "
                scp -o StrictHostKeyChecking=no admin@35.154.141.97:/home/admin/zap-report.html .
            '''
        }
        publishHTML([
            reportDir: '.',
            reportFiles: 'zap-report.html',
            reportName: 'OWASP ZAP Security Report',
            keepAll: true,
            alwaysLinkToLastBuild: true,
            allowMissing: false
        ])
        archiveArtifacts artifacts: 'zap-report.html', fingerprint: true
    }
}

    }
}
