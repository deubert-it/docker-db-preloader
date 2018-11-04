pipeline {
    agent any
    stages {
        stage('Preparation') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId: 'ssh-jenkins-master', url: 'ssh://git@stash.deubert.it:7999/doc/db-databuilder.git']]
                ])
            }
        }

        stage('Set Dotenv config') {
            steps {
                sh 'cp .env.dist .env'
            }
        }

        stage('Build docker env 01') {
            steps {
                sh 'docker-compose -f docker-compose.01-import.yml build'
            }
        }

        stage('Start docker env 01') {
            steps {
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_01 up -d'
            }
        }

        stage('Validate output 01') {
            steps {
                echo "not implemented yet"
            }
        }

        stage('Stop docker env 01') {
            steps {
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_01 stop'
            }
        }



        stage('Push data container to registry') {
            steps {
                echo "not implemented yet"
            }
        }
    }

    post {
        failure {
            sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_01 stop'
            //mail to: support@deubert.it, subject: 'The Pipeline failed :('
        }
    }
}