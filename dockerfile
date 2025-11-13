# ---------- build stage ----------
FROM node:18-alpine AS build
ENV NODE_ENV=production
WORKDIR /app

# Patch Alpine right away
RUN apk --no-cache update && apk --no-cache upgrade

# Install only production deps (using lockfile if present)
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source code
COPY . .

# ---------- runtime stage ----------
FROM node:18-alpine
ENV NODE_ENV=production
WORKDIR /app

# Keep runtime base patched
RUN apk --no-cache update && apk --no-cache upgrade \
 && addgroup -S app && adduser -S app -G app \
 && mkdir -p /app && chown -R app:app /app

# Copy only built app + prod node_modules
COPY --from=build /app /app
RUN chown -R app:app /app

# Drop root privileges
USER app

# App port
EXPOSE 3000

# Run without shell
CMD ["node", "app.js"]
