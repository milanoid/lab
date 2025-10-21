
### Docker images

Exercise - containerize a Flask web application

```
FROM ubuntu

RUN apt-get update
RUN apt-get install python

RUN pip install flask
RUN pip install flask-mysql

COPY . /opt/source-code

ENTRYPOINT FLASK_APP=/opt/souce-code/app.py flask run
```

- INSTRUCTIONS - in CAPITAL, e.g. FROM, RUN
- arguments - in lowercase, e.g. ubuntu


#### Layered architecture

-  each line of instructions creates a new layer!
- `docker history <image>` show the layers and size in MBs
- all the layers are cached

```bash
docker history docker.io/library/rabbitmq:3.6.15-management
ID            CREATED      CREATED BY                                     SIZE                     COMMENT
bf13a3aceead  7 years ago  /bin/sh -c #(nop)  EXPOSE 15671/tcp 15672/tcp  0B
<missing>     7 years ago  /bin/sh -c set -eux;                           erl -noinput -eval '...  24.7MB
<missing>     7 years ago  /bin/sh -c rabbitmq-plugins enable --offli...  3.07kB
<missing>     7 years ago  /bin/sh -c #(nop)  CMD ["rabbitmq-server"]     0B
<missing>     7 years ago  /bin/sh -c #(nop)  EXPOSE 25672/tcp 4369/t...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENTRYPOINT ["docker-ent...  0B
<missing>     7 years ago  /bin/sh -c ln -s usr/local/bin/docker-entr...  1.54kB
<missing>     7 years ago  /bin/sh -c #(nop) COPY file:7f3c1def1757a3...  13.8kB
<missing>     7 years ago  /bin/sh -c ln -sf "/usr/lib/rabbitmq/lib/r...  1.54kB
<missing>     7 years ago  /bin/sh -c ln -sf /var/lib/rabbitmq/.erlan...  2.05kB
<missing>     7 years ago  /bin/sh -c #(nop)  VOLUME [/var/lib/rabbitmq]  0B
<missing>     7 years ago  /bin/sh -c mkdir -p /var/lib/rabbitmq /etc...  10.8kB
<missing>     7 years ago  /bin/sh -c #(nop)  ENV HOME=/var/lib/rabbitmq  0B
<missing>     7 years ago  /bin/sh -c set -eux;                                                    apt-get update;   ap...       11.4MB
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_DEBIAN_VER...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_GITHUB_TAG...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_VERSION=3....  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_GPG_KEY=0A...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV PATH=/usr/lib/rabbi...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_LOGS=- RAB...  0B
<missing>     7 years ago  /bin/sh -c set -eux;                           apt-get update;          if ...        41.1MB
<missing>     7 years ago  /bin/sh -c set -eux;                                                    fetchDeps='               ca-ce...    3.16MB
<missing>     7 years ago  /bin/sh -c #(nop)  ENV GOSU_VERSION=1.10       0B
<missing>     7 years ago  /bin/sh -c groupadd -r rabbitmq && useradd...  350kB
<missing>     7 years ago  /bin/sh -c set -eux;                           apt-get update;          apt...      9.58MB
<missing>     7 years ago  /bin/sh -c #(nop)  CMD ["bash"]                0B
<missing>     7 years ago  /bin/sh -c #(nop) ADD file:d423aa6d423df23...  53.8MB

```