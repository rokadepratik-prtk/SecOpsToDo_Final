pipeline {
    agent any

    environment {
        IMAGE_NAME = "glass-todo"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/rokadepratik-prtk/SecOpsToDo_Final.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-local') {
                    script {
                        def scannerHome = tool 'sonar-scanner'
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                          -Dsonar.projectKey=glass-todo \
                          -Dsonar.sources=frontend/src,backend
                        """
                    }
                }
            }
        }

        stage('Trivy Code Scan') {
            steps {
                sh '''
                echo "Running Trivy filesystem scan (non-blocking)"
                trivy fs . \
                  --scanners vuln,secret,config \
                  --severity HIGH,CRITICAL \
                  --timeout 10m \
                  --format json \
                  --output trivy-code-report.json || true
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Docker Run (Test)') {
            steps {
                sh '''
                docker rm -f glass-todo-test || true
                docker run -d --name glass-todo-test -p 5000:5000 $IMAGE_NAME
                sleep 10
                docker ps | grep glass-todo
                '''
            }
        }

        stage('Deploy to App Server (192.168.56.115)') {
            environment {
                APP_HOST = "192.168.56.115"
                APP_USER = "star"
            }
            steps {
                sh '''
                echo "Stopping old container on app server"
                ssh ${APP_USER}@${APP_HOST} "docker rm -f glass-todo || true"

                echo "Transferring image to app server"
                docker save glass-todo | ssh ${APP_USER}@${APP_HOST} docker load

                echo "Running new container on app server"
                ssh ${APP_USER}@${APP_HOST} "
                  docker run -d \
                    --name glass-todo \
                    -p 5000:5000 \
                    glass-todo
                "
                '''
            }
        }

        stage('OWASP ZAP DAST Scan') {
            steps {
                sh '''
                echo "Running OWASP ZAP baseline scan"

                docker run --rm \
                  --user $(id -u jenkins):$(id -g jenkins) \
                  -e HOME=/zap/wrk \
                  -v $(pwd):/zap/wrk \
                  zaproxy/zap-stable \
                  zap-baseline.py \
                  -t http://192.168.56.115:5000 \
                  -r zap-report.html || true
                '''
            }
        }
    }

    post {
        always {
            sh 'docker rm -f glass-todo-test || true'
        }

        success {
            emailext(
                to: 'rokadepratik.m@gmail.com',
                subject: "Jenkins Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                Build SUCCESS 

                Job: ${env.JOB_NAME}
                Build Number: ${env.BUILD_NUMBER}

                View details:
                ${env.BUILD_URL}
                """
            )
        }

        failure {
            emailext(
                to: 'rokadepratik.m@gmail.com',
                subject: "Jenkins Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                Build FAILED 

                Job: ${env.JOB_NAME}
                Build Number: ${env.BUILD_NUMBER}

                Check details here:
                ${env.BUILD_URL}
                """
            )
        }
    }
}
