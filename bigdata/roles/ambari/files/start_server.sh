#!/bin/bash
# 重启ambari server
echo "重启ambari server:"`date` >> /etc/keepalived/keepalived.log
/usr/sbin/ambari-server restart
/usr/sbin/ambari-agent restart
echo "重启ambari server成功:"`date` >> /etc/keepalived/keepalived.log
