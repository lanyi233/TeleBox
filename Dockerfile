# --- 第一阶段：构建 ---
FROM node:24-bullseye-slim AS builder

RUN echo ":: Testing APT..." && \
    if node -e "const net = require('net'); const client = net.createConnection({ port: 53, host: '8.8.8.8', timeout: 2000 }, () => { process.exit(0); }); client.on('error', () => { process.exit(1); }); client.on('timeout', () => { process.exit(1); });"; then \
        echo " -> Global" ; \
    else \
        echo " -> China" ; \
        printf "deb https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free\ndeb https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free\ndeb https://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list; \
    fi && \
    apt-get update && apt-get install -y \
    python3 make g++ curl git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./

RUN echo ":: Testing npm..." && \
    if node -e "const net = require('net'); const client = net.createConnection({ port: 53, host: '8.8.8.8', timeout: 2000 }, () => { process.exit(0); }); client.on('error', () => { process.exit(1); }); client.on('timeout', () => { process.exit(1); });"; then \
        echo " -> Global" ; \
    else \
        echo " -> China" ; \
        npm config set registry https://mirrors.cloud.tencent.com/npm/ ; \
    fi && \
    npm install && \
    npm cache clean --force

COPY . .

# --- 第二阶段：运行 ---
FROM node:24-bullseye-slim

RUN echo ":: Testing APT..." && \
    if node -e "const net = require('net'); const client = net.createConnection({ port: 53, host: '8.8.8.8', timeout: 2000 }, () => { process.exit(0); }); client.on('error', () => { process.exit(1); }); client.on('timeout', () => { process.exit(1); });"; then \
        echo " -> Global" ; \
    else \
        echo " -> China" ; \
        printf "deb https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free\ndeb https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free\ndeb https://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list; \
    fi && \
    apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# 开发测试
#ENV NODE_ENV=development

CMD ["npm", "start"]
