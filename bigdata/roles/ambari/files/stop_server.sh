#!/bin/bash
# 停止ambari server
echo "停止ambari server:"`date` >> /etc/keepalived/keepalived.log
/usr/sbin/ambari-server stop
/usr/sbin/ambari-agent restart
echo "停止ambari server成功:"`date` >> /etc/keepalived/keepalived.log
