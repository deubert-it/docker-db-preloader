pipeline {
    agent any
    stages {
        stage('Preparation') {
            steps {

                sh 'sudo rm -rf ${WORKSPACE}/data'

                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId: 'ssh-jenkins-master', url: 'ssh://git@stash.deubert.it:7999/doc/db-databuilder.git']]
                ])

                sh 'mkdir ${WORKSPACE}/data && chmod 0777 ${WORKSPACE}/data'
            }
        }

        stage('Set Dotenv config') {
            steps {
                sh 'cp .env.dist .env'
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

        stage('Validate docker env') {
            steps {
                sh 'docker ps | grep "${JOB_NAME}_db"'
            }
        }

        stage('Wait for import completion') {
            steps {
                sh 'chmod +x ${WORKSPACE}/wait-for-it.sh'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} exec -T db bash -c "chmod +x /tmp/wait-for-it.sh && /tmp/wait-for-it.sh --timeout=30 --host=localhost --port=3306"'
                sh 'echo fixing permissions now'
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
            sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} exec -T db chmod -R 0777 /var/lib/mysql'
            sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME} stop'
            //mail to: support@deubert.it, subject: 'The Pipeline failed :('
        }
        always {
            sh 'rm -rf data'
        }
    }
}