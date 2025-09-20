FROM node:alphine3.18 as build 

# Declare build time enviroment variable
ARG REACT_APP_NODE_ENV
ARG REACT_APP_SERVER_BASE_URL

# Set default value for enviroment variable 
ENV REACT_APP_NODE_ENV=${REACT_APP_NODE_ENV}
ENV REACT_APP_SERVER_BASE_URL=${REACT_APP_SERVER_BASE_URL}

# Build the app 
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build 

# Serve the app with nginx server
FROM nginx:1.23-alphine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=build /app/build .
EXPOSE 80                           
ENTRYPOINT ["nginx", "-g", "daemon off;"]