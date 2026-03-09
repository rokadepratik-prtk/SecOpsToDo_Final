# Stage 1: Build frontend
FROM node:18 AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Stage 2: Build backend
FROM node:18 AS backend-build
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install
COPY backend/ .

# Stage 3: Production image
FROM node:18-alpine
WORKDIR /app

# Copy backend
COPY --from=backend-build /app/backend ./

# Copy frontend build output into backend's public folder (or wherever you serve static files)
COPY --from=frontend-build /app/frontend/build ./frontend/build

EXPOSE 3000
CMD ["npm", "start", "--prefix", "backend"]
