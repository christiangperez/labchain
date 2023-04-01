FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./
COPY connection-org1.json ./

RUN npm install

COPY . .

EXPOSE 4000
CMD [ "node", "index.js" ]