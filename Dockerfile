# Stage 1: Build React App
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Serve with Node (serve package)
FROM node:18-alpine

WORKDIR /app

# Install lightweight static server
RUN npm install -g serve

# Copy only build files
COPY --from=build /app/build ./build

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
