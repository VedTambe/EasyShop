pipeline {
    agent any;
    
    stages{
        stage("Code Clone") {
            steps { 
                git url: "https://github.com/VedTambe/EasyShop.git", branch: "EasyShop"
            }
        }
        
        stage("Code Build") {
            steps {
                sh "docker build -t easyshop:latest --no-cache ."
            }
        }
        
        stage("Push to Docker Hub") {
            steps { 
                withCredentials([usernamePassword(credentialsId: "dockerHubCreds",
                                                  passwordVariable: "dockerHubPass",
                                                  usernameVariable: "dockerHubUser")]) {
                    
                    // Tagging the built image correctly
                    sh "docker image tag easyshop:latest ${env.dockerHubUser}/easyshop:latest"
                    
                    // Logging in to Docker Hub
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
                    
                    // Pushing the image to Docker Hub
                    sh "docker push ${env.dockerHubUser}/easyshop:latest"
                }
            }
        }
        
        stage("Code Run") {
            steps {
                sh "docker compose up -d"  // Make sure docker-compose.yml exists in the root directory
            }
        }
    }
}
