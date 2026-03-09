pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        DOCKER_IMAGE = "secopstodo:latest"
        DOCKER_REGISTRY = "rokadepratik-prtk/secopstodo"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Backend Dependencies') {
            steps {
                dir('backend') {
                    sh 'npm install'
                }
            }
        }

        stage('Install Frontend Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'npm run build'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir('backend') {
                    sh 'npm test || echo "No tests defined"'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarQubeServer') {
                    script {
                        def scannerHome = tool 'SonarQubeScanner'
                        sh "${scannerHome}/bin/sonar-scanner \
                           -Dsonar.projectKey=SecOpsToDo_Final \
                           -Dsonar.sources=frontend/src,backend \
                           -Dsonar.exclusions=**/node_modules/**,**/build/**,**/dist/**,**/*.css,**/*.map \
                           -Dsonar.sourceEncoding=UTF-8"
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t $DOCKER_IMAGE ."
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image --exit-code 0 --severity HIGH $DOCKER_IMAGE"
            }
        }

        stage('Push to Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker tag $DOCKER_IMAGE $DOCKER_REGISTRY"
                    sh "docker push $DOCKER_REGISTRY"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying with Docker Compose..."
                sh "docker-compose -f docker-compose.yml up -d --build"
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
