FROM vertx/vertx3

# Expose 8080 by default
EXPOSE 8080

ENV PATH=$PATH:"/usr/local/s2i"

LABEL io.k8s.description="Platform for building and running vert.x 3 applications" \
      io.k8s.display-name="Vert.x 3" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,vertx" \
      io.openshift.s2i.scripts-url=image:///usr/local/s2i

COPY s2i /usr/local/s2i
ADD README.md /usr/local/s2i/usage.txt

# Necessary to permit running with a randomised UID
RUN mkdir /deployments \
 && chmod -R "a+rwX" /deployments

# S2I requires a numeric, non-0 UID
USER 1000
WORKDIR /deployments

CMD [ "/usr/local/s2i/usage" ]
