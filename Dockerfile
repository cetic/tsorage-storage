FROM alpine:latest

RUN apk add --no-cache \
    py-pip \
   	&& pip --no-cache-dir install cqlsh

WORKDIR /usr/src/cassandra_init

copy cassandra_prod.cql cassandra_init.cql
copy cassandra_check.cql cassandra_check.cql
copy docker_entrypoint docker_entrypoint

RUN ["chmod", "u+x,g+x", "docker_entrypoint"]

ENTRYPOINT ["/usr/src/cassandra_init/docker_entrypoint"]
