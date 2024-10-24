# frozen_string_literal: true

# Run this file when you configure a Linux machine for the very first time

require "net/ssh"

# TODO: remove the hard coded server ip
LINODE_HOST = "172.236.19.159"
DEPLOY_USER = "deploy"

# Install essential packages
install_essentials = <<~EOF
  apt update;
  apt upgrade -y;
  apt install -y docker.io curl unattended-upgrades
EOF

# Add the deploy user
add_user = <<~EOF
  useradd --create-home #{DEPLOY_USER};
  usermod -s /bin/bash #{DEPLOY_USER};
  su - #{DEPLOY_USER} -c 'mkdir -p ~/.ssh';
  su - #{DEPLOY_USER} -c 'touch ~/.ssh/authorized_keys';
  cat /root/.ssh/authorized_keys >> /home/#{DEPLOY_USER}/.ssh/authorized_keys;
  chmod 700 /home/#{DEPLOY_USER}/.ssh;
  chmod 600 /home/#{DEPLOY_USER}/.ssh/authorized_keys;
  echo '#{DEPLOY_USER} ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/#{DEPLOY_USER};
  chmod 0440 /etc/sudoers.d/#{DEPLOY_USER};
  visudo -c -f /etc/sudoers.d/#{DEPLOY_USER};
  usermod -aG docker #{DEPLOY_USER}
EOF

# Configure firewall
configure_firewall = <<~EOF
  ufw logging on;
  ufw default deny incoming;
  ufw default allow outgoing;
  ufw allow 22;
  ufw allow 80;
  ufw allow 443;
  ufw --force enable;
  systemctl restart ufw
EOF

Net::SSH.start(LINODE_HOST, "root", keys: [ "/Users/user/.ssh/private_key.pem" ]) do |ssh|
  puts "Installing essential packages..."
  puts ssh.exec!(install_essentials)
  puts "Adding deploy user..."
  puts ssh.exec!(add_user)
  puts "Setting basic Ubuntu firewall configuration..."
  puts ssh.exec!(configure_firewall)
end
