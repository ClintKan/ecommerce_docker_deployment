pipeline {
  agent any

 environment {
  DOCKER_CREDS = credentials('docker-hub-credentials')
  }

  stages {
    stage('Build') {
      agent any
      steps {
        sh '''#!/bin/bash
          python3.9 -m venv venv
          source venv/bin/activate
          pip install pip --upgrade
          pip install -r backend/requirements.txt
        '''
      }
    }

    stage('Test') {
      agent any
      steps {
        sh '''#!/bin/bash
        source venv/bin/activate
        pip install pytest-django
        pytest backend/account/tests.py --verbose --junit-xml test-reports/results.xml
        '''
      }
    }

    stage('Cleanup') {
      agent { label 'build-node' }
      steps {
        sh '''#!/bin/bash
        echo "Only clean Docker system"
        docker system prune -f
        '''
      }
    }

    stage('Build & Push Images') {
      agent { label 'build-node' }
      steps {
        sh '''echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin'''
        
        // Build and push backend
        sh '''
        echo "Building the backend image..."
        docker build -t cklany/wkld6_backend:latest -f Dockerfile.backend .
        echo "Pushing backend image..."
        docker push cklany/wkld6_backend:latest
        '''
        
        // Build and push frontend
        sh '''
        echo "Building the frontend image..."
        docker build -t cklany/wkld6_frontend:latest -f Dockerfile.frontend .
        echo "Pushing frontend image..."          
        docker push cklany/wkld6_frontend:latest
        '''
      }
    }

    stage('Infrastructure') {
      agent { label 'build-node' }
      steps {
        dir('Terraform') {
          sh '''
            terraform init
            terraform apply -auto-approve \
              -var="dockerhub_username=${DOCKER_CREDS_USR}" \
              -var="dockerhub_password=${DOCKER_CREDS_PSW}"
          '''
          }
        }
      }


  post {
    always {
      node('build-node') {
          sh '''
            docker logout
            docker system prune -f
          '''
        }
      }
    }
  }
}
}

