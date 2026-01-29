FROM node:20-alpine

WORKDIR /app

COPY backend ./backend
COPY frontend ./frontend

WORKDIR /app/backend
RUN npm install

WORKDIR /app/frontend
RUN npm install && npm run build

WORKDIR /app/backend
EXPOSE 5000

CMD ["node", "server.js"]


