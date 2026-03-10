# Stage 2: Backend (plain Node.js, no build step)
FROM node:18 AS backend-build
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install
COPY backend/ .

# No build step needed
