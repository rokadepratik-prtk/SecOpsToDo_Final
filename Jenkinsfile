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
        # Clear scan cache to avoid lock errors
        trivy clean --scan-cache || true
        # Use a unique cache dir per build to prevent collisions
        trivy image --cache-dir /tmp/trivy-${BUILD_ID} \
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

  stage('Smoke Test') {
    steps {
        sshagent(['admin']) {
            sh '''
                ssh -o StrictHostKeyChecking=no admin@35.154.141.97 \
                "curl -f http://localhost:8081/ || exit 1"
            '''
        }
    }
}


stage('OWASP ZAP Scan') {
    steps {
        sh '''
            echo "Running OWASP ZAP baseline scan..."
            docker run --rm -u root -v $WORKSPACE:/zap/wrk/:rw \
              ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
              -t http://35.154.141.97:8081 \
              -r zap_report.html --autooff -I
        '''
        archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
        publishHTML([
            reportDir: '.',
            reportFiles: 'zap_report.html',
            reportName: 'OWASP ZAP Report',
            keepAll: true,
            alwaysLinkToLastBuild: true,
            allowMissing: false
        ])
    }
}









    }
}
