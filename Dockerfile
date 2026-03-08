# Stage 1: Build frontend
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend ./
RUN npm run build

# Stage 2: Backend
FROM node:20-alpine AS backend
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install --only=production
COPY backend ./

# Copy frontend build into backend (if backend serves static files)
COPY --from=frontend-build /app/frontend/build ./public

EXPOSE 5000
CMD ["node", "server.js"]
