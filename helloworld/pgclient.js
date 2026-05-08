const { Client } = require('pg')

// Read configuration from environment variables or fall back to config.json
let password, uri, cert;

if (process.env.DB_PASSWORD && process.env.DB_URL && process.env.DB_CERT) {
  // Use environment variables (preferred for containers)
  password = process.env.DB_PASSWORD;
  uri = process.env.DB_URL.replace('$PASSWORD', password).replace(/\?sslmode.+$/,'');
  cert = Buffer.from(process.env.DB_CERT, "base64").toString();
} else {
    console.error("Error: Database configuration not found. Please provide");
    console.error("  - Environment variables: DB_PASSWORD, DB_URL, DB_CERT");
}

module.exports = async function () {

  const client = new Client({
    connectionString: uri,
    ssl: {
      ca: cert,
      rejectUnauthorized: true
    }
  })

  await client.connect()
  console.log("Connected!")

  //Now create a table for the words
  const query = 'CREATE TABLE IF NOT EXISTS words (_id SERIAL PRIMARY KEY, word varchar(255), definition varchar(255))'
  await client.query(query)
  
  console.log("table created")

  return client
}