FROM node:8.9.4-alpine

WORKDIR /tmp
ADD package.json ./
ADD index.js ./
RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
