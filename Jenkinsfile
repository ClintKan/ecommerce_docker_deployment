pipeline {
  agent any

  environment {
    DOCKER_CREDS = credentials('docker-hub-credentials')
    DJANGO_SETTINGS_MODULE = 'backend.myproject.settings'
  }

  stages {
    stage ('Build') {
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

    // stage('SonarQube Analysis') {
    //   agent { label 'build-node' }
    //   steps {
    //     script {
    //       // Perform the SonarQube scan using SonarScanner
    //         withSonarQubeEnv(SonarQubeServer) {
    //             sh 'sonar-scanner -Dsonar.login=${SonarQube_Token}'
    //         }
    //     }
    //   }
    // }
  
    // stage('Checkov Setup') {
    //   steps {
    //     script {
    //     // Step 1: Create Python virtual environment
    //         sh '''
    //         python3 -m venv checkov_env
    //         source checkov_env/bin/activate
    //         pip install --upgrade pip
    //         pip install checkov
    //         '''
                    
    //     // Step 2: Run Checkov scan and save the output to the reports directory
    //         sh '''
    //         mkdir -p reports
    //         source checkov_env/bin/activate
    //         checkov -d . --output-file-path reports/checkov_report.json
    //         '''
                    
    //     // Step 3: Archive the Checkov report
    //         archiveArtifacts artifacts: 'reports/checkov_report.json', fingerprint: true
    //     }
    //   }
    // }

    stage ('Test') {
      agent any
      steps {
        sh '''#!/bin/bash
        source venv/bin/activate
        pip install -r ./backend/requirements.txt
        pip install pytest-django
        pytest backend/account/tests.py --verbose --junit-xml test-reports/results.xml
        ''' 
      }
    }

    stage('Cleanup') {
      agent { label 'build-node' }
      steps {
        sh '''
          # Only clean Docker system
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

    // // Stage to install and run OWASP ZAP scan
    // stage('OWASP ZAP Scan') {
    //   agent { label 'build-node' }  // Use your build agent

    //   steps {
    //     // Install OWASP ZAP (if not already installed on the agent)
    //     script {
    //         // Check if ZAP is already installed, otherwise install it
    //         if (!fileExists('/opt/zap')) {
    //             echo "Installing OWASP ZAP..."
    //             sh '''
    //                 wget https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2_15_0_unix.sh -O zap_install.sh
    //                 chmod +x zap_install.sh
    //                 sudo ./zap_install.sh -q -dir /opt/zap
    //             '''
    //         } else {
    //             echo "OWASP ZAP is already installed."
    //         }
    //     }

    //     // Run OWASP ZAP in headless mode for dynamic web application security testing
    //     sh '''
    //       echo "Running OWASP ZAP scan in headless mode..."

    //       # Set up the target URL (this can be a test URL or deployed app)
    //       TARGET_URL="http://google.com"

    //       # Run the ZAP scan (headless mode)
    //       /opt/zap/zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true -config spider.maxDuration=5 -config zap.spider.timeout=300

    //       # Run the active scan on the target web application URL
    //       curl -X GET "http://127.0.0.1:8080/JSON/ascan/action/scan?url=${TARGET_URL}&maxDepth=5&maxDuration=60"

    //       # Waiting for the scan to finish
    //       echo "Waiting for ZAP scan to finish..."
    //       sleep 60

    //       # Export the ZAP scan results to a JSON file
    //       curl -X GET "http://127.0.0.1:8080/JSON/core/action/response?url=${TARGET_URL}" > /var/lib/jenkins/workspace/workload_6_main/reports/zap_scan_results.json
    //     '''

    //       // Archive the ZAP results (optional but useful for reviewing later)
    //       archiveArtifacts artifacts: 'reports/zap_scan_results.json', allowEmptyArchive: true
    //   }
    // }

// Stage to run security checks (Trivy scan)
  //   stage('Images Security Check') {
  //     agent { label 'build-node' }
  //     steps {
  //       // Run security scan on the backend image
  //       sh '''
  //         echo "Running Trivy scan on backend image..."
  //         trivy image --format json --output /var/lib/jenkins/workspace/workload_6_main/reports/trivy_backend_report.json cklany/wkld6_backend:latest
          
  //         # Check if Trivy scan found vulnerabilities and fail the build if any are found
  //         if [ $? -ne 0 ]; then
  //           echo "Trivy scan found vulnerabilities in backend image. Failing the build."
  //           exit 1
  //         fi
  //       '''
        
  //       // Run security scan on the frontend image
  //       sh '''
  //         echo "Running Trivy scan on frontend image..."
  //         trivy image --format json --output /var/lib/jenkins/workspace/workload_6_main/reports/trivy_frontend_report.json cklany/wkld6_frontend:latest
          
  //         # Check if Trivy scan found vulnerabilities and fail the build if any are found
  //         if [ $? -ne 0 ]; then
  //           echo "Trivy scan found vulnerabilities in frontend image. Failing the build."
  //           exit 1
  //         fi
  //       '''
  //   }
  // }

    stage('Infrastructure') {
      agent { label 'build-node' }
      steps {
        // Securely inject AWS credentials from Jenkins' credentials store
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'),
                      string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY')]) {
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
                                -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
                                -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}"
                            '''
                            }
        }
      }
    }

  post {
    always {
      node('build-node') }
      steps {
        sh '''
          docker logout
          docker system prune -f
        '''
      }
    }
  }
}
