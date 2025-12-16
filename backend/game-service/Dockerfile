FROM node:18-alpine

WORKDIR /app

# Copia os arquivos de dependência primeiro (para cachear o npm install)
COPY package*.json ./

# Instala ferramentas de compilação para o SQLite3 (Python, Make, G++)
RUN apk add --no-cache python3 make g++

# Instala as dependências do Node
RUN npm install

# Copia o resto do código (incluindo a pasta src, index.js, database.js)
COPY . .

# Expõe a porta (será mapeada no docker-compose)
EXPOSE 3001 3002

# Comando de inicialização
CMD ["node", "index.js"]