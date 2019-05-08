## Docker run examples

* Image from DockerHub

        docker run \
            -d \
            --rm \
            --privileged \
            -p 13389:3389 \
            -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
            --name devenv-xrdp-jdk8 \
            ogismiyamura/openam:devenv-xrdp

* Image from local build

        docker run \
            -d \
            --rm \
            --privileged \
            -p 13389:3389 \
            -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
            --name devenv-xrdp-jdk8 \
            devenv-xrdp-jdk8


## XRDP GUI usage

| Title | Value |
|---|---|
| Default login ID | xrdpuser |
| Default login Password | password |
| Run Eclipse | Applications -> Programming -> Eclipse 2018-09 |
| Default Git user name | xrdpuser |
| Default Git user email| xrdpuser@example.net |


## Docker build arguments

| Key | Default value |
|---|---|
| MAVENVERSION | 33 |
| JDKVERSION | 1.8.0 |
| XRDP_USER | xrdpuser |
| XRDP_USER_PASSWORD | password |
| XRDP_USER_MAIL | xrdpuser@example.net |
| XRDP_USER_ID | 1000 |


## Docker build examples

* OpenJDK 8, Maven 3.3

        docker build . \
            -t devenv-xrdp-jdk8

* OpenJDK 11, Maven 3.3

        docker build . \
            -t devenv-xrdp-jdk11 \
            --build-arg JDKVERSION=11

* OpenJDK 11, Maven 3.5

        docker build . \
            -t devenv-xrdp-jdk11-mvn35 \
            --build-arg JDKVERSION=11 \
            --build-arg MAVENVERSION=35
