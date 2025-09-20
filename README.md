Project: Node.js Backend & React Frontend Deployment using Docker and GitHub Actions
1. Overview

This project demonstrates a full-stack application deployment using Docker and GitHub Actions CI/CD workflow. The application consists of:

Frontend: ReactJS app served using Nginx.

Backend: Node.js API server connecting to MongoDB Atlas.

The deployment workflow is automated using GitHub Actions, with Docker images published to Docker Hub and deployed to a self-hosted server.


2. Architecture
2.1 Stack
Component	Technology	Purpose
Frontend	ReactJS, Nginx	Client-side web application
Backend	Node.js, Express	REST API server
Database	MongoDB Atlas	Cloud database
CI/CD	GitHub Actions	Build, test, and deploy Docker images
Containerization	Docker	Package applications for deployment


2.2 CI/CD Workflow Flowchart


flowchart TD
    A[Push to main branch] --> B[GitHub Actions CI/CD]
    B --> C[Build Frontend Docker Image]
    B --> D[Build Backend Docker Image]
    C --> E[Push Frontend Image to Docker Hub]
    D --> F[Push Backend Image to Docker Hub]
    E --> G[Deploy Frontend to Server]
    F --> H[Deploy Backend to Server]
    G --> I[ReactJS App Running on Port 3000]
    H --> J[Node.js App Running on Port 4000]
    I --> K[Users Access Frontend]
    J --> L[Frontend Connects to Backend API]


3. GitHub Actions Workflow

 3.1 Frontend Deployment Workflow

 name: Deploy Node Application

on: 
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: actions/checkout@v4
      - name: Login to Docker Hub
        run: echo "${{ secrets.DOCKER_HUB_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_HUB_USERNAME }}" --password-stdin   
      - name: Build Docker Image
        run: docker build -t meghadumbre/reactjs-app \
             --build-arg REACT_APP_NODE_ENV='production' \
             --build-arg REACT_APP_SERVER_BASE_URL='${{ secrets.REACT_APP_SERVER_BASE_URL }}' .
      - name: Publish Image to Docker Hub
        run: docker push meghadumbre/reactjs-app:latest 
  deploy:
    needs: build
    runs-on: self-hosted 
    steps:
      - name: Pull Image from Docker Hub
        run: docker pull meghadumbre/reactjs-app:latest 
      - name: Delete Old Container
        run: docker rm -f reactjs-app-container
      - name: Run Docker Container
        run: docker run -d -p 3000:80 --name reactjs-app-container meghadumbre/reactjs-app

3.2 Backend Deployment Workflow


name: Deploy Node Application

on: 
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source
        uses: actions/checkout@v4
      - name: Login to Docker Hub
        run: echo "${{ secrets.DOCKER_HUB_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_HUB_USERNAME }}" --password-stdin
      - name: Build Docker Image
        run: docker build -t meghadumbre/nodejs-app .
      - name: Publish Image to Docker Hub
        run: docker push meghadumbre/nodejs-app:latest 
  deploy:
    needs: build
    runs-on: self-hosted 
    steps:
      - name: Pull Image from Docker Hub
        run: docker pull meghadumbre/nodejs-app:latest 
      - name: Delete Old Container
        run: docker rm -f nodejs-app-container  
      - name: Run Docker Container
        run: docker run -d -p 4000:4000 --name nodejs-app-container -e MONGO_PASSWORD='${{ secrets.MONGO_PASSWORD }}' meghadumbre/nodejs-app


4. Dockerfile Structure
5.  4.1 Frontend Dockerfile


   # Build Stage
FROM node:alpine3.18 as build
ARG REACT_APP_NODE_ENV
ARG REACT_APP_SERVER_BASE_URL
ENV REACT_APP_NODE_ENV=$REACT_APP_NODE_ENV
ENV REACT_APP_SERVER_BASE_URL=$REACT_APP_SERVER_BASE_URL
WORKDIR /app
COPY package.json . 
RUN npm install
COPY . . 
RUN npm run build

# Production Stage
FROM nginx:1.23-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf *
COPY --from=build /app/build .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]


4.2 Backend Dockerfile

FROM node:alpine3.18
WORKDIR /app
COPY package.json ./ 
RUN npm install
COPY . . 
EXPOSE 4000
CMD ["npm", "run", "start"]



5. Deployment Flow

Developer pushes code to main branch.

GitHub Actions triggers CI/CD workflow.

Frontend and backend Docker images are built and pushed to Docker Hub.

Self-hosted server pulls the latest Docker images.

Old containers are removed.

New containers are run with environment variables for configuration.

Frontend is accessible on port 3000, backend on port 4000.


6. Diagram


           +------------------+
        | Developer Pushes |
        +--------+---------+
                 |
                 v
        +------------------+
        | GitHub Actions CI|
        +---+----------+---+
            |          |
            v          v
   +----------------+ +----------------+
   | Build Frontend | | Build Backend  |
   +-------+--------+ +--------+-------+
           |                 |
           v                 v
  +----------------+  +----------------+
  | Docker Hub Repo|  | Docker Hub Repo|
  +-------+--------+  +--------+-------+
           |                 |
           v                 v
   +----------------+  +----------------+
   | Deploy Frontend|  | Deploy Backend |
   +----------------+  +----------------+
           |                 |
           v                 v
       Users Access Frontend & Backend



