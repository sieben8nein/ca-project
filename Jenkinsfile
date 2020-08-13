def remote = [:]
remote.name = "ubuntu"
remote.host = "34.78.27.10"
remote.allowAnyHosts = true

pipeline {
  agent any
  environment {
    docker_username = 'sieben8nein'
  }

  stages {
    stage('HelloWorld') {
      steps {
        sh 'echo "hello world"'
      }
    }
    stage('Clone down') {
      steps {
        stash(excludes: '.git', name: 'code')
      }
    }
    stage('Test'){
      steps{
        unstash 'code'
        sh 'apt-get update && apt-get install -y python3-pip'
        sh 'pip3 install -r app/requirements.txt'
        sh 'python3 tests.py'
      }
    }
    stage("Dockerize"){
      environment {
        DOCKERCREDS = credentials('docker_login') //use the credentials just created in this stage
      }
      steps{
        unstash 'code'
        sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin'
        sh 'docker build -t $docker_username/devopsproject .'
        stash(name: 'image')
      }
    }
    stage("Push docker image"){
      environment {
        DOCKERCREDS = credentials('docker_login') //use the credentials just created in this stage
      }
      steps{
        unstash 'image'
        sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin'
        sh 'docker push $docker_username/devopsproject'
      }
    }
    
    withCredentials([sshUserPrivateKey(credentialsId: 'ubuntu', keyFileVariable: 'identity', passphraseVariable: '', usernameVariable: 'userName')]) {
        remote.user = userName
        remote.identityFile = identity
        stage("deploy to test env") {
            writeFile file: 'abc.sh', text: 'ls'
            sshCommand remote: remote, command: 'for i in {1..5}; do echo -n \"Loop \$i \"; date ; sleep 1; done'
        }
    }
  }
}