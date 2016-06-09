FROM node:5
# replace this with your application's default port
EXPOSE 3000

# Update packages and clean temp/cache files

RUN apt-get update && apt-get install -yq mc && apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

RUN npm install -g bower
RUN npm install -g bower-installer

# Add the user node, and change to this user

RUN useradd -ms /bin/bash node
USER node

WORKDIR /home/node

RUN mkdir nodecg

# Download and install NodeCG

ENV NODECG https://github.com/nodecg/nodecg/archive/v0.7.8.tar.gz
RUN curl -sSL $NODECG | tar -v -xz -C /home/node/nodecg --strip-components=1

WORKDIR /home/node/nodecg

RUN npm install --production
RUN bower install

# Copy some tools

COPY getdeps.sh bundles

WORKDIR /home/node/nodecg/bundles

# Create places and install dep modules

RUN mkdir lfg-nucleus lfg-sublistener lfg-filter nodecg-dashboard lfg-sounds lfg-streamtip

ENV NUCLEUS https://api.github.com/repos/SupportClass/lfg-nucleus/tarball/39ca026
ENV FILTER https://api.github.com/repos/SupportClass/lfg-filter/tarball/6388f80
ENV SUBLISTENER https://api.github.com/repos/SupportClass/lfg-sublistener/tarball/v2.0.1
ENV DASHBOARD https://api.github.com/repos/denolfe/nodecg-dashboard/tarball/2413f33
ENV SOUNDS https://api.github.com/repos/SupportClass/lfg-sounds/tarball/ded1527
ENV STREAMTIP https://api.github.com/repos/SupportClass/lfg-streamtip/tarball/ef91a09

RUN curl -sSL $NUCLEUS | tar -v -xz -C /home/node/nodecg/bundles/lfg-nucleus --strip-components=1
RUN curl -sSL $SUBLISTENER | tar -v -xz -C /home/node/nodecg/bundles/lfg-sublistener --strip-components=1
RUN curl -sSL $FILTER | tar -v -xz -C /home/node/nodecg/bundles/lfg-filter --strip-components=1
RUN curl -sSL $DASHBOARD | tar -v -xz -C /home/node/nodecg/bundles/nodecg-dashboard --strip-components=1
RUN curl -sSL $SOUNDS | tar -v -xz -C /home/node/nodecg/bundles/lfg-sounds --strip-components=1
RUN curl -sSL $STREAMTIP | tar -v -xz -C /home/node/nodecg/bundles/lfg-streamtip --strip-components=1

# Run the script to recursivly add the modules deps

RUN ./getdeps.sh

# Begin installing the client's modules, change [CLIENTMODULE] to something specific

COPY [CLIENTMODULE] [CLIENTMODULE]

USER root
RUN chown node:node [CLIENTMODULE] -R
USER node

WORKDIR /home/node/nodecg/bundles/[CLIENTMODULE]

RUN npm install -p && bower-installer && rm -rf bower_components && mv temp_lib bower_components && rm -rf /home/node/.cache

WORKDIR /home/node/nodecg

# Copy the config over, however I recommend using a docker volume for this

COPY cfg cfg

# The command to run

CMD ["node", "index.js"]
