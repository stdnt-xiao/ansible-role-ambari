# 清空apt缓存
ps -ef | grep apt | grep systemd.daily | awk '{print $2}' |xargs kill -9
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock
sudo rm /var/cache/apt/archives/lock

# 清空缓存目录
rm -rf /var/cache/apt/archives/*

# 仅下载ansible安装依赖
apt-get -d install ansible

#制作离线安装宝
mkdir -p /opt/download/debs/ansible
cp -r /var/cache/apt/archives/*.deb /opt/download/debs/ansible/
cd /opt/download/debs && apt-ftparchive packages ansible > ansible/Packages
cd ansible && gzip -c Packages > Packages.gz && apt-ftparchive release ./ > Release
#拷贝离线安装包到离线服务器环境
