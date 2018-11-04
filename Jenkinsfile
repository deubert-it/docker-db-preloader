pipeline {
    agent any
    stages {
        stage('Preparation') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[$class: 'CleanBeforeCheckout']],
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

        stage('Clean data dir') {
            steps {
                sh 'rm -rf data'
                sh 'mkdir data'
            }
        }

        stage('Build docker env') {
            steps {
                sh 'docker-compose -f docker-compose.01-import.yml build'
            }
        }

        stage('Start docker env') {
            steps {
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} up -d'
            }
        }

        stage('Wait for import completion') {
            steps {
                sh 'chmod +x ${WORKSPACE}/wait-for-it.sh'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} exec -T db /bin/bash /tmp/wait-for-it.sh --timeout=30 --host=localhost --port=3306'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} exec -T db chmod -R 0777 /var/lib/mysql'
            }
        }

        stage('Validate output') {
            steps {
                echo "not implemented yet"
            }
        }

        stage('Stop docker env') {
            steps {
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} stop'
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
            sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} stop'
            //mail to: support@deubert.it, subject: 'The Pipeline failed :('
        }
    }
}