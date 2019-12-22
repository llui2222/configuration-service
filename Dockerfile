# Start with a base image containing Java runtime
FROM openjdk:8-jdk-alpine

# install ssh-client and bash
RUN apk --no-cache add openssh-client bash

# Spring Boot application creates working directories for Tomcat 
VOLUME /tmp

# Add Maintainer Info
LABEL maintainer="vgeorgiou@trading-point.com"

# The application's jar file
ARG JAR_FILE=build/libs/*.jar
ARG SSH_PRIVATE_KEY
ARG SSH_KNOWN_HOSTS

# Service logging directory
ENV LOGGING_PATH /var/log/ms

# Add the application's jar to the container
ADD ${JAR_FILE} /opt/tpam/ms/service.jar

RUN eval "$(ssh-agent -s)"
RUN mkdir -p ~/.ssh
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
RUN echo "${SSH_KNOWN_HOSTS}" > ~/.ssh/known_hosts
RUN chmod 700 /root/.ssh/id_rsa
RUN ssh-keyscan gitlab.ixi.com >> /root/.ssh/known_hosts
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Run the jar file
ENTRYPOINT ["java", "-Xmx512m", "-Djava.security.egd=file:/dev/./urandom", "-jar","/opt/tpam/ms/service.jar"]
