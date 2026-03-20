pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    args: ["$(JENKINS_SECRET)", "$(JENKINS_NAME)"]
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/busybox/cat"]
    tty: true
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
    - name: workspace-volume
      mountPath: /home/jenkins/agent

  - name: tools
    image: dtzar/helm-kubectl:latest
    command: ["cat"]
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent

  volumes:
  - name: kaniko-secret
    secret:
      secretName: dockerhub-secret
      items:
      - key: .dockerconfigjson
        path: config.json
  - name: workspace-volume
    emptyDir: {}
  restartPolicy: Never
'''
        }
    }

    environment {
        DOCKER_IMAGE = "docker.io/pradeepreddyhub/hello-world"
        IMAGE_TAG    = "${BUILD_NUMBER}"

        HELM_CHART   = "hello-world"
        HELM_VERSION = "0.2.${BUILD_NUMBER}"   // 🔥 dynamic version

        JFROG_URL    = "https://trial3sfswa.jfrog.io/artifactory/jenkins-helm"
        KUBE_NS      = "default"

        JFROG_CREDS  = credentials('jfrog-creds')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                url: 'https://github.com/pradeepreddy-hub/Jenkins_docker_hello-world-war.git'
            }
        }

        stage('Build & Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --dockerfile=Dockerfile \
                      --context=/home/jenkins/agent/workspace/hello-world-war \
                      --destination=$DOCKER_IMAGE:$IMAGE_TAG \
                      --destination=$DOCKER_IMAGE:latest \
                      --skip-tls-verify
                    '''
                }
            }
        }

        stage('Helm Package & Push') {
            steps {
                container('tools') {
                    sh '''
                    helm lint $HELM_CHART

                    # 🔥 Update Chart.yaml dynamically
                    sed -i "s/^version:.*/version: ${HELM_VERSION}/" ${HELM_CHART}/Chart.yaml
                    sed -i "s/^appVersion:.*/appVersion: \\"${IMAGE_TAG}\\"/" ${HELM_CHART}/Chart.yaml

                    # 🔥 Update image tag in values.yaml
                    sed -i "s/tag:.*/tag: \\"${IMAGE_TAG}\\"/" ${HELM_CHART}/values.yaml

                    # Package Helm chart
                    helm package $HELM_CHART

                    # Push chart to JFrog
                    curl -u $JFROG_CREDS_USR:$JFROG_CREDS_PSW \
                      -T ${HELM_CHART}-${HELM_VERSION}.tgz \
                      ${JFROG_URL}/${HELM_CHART}-${HELM_VERSION}.tgz

                    # Update repo index
                    helm repo index . --url ${JFROG_URL}

                    curl -u $JFROG_CREDS_USR:$JFROG_CREDS_PSW \
                      -T index.yaml \
                      ${JFROG_URL}/index.yaml
                    '''
                }
            }
        }
    }

    post {
        success { echo "SUCCESS 🚀" }
        failure { echo "FAILED ❌" }
    }
}
