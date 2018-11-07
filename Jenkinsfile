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
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import up -d'
            }
        }

        stage('Validate docker env') {
            steps {
                sh 'docker ps | grep "${JOB_NAME}_import_db"'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import exec -T db printenv'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import exec -T db bash -c "printenv"'
            }
        }

        stage('Wait for import completion') {
            steps {
                sh 'chmod +x ${WORKSPACE}/wait-for-it.sh'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import exec -T db bash -c "chmod +x /tmp/wait-for-it.sh && /tmp/wait-for-it.sh --timeout=30 --host=localhost --port=3306"'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import exec -T db chmod -R 0777 /var/lib/mysql'
            }
        }

        stage('Validate output') {
            steps {
                sh 'rm -f ${WORKSPACE}/examples/01-simple/export/*.sql'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import exec -T db sh -c "/usr/bin/mysqldump -uroot -proot --skip-dump-date mysql user" > ${WORKSPACE}/examples/01-simple/export/mysql-users.sql'
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import exec -T db sh -c "/usr/bin/mysqldump -uroot -proot --skip-dump-date test01" > ${WORKSPACE}/examples/01-simple/export/test01.sql'

                sh 'diff ${WORKSPACE}/examples/01-simple/export/mysql-users.sql ${WORKSPACE}/examples/01-simple/test/mysql-users.sql'
                sh 'diff ${WORKSPACE}/examples/01-simple/export/test01.sql ${WORKSPACE}/examples/01-simple/test/test01.sql'
            }
        }

        stage('Stop docker env') {
            steps {
                sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import stop'
            }
        }

        stage('Build data container') {
            steps {
                sh 'rm -rf ${WORKSPACE}/etc/data'
                sh 'mv ${WORKSPACE}/data ${WORKSPACE}/etc/'

                sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build build'
            }
        }

        stage('Start data container') {
            steps {
                sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build up -d'
            }
        }

        stage('Validate preloaded output') {
            steps {
                sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build exec -T db-preloaded bash -c "chmod +x /tmp/wait-for-it.sh && /tmp/wait-for-it.sh --timeout=30 --host=localhost --port=3306"'

                sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build exec -T db-preloaded sh -c "/usr/bin/mysqldump -uroot -proot --skip-dump-date mysql user" > ${WORKSPACE}/examples/01-simple/export/mysql-users_PRELOADED.sql'
                sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build exec -T db-preloaded sh -c "/usr/bin/mysqldump -uroot -proot --skip-dump-date test01" > ${WORKSPACE}/examples/01-simple/export/test01_PRELOADED.sql'

                sh 'diff ${WORKSPACE}/examples/01-simple/export/mysql-users_PRELOADED.sql ${WORKSPACE}/examples/01-simple/test/mysql-users.sql'
                sh 'diff ${WORKSPACE}/examples/01-simple/export/test01_PRELOADED.sql ${WORKSPACE}/examples/01-simple/test/test01.sql'
            }
        }

        stage('Stop data container') {
            steps {
                sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build stop'
            }
        }

        stage('Push data container to registry') {
            steps {
                sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build push'
            }
        }
        
        stage('Start test container') {
            steps {
                sh 'docker-compose -f docker-compose.03-test.yml -p ${JOB_NAME}_test up -d'
            }
        }

        stage('Validate test output') {
            steps {
                sh 'docker-compose -f docker-compose.03-test.yml -p ${JOB_NAME}_test exec -T db-preloaded bash -c "chmod +x /tmp/wait-for-it.sh && /tmp/wait-for-it.sh --timeout=30 --host=localhost --port=3306"'

                sh 'docker-compose -f docker-compose.03-test.yml -p ${JOB_NAME}_test exec -T db-preloaded sh -c "/usr/bin/mysqldump -uroot -proot --skip-dump-date mysql user" > ${WORKSPACE}/examples/01-simple/export/mysql-users_TEST.sql'
                sh 'docker-compose -f docker-compose.03-test.yml -p ${JOB_NAME}_test exec -T db-preloaded sh -c "/usr/bin/mysqldump -uroot -proot --skip-dump-date test01" > ${WORKSPACE}/examples/01-simple/export/test01_TEST.sql'

                sh 'diff ${WORKSPACE}/examples/01-simple/export/mysql-users_TEST.sql ${WORKSPACE}/examples/01-simple/test/mysql-users.sql'
                sh 'diff ${WORKSPACE}/examples/01-simple/export/test01_TEST.sql ${WORKSPACE}/examples/01-simple/test/test01.sql'
            }
        }

        stage('Stop test container') {
            steps {
                sh 'docker-compose -f docker-compose.03-test.yml -p ${JOB_NAME}_test stop'
            }
        }
    }

    post {
        failure {
            sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import logs db'
            sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import exec -T db chmod -R 0777 /var/lib/mysql'
            sh 'docker-compose -f docker-compose.01-import.yml -p ${JOB_NAME}_import stop'

            sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build logs db-preloaded'
            sh 'docker-compose -f docker-compose.02-build.yml -p ${JOB_NAME}_build stop'
            
            sh 'docker-compose -f docker-compose.03-test.yml -p ${JOB_NAME}_test logs db-preloaded'
            sh 'docker-compose -f docker-compose.03-test.yml -p ${JOB_NAME}_test stop'

            //mail to: support@deubert.it, subject: 'The Pipeline failed :('
        }
        always {
            sh 'rm -rf data'
        }
    }
}