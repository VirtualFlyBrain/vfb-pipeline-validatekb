FROM python:3.6

VOLUME /logs

# from compose args
ARG CONF_REPO
ARG CONF_BRANCH

ENV CONF_BASE=/opt/conf_base
ENV CONF_DIR=${CONF_BASE}/config/validatekb

ENV WORKSPACE=/opt/VFB
ENV VFB_OWL_VERSION=Current
ENV CHUNK_SIZE=1000
ENV PING_SLEEP=120s
ENV BUILD_OUTPUT=${WORKSPACE}/build.out

RUN pip3 install wheel requests psycopg2 pandas base36

RUN apt-get -qq update || apt-get -qq update && \
apt-get -qq -y install git curl wget default-jdk pigz maven libpq-dev python-dev tree gawk git

RUN mkdir $CONF_BASE

###### REMOTE CONFIG ######
ARG CONF_BASE_TEMP=${CONF_BASE}/temp
RUN mkdir $CONF_BASE_TEMP
RUN cd "${CONF_BASE_TEMP}" && git clone --quiet ${CONF_REPO} && cd $(ls -d */|head -n 1) && git checkout ${CONF_BRANCH}
# copy inner project folder from temp to conf base
RUN cd "${CONF_BASE_TEMP}" && cd $(ls -d */|head -n 1) && cp -R . $CONF_BASE && cd $CONF_BASE && rm -r ${CONF_BASE_TEMP}

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
