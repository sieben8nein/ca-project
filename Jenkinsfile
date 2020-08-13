pipeline {
  agent any
  environment {
    docker_username = 'sieben8nein'
  }
  stages {
    stage('Clone down') {
      steps {
        stash(excludes: '.git', name: 'code')
      }
    }
    stage('Test'){
      steps{
        skipDefaultCheckout(true)
        unstash 'code'
        sh 'apt-get update && apt-get install -y python3-pip'
        sh 'pip3 install -r app/requirements.txt'
        sh 'python3 tests.py'
      }
    }
    stage("Dockerize & Archive artifacts") {
      parallel {
        stage("Dockerize") {
          environment {
            DOCKERCREDS = credentials('docker_login') //use the credentials just created in this stage
            }
            steps {
            skipDefaultCheckout(true)
            unstash 'code'
            sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin'
            sh 'docker build -t $docker_username/devopsproject .'
            stash(name: 'image')
          }
        }
      stage("Archive artifacts") {
        steps {
          skipDefaultCheckout(true)
          unstash 'code'
          sh 'apt-get update && apt-get install -y zip unzip'
          sh 'zip -r project_artifact.zip .'
          sh 'ls -l project_artifact.zip'
          archive "project_artifact.zip"
        }
      }
    }
  }
    stage("Push docker image"){
      when{
        branch "master"
      }
      environment {
        DOCKERCREDS = credentials('docker_login') //use the credentials just created in this stage
      }
      steps{
        skipDefaultCheckout(true)
        unstash 'image'
        sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin'
        sh 'docker push $docker_username/devopsproject'
      }
    }
    stage('Deployment to testenv'){ 
      when{
        branch "dev/*"
      } 
      steps {
        skipDefaultCheckout(true)
        unstash 'code'
        sshagent (credentials: ['ubuntu']) {
        
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@34.78.27.10 ls'
        sh "scp docker-compose.yml ubuntu@34.78.27.10:."
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@34.78.27.10 docker-compose up -d'
        sleep(time: 10, unit: "SECONDS")
        sh 'curl 34.78.27.10:5000'
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@34.78.27.10 docker-compose down'
        }
      }
    }
    stage('Deployment to production'){ 
      when{
        branch "master"
      } 
      steps {
        skipDefaultCheckout(true)
        unstash 'code'
        sshagent (credentials: ['ubuntu']) {
        
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@34.78.27.10 ls'
        sh "scp docker-compose.yml ubuntu@34.78.27.10:."
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@34.78.27.10 docker-compose up -d'
        sleep(time: 10, unit: "SECONDS")
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@34.78.27.10 docker-compose down'
        }
      }
    }
  }
}
