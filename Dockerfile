FROM python:3.6

VOLUME /logs

ENV WORKSPACE=/opt/VFB
ENV VFB_OWL_VERSION=Current
ENV CHUNK_SIZE=1000
ENV PING_SLEEP=120s
ENV BUILD_OUTPUT=${WORKSPACE}/build.out

RUN pip3 install wheel requests psycopg2 pandas base36

RUN apt-get -qq update || apt-get -qq update && \
apt-get -qq -y install git curl wget default-jdk pigz maven libpq-dev python-dev tree gawk

ENV KBserver=http://192.168.0.1:7474

ENV KBuser=neo4j

ENV KBpassword=password

ENV GITBRANCH=kbold2new_neo4j_v4

ENV RUNSILENT=https://raw.githubusercontent.com/VirtualFlyBrain/pipeline/master/runsilent.sh

RUN wget -P ${WORKSPACE} ${RUNSILENT}

COPY process.sh /opt/VFB/process.sh

RUN chmod +x /opt/VFB/*.sh

RUN echo -e "travis_fold:start:processLoad" && \
cd "${WORKSPACE}" && \
echo '** Git checkout VFB_neo4j **' && \
git clone --quiet https://github.com/VirtualFlyBrain/VFB_neo4j.git

RUN cd ${WORKSPACE} && \
echo -e "travis_fold:end:processLoad"

RUN echo -e "travis_fold:start:sourcetree" && tree ${WORKSPACE} && echo -e "travis_fold:end:sourcetree"

ENV PYTHONPATH=${WORKSPACE}/VFB_neo4j/src/

CMD ["/opt/VFB/process.sh"]
