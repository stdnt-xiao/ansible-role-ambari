# 基于Ansible离线部署Ambari集群(ubuntu18、hdp3.5.1)

## 一、简介

为解决繁琐的部署流程，简化安装步骤，本脚本提供一键安装Ambari、HDP、MGRMysql环境。

### 1.1 版本介绍

以下版本及配置信息可参考安装程序`hosts`文件中的`[all:vars]`字段。

|   软件名称  |  软件版本   |   应用路径  |  测试/连接命令   |
|-----|-----|-----|-----|
|   MySQL  |  mysql-5.7   |   /usr/local/mysql   |  mysql -pbigdata |
|   JDK  |  jdk1.8.0_202   |  /usr/local/java   |  java -version   |
|  keepalived   |  keepalived/1.20.1   |   /etc/keepalived   |     |
|  Ambari   |   2.7.5   |  /var/lib/ambari-server    |   http://<服务器IP>:8080   |
|  HDP   |  3.1.5    |     |     |

## 二、部署前注意事项

**要求**：

- 本脚本仅在`Ubuntu 18.04`系统上测试过，请确保安装的服务器为`Ubuntu 18.04`。

## 三、外网构建私有化部署软件
### 3.1 下载ansible-role-ambari代码
```bash
$ cd /opt/
$ git clone https://github.com/stdnt-xiao/ansible-role-ambari.git
```
### 3.2 下载ambari及hdp包
若没有下列文件，可以添加微信（create17_）获取
```
# 目标目录
/opt/ansible-role-ambari/
# 文件列表
ambari-2.7.5.0-ubuntu18.tar.gz
HDP-3.1.5.0-ubuntu18-deb.tar.gz
HDP-GPL-3.1.5.0-ubuntu18-gpl.tar.gz
HDP-UTILS-1.1.0.22-ubuntu18.tar.gz
```
### 3.3 缓存ambari、hdp安装依赖
```bash
$ bash /opt/ansible-role-ambari/build_local_debs.sh
```
## 四、私有化部署方法
```text
将ansible-role-ambari拷贝到离线环境/opt/目录下
本案例部署主机IP为`192.168.26.192、192.168.26.193、192.168.26.194`，以下步骤请按照自己实际情况更改。
```
### 4.1 目录说明
```text
/opt/ansible-role-ambari
    ├── playbooks             # ansible剧本
    ├── roles                 # ansible角色
    ├── .gitignore            # git忽略上传文件清单
    ├── ansible.cfg           # ansible配置文件
    ├── build_local_debs.sh   # 离线包构建脚本
    ├── hosts                 # ansible部署环境变量
    ├── install_ansible.sh    # 安装ansible
    ├── LICENSE               # 开源协议
    ├── README.md             # 说明文档
    ├── ambari-2.7.5.0-ubuntu18.tar.gz       # ambari软件包，自行下载
    ├── HDP-3.1.5.0-ubuntu18-deb.tar.gz      # hdp软件包，自行下载
    ├── HDP-GPL-3.1.5.0-ubuntu18-gpl.tar.gz  # hdp软件包，自行下载
    ├── HDP-UTILS-1.1.0.22-ubuntu18.tar.gz   # hdp软件包，自行下载
```
### 4.2 配置部署主机
```bash
### 安装ansible
$ bash /opt/ansible-role-ambari/install_ansible.sh

### 修改全局配置文件
$ vim hosts
# 远程服务器
[manager]
node001 ansible_ssh_host=192.168.26.192 ansible_ssh_port=22 ansible_ssh_pass=bigdata ansible_python_interpreter=/usr/bin/python3 STATE=MASTER KEEPALIVED_PRIORITY=100
node002 ansible_ssh_host=192.168.26.193 ansible_ssh_port=22 ansible_ssh_pass=bigdata ansible_python_interpreter=/usr/bin/python3 STATE=BACKUP KEEPALIVED_PRIORITY=90
[work]
node003 ansible_ssh_host=192.168.26.194 ansible_ssh_port=22 ansible_ssh_pass=bigdata ansible_python_interpreter=/usr/bin/python3

[all:vars]
### --------- Main Variables ---------------
# Java配置
JAVA_HOME="/usr/local/java"

# MySQL 配置
MYSQL_PASSWORD="bigdata"
MYSQL_MGR_MASTER="node001" #根据环境修改

# Keepalived 配置
KEEPALIVED_VRID="100" #根据环境修改
KEEPALIVED_VIP="192.168.26.100" #根据环境修改
KEEPALIVED_INTERFACE="ens33" #根据环境修改
```
```
TASK [dss : 打印访问信息] *****************************************************************************************
ok: [node01] => {
    "msg": [
        "*****************************************************************", 
        "              访问 http://192.168.26.100:8080 查看访问信息                 ", 
        "*****************************************************************"
    ]
}
```
执行结束后，即可访问：http://1192.168.26.100:8080 查看信息页面，上面记录了所有服务的访问地址及账号密码。
### HDP组件清单文件
```text
/var/www/html/HDP/ubuntu18/3.1.5.0-152/HDP-3.1.5.0-152.xml
```
## 五、部署注意事项
1、部署hadoop时注意避免53端口冲突
```text
#yarn 53端口冲突 修改为8053
#"hadoop.registry.dns.bind-port". (registry.dns.bind-port) default value = 53
```