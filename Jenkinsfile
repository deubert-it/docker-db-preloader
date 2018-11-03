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
                    userRemoteConfigs: [[credentialsId: 'ssh-jenkins-master', url: 'https://kdeubert@stash.deubert.it/scm/doc/db-databuilder.git']]
                ])
            }
        }

        stage('Build docker env') {
            steps {
                sh 'docker-compose -f docker-compose.yml build'
            }
        }

        stage('Set Dotenv config') {
            steps {
                sh 'cp .env.dist .env'
            }
        }

        stage('Start docker env') {
            steps {
                sh 'docker-compose -f docker-compose.yml -p ${JOB_NAME} up -d'
            }
        }

        stage('Validate output') {
            steps {
                echo "not implemented yet"
            }
        }

        stage('Stop docker env') {
            steps {
                sh 'docker-compose -f docker-compose.yml -p ${JOB_NAME} stop'
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
            sh 'docker-compose -f docker-compose.yml -p ${JOB_NAME} stop'
            //mail to: support@deubert.it, subject: 'The Pipeline failed :('
        }
    }
}