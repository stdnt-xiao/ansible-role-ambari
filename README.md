# 基于Ansible离线部署Ambari集群

## 一、简介

为解决繁琐的部署流程，简化安装步骤，本脚本提供一键安装Ambari+MGR-Mysql环境。

### 1.1 版本介绍

以下版本及配置信息可参考安装程序`hosts`文件中的`[all:vars]`字段。

| 软件名称 | 软件版本     | 应用路径              | 测试/连接命令                            |
|--| ------------ | --------------------- | ---------------------------------------- |
| MySQL | mysql-5.7    | /usr/local/mysql      | mysql -pbigdata       |
| JDK | jdk1.8.0_202 | /usr/local/java       | java -version                            |
| Nginx | nginx/1.20.1 | /etc/nginx            | nginx -t                                 |
| keepalived | keepalived/1.20.1 | /etc/keepalived            | nginx -t                                 |
| Ambari | 2.7.6        | /var/lib/ambari-server        | http://<服务器IP>:8028                   |

## 二、部署前注意事项

**要求**：

- 本脚本仅在`Ubuntu 18.04`系统上测试过，请确保安装的服务器为`Ubuntu 18.04`。

## 三、外网构建私有化部署软件


## 四、私有化部署方法

本案例部署主机IP为`192.168.26.192、192.168.26.193、192.168.26.194`，以下步骤请按照自己实际情况更改。

### 4.1 安装前设置
```bash
### 安装ansible
$ sh /opt/download/ansible/install_ansible.sh

### 配置免密
$ ansible-playbook /opt/download/bigdata/playbooks/all.yml
```
### 4.2 部署linkis+dss

```bash
### 获取安装包
$ git clone https://github.com/stdnt-xiao/ansible-role-ambari.git
$ cd ansible-role-ambari
```

### 4.3 目录说明
ansible-role-ambari
├── ansible    # ansible 配置文件
├── bigdata    # 大数据主机及变量配置
├── hdp        # hdp资源文件（手动下载HDP-3.1.0.0-ubuntu18-deb.tar.gz、HDP-UTILS-1.1.0.22-ubuntu18.tar.gz放到/opt/download/hdp目录）
├── README.md  # 说明文档

### 4.4 配置部署主机（注：ansible_ssh_host的值不能设置127.0.0.1）
```bash
$ vim hosts
[deploy]
node01 ansible_ssh_host=192.168.26.192 ansible_ssh_port=22
```
### 4.5 下载安装包到download目录(如果下载失败，可以手动下载放到该目录)
```bash
$ cd /opt/download/bigdata
$ ansible-playbook playbooks/all.yml
```
```
TASK [dss : 打印访问信息] *****************************************************************************************
ok: [node01] => {
    "msg": [
        "*****************************************************************", 
        "              访问 http://192.168.26.192:8080 查看访问信息                 ", 
        "*****************************************************************"
    ]
}
```
执行结束后，即可访问：http://192.168.26.192:8080 查看信息页面，上面记录了所有服务的访问地址及账号密码。

### 4.6 维护指南
```bash
### 查看实时日志

### 启动服务（如服务器重启可使用此命令一建启动）
$ ansible-playbook playbooks/all.yml -t restart
# 启动其它服务
```
