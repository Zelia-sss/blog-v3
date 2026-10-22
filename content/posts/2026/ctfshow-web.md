---
title: ctfshow-web-信息搜集
description: web-wp
date: 2026-10-20 23:09:00
updated: 2026-10-20 23:09:00
image: /images/ctf-show/Screenshots-20261021-183601708.png
tags: [web,信息搜集]
---

## 信息搜集

## web03



![Snipaste_2026-10-20_23-57-36](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-20_23-57-36.png)

![Snipaste_2026-10-20_23-52-10](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-20_23-52-10.png)

`ctrl+shift+I`或`F12`,`ctrl+u`查看源代码,啥也没有怎么办？

根据题目提示的，`没有思路的时候抓个包看看`，这里用到的抓包工具是Burp Suite（下面都简称burp）

在burp中的Proxy拦截，点击图中的红色框框，把拦截到的发送到Repeater中,再点击`send`就可以在`Response`中看到flag了

![Snipaste_2026-10-21_00-08-11](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-08-11.png)

![Snipaste_2026-10-21_00-10-09](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-10-09.png)



---

## web04

题目提示了`robots`文件，直接在url后边加上`robots.txt`即可

### 关于robots.txt

- 但是，光是提示一个`robots`,我怎么知道是`robots.txt`呢，这是猜出来的吗？不，`robots.txt`这个名字是标准规定好的。所以看到`robots`,就做出在url写`robots.txt`对于熟练的人来说是很自然的一个动作，对于不太熟练的，看多了就记住了。

- 其实，我们还可以用工具扫描来解：我这里用的工具是dirsearch

  因为，dirsearch的字典里有`robots.txt`,所以它直接给我们扫出来了，但是关于`robots.txt`的内容我们还是要知道的,其次就是，虽然扫描很方便，但扫描也存在局限性，所以能够根据提示做出来的，就优先提示吧

  ![image-20261021181349472](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021181349472.png)

### 再记住三个状态码

![image-20261021181720999](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021181720999.png)

| 状态码 | 含义         | 说明                                            |
| ------ | ------------ | ----------------------------------------------- |
| 200    | 存在且能读   | 拿到了                                          |
| 301    | 重定向       | 常见于访问目录不带 `/`，比如 `/.git` → `/.git/` |
| 403    | 存在但被禁止 | 目录在，但禁止列目录（可以再试具体文件）        |
| 404    | 不存在       | 注意：很多站会返回自定义 404 页面，长度都相同   |

#### 关于200（可能是软404）

200 只代表“服务器成功返回了内容”， **不代表这个文件真的存在**。

有些站点（尤其是前端路由的站）会对**任何路径**都返回 200 + 首页， 这叫 **软 404**。

所以扫到 200 之后，还要**打开看内容**：

- 内容是 `User-agent: ... / Disallow: ...` → 真存在
- 内容是首页 HTML → 软 404，是假的

### 一个URL拆开是这样的

```
https://xxx.challenge.ctf.show / system1103 / login.php ? a=1
└────── 协议+主机 ──────┘   └──────── path ────────┘ └query┘
```

Web 服务器（nginx / Apache）启动时会配置一个**网站根目录**（DocumentRoot，比如 `/var/www/html`）。你请求 `/index.php`，服务器就去 `/var/www/html/index.php` 找这个文件。

所以：

- **`index.php`、`robots.txt`、`www.zip`、`.git/`，在"写法"上完全一样**，都是"根目录下的一个名字"。没有任何语法区别。

- 区别只在

  服务器拿到这个名字之后怎么处理：

  - `.php` → 交给 PHP 解释器**执行**，你只看到它输出的 HTML，看不到源码；
  - `.txt` / `.zip` / `.png` / `.git/xxx` → **当静态文件原样返回**（zip 会变成下载）。

- 所以"能不能访问到"取决于两件事：**文件到底存不存在**、**服务器有没有禁止访问它**。





![Snipaste_2026-10-21_00-18-34](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-18-34.png)![Snipaste_2026-10-21_00-17-34](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-17-34.png)![Snipaste_2026-10-21_00-18-01](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-18-01.png)

---

## web05



![Snipaste_2026-10-21_00-34-46](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-34-46.png)

题目提示了phps源码泄露，加之这题又是那种看源码啥也没有的，在url输入index.phps

### 为什么`.phps`可以看到源码？

- `.php`是`被执行的`，我们是看不到源码的

```
浏览器请求 /index.php
   → 服务器发现是 .php
   → 交给 PHP 解释器执行
   → 执行结果（HTML）返回给浏览器
```

我们在页面上按 Ctrl+U 看到的只是输出，不是源码

- `.phps` 是一个**历史遗留配置**：Apache 的 PHP 模块支持

  ```
  AddType application/x-httpd-php-source .phps
  ```

  意思是"`.phps` 后缀的文件，输出**语法高亮后的源码**，不要执行"。这本意是给开发者调试用的，一旦线上开着就是源码泄露

- 所以为什么是`index.phps`???

  因为首页文件叫 `index.php`，只是把后缀换成 `.phps` 而已

![Snipaste_2026-10-21_00-28-58](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-28-58.png)![Snipaste_2026-10-21_00-29-41](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-29-41.png)



![Snipaste_2026-10-21_00-29-18](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-29-18.png)

### 扫描的局限性

这题解完之后我还用扫描工具试了一下，结果全是404，这说明什么？

如下图所示，不难看出，我扫描的文件后缀名是php/asp/aspx/zip/html等，并没有这一题的后缀名`phps`,所以才扫不到，因为`phps`没那么常见，不在扫描字典里，从这里我们不难看出，扫描的局限性其实就是，万一文件的后缀名不常见，那就扫不出来

那也可以把以后写题遇到的，不常见的后缀名全部加到字典中，扩大扫描的范围

![image-20261021192247975](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021192247975.png)

---

## web06

### 题目提示

1. “解压源码”说明存在`压缩包`
2. “到当前目录，测试正常就收工了”说明：“到当前目录”->在网站根目录，“测试正常就收工“->没删掉
3. 未知：这个压缩包叫什么

### 为什么是www.zip?

因为www是网站根目录的习惯名，在打包的时候`习惯了`用根目录命名压缩包。

**这是“人的习惯”，不是标准。** 所以它不是“唯一正确答案”，而是“命中率最高的答案”。



![Snipaste_2026-10-21_00-58-07](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-58-07.png)![Snipaste_2026-10-21_00-59-30](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_00-59-30.png)![Snipaste_2026-10-21_01-00-12](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_01-00-12.png)

![Snipaste_2026-10-21_01-03-48](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-21_01-03-48.png)

---

## web07

### 题目提示

- ”版本控制“：说明这题运用了版本控制工具（git/svn),它们在初始化时，会在项目根目录自动生成一个隐藏目录git-.git    svn-.svn  所以我们要做的就是去找这个隐藏目录

- "不要部署到生产环境"说明，本来不应该部署到生产环境的，但在这一题中部署了

### 关于.git

- 为什么以点开头：linux的约定,**点开头的文件/目录算隐藏文件**，`ls` 默认不显示。 没有任何规则要求点前面必须有字母——`.git` 就是一个完整名字。

- .git里面装了什么

  ```
  .git/
  ├── HEAD        当前在哪个分支
  ├── config      仓库配置（远程地址、有时含凭据）
  ├── index       暂存区：所有被跟踪文件的文件名清单
  ├── objects/    所有文件内容 + 每次提交（zlib 压缩）
  ├── refs/       分支、tag 指向哪个 commit
  └── logs/       操作历史（谁、什么时候、改了什么）
  ```

- 最重要的是index里边有文件名列表,ogjects里边有文件完整内容，这两样可以把项目还原出来，而它们都在.git下

- 301：目录存在，看图中/.git 是301说明这个目录是有的

  200： /.git/ 和/.git相比较，就多了个斜杠，/..../代表访问的是目录

![image-20261021100657678](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021100657678.png)

![image-20261021101442440](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021101442440.png)

---

## web08

### 题目提示

和web07一样，只不过这题是.svn

### 关于SVN

SVN 全称 **Subversion**，是 git 流行之前最主流的版本控制工具

老版本（1.6以前）

```
.svn/
├── entries          文件名 + 版本号清单（纯文本）
└── text-base/       每个文件的“原始副本”
    ├── index.php.svn-base
    ├── config.php.svn-base
    └── ...
```

text-base/里边存的是文件的明文副本，文件名规则是：源文件名+.svn-base

所以拿到 `.svn` 之后，**不需要任何还原工具**，直接访问：

```
/.svn/text-base/index.php.svn-base
```

返回的就是 `index.php` 的**完整源码**。

新版本（1.7+）

```
.svn/
├── wc.db        SQLite 数据库：记录路径、版本、校验和
└── pristine/    按 SHA1 命名的文件内容
    ├── 0a/
    │   └── abcdef...
```

这时内容不是明文文件名了， 需要工具来解析：

```
perl rip-svn.pl -v -u http://目标/.svn/
```

**这题简化了**

![image-20261021102153899](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021102153899.png)

![image-20261021102126198](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021102126198.png)

---

## web09

### 题目提示

看到vim，以后条件反射：

**vim 编辑文件时会留下临时文件，这个临时文件里存着文件内容。**这是找编辑器留下的痕迹

### 关于.swp

- vim 在编辑一个文件时，会在旁边创建一个**交换文件（swap file）**。

- 定时把内存里的编辑缓冲区写到磁盘，断电，ssh断了，数据还能恢复

- 所以交换文件里边的的内容就是文件内容本身，相当于copy了一份

  ```
  index.php       ← 线上运行的文件
  index.php.swp   ← 编辑器里那份内容的副本
  ```

### vim

**标准写法：原文件名前加一个点，后面加 `.swp`**

```
原文件：index.php
交换文件：.index.php.swp      ← 注意前面那个点
```

**如果第一个交换文件已存在，会依次变成：**

```
.index.php.swo
.index.php.swn
```

**vim 还会留下其他痕迹：**

```
.index.php~        ← 备份文件（保存前的旧版本）
.index.php.un~     ← undo 历史
.index.php.swp     ← 交换文件
```

**这次访问的是**

````
/index.php.swp     ← 没有前面那个点
````

说明这个环境里放的正是**不带点的变体**。

**但是实战里两个都要试**

```
/.index.php.swp
/index.php.swp
```



![image-20261021103811884](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021103811884.png)

![image-20261021103744443](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021103744443.png)

---

## web10

### Cookie是什么？

一组**存在你浏览器里的键值对**

这题看到flag有`%7B%7D`说明是URL编码，需要解码

![image-20261021104555503](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021104555503.png)

![image-20261021104527507](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021104527507.png)

---

## web12

```
找后台地址  →  从页面公开信息里找密码  →  登录后台  →  flag
   /admin         手机号 / QQ / 邮箱          admin + 密码
```

### 后台地址admin从哪来

**来源是 robots.txt**（就是 web04 学的那招）

### 密码从哪来

**有时候网站上的公开信息，就是管理员常用密码**  为什么网页中给你一串数字，好难猜哟~

![image-20261021210657805](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021210657805.png)

![image-20261021114533163](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021114533163.png)

![image-20261021210718559](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021210718559.png)

![image-20261021210516371](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021210516371.png)

![image-20261021114505451](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021114505451.png)

---

## web13

### 题目提示

**① 技术文档** → 去站上找文档 **② 敏感信息** → 文档里有不该出现的东西 **③ 默认密码** → 后台用了默认密码，而且没改

```
首页 → 页脚 document 链接
     → 下载技术文档
     → 文档里写着后台地址 + 默认账号密码
     → 访问 /system1103/login.php
     → 登录 → flag
```

### 为什么是document？

因为那一小段英文就document首字母是小写，别的都是大写，为了引起你的注意



![image-20261021211101953](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021211101953.png)







![image-20261021115735139](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021115735139.png)

![image-20261021115634984](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021115634984.png)

---

## web14

### 题目信息

- editor提示了这题可以往`编辑器`的方向去思考
- ”如果目录不存在，则会遍历服务器根目录“



先查看一下源码，发现没线索

![image-20261022011347276](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022011347276.png)

![image-20261022011435491](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022011435491.png)

![image-20261022011854488](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022011854488.png)

扫描得到/editor/目录，访问一下

![image-20261022012020957](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022012020957.png)



![image-20261022023956600](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022023956600.png)

这就是一个editor的界面的demo页

### 为什么能确定这是一个demo界面？

页面底部 `提交内容（提交快捷键: Ctrl + Enter）` 是 KindEditor 自带 `php/demo.php` 的原样输出——**说明整个安装包被扔到了网站根下，连示例都没删**。

既然 `/editor/` 是完整安装包，那它下面必然有：

```
/editor/
├── kindeditor.js            ← 主程序
├── plugins/                 ← 各种插件（filemanager、insertfile、image...）
├── themes/                  ← 皮肤
├── php/
│   ├── demo.php             ← 看到的这个页面
│   ├── file_manager_json.php ← 文件空间的后端（本题主角）
│   ├── upload_json.php      ← 上传的后端
│   └── JSON.php
├── asp/  asp.net/  jsp/     ← 其他语言版本，也在！
└── attached/                ← 上传文件存放目录（默认应该在这）
```



![image-20261022012129727](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022012129727.png)

### 为什么点var?

Linux 的网站默认放在 `/var/www`。**它命中的的可能性比较大**——它让你少点几次，但不保证对。

![image-20261022012335424](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022012335424.png)

### 为什么选www?

在前边的web题目中我们也遇到过，www就是常见的网站文件夹

![image-20261022012258113](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022012258113.png)

### 为什么先选了html?

因为，html是前端三件套，该文件夹以此命名，说明是与网站有关的



![image-20261022012945470](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022012945470.png)



### 为什么选nothinghere?

你不觉得，它很具有迷惑性吗？nothinghere这里啥也没有,你真信啊？

![image-20261022013013714](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022013013714.png)



![image-20261022013049593](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022013049593.png)



flooog.txt 和flag很像啊，大概率就是它，而且这下边只有这一个文件，你也只能点它，点击确定

![image-20261022013125383](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022013125383.png)

### 关于绝对路径

`/var/www/html/nothinghere/fl000g.txt`

#### 为什么它是绝对路径？

在linux系统中，根（/)就是这个斜杠，var/www/html/nothinghere/  是文件夹，fl000g.txt是文件名，`/`也叫`磁盘根`,是linux整个硬盘的起点，这需要我们有一些linux相关的基础知识

### 关于网站根

网站根简称站根，网站根目录 = Web 服务器“对外开放”的那个起点文件夹。浏览器 URL 里的那个 `/`，指的就是它，不是硬盘的 `/`。

### 分清三个根

```
① 磁盘根        /                        ← Linux 整个硬盘的起点
② 网站根        /var/www/html             ← 网站“对外营业”的起点（DocRoot）
③ URL 根        https://host/             ← 浏览器眼里的起点，对应 ②
```

```
磁盘根  /
 ├── bin/  dev/  etc/  home/  lib/  ...   ← 后厨，URL 访问不到
 └── var/
      └── www/
           └── html/        ←←← 网站根（DocRoot）
                ├── index.php        →  URL: /
                ├── editor/          →  URL: /editor/
                ├── assets/          →  URL: /assets/
                └── nothinghere/
                     └── fl000g.txt  →  URL: /nothinghere/fl000g.txt
```

### 绝对路径转换到url路径

由于url的根在html后边，从/开始，所以我们可以根据`/var/www/html/nothinghere/fl000g.txt`把url路径，`/nothinghere/fl000g.txt`写到url中,如图所示

![image-20261022014417305](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022014417305.png)

---

## web15（这题还蛮有意思的）





![image-20261022121419013](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022121419013.png)



![image-20261022121847971](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022121847971.png)



![image-20261022123157449](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022123157449.png)

这里用到了QQ邮箱的一个特点：QQ邮箱一般都是qq号+@qq.com  这个qq号可能后面会用上，可能是密码什么的（像web12一样），也可能是其他的

看源码你会发现，没有什么信息，然后观察一下这个网站，是那种登录的，需要你输入name,和email,熟悉吗？和web12有点像，那是不是可以采取web12的思路呢，在url，写`/admin`

![image-20261022122606861](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022122606861.png)



还真有，后台的管理员登录系统，可以先试一下，账号：admin / demo  密码：1156631961  或 0000000 或 12586954775

都试一下发现，都不是

### 忘记密码是不是可以看看

![image-20261022123555555](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022123555555.png)

没招了，看看前面，有什么信息还没用？qq号，如果不是密码，那能不能去qq搜一下呢

![image-20261022124026135](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022124026135.png)



好嘛，搜完得到地址是陕西安，回到重置密码那里，填入`陕西西安`不对，填`西安`

![image-20261022124111365](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022124111365.png)

拿到密码，回到管理员登录界面，试试看，账号：admin  密码：admin7789

![image-20261022124255721](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022124255721.png)



---

## web16



![image-20261022124829645](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261022124829645.png)

