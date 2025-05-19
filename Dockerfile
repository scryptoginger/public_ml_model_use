FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y docker.io #&& \ rm -rf /var/lib/apt/lists/*
COPY init_pipeline.groovy /usr/share/jenkins/ref/init.groovy.d/init_pipeline.groovy
USER jenkins