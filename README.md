# vertx-s2i
OpenShift vert.x source-to-image

This image can be used to build and deploy [vert.x](https://vertx.io) applications on [OpenShift](http://www.openshift.com)
 using [Source-to-image](https://docs.openshift.com/enterprise/3.1/creating_images/s2i.html).

This S2I image supports two mechanism for deploying vert.x applications:

1. Use 'vertx run' to directly execute verticles written in one of the vert.x supported languages

2. Build a Java "fat" jar by declaring a pom.xml 

## Creating an OpenShift ImageStream

Before you can use the vert.x image in OpenShift, you must first create the ImageStream containing the vertx-s2i image

.image-stream.json
[source, json]
----
{
  "kind": "ImageStream",
  "apiVersion": "v1",
  "metadata": {
    "name": "vertx-s2i"
  },
  "spec": {
    "dockerImageRepository": "maschmid/vertx-s2i"
  }
}
----

```oc create -f image-stream.json```

## Deploying verticle sources

To deploy a set of verticles by their source code, just add them to a git repository and add the following file to declare the main verticle:

..sti/environment
[source]
----
VERTICLE_NAME=hello-verticle.js
----

.hello-verticle.js
[source, JavaScript]
----
vertx.createHttpServer().requestHandler(function (request) {
    request.response().end("Hello world");
}).listen(8080);
----

## Building a Java "fat" jar

You can use the vertx-s2i image to deploy a vert.x application by providing a maven build that produces a 'fat' executable JAR file.
 
In this case you need to provide a pom.xml. The s2i assemble script will execute the maven build ('mvn package' by default) and will look for a file named target/*-fat.jar.

.pom.xml
[source]
----
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>

  <groupId>io.vertx</groupId>
  <artifactId>maven-simplest</artifactId>
  <version>3.1.0</version>

  <properties>
    <!-- the main class -->
    <exec.mainClass>io.vertx.example.HelloWorldEmbedded</exec.mainClass>
  </properties>

  <dependencies>
    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-core</artifactId>
      <version>${project.version}</version>
    </dependency>
  </dependencies>

  <build>

    <pluginManagement>
      <plugins>
        <!-- We specify the Maven compiler plugin as we need to set it to Java 1.8 -->
        <plugin>
          <artifactId>maven-compiler-plugin</artifactId>
          <version>3.1</version>
          <configuration>
            <source>1.8</source>
            <target>1.8</target>
          </configuration>
        </plugin>
      </plugins>
    </pluginManagement>

    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-shade-plugin</artifactId>
        <version>2.3</version>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>shade</goal>
            </goals>
            <configuration>
              <transformers>
                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                  <manifestEntries>
                    <Main-Class>${exec.mainClass}</Main-Class>
                  </manifestEntries>
                </transformer>
                <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
                  <resource>META-INF/services/io.vertx.core.spi.VerticleFactory</resource>
                </transformer>
              </transformers>
              <artifactSet>
              </artifactSet>
              <outputFile>${project.build.directory}/${project.artifactId}-${project.version}-fat.jar</outputFile>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
----


