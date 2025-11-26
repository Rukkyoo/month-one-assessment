#!/bin/bash
# Update and install Apache
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Enable Password Authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "ec2-user:qwerty12345" | chpasswd
systemctl restart sshd

# Create a custom index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Techcorp's Terraform!</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        h1 { color: #333; }
        .info { background: #f0f0f0; padding: 20px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Hello from Techcorp's Terraform!</h1>
    <div class="info">
        <h2>Server Information</h2>
        <p><strong>Server Name:</strong> ${server_name}</p>
        <p><strong>Deployed with:</strong> Terraform</p>
        <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    </div>
</body>
</html>
EOF