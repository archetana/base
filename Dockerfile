FROM node:14

WORKDIR /app

COPY . /app

EXPOSE 8080

RUN npm install http-server -g
RUN npm install -g @angular/cli

RUN npm install --no-optional && ng build

CMD http-server ./dist
