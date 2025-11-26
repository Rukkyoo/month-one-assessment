#!/bin/bash
# Update and install PostgreSQL
yum update -y
amazon-linux-extras enable postgresql14
yum install -y postgresql-server postgresql-contrib
postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql

# Enable Password Authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "ec2-user:qwerty12345" | chpasswd
systemctl restart sshd

# Configure PostgreSQL
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'qwerty123';"
sudo -u postgres createdb techcorpdb
sudo -u postgres createuser techcorpuser
sudo -u postgres psql -c "ALTER USER techcorpuser WITH PASSWORD 'qwerty123';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE techcorpdb TO techcorpuser;"

# Allow remote connections (optional, but good for testing from web server)
echo "listen_addresses = '*'" >> /var/lib/pgsql/data/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /var/lib/pgsql/data/pg_hba.conf
systemctl restart postgresql


