pipeline {
    agent any

    triggers {
        // Poll SCM disabled; webhook will trigger builds
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull latest code from GitHub
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Building project..."
                sh 'echo Hello, Jenkins Build!'
            }
        }

        stage('Test') {
            steps {
                echo "Running tests..."
                sh 'echo Tests passed!'
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploy stage triggered..."
                sh 'echo Deployment successful!'
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
