# Use the official Jenkins LTS image as a base
FROM jenkins/jenkins:lts

# Switch to root to install Docker CLI
USER root

# Install Docker CLI so Jenkins can spawn sibling containers
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

# Copy in the job–seeding Groovy script
COPY init_pipeline.groovy /usr/share/jenkins/ref/init.groovy.d/init_pipeline.groovy

# Switch back to the default Jenkins user
USER jenkins
