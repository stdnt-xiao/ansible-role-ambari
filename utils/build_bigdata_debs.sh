# 使用python启动临时http服务
mkdir /opt/repo/
cd /opt/repo
nohup python3 -mhttp.server 80 &

# 解压文件到/opt/repo/目录
tar -zxvf /opt/ansible-role-ambari/bigdata/roles/ambari/files/ambari-2.7.5.0-ubuntu18.tar.gz -C /opt/repo/
tar -zxvf /opt/ansible-role-ambari/bigdata/roles/ambari/files/HDP-3.1.5.0-ubuntu18-deb.tar.gz -C /opt/repo/
tar -zxvf /opt/ansible-role-ambari/bigdata/roles/ambari/files/HDP-GPL-3.1.5.0-ubuntu18-gpl.tar.gz -C /opt/repo/
tar -zxvf /opt/ansible-role-ambari/bigdata/roles/ambari/files/HDP-UTILS-1.1.0.22-ubuntu18.tar.gz -C /opt/repo/

# 配置ambari、hdp软件源
cat >/etc/apt/sources.list.d/local.list <<EOF
deb [trusted=yes] http://localhost/ambari/ubuntu18/2.7.5.0-72/ Ambari main
deb [trusted=yes] http://localhost/HDP/ubuntu18/3.1.5.0-152/ HDP main
deb [trusted=yes] http://localhost/HDP-UTILS/ubuntu18/1.1.0.22/ HDP-UTILS main
deb [trusted=yes] http://localhost/HDP-GPL/ubuntu18/3.1.5.0-152/ HDP-GPL main
EOF
cp /opt/ansible-role-ambari/bigdata/roles/ambari/files/trusted.gpg /etc/apt/
apt-get update

# 清空apt临时缓存目录
ps -ef | grep apt | grep systemd.daily | awk '{print $2}' |xargs kill -9
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock
sudo rm /var/cache/apt/archives/lock
rm -rf /var/cache/apt/archives/*

# 安装并缓存所有deb文件依赖
ls -l -R /opt/repo/ | grep deb | awk '{split($9, array, "_");print array[1]}' | xargs apt-get -d -y install

# 拷贝互联网依赖包(除ambari、hdp外)，生成离线debs包
mkdir -p /var/cache/apt/archives/bigdata
diff <(ls -l -R /opt/repo/ | grep deb | awk '{print $9}' | sort) <(ls -l -R /var/cache/apt/archives/ | grep deb | awk '{print $9}' | sort) | grep ">" | awk '{print "/var/cache/apt/archives/"$2}' | xargs -i cp {} /var/cache/apt/archives/bigdata/
cd /var/cache/apt/archives && apt-ftparchive packages bigdata > bigdata/Packages
cd /var/cache/apt/archives/bigdata && gzip -c Packages > Packages.gz && apt-ftparchive release ./ > Release
cd /var/cache/apt/archives && tar -czvf bigdata.debs.tar.gz bigdata
cd /var/cache/apt/archives  && cp -r bigdata.debs.tar.gz /opt/ansible-role-ambari/bigdata/roles/ambari/files/

# 关闭http服务
ps -ef | grep python3 | grep http.server | awk '{print $2}' | xargs kill -9