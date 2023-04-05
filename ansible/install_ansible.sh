# 清空apt缓存
ps -ef | grep apt | grep systemd.daily | awk '{print $2}' |xargs kill -9
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock
sudo rm /var/cache/apt/archives/lock

#解压文档
mkdir -p /opt/debs/
tar -zxvf /opt/download/ansible/debs/ansible.debs.tar.gz -C /opt/debs/

#配置本地软件源
mv /etc/apt/sources.list /etc/apt/sources.list.bk
echo "deb [trusted=yes] file:/opt/debs ansible/" > /etc/apt/sources.list.d/local.list
apt-get update

#安装软件
apt-get install -y ansible python-pexpect sshpass