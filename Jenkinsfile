pipeline {
    agent any

    environment {
        IMAGE_NAME   = "pradeepreddyhub/hello-world-war"
        IMAGE_TAG    = "latest"
        DOCKER_CREDS = "dockerhub-creds"
        CONTAINER_NAME = "hello-world-war-container"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/pradeepreddy-hub/Jenkins_docker_hello-world-war.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    # Stop and remove existing container if it exists
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    # Run container in detached mode
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p 5050:8080 \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }
}
