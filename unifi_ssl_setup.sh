#!/bin/bash

# 1. Install Certbot
sudo apt update
sudo apt install -y certbot

# 2. Obtain the Certificate
sudo certbot certonly --standalone -d unifi.itgold.net --email mina.info.tech@gmail.com --agree-tos

# If the certificate is successfully obtained, proceed to configure UniFi
if [ $? -eq 0 ]; then

    # 3. Configure UniFi Controller to use the SSL certificate

    # Backup the original keystore for safety
    sudo cp /var/lib/unifi/keystore /var/lib/unifi/keystore.backup
    
    # Convert the Let's Encrypt certificate to a format the UniFi Controller can read
    sudo openssl pkcs12 -export -in /etc/letsencrypt/live/unifi.itgold.net/fullchain.pem -inkey /etc/letsencrypt/live/unifi.itgold.net/privkey.pem -out /tmp/cert.p12 -name unifi -password pass:unifi
    
    # Import the new certificate into the UniFi Controller's keystore
    sudo keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /var/lib/unifi/keystore -srckeystore /tmp/cert.p12 -srcstoretype PKCS12 -srcstorepass unifi -alias unifi
    
    # Restart the UniFi Controller to apply the changes
    sudo service unifi restart

    echo "Certificate has been successfully applied to UniFi Controller."

    # 4. Set up automatic renewal
    
    # Create a post-renewal hook script
    echo '#!/bin/bash
    sudo openssl pkcs12 -export -in /etc/letsencrypt/live/unifi.itgold.net/fullchain.pem -inkey /etc/letsencrypt/live/unifi.itgold.net/privkey.pem -out /tmp/cert.p12 -name unifi -password pass:unifi
    sudo keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /var/lib/unifi/keystore -srckeystore /tmp/cert.p12 -srcstoretype PKCS12 -srcstorepass unifi -alias unifi
    sudo service unifi restart' > /tmp/renew_unifi_cert.sh
    
    # Make the script executable
    sudo chmod +x /tmp/renew_unifi_cert.sh
    
    # Add the renewal command to cron
    echo "@monthly root certbot renew --post-hook '/tmp/renew_unifi_cert.sh'" | sudo tee -a /etc/crontab

    echo "Automatic renewal setup complete."

else
    echo "Failed to obtain a certificate. Please check your domain and DNS settings."
fi
