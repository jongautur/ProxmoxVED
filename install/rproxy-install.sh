#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Jón Gautur (jongautur)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jongautur/rproxy

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Bootstrap Dependencies"
$STD apt-get install -y \
  ca-certificates \
  git
msg_ok "Installed Bootstrap Dependencies"

msg_info "Cloning rproxy"
if [[ -d /opt/rproxy ]]; then
  msg_error "/opt/rproxy already exists"
  exit 1
fi
$STD git clone https://github.com/jongautur/rproxy.git /opt/rproxy
msg_ok "Cloned rproxy"

msg_info "Running System Setup"
$STD bash /opt/rproxy/scripts/setup.sh
msg_ok "Ran System Setup"

msg_info "Installing rproxy Application"
$STD runuser -u rproxy -- bash /opt/rproxy/scripts/install-app.sh
msg_ok "Installed rproxy Application"

msg_info "Creating Update Command"
cat <<'EOF' >/usr/bin/update
#!/usr/bin/env bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jongautur/ProxmoxVED/rproxy-beta/ct/rproxy.sh)"
EOF
chmod +x /usr/bin/update
msg_ok "Created Update Command"

motd_ssh
customize
cleanup_lxc
