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

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy frontend production build
COPY --from=frontend-build /app/frontend/build ./frontend/build

# Copy backend code
COPY --from=backend-build /app/backend ./backend

# Copy backend node_modules explicitly
COPY --from=backend-build /app/backend/node_modules ./backend/node_modules

# Healthcheck on /health endpoint
HEALTHCHECK CMD node -e "require('http').get('http://localhost:5000/health', res => process.exit(res.statusCode === 200 ? 0 : 1))"


# Run backend server
CMD ["node", "backend/server.js"]
