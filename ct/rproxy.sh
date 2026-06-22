#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Jón Gautur (jongautur)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jongautur/rproxy

APP="rproxy"
var_tags="${var_tags:-proxy;nginx;ssl;management}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-16}"
var_os="${var_os:-ubuntu}"
var_version="${var_version:-24.04}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/rproxy ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Stopping rproxy"
  runuser -u rproxy -- pm2 stop rproxy || true
  msg_ok "Stopped rproxy"

  msg_info "Updating rproxy"
  runuser -u rproxy -- bash /opt/rproxy/scripts/update-app.sh
  msg_ok "Updated rproxy"

  msg_info "Starting rproxy"
  runuser -u rproxy -- pm2 start /opt/rproxy/ecosystem.config.js || runuser -u rproxy -- pm2 restart rproxy
  runuser -u rproxy -- pm2 save
  msg_ok "Started rproxy"

  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:81${CL}"
echo -e "${INFO}${YW} Default login:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}Username: admin${CL}"
echo -e "${TAB}${GATEWAY}${BGN}Password: admin${CL}"
echo -e "${INFO}${YW} Change the default password immediately after first login.${CL}"
