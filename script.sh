#!/bin/bash

# chmod +x script.sh

# Request user infos
echo "New Wordpress Install"
read -p "Domain (without www): " DOMAIN
read -p "DB Name: " DB_NAME
read -p "DB User: " DB_USER
read -p "Email for SSL: " SSL_EMAIL

# Generate secure password
while true; do
    DB_PASS=$(tr -dc 'A-Za-z0-9!@#$%&*-_+=' < /dev/urandom | head -c 20)
    # Usando Perl-style regex com [[ ]] para escapar corretamente os caracteres especiais
    if [[ "$DB_PASS" =~ [A-Z] ]] && [[ "$DB_PASS" =~ [a-z] ]] && [[ "$DB_PASS" =~ [0-9] ]] && [[ "$DB_PASS" =~ [\!\@\#\$\%\&\*\-\_\+\=] ]]; then
        break
    fi
done
echo "Generated pass: $DB_PASS"



# Error handler
function check_error {
    if [ $? -ne 0 ]; then
        echo "Erro na execução: $1"
        exit 1
    fi
}

# Update and install
sudo apt update
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql certbot python3-certbot-apache -y
check_error "Components Install"

# MySQL Settings
sudo mysql_secure_installation
check_error "Secure MySQL"

# Prepare website local
sudo mkdir -p /var/www/$DOMAIN/public_html
sudo chown -R www-data:www-data /var/www/$DOMAIN
sudo chmod -R 755 /var/www/$DOMAIN

# Create DB and User
sudo mysql -e "CREATE DATABASE $DB_NAME; CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"
check_error "Database settings"

# Download and setup Wordpress
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sed -i "s|database_name_here|$DB_NAME|; s|username_here|$DB_USER|; s|password_here|$DB_PASS|" /tmp/wordpress/wp-config.php
sudo rsync -avP /tmp/wordpress/ /var/www/$DOMAIN/public_html/
check_error "WordPress Settings"

#  Virtual Host
VHOST_FILE="/etc/apache2/sites-available/$DOMAIN.conf"
sudo bash -c "cat > $VHOST_FILE <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot /var/www/$DOMAIN/public_html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/$DOMAIN/public_html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"
sudo a2ensite $DOMAIN.conf
sudo a2enmod rewrite
sudo systemctl reload apache2
check_error "Virtual Host"

# Open WordPress Directory
cd /var/www/$DOMAIN/public_html

# Create .htaccess
sudo touch .htaccess
sudo bash -c 'cat > .htaccess <<EOF
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF'

# htaccess permissions
sudo chown www-data:www-data .htaccess
sudo chmod 644 .htaccess

# SSL
sudo certbot --apache -n --redirect --agree-tos --hsts --email $SSL_EMAIL --domains $DOMAIN,www.$DOMAIN
check_error "SSL"

# Limpa arquivos temporários
sudo rm -rf /tmp/wordpress
sudo rm /tmp/latest.tar.gz

# Apache test and restart
sudo apachectl configtest
check_error "Apache test"
sudo systemctl restart apache2
check_error "Apache restart"

# Delet script
rm -rf ~/wordpress-install-ubuntu

# Install WordPress Security Toolkit
if [ -d "/home/ubuntu/wordpress-security-toolkit" ]; then
    echo "/home/ubuntu/wordpress-security-toolkit already exist."
else
    echo "/home/ubuntu/wordpress-security-toolkit don't exist. Creating..."

    # 1. Cloning
    git clone https://github.com/NereuFajardo/wordpress-security-toolkit.git /home/ubuntu/wordpress-security-toolkit

    # 2. Open
    cd /home/ubuntu/wordpress-security-toolkit || exit

    # 3. Grant
    chmod +x scripts/*.sh
    chmod +x run.sh

    # 4. Run
    sudo ./run.sh

    # 5. Cron Tab
    crontab -e

    # 6. Insert
    echo "Configurando o cron job..."
    echo "0 3 * * 0 /home/ubuntu/wordpress-security-toolkit/run.sh >> /var/log/run_sh_log.log 2>&1" >> temp_crontab
    crontab temp_crontab
    rm temp_crontab

    echo "Wordpress Security Toolkit has done."
fi

echo "Wordpress Sucessfull install for $DOMAIN!"
