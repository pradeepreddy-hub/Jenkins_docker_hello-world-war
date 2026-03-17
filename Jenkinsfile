pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins

  volumes:
  - name: workspace-volume
    emptyDir: {}
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock

  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent

  - name: maven
    image: pradeepreddyhub/jenkins-image:v1
    command: ['cat']
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent
    - name: docker-sock
      mountPath: /var/run/docker.sock

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent
"""
        }
    }

    environment {
        IMAGE   = "docker.io/pradeepreddyhub/hello-world"
        TAG     = "${BUILD_NUMBER}"
        CHART   = "hello-world"
        VERSION = "0.2.0"
        NS      = "default"

        DOCKER_CREDS = credentials('dockerhub-creds')
        JFROG_CREDS  = credentials('jfrog-creds')
        JFROG_URL    = "https://trial3sfswa.jfrog.io/artifactory/jenkins-helm"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/pradeepreddy-hub/Jenkins_docker_hello-world-war.git'
            }
        }

        stage('Build & Push Image') {
            steps {
                container('maven') {
                    sh """
                    docker build -t $IMAGE:$TAG .
                    echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin
                    docker push $IMAGE:$TAG
                    docker tag $IMAGE:$TAG $IMAGE:latest
                    docker push $IMAGE:latest
                    """
                }
            }
        }

        stage('Helm Package & Upload') {
            steps {
                container('maven') {
                    sh """
                    helm package $CHART

                    curl -u $JFROG_CREDS_USR:$JFROG_CREDS_PSW \
                      -T ${CHART}-${VERSION}.tgz \
                      $JFROG_URL/${CHART}-${VERSION}.tgz

                    helm repo index . --url $JFROG_URL

                    curl -u $JFROG_CREDS_USR:$JFROG_CREDS_PSW \
                      -T index.yaml \
                      $JFROG_URL/index.yaml
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                container('maven') {
                    sh """
                    helm repo add jfrog-helm $JFROG_URL \
                      --username $JFROG_CREDS_USR \
                      --password $JFROG_CREDS_PSW \
                      --force-update

                    helm repo update

                    helm upgrade --install $CHART jfrog-helm/$CHART \
                      --version $VERSION \
                      --set image.tag=$TAG \
                      -n $NS --wait
                    """
                }
            }
        }

        stage('Verify') {
            steps {
                container('kubectl') {
                    sh """
                    kubectl rollout status deployment/$CHART -n $NS
                    kubectl get pods -n $NS -l app=$CHART
                    kubectl get svc $CHART -n $NS
                    """
                }
            }
        }
    }

    post {
        always {
            container('maven') {
                sh "docker rmi $IMAGE:$TAG || true"
                sh "docker rmi $IMAGE:latest || true"
            }
        }
    }
}
