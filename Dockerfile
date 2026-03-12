# Stage 1: Build frontend
FROM node:18 AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install --production
COPY frontend/ .
RUN npm run build

# Stage 2: Backend build
FROM node:18 AS backend-build
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install --production
COPY backend/ .

# Stage 3: Final runtime image
FROM node:18-slim
WORKDIR /app

# Copy frontend production build
COPY --from=frontend-build /app/frontend/build ./frontend/build

# Copy backend code
COPY --from=backend-build /app/backend ./backend

# Copy backend node_modules explicitly (fix for missing cors, express, etc.)
COPY --from=backend-build /app/backend/node_modules ./backend/node_modules

# Healthcheck on new /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
  CMD curl -f http://localhost:5000/health || exit 1

# Run backend server
CMD ["node", "backend/server.js"]
