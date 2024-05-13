
# Wordpress Automated Install for Ubuntu 22.04

This repository provides a script designed to streamline the process of setting up WordPress on Ubuntu 22.04, especially on platforms like EC2 where manual setup can often be cumbersome. The script automates the installation, including SSL certificate configuration, and supports the setup of multiple WordPress sites on a single server.

## Key Features and Benefits of the Installation Script

- **Fast and Secure Installation**: Streamlines the entire setup process, ensuring that WordPress is quickly and securely installed on Ubuntu 22.04.

- **Automated SSL Configuration**: Integrates Let's Encrypt SSL to secure your website automatically, which is crucial for protecting your site's data and improving SEO rankings.

- **Support for Multiple Websites**: Capable of configuring multiple WordPress sites on a single server, making it ideal for developers and administrators managing multiple projects.

- **Simplified Management**: Reduces the complexity of manually configuring servers, databases, and SSL, making it easier to manage and less prone to errors.

- **Open Source and Community-Driven**: Encourages community input and improvement, helping to refine the script over time through user contributions and feedback.


## Before You Start

Before running the script, ensure that you are logged into your server via SSH and have configured your DNS settings appropriately.

### DNS Configuration

- **A Record**
  - **Host**: `@`
  - **Target**: `Your server IP`

- **CNAME Record**
  - **Host**: `www`
  - **Target**: `yoursite.com`

## Usage Instructions

1. **Clone the repository**
   ```bash
   sudo git clone https://github.com/NereuFajardo/wordpress-install-ubuntu.git
   ```

2. **Make the script executable**
   ```bash
   sudo chmod +x wordpress-install-ubuntu/script.sh
   ```

3. **Run the script**
   ```bash
   sudo ./wordpress-install-ubuntu/script.sh
   ```

### What You Will Need to Provide

When you run the script, it will ask you for:
- **Domain name** (without the www)
- **Desired database name**
- **Desired database username**
- **Email for the SSL certificate**

Simply provide the requested information and let the script handle the rest. 

Just press Yes for every MySQL question you ask

## Enjoy Your New WordPress Site!

After the script completes, your new WordPress site will be ready to use, secured with an SSL certificate, and configured according to best practices for Apache on Ubuntu 22.04.
