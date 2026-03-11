# Stage 1: Build frontend
FROM node:18 AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Stage 2: Backend build
FROM node:18 AS backend-build
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install
COPY backend/ .

# Stage 3: Final runtime image
FROM node:18-slim
WORKDIR /app

# Copy frontend production build
COPY --from=frontend-build /app/frontend/build ./frontend/build

# Copy backend including node_modules
COPY --from=backend-build /app/backend ./backend

# Ensure only production dependencies remain
RUN npm prune --production --prefix backend

# Run backend server.js
CMD ["node", "backend/server.js"]
