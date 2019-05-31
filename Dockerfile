FROM openjdk:8-alpine

ENV SONAR_SCANNER_VERSION=3.3.0.1492

RUN apk add --no-cache curl grep sed unzip bash nodejs nodejs-npm && \
    npm install -g typescript

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /usr/src

RUN curl -o ./sonarscanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
	unzip sonarscanner.zip && \
	rm sonarscanner.zip && \
	mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /usr/lib/sonar-scanner && \
	ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

ENV SONAR_RUNNER_HOME=/usr/lib/sonar-scanner

#   ensure Sonar uses the provided Java for musl instead of a borked glibc one
RUN sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /usr/lib/sonar-scanner/bin/sonar-scanner

# Separating ENTRYPOINT and CMD operations allows for core execution variables to
# be easily overridden by passing them in as part of the `docker run` command.
# This allows the default /usr/src base dir to be overridden by users as-needed.
ENTRYPOINT ["sonar-scanner"] 
CMD ["-Dsonar.projectBaseDir=/usr/src"]
