# Usa uma imagem leve e segura do Node.js
FROM node:20-alpine

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia os arquivos de dependências
COPY package*.json ./

# Instala apenas dependências de produção
RUN npm ci --only=production

# Copia o restante do código do projeto
COPY . .

# Expõe a porta que o Cloud Run usará
EXPOSE 8080

# Inicia a aplicação (ajuste se o seu script de start for diferente)
CMD ["npm", "start"]