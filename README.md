# Ambari+MGR-Mysql Ansible集群一键安装脚本

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

## 三、部署方法

本案例部署主机IP为`192.168.26.192、192.168.26.193、192.168.26.194`，以下步骤请按照自己实际情况更改。

### 3.1 安装前设置
```bash
### 安装ansible
$ sh /opt/download/ansible/install_ansible.sh

### 配置免密
$ sh ansible-playbook /opt/download/bigdata/playbooks/all.yml
```
### 3.2 部署linkis+dss

```bash
### 获取安装包
$ git clone https://github.com/wubolive/dss-linkis-ansible.git
$ cd dss-linkis-ansible

### 目录说明
dss-linkis-ansible
├── ansible.cfg    # ansible 配置文件
├── hosts          # hosts主机及变量配置
├── playbooks      # playbooks剧本
├── README.md      # 说明文档
└── roles          # 角色配置

### 配置部署主机（注：ansible_ssh_host的值不能设置127.0.0.1）
$ vim hosts
[deploy]
dss-service ansible_ssh_host=192.168.1.52 ansible_ssh_port=22

### 下载安装包到download目录(如果下载失败，可以手动下载放到该目录)
$ ansible-playbook playbooks/download.yml

### 一键安装Linkis+DSS
$ ansible-playbook playbooks/all.yml
......
TASK [dss : 打印访问信息] *****************************************************************************************
ok: [dss-service] => {
    "msg": [
        "*****************************************************************", 
        "              访问 http://192.168.1.52 查看访问信息                 ", 
        "*****************************************************************"
    ]
}

```

执行结束后，即可访问：http://192.168.1.52 查看信息页面，上面记录了所有服务的访问地址及账号密码。

![image](https://user-images.githubusercontent.com/31678260/209619054-b776a4e6-2044-4855-8185-e57a269d2306.png)

### 3.3 部署其它服务

```bash
# 安装dolphinscheduler
$ ansible-playbook playbooks/dolphinscheduler.yml
### 注: 安装以下服务必须优先安装dolphinscheduler调度系统
# 安装visualis
$ ansible-playbook playbooks/visualis.yml 
# 安装qualitis
$ ansible-playbook playbooks/qualitis.yml
# 安装streamis
$ ansible-playbook playbooks/streamis.yml
# 安装exchangis
$ ansible-playbook playbooks/exchangis.yml
```
### 3.4 维护指南
```
### 查看实时日志
$ su - hadoop
$ tail -f ~/linkis/logs/*.log ~/dss/logs/*.log

### 启动服务（如服务器重启可使用此命令一建启动）
$ ansible-playbook playbooks/all.yml -t restart
# 启动其它服务
$ sh /usr/local/zookeeper/bin/zkServer.sh start
$ su - hadoop
$ cd /opt/dolphinscheduler/bin &&  sh start-all.sh 
$ cd /opt/visualis-server/bin && sh start-visualis-server.sh
$ cd /opt/qualitis/bin/ && sh start.sh
$ cd /opt/streamis/streamis-server/bin/ && sh start-streamis-server.sh
$ cd /opt/exchangis/sbin/ && ./daemon.sh start server
```
使用问题请访问官方QA文档：https://docs.qq.com/doc/DSGZhdnpMV3lTUUxq
