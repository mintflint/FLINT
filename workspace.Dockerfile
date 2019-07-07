FROM mhart/alpine-node:12.6

RUN apk update && apk upgrade && apk add git && apk add python && apk add make && apk add g++

RUN npm i -g truffle@5.0.26
VOLUME /usr/src/workspace
WORKDIR /usr/src/workspace
