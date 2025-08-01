# Stage 1: Build frontend
FROM node:20 AS frontend-builder
WORKDIR /app
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm ci
COPY frontend ./frontend
WORKDIR /app/frontend
RUN npm run build

# Stage 2: Build backend
FROM python:3.10-slim
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
# Copy backend
COPY backend ./backend
# Copy built frontend
COPY --from=frontend-builder /app/frontend/out ./backend/static
EXPOSE 3001 443
CMD ["python", "./backend/main.py", "--dev", "--no-browser"]
