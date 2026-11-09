# Barbearia WJ / PropeX - Node.js 22 + Express
FROM node:22-bookworm-slim

ENV NODE_ENV=production \
    PORT=8080

WORKDIR /app

# 1. Copia apenas os arquivos de dependência do backend e instala
COPY --chown=node:node backend/package.json backend/package-lock.json ./backend/
RUN cd backend && npm ci --omit=dev && npm cache clean --force

# 2. Copia o código fonte do backend, o certificado do Supabase e a pasta database
COPY --chown=node:node backend/src/ ./backend/src/
COPY --chown=node:node backend/database/ ./backend/database/
COPY --chown=node:node backend/supabase-ca.crt ./backend/

# 3. Copia os arquivos estáticos do frontend (arquivos na raiz do projeto)
COPY --chown=node:node assets/ ./assets/
COPY --chown=node:node css/ ./css/
COPY --chown=node:node js/ ./js/
COPY --chown=node:node *.html ./
COPY --chown=node:node manifest.webmanifest service-worker.js ./

USER node
EXPOSE 8080

CMD ["node", "backend/src/server.js"]