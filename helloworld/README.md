# PostgreSQL Hello World Node.js App

A simple Node.js application that connects to PostgreSQL and provides a word dictionary API.

## Environment Variables

The application requires the following environment variables to connect to PostgreSQL:

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_PASSWORD` | PostgreSQL database password | `your-secure-password` |
| `DB_URL` | PostgreSQL connection URL with `$PASSWORD` placeholder | `postgres://admin:$PASSWORD@hostname:port/database?sslmode=verify-full` |
| `DB_CERT` | Base64-encoded SSL certificate for secure connection | `LS0tLS1CRUdJTi...` |

### Getting Database Credentials from IBM Cloud

If you're using IBM Cloud Databases for PostgreSQL:

1. Go to your PostgreSQL instance in IBM Cloud
2. Navigate to **Service Credentials**
3. Create or view credentials
4. Extract the following values:
   - `DB_PASSWORD`: Use the `password` field
   - `DB_URL`: Use the `composed` connection string (it already contains `$PASSWORD` placeholder)
   - `DB_CERT`: Use the `certificate.certificate_base64` field

## Local Development

### Using config.json (Local Only)

For local development, you can create a `config.json` file:

```json
{
  "password": {
    "value": "your-password"
  },
  "url": {
    "value": "postgres://admin:$PASSWORD@hostname:port/database?sslmode=verify-full"
  },
  "cert": {
    "value": "base64-encoded-certificate"
  }
}
```

**Note:** `config.json` is in `.gitignore` and should never be committed.

### Using Environment Variables (Recommended)

Create a `.env` file (also in `.gitignore`):

```bash
DB_PASSWORD=your-password
DB_URL=postgres://admin:$PASSWORD@hostname:port/database?sslmode=verify-full
DB_CERT=base64-encoded-certificate
```

Then run:
```bash
npm install
npm start
```

## Container Deployment

### Building the Container

```bash
docker build -t helloworld-postgres:latest .
```

### Running Locally with Docker

```bash
docker run -p 8080:8080 \
  -e DB_PASSWORD="your-password" \
  -e DB_URL="postgres://admin:\$PASSWORD@hostname:port/database?sslmode=verify-full" \
  -e DB_CERT="base64-encoded-certificate" \
  helloworld-postgres:latest
```

### Kubernetes Deployment

Create a Secret for database credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
type: Opaque
stringData:
  DB_PASSWORD: "your-password"
  DB_URL: "postgres://admin:$PASSWORD@hostname:port/database?sslmode=verify-full"
  DB_CERT: "base64-encoded-certificate"
```

Create a Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-postgres
spec:
  replicas: 2
  selector:
    matchLabels:
      app: helloworld-postgres
  template:
    metadata:
      labels:
        app: helloworld-postgres
    spec:
      containers:
      - name: helloworld
        image: helloworld-postgres:latest
        ports:
        - containerPort: 8080
        envFrom:
        - secretRef:
            name: postgres-credentials
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld-postgres
spec:
  selector:
    app: helloworld-postgres
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

Apply the manifests:

```bash
kubectl apply -f postgres-secret.yaml
kubectl apply -f deployment.yaml
```

## API Endpoints

- `GET /words` - Retrieve all words and definitions
- `PUT /words` - Add a new word and definition
  ```json
  {
    "word": "example",
    "definition": "a thing characteristic of its kind"
  }
  ```

## Security Notes

- The application uses SSL/TLS for database connections
- Runs as non-root user in container
- Includes health checks for container orchestration
- Never commit credentials to version control