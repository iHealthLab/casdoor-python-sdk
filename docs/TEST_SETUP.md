# Test Setup Guide for Custom Casdoor Server

This guide explains how to configure the tests to use your own Casdoor server instead of the demo server.

## Prerequisites

1. Access to your Casdoor server at `https://auth.ihealth-eng.com`
2. Admin access to create applications and configure settings
3. The following information from your Casdoor server:
   - Organization name
   - Application name
   - Client ID
   - Client Secret
   - JWT Public Key (Certificate)

## Step 1: Get Required Information from Your Casdoor Server

### 1.1 Get Organization Name
1. Log into your Casdoor server
2. Go to **Organizations** page
3. Note the name of the organization you want to use for testing

### 1.2 Create or Get Application
1. Go to **Applications** page
2. Either create a new application for testing or use an existing one
3. Note the application name
4. In the application settings, ensure:
   - **Enable password grant type** is checked (for password-based tests)
   - **Enable authorization code grant type** is checked (for OAuth tests)
   - **Redirect URLs** are configured if needed

### 1.3 Get Client ID and Client Secret
1. In your application settings, find:
   - **Client ID** (copy this)
   - **Client Secret** (copy this - you may need to click "Show" to reveal it)

### 1.4 Get JWT Public Key (Certificate)
1. Go to **Certificates** page in your Casdoor server
2. Find the certificate used by your organization
3. Click on the certificate to view details
4. Copy the **Certificate** content (the full PEM format including `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----`)

Alternatively, you can get it via API:
```bash
curl https://auth.ihealth-eng.com/api/get-certificate?id=<org-name>/<cert-name>
```

## Step 2: Configure Test Environment

You have two options to configure the tests:

### Option A: Environment Variables (Recommended)

Create a `.env` file in the project root or export environment variables:

```bash
export CASDOOR_ENDPOINT="https://auth.ihealth-eng.com"
export CASDOOR_CLIENT_ID="your-client-id"
export CASDOOR_CLIENT_SECRET="your-client-secret"
export CASDOOR_ORGANIZATION="your-org-name"
export CASDOOR_APPLICATION="your-app-name"
export CASDOOR_JWT_PUBLIC_KEY="-----BEGIN CERTIFICATE-----
...your certificate content...
-----END CERTIFICATE-----"
```

Or save the JWT key to a file and reference it:
```bash
export CASDOOR_JWT_PUBLIC_KEY_FILE="/path/to/certificate.pem"
```

### Option B: Direct Code Modification

Edit `src/tests/test_util.py` and update the default values:

```python
TestEndpoint = "https://auth.ihealth-eng.com"
TestClientId = "your-client-id"
TestClientSecret = "your-client-secret"
TestOrganization = "your-org-name"
TestApplication = "your-app-name"
TestJwtPublicKey = """-----BEGIN CERTIFICATE-----
...your certificate content...
-----END CERTIFICATE-----"""
```

## Step 3: Set Up Test Data on Your Server

Some tests require specific data to exist on your server:

### 3.1 Create Test Permission (for enforce tests)
1. Go to **Permissions** page
2. Create a permission named `permission-built-in` in your organization
3. Or update the test to use an existing permission name

### 3.2 Create Test User (for user tests)
1. Go to **Users** page
2. Create a test user (e.g., `test_ffyuanda`)
3. Ensure the user is in your test organization

### 3.3 Get Authorization Code (for OAuth tests)
1. Some tests require an authorization code
2. You'll need to:
   - Set up OAuth flow
   - Get an authorization code from your server
   - Update the test code in `test_oauth.py` (line 33) and `test_async_oauth.py` (line 31)

## Step 4: Run Tests

With environment variables set:
```bash
make test
```

Or if you modified `test_util.py` directly:
```bash
make test
```

## Step 5: Verify SSL Certificate

The tests now use certifi for SSL certificate verification, which should work with your server's SSL certificate. If you encounter SSL errors:

1. Ensure your server has a valid SSL certificate
2. The certificate should be trusted by standard CA authorities
3. If using a self-signed certificate, you may need to add it to your system's trust store

## Troubleshooting

### SSL Certificate Errors
- Ensure your server's SSL certificate is valid and trusted
- Check that `certifi` package is installed: `pip install certifi`

### Authentication Errors
- Verify Client ID and Client Secret are correct
- Check that the application is enabled
- Ensure grant types are enabled in application settings

### Permission Errors
- Some tests expect specific permissions to exist
- Create the required permissions or update test expectations

### User/Resource Errors
- Tests may fail if required users or resources don't exist
- Create test data or skip those specific tests

## Example Configuration Script

Create a file `setup-test-env.sh`:

```bash
#!/bin/bash
export CASDOOR_ENDPOINT="https://auth.ihealth-eng.com"
export CASDOOR_CLIENT_ID="your-client-id-here"
export CASDOOR_CLIENT_SECRET="your-client-secret-here"
export CASDOOR_ORGANIZATION="your-org-name"
export CASDOOR_APPLICATION="your-app-name"
export CASDOOR_JWT_PUBLIC_KEY_FILE="./certificate.pem"

# Run tests
make test
```

Make it executable:
```bash
chmod +x setup-test-env.sh
./setup-test-env.sh
```

## Notes

- Never commit your actual credentials to version control
- Use environment variables or `.env` files (add `.env` to `.gitignore`)
- The demo server configuration remains as fallback if environment variables are not set
- Some tests may still fail if your server doesn't have the exact same data structure as the demo server
