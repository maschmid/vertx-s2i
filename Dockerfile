FROM vertx/vertx3

# Expose 8080 by default
EXPOSE 8080

ENV MAVEN_VERSION="3.3.3" \
    PATH=$PATH:"/usr/local/s2i"

LABEL io.k8s.description="Platform for building and running vert.x 3 applications" \
      io.k8s.display-name="Vert.x 3" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,vertx" \
      io.openshift.s2i.scripts-url=image:///usr/local/s2i

# Temporary switch to root
USER root

COPY s2i /usr/local/s2i
ADD README.md /usr/local/s2i/usage.txt

# Necessary to permit running with a randomised UID
RUN mkdir /deployments \
 && chmod -R "a+rwX" /deployments

# Install maven
RUN curl http://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | \
    tar -xzf - -C /opt \
     && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
     && ln -s /opt/maven/bin/mvn /usr/bin/mvn

# S2I requires a numeric, non-0 UID
USER 1000
WORKDIR /deployments

CMD [ "/usr/local/s2i/usage" ]
