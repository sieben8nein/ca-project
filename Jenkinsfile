pipeline {
  agent any
  stages {
    stage('HelloWorld') {
      steps {
        sh 'echo "hello world"'
      }
    }
    stage('clone down') {
      steps {
        stash(excludes: '.git', name: 'code')
      }
    }
    stage('Test'){
      steps{
        unstash 'code'
        sh 'apt-get update && apt-get install pip'
        sh 'pip install -r requirements.txt'
        sh 'python tests.py'
      }
    }
  }
}