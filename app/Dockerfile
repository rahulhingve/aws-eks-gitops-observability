# stage 1st 

FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

# stage 2nd

FROM node:20-alpine AS runner

WORKDIR /app


# Create non-root user for security

RUN addgroup -g 1001 -S nodejs && \
    adduser -u 1001 -S nodeuser -u 1001 -G nodejs

COPY --from=builder /app/node_modules /app/node_modules
COPY --chown=nodeuser:nodejs . .

USER nodeuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "index.js"]    



