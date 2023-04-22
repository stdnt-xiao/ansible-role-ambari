# 清空apt临时缓存目录
ps -ef | grep apt | grep systemd.daily | awk '{print $2}' | grep -v grep | xargs kill -9
rm /var/lib/dpkg/lock-frontend
rm /var/lib/dpkg/lock
rm /var/cache/apt/archives/lock
rm -rf /var/cache/apt/archives/*

# 删除以安装软件
apt-get remove -y apache2 ansible

# 使用python启动临时http服务
apt-get install -y apache2
rm -fr /var/www/html/index.html

# 解压文件到/opt/repo/目录
tar -zxvf /opt/ansible-role-ambari/ambari-2.7.5.0-ubuntu18.tar.gz -C /var/www/html/
tar -zxvf /opt/ansible-role-ambari/HDP-3.1.5.0-ubuntu18-deb.tar.gz -C /var/www/html/
tar -zxvf /opt/ansible-role-ambari/HDP-GPL-3.1.5.0-ubuntu18-gpl.tar.gz -C /var/www/html/
tar -zxvf /opt/ansible-role-ambari/HDP-UTILS-1.1.0.22-ubuntu18.tar.gz -C /var/www/html/

# 配置ambari、hdp软件源
cat >/etc/apt/sources.list.d/local.list <<EOF
deb [trusted=yes] http://localhost/ambari/ubuntu18/2.7.5.0-72/ Ambari main
deb [trusted=yes] http://localhost/HDP/ubuntu18/3.1.5.0-152/ HDP main
deb [trusted=yes] http://localhost/HDP-UTILS/ubuntu18/1.1.0.22/ HDP-UTILS main
deb [trusted=yes] http://localhost/HDP-GPL/ubuntu18/3.1.5.0-152/ HDP-GPL main
EOF
cp /opt/ansible-role-ambari/roles/ambari/files/trusted.gpg /etc/apt/trusted.gpg.d/
apt-get update

# 缓存所有deb文件依赖
cd /var/cache/apt/archives/
apt-get -d -y install unzip apache2 ansible keepalived mysql-server-5.7 mysql-client-5.7 sshpass python3-mysqldb python-pexpect
ls -l -R /var/www/html/ | grep deb | awk '{split($9, array, "_");print array[1]}' | xargs apt-get -d -y install

# 生成离线debs包（过滤掉ambari、hdp）
mkdir -p /var/cache/apt/archives/local
diff \
<(ls -l -R /var/www/html/ | grep deb | awk '{print $9}' | sort) \
<(ls -l -R /var/cache/apt/archives/ | grep deb | awk '{print $9}' | sort) \
| grep ">" | awk '{print "/var/cache/apt/archives/"$2}' | xargs -i cp {} /var/cache/apt/archives/local/

#离线软件打包
cd /var/cache/apt/archives/
apt-ftparchive packages local > local/Packages
gzip -c local/Packages > local/Packages.gz
apt-ftparchive release local > local/Release
tar -czvf local.debs.tar.gz local
cp -r local.debs.tar.gz /opt/ansible-role-ambari/