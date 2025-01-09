---
layout: page
title: "Chicory Integration Guide"
date:   2025-01-07 00:16:37 -0800
categories: jekyll update
---

# Chicory AI Integration Guide for Platform Services

This guide provides detailed steps for integrating your infrastructure with various platforms, including Databricks, GitHub, Confluence, and Slack. The goal is to ensure the services can perform API requests for reading data, accessing repositories, exporting documents, and interacting with users.

## 1. **AWS Infrastructure Setup**

- **Terraform**: We will provide Terraform scripts to deploy the necessary infrastructure.
- **Required Services**:
    - **EKS (Elastic Kubernetes Service)**: For managing containerized applications.
    - **S3 (Simple Storage Service)**: For storing data and logs.
    - **API Gateway**: To manage APIs for service communication.
    - **VPC (Virtual Private Cloud)**: For secure network isolation.

## 2. **Service Overview**

### **Training Service**
- Responsible for user onboarding and integration.
- Continuously indexes and manages the knowledge graph to ensure the system has up-to-date data relationships and insights.

### **Inference Service**
- An agentic service designed for extracting the correct context from data and performing actions based on user interactions or automated triggers.

## 3. **OpenAI API Access**
- **Agent Access Requirements**: Access frequency and data rate can be customized based on the user’s preferences and data handling needs.
- Use `OPENAI_API_KEY` to enable API interactions.

## 4. **Platform Integration Steps**

### **1. Databricks Integration**

#### **Goal**: Enable API access to run "GET" requests and query data for reading.

**Current Support Scope**:
* Single Catalog
* Single Schema

**Requirements**:
- Databricks workspace with API integration enabled.
- API token for authentication.
- `values.yaml` file to pass necessary configurations as secret environment variables (can be found in the Helm chart directory.)

**Steps**:

1. **Generate API Token**:
   - Log in to your Databricks workspace.
   - Go to **User Settings** > **Access Tokens**.
   - Create a new token and save it securely. Take care since you won't be able to see this again.

2. **Update Values**:
   - Add the following values in the `values.yaml` file or pass them as environment variables:
   
   For Databricks Integration:
     - `DATABRICKS_ACCESS_TOKEN`-  The API token generated in Step 1.
     - `DATABRICKS_HOST` - URL of your Databricks workspace (e.g., https://<your-workspace>.cloud.databricks.com).
     - `DATABRICKS_HTTP_PATH` - HTTP path for your Databricks cluster or SQL endpoint. This is found under the **Cluster** or **SQL Endpoint** details in Databricks.e
     - `DATABRICKS_CATALOG`: The catalog name in your Databricks environment, under which the data resides. 
     - `DATABRICKS_SCHEMA` :  The schema within the catalog where your target tables or data structures are located.

### **2. Google Docs**

#### **Goal**: Enable API access to run "GET" on google docs.

**Requirements**:
- Google Cloud account access with Google Doc API integration enabled.
- Credentials for authentication.
- Download credentials json file to pass necessary configurations as environment variables (can be download from Google cloud console.)

**Steps**:
1. **Set Up Google Cloud Project**
   1. Visit the [Google Cloud Console](https://console.cloud.google.com).
   2. Create a new project or select an existing one.
   3. Enable the [Google Drive API](https://developers.google.com/docs/api/reference/rest):
      * Navigate to `APIs & Services > Library`.
      * Search for "Google Drive API" and enable it.
2. **Set Up a Service Account**
   1. Go to Google Cloud Console:
      * Navigate to Google Cloud Console.
   2. Create a Service Account:
      * Go to `IAM & Admin > Service Accounts`.
      * Click Create Service Account.
      * Provide a name and description for the account.
   3. Assign Permissions:
      * Assign the `Editor` or `Owner` role to the Service Account, or a custom role that allows accessing Google Drive files.
   4. Generate a Key:
      * After creating the Service Account, select it from the list.
      * Click Add Key > Create New Key and choose `JSON`.
      * Download the JSON key file (contains credentials like `client_email`, `private_key`, etc.).
      * You will need to extract information from this file into deployment secrets.
      ![image](/images/google_sa1.png)
      ![image](/images/google_sa2.png)
3. **Share the Google Drive Folder with the Service Account**
   1. Open Google Drive and locate the folder you want to access.
   2. Share the folder with the Service Account's email (`<service-account-name>@<project-id>.iam.gserviceaccount.com`) and give it appropriate permissions (e.g., Viewer, Editor).
4. Update `values.yaml` file with environment variables:
    
   For Google Docs Integration:
      - `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID`: Extract from client_secret...json file
      - `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY`: Extract from client_secret...json file
      - `GOOGLE_SERVICE_ACCOUNT_CLIENT_ID`: Extract from client_secret...json file
      - `GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL`: Extract from client_secret...json file
      - `GOOGLE_SERVICE_ACCOUNT_CLIENT_CERT_URL`: Extract from client_secret...json file
      - `GOOGLE_PROJECT_ID`: Google Cloud Project ID with Enabled Google Doc API access.
      - `GOOGLE_FOLDER`: Google Folder Id. Copy the folder's ID from the URL: https://drive.google.com/drive/folders/<folder-id>

### **3. Confluence**

#### **Goal**: Access and Download documents (html) from Confluence account.

**Current Support Scope**:
* Supports Confluence Cloud and Confluence Server/Data Center.
* Uses the Confluence REST API for programmatic access to access Single Space.
* Outputs HTML files for all pages in the specified space.

**Requirements**:
- A Confluence account with access to API token generation.
- A Confluence Target Space.

**Steps**:
1. **Base URL**: The URL of your Confluence instance
   - Example for Confluence Cloud: `https://your-domain.atlassian.net/wiki`
   - Example for Confluence Server/Data Center: `https://confluence.your-company.com`
2. **API Token**:
   - For Confluence Cloud: Generate via Atlassian account's API token page: https://id.atlassian.com/manage/api-tokens
   - For Server/Data Center: Use username/password or request an API token if supported.
3. **Space Key**:
   - The unique identifier for the Confluence space.
   - Found in the URL, e.g., `/spaces/SPACEKEY/overview`.
4. Update `values.yaml` file witk Slack environment variables:
    
   For Confluence Space Integration:
      - `CONFLUENCE_BASE_URL`: Base Url of Confluence Domain. eg: "https://chicory.atlassian.net/wiki/"
      - `CONFLUENCE_API_TOKEN`: API Token with appropriate access. 
      - `CONFLUENCE_SPACE_KEY`: Space ID.
      - `CONFLUENCE_EMAIL`: User email, who owns the Token.


### **4. GitHub Integration**

#### **Goal**: Enable API access to fetch repository data, read files, and integrate with an AI bot for automated analysis.

**Current Support Scope**:
- Supports repository-level access for reading files.
- Automates cloning, reading, and updating repository files.
- Provides integration with an AI agent for processing code or documentation.

**Requirements**:
- A GitHub account with access to the repositories you wish to integrate.
- A personal access token (PAT) or organization-level token with the required scopes.
- A `.yaml` configuration file for passing environment variables securely.

**Steps**:

1. **Generate a Personal Access Token (PAT)**:
   - Log in to your GitHub account.
   - Go to **Settings > Developer Settings > Personal Access Tokens > Tokens (classic)**.
   - Generate a new token with the following scopes:
      - `repo`: Full control of private repositories.
      - `read:org`: Read-only access to organization data (if accessing organizational repositories).
      - `workflow`: Access workflows for triggering or managing GitHub Actions (optional).
   - Save the token securely, as it will not be visible again.

2. **Update Values**:
   - Add the following values in the `values.yaml` file or pass them as environment variables:
   
   For Databricks Integration:
      - `GITHUB_USERNAME`: Your GitHub username.
      - `GITHUB_ACCESS_TOKEN`: The personal access token generated in Step 1.
      - `GITHUB_BASE_URL`: The base URL for your GitHub instance (e.g., https://api.github.com for GitHub cloud or https://<enterprise-domain>/api/v3 for enterprise GitHub).

### **5. Slack Integration**

#### **Goal**: Set up an installable Slack bot to fetch chat messages from channels and integrate with an AI bot for the inference service.

**Requirements**:
- A Slack bot token with necessary permissions.
- A Slack workspace configured to allow bot installation.

**Steps**:

1. **Create a Slack App**:
   - Go to the [Slack API Dashboard](https://api.slack.com/apps).
   - Click Create an App and choose From Scratch.
   - Provide an App Name (e.g., "Chicory Bot") and select your workspace.
   - Click **Create App**.

2. **Configure OAuth & Permissions:**:
   - In the App settings, navigate to OAuth & Permissions.
   - Add the following Bot Token Scopes under **Scopes**:
     - **`chat:write`**: To send messages in channels and DMs.
     - **`channels:history`**: To read message history from public channels.
     - **`app_mentions:read`**: To listen for mentions of the bot.
     - **`im:history`**: To read message history in direct messages (optional).
     - **`channels:read`**: To access basic channel information.
   - Save changes.
      - Slack Integration Config :![image](/images/slack.png)
      ```bash
      In short - the steps to verify permissions:
         1. Navigate to your Slack App dashboard at Slack API Apps.
         2. Go to **OAuth & Permissions** and review the scopes listed under Bot Token Scopes.
         3. Ensure the following scopes are included:
            chat:write
            channels:history
            app_mentions:read
            im:history (optional)
            channels:read
      ```
   - Generate OAuth Tokens:
      - Click Install App to Workspace.
      - Review the permissions and authorize the app for your workspace.
      - Save the generated Bot User OAuth Token securely.
      - Slackbot Token: ![image](/images/slack_oauth.png)
   - Slackbot Signing Secret: ![image](/images/slack_sign_sec.png)
   - Slackbot Bot Id: With the OAuth Access Token, you can request for BOT ID, It should start with B (e.g., B01ABCDEFG).
   ```
   curl -X POST -H "Authorization: Bearer xoxb-your-token" https://slack.com/api/auth.test
   ```

3. Update `values.yaml` file witk Slack environment variables:
    
   For Slack Integration:
      - `SLACK_BOT_ID`: The unique ID of your Slack bot, generated when you create the bot in the Slack App dashboard and is used to reference the bot in Slack interactions. 
      - `SLACK_SIGNING_SECRET`: The signing secret for validating Slack requests to your backend and helps to ensures that requests are genuinely from Slack. 
      - `SLACK_BOT_TOKEN`: The API token for your Slack bot, used for authenticating API calls made on behalf of the bot (e.g., sending messages or interacting with users).


5. **Set Up Event Subscriptions**:
   - Navigate to **Event Subscriptions** in your Slack App settings.
   - Enable **Event Subscriptions** and set the **Request URL** to your backend endpoint (e.g., `https://your-backend-service.com/slack/events`).
   - Add the following events under **Subscribe to bot events**:
     - **`app_mention`**: To trigger the bot when it is mentioned.
     - **`message.im`**: To listen for direct messages (optional for private interactions).

6. **Configure and Reinstall the App**:
   - After configuring the event subscriptions and permissions, reinstall the app if needed by navigating to **Install App** > **Reinstall to Workspace**.

7. **Test the Bot**:
   - Mention the bot in a channel using `@your-bot-name` to ensure it interacts with the backend inference service and responds.
   - Send a direct message to test interactions if `message.im` is configured.
   - Error Scenarios: Test how the bot behaves when it cannot reach the backend or when invalid commands are sent.

8. **Set Up AI Bot for Inference**:
   - Ensure the bot can process and respond to user interactions. Implement a backend service to handle incoming events from Slack, process them, and send responses back through Slack’s Web API.
   - Example to post a response:
     ```bash
     curl -X POST -H "Authorization: Bearer <your-bot-token>" -H "Content-type: application/json" \
     --data '{
       "channel": "<channel-id>",
       "text": "Here is your processed response!"
     }' https://slack.com/api/chat.postMessage
     ```

- Slack Webhooks Details: [link](https://api.slack.com/messaging/webhooks) 
   - Note: Webhooks can be created in Incoming Webhooks under the Slack App settings.
   - Example payload for sending messages with webhooks
      ```bash 
      {
      "text": "This is a test message",
      "channel": "#general"
      }
      ```

9. **Add the app/bot to target channel**:
   - add the app to a channel: settings of a channel -> Integrations -> add apps -> target <Chicory> app: ![alt text](/images/slack-app.png)
   - add the bot to the channel: like an user by using @Chicory: ![alt text](/images/slack-bot.png)

This setup allows the Slack bot to interact with users, fetch content from channels, and pass user inputs to the backend inference service for processing and responses.

---

## **Summary**

Following the above steps will enable your infrastructure and services to integrate seamlessly with Databricks, GitHub, Confluence, and Slack, allowing for data access, document management, and user interactions.
