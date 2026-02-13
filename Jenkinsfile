pipeline {
    // agent { label 'java' }
    agent any
    parameters {
        string(name: 'mcd1', defaultValue: '', description: 'Enter your name')
        booleanParam(name: 'Boolean', defaultValue: true, description: 'Enable or disable')
        choice(name: 'mcd2', choices: ['install', 'package', 'compile'], description: 'select the choice')
    }
    stages {
        stage('checkout') {
            // agent { label 'java' }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: '069fddf1-c2cf-4262-9172-5bb4cfbd94c7',
                    usernameVariable: 'admin',
                    passwordVariable: 'admin_password'
                ),
                    sshUserPrivateKey(
    credentialsId: '170dadeb-9b7a-43b8-8d8b-9a50dcab1833',
    keyFileVariable: 'KEY_FILE',
    usernameVariable: 'SSH_USER'
               )
    ]) {
                    sh "rm -rf hello-world-war"
                    sh "git clone https://${admin}:${admin_password}@github.com/pradeepreddy-hub/hello-world-war.git"
                }
            }
        }
        stage ('build') {
            steps {
                sh "mvn ${params.mcd1} ${params.mcd2}"
            }
        }
        stage ('deploy') {
            steps {
                sh "sudo cp ${env.WORKSPACE}/target/hello-world-war-1.0.1.war /opt/apache-tomcat-10.1.49/webapps/"
            }
        }
    }
}
