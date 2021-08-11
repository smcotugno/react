FROM registry.access.redhat.com/ubi8/nodejs-14
#test
WORKDIR /usr/src/app
USER 0
COPY . /usr/src/app
RUN chown -R 1001:0 /usr/src/app
USER 1001
RUN npm install
CMD ["npm", "start"]

EXPOSE 3000




