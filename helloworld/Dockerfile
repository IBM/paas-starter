FROM node:22-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

RUN npm ci --only=production

# Bundle app source
COPY . .

# OpenShift runs containers with arbitrary user IDs
# Set permissions to allow any user in root group to access the app
RUN chgrp -R 0 /usr/src/app && \
    chmod -R g=u /usr/src/app

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

ENTRYPOINT ["node", "server.js"]