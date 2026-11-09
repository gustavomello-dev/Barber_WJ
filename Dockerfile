# Barbearia WJ / PropeX - Node.js 22 + Express
# Coloque este arquivo na pasta Barbearia2026_WJ, junto do diretorio backend.
FROM node:22-bookworm-slim

ENV NODE_ENV=production \
    PORT=3000

# Instala apenas as dependencias de producao do backend.
WORKDIR /app/backend
COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# O Express serve a API e os arquivos do frontend a partir de /app.
WORKDIR /app
COPY --chown=node:node backend/src/ ./backend/src/
COPY --chown=node:node assets/ ./assets/
COPY --chown=node:node css/ ./css/
COPY --chown=node:node js/ ./js/
COPY --chown=node:node *.html ./
COPY --chown=node:node manifest.webmanifest service-worker.js ./

# Nao copie backend/.env: passe os segredos no momento da execucao.
USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://127.0.0.1:' + (process.env.PORT || 3000) + '/api/health', (r) => { r.resume(); process.exit(r.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1))"

CMD ["node", "backend/src/server.js"]
