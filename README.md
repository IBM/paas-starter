# IBM Cloud PaaS Starter Kit

A comprehensive starter project for deploying an environment that can host a database-backed containerized application on IBM Cloud. With this project, you can quickly standup the environment, deploy a sample application, and have something to quickly examine. This project is designed to be used as a starting point to explore the resources in IBM Cloud.

---

## 📋 Overview

The **IBM Cloud PaaS Starter Kit** is designed to help new users quickly establish an application environment on IBM Cloud. This project eliminates the complexity of manually configuring and integrating multiple cloud services by providing a fully automated Infrastructure as Code (IaC) solution using Terraform.

### What This Project Provides

This starter kit creates a complete, integrated cloud environment consisting of four core IBM Cloud services:

1. **Red Hat OpenShift Cluster** - A managed Kubernetes platform for running containerized applications
2. **IBM Cloud Logs** - Centralized logging solution for application and infrastructure logs
3. **IBM Cloud Monitoring** - Real-time metrics and monitoring for cluster health and application performance
4. **IBM Cloud Databases for PostgreSQL** - Fully managed, enterprise-grade PostgreSQL database

### Key Features

- **Fully Automated Deployment**: Single Terraform configuration creates and integrates all services
- **Pre-Integrated Observability**: Cloud Logs and Cloud Monitoring are automatically connected to your OpenShift cluster
- **Database Ready**: PostgreSQL database is provisioned and ready for your application to use
- **Cloud Registry**: A container registry namespace is created for use in storing the sample application container images
- **Sample Application Included**: A working Node.js application demonstrates database connectivity
- **Production Best Practices**: Includes health checks, resource limits, and secure credential management
- **Easy Cleanup**: Terraform destroy removes all resources cleanly

### Who Is This For?

This project is ideal for:

- **New IBM Cloud Users** - Get started quickly without learning every service individually
- **Developers** - Focus on building applications, not infrastructure
- **Learning** - Understand how IBM Cloud services are provisioned and work together in a real-world scenario

### What You'll Get

After running this project, you'll have:

- A running OpenShift cluster
- Integrated logging capturing all cluster and application logs
- Real-time monitoring dashboards for cluster metrics
- A PostgreSQL database ready for your application
- A sample application demonstrating database connectivity ready to build and deploy
- All services properly networked and secured

### Architecture Overview

### Time to Deploy

- **Initial Setup**: 5-10 minutes (one-time configuration)
- **Deployment**: 30-45 minutes (automated Terraform execution)
- **Total Time to Running Application**: ~1 hour

### Cost Considerations

This project creates billable IBM Cloud resources. Using the defaults, below are the estimated monthly costs (as of May 2026):

- OpenShift Cluster (2 workers): ~$300-400/month
- Cloud Logs: ~$10-50/month (depending on log volume)
- Cloud Monitoring: ~$10-30/month (depending on metrics)
- PostgreSQL Database: ~$50-100/month (depending on configuration)

**Total Estimated Cost**: $370-580/month

> **Note**: Costs vary based on region, usage, and configuration. Always check current IBM Cloud pricing. Remember to destroy resources when not in use to avoid unnecessary charges.

## 🔧 Prerequisites

Before you begin, ensure you have the following requirements in place:

### 1. IBM Cloud Account with Proper Permissions

This Terraform configuration requires **account owner** or **administrator** level permissions to create and manage resources across multiple IBM Cloud services. If you are the **account owner**, you will have all the necessary permission to proceed. 

**Required Permissions:**

You need the ability to:
- Create and manage OpenShift clusters
- Create and configure Cloud Logs instances
- Create and configure Cloud Monitoring instances
- Create and manage PostgreSQL database instances
- Create and manage VPC resources (subnets, security groups, etc.)
- Create and manage IAM service authorizations
- Create container registry namespaces

**Permission Check:**

To verify you have the necessary permissions:

1. Log in to [IBM Cloud Console](https://cloud.ibm.com)
2. Navigate to **Manage** → **Access (IAM)**
3. Click on **Users** and select your user
4. Review your **Access policies**
5. Ensure you have **Administrator** or **Editor** roles for:
   - All Account Management services
   - All IAM Account Management services
   - Kubernetes Service
   - Databases for PostgreSQL
   - Cloud Logs
   - Cloud Monitoring
   - VPC Infrastructure Services
   - Container Registry

> **Note**: If you don't have these permissions, contact your IBM Cloud account administrator. Running this project without proper permissions will result in Terraform errors during resource creation.

### 2. Standard Tools

This project requires the following list of tools to be installed on your local machine. These are typically found on most developers' workstations.

   - Terraform - infrastructure as code to create the environment in IBM Cloud
   - oc (OpenShift CLI) or kubectl - access your cluster
   - git - clone this repository
   - podman or docker - build your app container image

### 3. IBM Cloud API Key

An IBM Cloud API key is required for Terraform to authenticate and create resources in your account.

**What is an API Key?**

An API key is a secure credential that allows Terraform to interact with IBM Cloud services on your behalf without requiring interactive login.

**How to Create an IBM Cloud API Key:**

**Step 1: Access the API Keys Page**

1. Log in to [IBM Cloud Console](https://cloud.ibm.com)
2. Click on **Manage** in the top menu bar
3. Select **Access (IAM)**
4. In the left sidebar, click **API keys**

**Step 2: Create a New API Key**

1. Click the **Create** button (or **Create an IBM Cloud API key**)
2. In the dialog that appears:
   - **Name**: Enter a descriptive name (e.g., `terraform-paas-starter`)
   - **Description**: (Optional) Add a description like "API key for PaaS Starter Terraform deployment"
3. Click **Create**

**Step 3: Download and Save Your API Key**

1. A dialog will appear showing your API key
2. Click **Download** to save the key to a file, or click **Copy** to copy it to your clipboard
3. **IMPORTANT**: Save this key securely - you won't be able to see it again!

**Step 4: Store Your API Key Securely**

⚠️ **Security Best Practices:**

- **Never commit your API key to version control** (Git, GitHub, etc.)
- Store it in a secure password manager
- Don't share it via email or messaging apps
- Don't hardcode it in your Terraform files
- Use environment variables or secure secret management tools

### 4. IBM Cloud CLI

The IBM Cloud Command Line Interface (CLI) is required for managing IBM Cloud resources and accessing your OpenShift cluster after deployment.

**What is the IBM Cloud CLI?**

The IBM Cloud CLI is a command-line tool that allows you to interact with IBM Cloud services, manage resources, and configure your environment without using the web console.

**Installation Instructions:**

Consult the IBM Cloud CLI installation documentation [CLI Install](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) and follow the installation instructions for your operating system.

**Verify Installation:**

After installation, verify the CLI is working:

```bash
$ ibmcloud version
```

You should see output similar to:
```bash
ibmcloud version 2.23.0+...
```

**Install Required Plugins:**

After installing the IBM Cloud CLI, install the required plugins for working with OpenShift and Container Registry:

```bash
# Install the Container Service plugin (for OpenShift)
$ ibmcloud plugin install container-service

# Install the Container Registry plugin
$ ibmcloud plugin install container-registry

# Verify plugins are installed
$ ibmcloud plugin list
```

**Log In to IBM Cloud:**

Test your CLI installation by logging in:

```bash
# Log in with your API key
$ ibmcloud login --apikey YOUR_API_KEY

# Or log in interactively
$ ibmcloud login
```

**Set Target Region:**

Set your target region to match your Terraform configuration:

```bash
$ ibmcloud target -r us-south
```

### Prerequisites Summary

Before proceeding with deployment, ensure you have:

- ✅ IBM Cloud account with administrator permissions
- ✅ Terraform 1.0.0 or higher installed
- ✅ IBM Cloud API key created and saved securely
- ✅ IBM Cloud CLI installed with required plugins
- ✅ OpenShift CLI (oc) or kubectl installed
- ✅ Podman or Docker installed and configured
- ✅ Git installed and configured

**Quick Verification:**

Run these commands to verify all prerequisites:

```bash
# Check Git
$ git --version

# Check Terraform
$ terraform version

# Check IBM Cloud CLI
$ ibmcloud version
$ ibmcloud plugin list

# Check OpenShift CLI
$ oc version
$ kubectl version

# Check build tool
$ podman version
$ docker version

# Check API key (should not error)
$ ibmcloud login --apikey <api key>
```

If all commands succeed, you're ready to proceed with deployment!

---

## 🚀 Quick Start

This guide will walk you through deploying the complete IBM Cloud PaaS environment in under an hour. Follow these steps in order for the smoothest experience.

### Step 1: Clone the Repository

First, get a local copy of this project:

```bash
$ git clone https://github.com/IBM/paas-starter.git
$ cd paas-starter
```

### Step 2: Configure Your Environment

**2.1 Terraform Variables**

The terraform configuration uses variables to allow you to customize the deployment. There is a file called `terraform.tfvars-example` that contains all the variables and their default values. You can copy this file to `terraform.tfvars` and then edit the values to customize your deployment.
There are only 2 variables that are required. All other variables have default values that work well for most users. The two required variables are:
- `ibmcloud_api_key`: Your IBM Cloud API Key
- `postgresql_password`: The password for the PostgreSQL database

There are two ways to provide the these values to Terraform:

**Option A: Environment Variable (Recommended)**

```bash
$ export TF_VAR_ibmcloud_api_key="your-api-key-here"
$ export TF_VAR_postgresql_password="your-postgresql-password-here"
```
This keeps your API key and password out of files and is the most secure option. The `TF_VAR_` prefix is required to indicate that these variables are for Terraform.

**Option B: Terraform Variables File**

If you don't want to use environment variables, you can create a file called `terraform.tfvars` and add your variables to it. The file should be in the same directory as your Terraform configuration files.
To use the `terraform.tfvars` file, copy the `terraform.tfvars-example` file to `terraform.tfvars`:

```bash
$ cp terraform.tfvars-example terraform.tfvars
```

Then edit `terraform.tfvars` and add your API key and your Postgesql password:

```
ibmcloud_api_key = "your-api-key-here"
postgresql_password = "your-postgresql-password-here"
```

> **Note**: Care should always be taken to protect your API key and password. Do not commit them to your source code or share them with others.

**2.2 Customize Your Configuration**

Look at the `terraform_tfvars.example` file. If you would like to set any variables to something other than its default value, copy the `terraform.tfvars-example` file to `terraform.tfvars` Edit the `terraform.tfvars` file to customize your deployment. The example file has all the variables defined. You can customize these for your environment.

### Step 3: Initialize Terraform

Initialize Terraform to download required providers and modules:

```bash
$ terraform init
```

**What This Does:**
- Downloads the IBM Cloud Terraform provider
- Initializes the backend for state management
- Prepares your workspace for deployment

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of ibm-cloud/ibm...
- Installing ibm-cloud/ibm v1.x.x...

Terraform has been successfully initialized!
```

⏱️ **Time Required**: ~30 seconds

### Step 4: Review the Deployment Plan

Before creating any resources, review what Terraform will create:

```bash
$ terraform plan
```

**What to Look For:**

- **Resources to be created**: Should show ~35-40 resources
- **No errors**: Ensure there are no red error messages
- **Estimated costs**: Review the resources being created

**Key Resources You'll See:**

- 1 OpenShift cluster
- 1 Cloud Logs instance
- 1 Cloud Monitoring instance
- 1 PostgreSQL database instance
- VPC networking components (subnets, security groups)
- IAM service authorizations
- Container registry namespace

> 💰 **Cost Reminder**: Review the [Cost Considerations](#cost-considerations) section. This deployment will create billable resources.

⏱️ **Time Required**: ~1 minute

### Step 5: Deploy the Infrastructure

Now deploy all the resources to IBM Cloud:

```bash
$ terraform apply
```

**What Happens:**

1. Terraform will show you the plan again
2. You'll be prompted: `Do you want to perform these actions?`
3. Type `yes` and press Enter to proceed
4. Terraform will create all resources in the correct order
5. Progress will be displayed in your terminal

**Deployment Stages:**

```
Stage 1: VPC and Networking (2-3 minutes)
  ├─ Creating VPC
  ├─ Creating subnets
  └─ Configuring security groups

Stage 2: OpenShift Cluster (25-35 minutes)
  ├─ Provisioning master nodes
  ├─ Provisioning worker nodes
  └─ Configuring cluster networking

Stage 3: Observability (5-10 minutes)
  ├─ Creating Cloud Logs instance
  ├─ Creating Cloud Monitoring instance
  └─ Integrating with cluster

Stage 4: Database (5-10 minutes)
  ├─ Provisioning PostgreSQL instance
  ├─ Configuring networking
  └─ Setting up credentials

Stage 5: Finalization (1-2 minutes)
  ├─ Creating IAM authorizations
  ├─ Creating container registry namespace
  └─ Outputting connection details
```

⏱️ **Total Time Required**: 30-45 minutes

**Success Indicators:**

When deployment completes successfully, you'll see:

```
Apply complete! Resources: 39 added, 0 changed, 0 destroyed.
Outputs:

cluster_id = "abc123..."
cluster_name = "paas-starter-cluster"
database_connection_string = "postgres://..."
logs_instance_id = "xyz789..."
monitoring_instance_id = "mon456..."
```

### Step 6: Access Your Resources

After deployment completes, access your newly created resources:

**6.1 OpenShift Cluster**

Assuming you have the IBM Cloud command line interface and your API key:

```bash
# Log in to IBM Cloud CLI
$ ibmcloud login --apikey $TF_VAR_ibmcloud_api_key

# Get cluster configuration
$ ibmcloud oc cluster config --cluster $(terraform output -raw cluster_name)
```

Then verify cluster access:

```bash
$ oc get nodes
```

You should see your worker nodes listed.

**6.2 IBM Cloud Console**

If you are interested in exploring your created resources, access your resources through the web console:

1. Log in to [IBM Cloud Console](https://cloud.ibm.com/resources)
2. Navigate to **Containers** → to see your cluster
3. Navigate to **Observability** → to see your Logging and Monitoring instances
4. Navigate to **Databases** to see your PostgreSQL instance

**6.3 Get Database Credentials**

Retrieve your PostgreSQL connection details:

```bash
$ terraform output url
$ terraform output -raw certificate_base64
```

These two strings, along with the password you provided as a variable, will be used when deploying the sample application.

### Step 7: Deploy the Sample Application

Now deploy the included Node.js sample application that demonstrates database connectivity:

**7.1 Navigate to the Application Directory**

```bash
$ cd helloworld
```

**7.2 Build the Application Docker Image**

Use Podman or Docker to build the application Docker image. Get the Container Registry namespace from the terraform output and replace the `namespace` placeholder in the build command. Login to the IBM Cloud container registry and run the build command. Finally, push the image to the IBM Cloud container registry.

```bash
$ podman login us.icr.io
$ podman build --platform linux/amd64 -t us.icr.io/{namespace}/helloworld-postgres:latest .
$ podman push us.icr.io/{namespace}/helloworld-postgres:latest
```

**7.2 Configure Database Credentials**

The application will access database connection information from a secret. Add the password you provided as a variable and the connection URL and cert from the terraform output to the `secrets.yaml` file. 

The url is a long string tht looks something like this: `"postgres://admin:$PASSWORD@d9538f95-1c3f-4f7e-8308-fc984b5540dd.c7e0lq3d0hm8lbg600bg.private.databases.appdomain.cloud:31687/ibmclouddb?sslmode=verify-full"`. 

The cert is a very long alphanumeric string. Make sure you include the entire string withing the quotes.

```hcl
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  labels:
    app: helloworld-postgres
type: Opaque
stringData:
  DB_PASSWORD: "REPLACE_WITH_YOUR_PASSWORD"
  DB_URL: "REPLACE_WITH_YOUR_CONNECTION_URL"
  DB_CERT: "REPLACE_WITH_YOUR_BASE64_CERT"
```

**7.3 Configure the Deployment**

Edit the deploy.yaml file and add your namespace in the image field.

```hcl
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-postgres
  labels:
    app: helloworld-postgres
spec:
  replicas: 1
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
        image: us.icr.io/<namespace>/helloworld-postgres:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
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
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 30
          timeoutSeconds: 3
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld-postgres
  labels:
    app: helloworld-postgres
spec:
  selector:
    app: helloworld-postgres
  ports:
  - name: http
    port: 8080
    targetPort: 8080
    protocol: TCP
  type: ClusterIP
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: helloworld-postgres
  labels:
    app: helloworld-postgres
spec:
  to:
    kind: Service
    name: helloworld-postgres
    weight: 100
  port:
    targetPort: http
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
  wildcardPolicy: None

```

**7.4 Deploy to OpenShift**

```bash
$ oc apply -f secret.yaml
$ oc apply -f deploy.yaml
```

Check the success of these commands. Your pod name will differ slightly.

```bash
$ oc get secrets
NAME                      TYPE                                  DATA   AGE
postgres-credentials      Opaque                               3      6h37m
```

```bash
$ oc get pods
NAME                                  READY   STATUS    RESTARTS   AGE
helloworld-postgres-xxxxxxxxx-xxxxx   1/1     Running   0          6h38m
```

```bash
$ oc get services
NAME                        TYPE           CLUSTER-IP       EXTERNAL-IP                            PORT(S)    AGE
helloworld-postgres         ClusterIP      172.21.250.166   <none>                                 8080/TCP   6h39m
```

```bash
$ oc get routes
NAME                  HOST/PORT                                                                                                           PATH   SERVICES              PORT   TERMINATION     WILDCARD
helloworld-postgres   helloworld-postgres-default.xyz-cluster-xxxxxxxxxxxxxxxxxxx-0000.us-south.containers.appdomain.cloud          helloworld-postgres   http   edge/Redirect   None
```


**7.5 Access the Application**

Get the application URL. It will be the long strong starting with helloworld-postgres.

```bash
oc get route helloworld-postgres
```

Paste that URL string in your browser to see the running application!

![Postgresql app](images/pg-app.jpg)

To see all the data in the database, append /words to the end of your URL. You will see an output that looks like this:

```
[{"_id":1,"word":"superduper","definition":"a very good thing"},{"_id":2,"word":"latergater","definition":"goodbye"}]
```

⏱️ **Time Required**: 10-15 minutes

### Step 8: Verify Everything Works

Visit your application URL and verify:
- The page loads successfully
- Database queries are working
- Data can be inserted and retrieved

**✅ Logging**

1. Go to IBM Cloud Console → **Observability** → **Logging**
2. Select your Cloud Logs instance
3. You should see logs from your OpenShift cluster and application

**✅ Monitoring**

1. Go to IBM Cloud Console → **Observability** → **Monitoring**
2. Select your Cloud Monitoring instance
3. You should see metrics for your cluster (CPU, memory, network)

### Step 9: Clean Up (When Done)

When you're finished exploring, clean up all resources to avoid ongoing charges:

```bash
# Return to the main project directory
cd /path/to/paas-starter

# Destroy all resources
terraform destroy
```

**What Happens:**

1. Terraform will show you all resources to be destroyed
2. You'll be prompted: `Do you really want to destroy all resources?`
3. Type `yes` to confirm
4. Terraform will delete all resources in reverse order

⏱️ **Time Required**: 10-15 minutes

> ⚠️ **Warning**: This will permanently delete:
> - Your OpenShift cluster and all deployed applications
> - All logs in Cloud Logs
> - All metrics in Cloud Monitoring  
> - Your PostgreSQL database and all data
> - All associated networking resources
>
> **Make sure to backup any important data before destroying!**

**Verify Cleanup:**

After destruction completes, verify in IBM Cloud Console that all resources are gone:

1. Check **OpenShift** → **Clusters** (should be empty)
2. Check **Databases** (should be empty)
3. Check **Observability** (instances should be deleted)

---

## 🎉 Congratulations!

You've successfully deployed a complete PaaS environment on IBM Cloud! You now have:

- ✅ A running OpenShift cluster
- ✅ Integrated logging and monitoring
- ✅ A PostgreSQL database
- ✅ A deployed sample application

### Next Steps

- **Customize the Sample App**: Modify the Node.js application to fit your needs
- **Explore OpenShift**: Learn about deployments, services, and routes
- **Review Logs**: Explore Cloud Logs to understand application behavior
- **Monitor Performance**: Use Cloud Monitoring to track resource usage
- **Scale Your Application**: Increase replicas or add more worker nodes
- **Deploy Your Own App**: Use this environment for your own applications

---

## 📱 Sample Application Details

The included sample application demonstrates a complete database-backed web application running on OpenShift. This section provides detailed information about the application's architecture, components, and how to customize it for your needs.

### Application Overview

**Name**: HelloWorld PostgreSQL Application

**Purpose**: A simple word dictionary application that demonstrates:
- Database connectivity (PostgreSQL)
- RESTful API design
- Container deployment on OpenShift
- Secure credential management
- Health checks and monitoring

**Technology Stack**:
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL (IBM Cloud Databases)
- **Orchestration**: OpenShift/Kubernetes

### Application Architecture

```
┌─────────────────────────────────────────────────────┐
│                    OpenShift Cluster                │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │         HelloWorld Application Pod            │  │
│  │                                               │  │
│  │  ┌──────────────────────────────────────┐     │  │
│  │  │  Express.js Web Server               │     │  │
│  │  │  - Serves static HTML/CSS/JS         │     │  │
│  │  │  - REST API endpoints                │     │  │
│  │  │  - Port 8080                         │     │  │
│  │  └──────────────────────────────────────┘     │  │
│  │                    │                          │  │
│  │                    │ PostgreSQL Client        │  │
│  │                    ▼                          │  │
│  │  ┌──────────────────────────────────────┐     │  │
│  │  │  Database Connection (pgclient.js)   │     │  │
│  │  │  - SSL/TLS encrypted                 │     │  │
│  │  │  - Credentials from Kube Secret      │     │  │
│  │  └──────────────────────────────────────┘     │  │
│  └───────────────────────────────────────────────┘  │
│                       │                             │
│                       │ Secure Connection           │
│                       ▼                             │
└─────────────────────────────────────────────────────┘
                        │
                        │ Private Network
                        ▼
┌─────────────────────────────────────────────────────┐
│         IBM Cloud Databases for PostgreSQL          │
│         - Managed database service                  │
│         - Automatic backups                         │
│         - High availability                         │
└─────────────────────────────────────────────────────┘
```

### File Structure

```
helloworld/
├── server.js              # Main application server
├── pgclient.js           # PostgreSQL connection handler
├── package.json          # Node.js dependencies
├── Dockerfile            # Container image definition
├── deploy.yaml           # Kubernetes deployment configuration
├── secret.yaml           # Database credentials (template)
└── public/               # Static web assets
    ├── index.html        # Frontend UI
    └── images/           # images
```

### Key Components

#### 1. Web Server (server.js)

The main application server built with Express.js:

**Features**:
- Serves static files from the `public/` directory
- Provides REST API endpoints for word management
- Handles database operations
- Runs on port 8080

**API Endpoints**:

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/` | Serves the main HTML page | None | HTML page |
| GET | `/words` | Retrieves all words from database | None | JSON array of words |
| PUT | `/words` | Adds a new word to database | `{word, definition}` | JSON object of created word |

**Example API Usage**:

```bash
# Get all words
$ curl http://your-app-url/words

# Add a new word
$ curl -X PUT http://your-app-url/words \
    -H "Content-Type: application/json" \
    -d '{"word":"hello","definition":"a greeting"}'
```

#### 2. Database Client (pgclient.js)

Handles PostgreSQL database connections:

**Features**:
- Reads credentials from environment variables
- Establishes SSL/TLS encrypted connection
- Creates the `words` table if it doesn't exist
- Validates database certificate

**Environment Variables Required**:
- `DB_PASSWORD`: PostgreSQL database password
- `DB_URL`: PostgreSQL connection URL
- `DB_CERT`: Base64-encoded SSL certificate

**Database Schema**:

```sql
CREATE TABLE words (
    _id SERIAL PRIMARY KEY,
    word VARCHAR(255),
    definition VARCHAR(255)
);
```

#### 3. Frontend (public/index.html)

Simple web interface for the dictionary application:

**Features**:
- Add new words and definitions
- View all stored words
- Responsive design
- Real-time updates

**User Interface**:
- Input form for word and definition
- Submit button to add entries
- List display of all words
- Clean, minimal design

#### 4. Container Configuration (Dockerfile)

Docker build for optimized image size:

**Build Process**:
1. Uses Node.js base image
2. Copies application files
3. Installs dependencies
4. Exposes port 8080
5. Sets startup command

**Image Characteristics**:
- Base: Node.js (latest LTS)
- Size: ~200-300 MB
- Platform: linux/amd64
- Registry: IBM Cloud Container Registry

#### 5. Kubernetes Deployment (deploy.yaml)

OpenShift/Kubernetes deployment configuration:

**Resources Defined**:

**Deployment**:
- Resource limits: 256Mi memory, 200m CPU
- Resource requests: 128Mi memory, 100m CPU
- Liveness probe on port 8080
- Readiness probe on port 8080
- Environment variables from secret

**Service**:
- Type: ClusterIP
- Port: 8080
- Selector: app=helloworld-postgres

**Route** (OpenShift):
- TLS termination: edge
- Insecure traffic: redirect to HTTPS
- Exposes application externally

#### 6. Credentials Management (secret.yaml)

Kubernetes Secret for database credentials:

**Template Structure**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
type: Opaque
data:
  DB_PASSWORD: <base64-encoded-password>
  DB_URL: <base64-encoded-url>
  DB_CERT: <base64-encoded-certificate>
```

**Security Features**:
- Credentials stored as Kubernetes Secret
- Base64 encoding (not encryption - use sealed secrets for production)
- Mounted as environment variables
- Not committed to version control

### How the Application Works

**1. Application Startup**:
```
1. Container starts → Node.js loads server.js
2. Express server initializes on port 8080
3. pgclient.js connects to PostgreSQL database
4. Creates 'words' table if it doesn't exist
5. Server begins listening for requests
```

**2. Adding a Word**:
```
User → Frontend Form → PUT /words → Express Server
                                          ↓
                                    Validate Input
                                          ↓
                                    SQL INSERT Query
                                          ↓
                                    PostgreSQL Database
                                          ↓
                                    Return Created Word
                                          ↓
                                    Update Frontend Display
```

**3. Viewing Words**:
```
Page Load → GET /words → Express Server
                              ↓
                         SQL SELECT Query
                              ↓
                         PostgreSQL Database
                              ↓
                         Return All Words
                              ↓
                         Render in Frontend
```

### Troubleshooting Common Issues

#### Application Won't Start

**Symptom**: Pods in CrashLoopBackOff state

**Possible Causes**:
1. Missing database credentials
2. Invalid database connection string
3. Database not accessible from cluster

**Solutions**:
```bash
# Check secret exists
$ oc get secret postgres-credentials

# Verify secret contents (base64 decode)
$ oc get secret postgres-credentials -o yaml

# Check pod logs for errors
$ oc logs helloworld-postgres-xxxxx-xxxxx
```

#### Database Connection Fails

**Symptom**: "Error: Database configuration not found" in logs

**Solutions**:
1. Verify secret is created: `oc get secret postgres-credentials`
2. Check secret is mounted in deployment
3. Verify database credentials are correct
4. Test database connectivity from pod

#### Application Not Accessible

**Symptom**: Cannot access application URL

**Solutions**:
```bash
# Check route exists
$ oc get route helloworld-postgres

# Verify service is running
$ oc get svc helloworld-postgres

# Check pods are ready
$ oc get pods -l app=helloworld-postgres

# Test service internally
$ oc run test --image=curlimages/curl --rm -it -- curl http://helloworld-postgres:8080
```

---
