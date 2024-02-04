pipeline {
    agent {
        node {
            label 'built-in'
        }

    }
    stages {
        stage('clone code') {
            steps {
                
                    git(url: 'https://github.com/ahuoze/CICD_TEST.git', credentialsId: "$GITHUB_CREDENTIAL_ID", branch: "$BRANCH_NAME", changelog: true, poll: false)
                

            }
        }

        stage('unit test') {
            steps {
                
                    sh 'mvn clean test'
                

            }
        }

        stage('sonarqube analysis') {
            steps {
                withCredentials([string(credentialsId : "$SONARKUBE_CREDENTIAL_ID" ,variable : 'SONAR_TOKEN' ,)]) {
                    withSonarQubeEnv("$SONARKUBE_SERVER") {
                        
                            sh '''mvn sonar:sonar -Dsonar.projectKey=$APP_NAME'''
                        

                    }

                    timeout(unit: 'MINUTES', activity: true, time: 5) {
                        waitForQualityGate 'true'
                    }

                }

            }
        }

        stage('build & push') {
            steps {
                
                    sh 'mvn clean package -DskipTests'
                    sh 'docker build -f Dockerfile -t $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BUILD_NUMBER .'
                    withCredentials([usernamePassword(credentialsId : "$ALIYUN_PASS" ,passwordVariable : 'DOCKER_PASSWORD' ,usernameVariable : 'DOCKER_USERNAME' ,)]) {
                        sh '''echo "$DOCKER_PASSWORD" | docker login $REGISTRY -u "$DOCKER_USERNAME" --password-stdin
docker push $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BUILD_NUMBER'''
                    

                }

            }
        }

        stage('push latest') {
            when {
                branch 'master'
            }
            steps {
                
                    sh 'docker tag $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BUILD_NUMBER $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:latest'
                    sh 'docker push $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:latest'
                

            }
        }

        stage('deploy to dev') {
            steps {
                
                    input(id: 'deploy-to-dev', message: 'deploy to dev?')
//                        sh 'mkdir -p ~/.kube/'
//                        sh 'echo "$ADMIN_KUBECONFIG" > ~/.kube/config'
                        sh '''sed -i\'\' "s#REGISTRY#$REGISTRY#" deploy/cicd-demo-dev.yaml
sed -i\'\' "s#DOCKERHUB_NAMESPACE#$DOCKERHUB_NAMESPACE#" deploy/cicd-demo-dev.yaml
sed -i\'\' "s#APP_NAME#$APP_NAME#" deploy/cicd-demo-dev.yaml
sed -i\'\' "s#BUILD_NUMBER#$BUILD_NUMBER#" deploy/cicd-demo-dev.yaml
kubectl apply -f deploy/cicd-demo-dev.yaml'''

            }
        }

        stage('push with tag') {
            agent none
            when {
                expression {
                    params.TAG_NAME =~ /v.*/
                }

            }
            steps {
                input(message: 'release image with tag?', submitter: '')
//                withCredentials([usernamePassword(credentialsId : 'gitlab-user-pass' ,passwordVariable : 'GIT_PASSWORD' ,usernameVariable : 'GIT_USERNAME' ,)]) {
//                    sh 'git config --global user.email "liugang@wolfcode.cn" '
//                    sh 'git config --global user.name "xiaoliu" '
//                    sh 'git tag -a $TAG_NAME -m "$TAG_NAME" '
//                    sh 'git push http://$GIT_USERNAME:$GIT_PASSWORD@$GIT_REPO_URL/$GIT_ACCOUNT/k8s-cicd-demo.git --tags --ipv4'
//                }

                
                    sh 'docker tag $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BUILD_NUMBER $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:$TAG_NAME'
                    sh 'docker push $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:$TAG_NAME'
                

            }
        }

        stage('deploy to production') {
            agent none
            when {
                expression {
                    params.TAG_NAME =~ /v.*/
                }

            }
            steps {
                input(message: 'deploy to production?', submitter: '')
                
                    sh '''sed -i\'\' "s#REGISTRY#$REGISTRY#" deploy/cicd-demo.yaml
sed -i\'\' "s#DOCKERHUB_NAMESPACE#$DOCKERHUB_NAMESPACE#" deploy/cicd-demo.yaml
sed -i\'\' "s#APP_NAME#$APP_NAME#" deploy/cicd-demo.yaml
sed -i\'\' "s#TAG_NAME#$TAG_NAME#" deploy/cicd-demo.yaml

kubectl apply -f deploy/cicd-demo.yaml'''
                

            }
        }

    }
    environment {
        REGISTRY = 'registry.cn-hangzhou.aliyuncs.com'
//        GIT_REPO_URL = '192.168.113.121:28080'
//        GIT_CREDENTIAL_ID = 'gitlab-user-pass'
        KUBECONFIG_CREDENTIAL_ID = '0d0cf0ae-313b-4cb0-bea4-1b6f48b752f8'
        SONARKUBE_CREDENTIAL_ID = 'sonarqube-token'
        SONARKUBE_SERVER = 'sonarqube'
        ALIYUN_CREDENTIAL_ID = 'aliyun-token'
        ALIYUN_PASS = 'aliyun-token'
        GITHUB_CREDENTIAL_ID = 'github-token'
        DOCKERHUB_NAMESPACE = 'chr-image'
        GITHUB_ACCOUNT = 'root'
        APP_NAME = 'cicd-test'
    }
    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'master', description: '请选择要发布的分支')
        string(name: 'TAG_NAME', defaultValue: 'snapshot', description: '标签名称，必须以 v 开头，例如：v1、v1.0.0')
    }
}
