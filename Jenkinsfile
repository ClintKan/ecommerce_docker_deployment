pipeline {
  agent any

  environment {
    // DOCKER_CREDS = credentials('docker-hub-credentials')
    DJANGO_SETTINGS_MODULE = 'backend.myproject.settings'
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
        pip install -r ./backend/requirements.txt
        pip install pytest-django
        python backend/manage.py makemigrations
        ''' 
      }
    }

    stage('Cleanup') {
      agent { label 'build-node' }
      steps {
        sh '''
          echo "Only clean Docker system"
          docker system prune -f
        '''
      }
    }

    stage('Build & Push Images') {
      agent { label 'build-node' }
      steps {
        sh 'echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin'
        
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
        // Securely inject AWS credentials from Jenkins' credentials store
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key'),
                        string(credentialsId: 'DB_USERNAME', variable: 'db_username'),
                        string(credentialsId: 'DB_PASSWORD', variable: 'db_password'),
                        string(credentialsId: 'DOCKER_CREDS_USR', variable: 'dockerhub_username'),
                        string(credentialsId: 'DOCKER_CREDS_PSW', variable: 'dockerhub_password')]) {
          dir('Terraform') {
            sh '''
              terraform init
              terraform plan -no-color -out plan.tfplan \
              -var="db_username=${db_username}" \
              -var="db_password=${db_password}" \
              -var="aws_access_key=${aws_access_key}" \
              -var="aws_secret_key=${aws_secret_key}"

              terraform apply -auto-approve \
                -var="dockerhub_username=${DOCKER_CREDS_USR}" \
                -var="dockerhub_password=${DOCKER_CREDS_PSW}" \
                -var="aws_access_key=${AWS_ACCESS_KEY}" \
                -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}"
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

