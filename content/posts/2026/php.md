---
title: php伪协议+base64过滤
description: web-php
date: 2026-10-19 22:03:29
updated: 2026-10-18 23:40:00
image: /images/php/微信图片_20261019202225_15_6.jpg
categories: [web]
tags: [Web安全, php]
---

---

## php伪协议+base64绕过

### php

题目：[[SWPUCTF 2022 新生赛\]ez_ez_php - CTF 题目 - NSSCTF](https://www.nssctf.cn/problem/2640)

![Snipaste_2026-10-19_20-42-15](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_20-42-15.png)

拿到这种有php代码的题目，先读代码

````php
<?php
error_reporting(0);                    // 关闭所有报错,即使出错页面也不显示错误信息
if (isset($_GET['file'])) {            // URL 里传了 file 参数吗?(有没有 ?file=xxx)
    if ( substr($_GET["file"], 0, 3) === "php" ) {   // 取 file 值的前 3 个字符,和 "php" 全等比较
        echo "Nice!!!";                // 成立 → 打印 Nice!!!
        include($_GET["file"]);        // 把 file 的值当作文件名/协议,包含进来
    } else {
        echo "Hacker!!";               // 传了 file,但前 3 位不是 "php" → 拒绝
    }
} else {
    highlight_file(__FILE__);          // 完全没传 file 参数 → 显示本页源码(就是你看到的题目页)
}
````



- 第一眼先看到下边有非常显眼的//flag.php,先试一下呢

  ![Snipaste_2026-10-19_21-11-37](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_21-11-37.png)

  题目提示了，这样拿不到flag,并且提示了php伪协议

- 那就仔细看代码所以，整体就是，URL里传的file有值->substr函数，它的作用就是提取字符，substr(要提取的字符串，从哪里开始提取，提取多少个)，

  `( substr($_GET["file"], 0, 3)`在这里的意思就是，提取file的值，并且是从第0位开始，提取三个字符。—>`===`是强等于，在php语法中，===不仅会比较两边的数据，还会比较数据类型，满足则echo，echo是打出的意思，打出Nice->include()的作用就是把传入的file得到的东西包含。大致就是这样

- 根据代码那我们就传file=php给它 `[node4.anna.nssctf.cn:28133/?file=php`

![Snipaste_2026-10-19_21-09-13](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_21-09-13.png)

- 界面只有一个Nice,也没有flag啊？熟悉的就知道这里要用伪协议绕过，不熟悉的话就证实了前边的提示，也能想到伪协议

  - 为什么明明代码里有include(GET[file]),但是界面啥也没有，为什么？

    PHP 最初就是个模板语言。PHP 解析器读任何文件时，默认**逐字符当作普通文本原样输出**，只有遇到 `<?php` 这个起始标签，才切换到“代码模式”，把标签里的内容当代码执行，直到 `?>` 或文件结尾再切回文本模式。

  - include（）只是包含，include(GET(file))，？file=php/resource=flag.php,这样include切换到代码模式，<?php这个起始标签依旧存在，就只会把flag.php的文件包含进来，但是包含不等于输出，所以我们看不到flag,

  - 怎么样才能让它没有`<？php`这个起始标签，打印出flag呢？

    **伪协议+base64过滤器**

    **`?file=php://filter/read=convert.base64-encode/resource=flag.php`**

    - 根据代码===需要强等于php,这里其实已经给出了白名单，所以伪协议就用`？file=php://filter...`

    substr()怎么取字符的？

    ```
    p  h  p  :  /  /  f  i  l  t  e  r  /  ...  r  e  s  o  u  r  c  e  =  f  l  a  g  .  p  h  p
        0  1  2  3  4  5  6  7  8  ...                              49 50 51 52 ...
        └─┬─┘                                                              └─┬─┘
        substr 取的是这里 → "php"                                      "fla" 在下标 49
    ```
  
    - `read=convert.base64-encode`是base64编码，为什么要这么写？不加过滤器会怎样？
  
      `?file=php://filter/resource=flag.php`

      这样写等于“原样读出文件内容再 include”——内容里 `<?php` 标签完好无损，PHP 照样把它当**代码执行**：执行一次 `$flag = "flag{xxx}"` 的赋值，没有任何 echo，页面除了 `Nice!!!` 什么都不显示。转了一圈回到原点。

      所以过滤器的作用只有一个：**把 `<?php` 这几个字符破坏掉**，让 PHP 解析器认不出“这是代码开始”，从而include()就不会只包含不打出flag了。凡是能做到这一点的变换都可以，base64 不是唯一的。还有**rot13 过滤器** **iconv 编码转换过滤器**

    - resource=flag.php

      `resource=` 是 php://filter **语法里的固定关键字**，`flag.php` 是**我们自己选的目标文件**

  输入`?file=php://filter/read=convert.base64-encode/resource=flag.php`

  ![Snipaste_2026-10-19_21-48-00](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_21-48-00.png)

  

  得到base64编码过的flag,找个解码工具解码就好了

  

  ![Snipaste_2026-10-19_21-50-34](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_21-50-34.png)

- 代码显示，flag不在这里，`real_flag_is_in_'flag'`真正的flag在flag文件下

- 改为**?file=php://filter/read=convert.base64-encode/resource=flag**

  

![Snipaste_2026-10-19_21-52-29](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_21-52-29.png)

依旧解码

![Snipaste_2026-10-19_21-56-07](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_21-56-07.png)

### 更快的解法

其实，我在解题的时候漏了，第二张图片的第二行，不然在输入伪协议的时候就可以直接输入**`?file=php://filter/read=convert.base64-encode/resource=flag`**就不用，二次解码了

## 🎉拿到flag啦！！！



## 梳理流程

```
① 服务器收到参数字符串 "php://filter/.../resource=flag.php"
      ↓  (此刻还没打开任何文件)
② substr 取下标 0~2 = "php" → === "php" 成立 → 放行     ← 检测在这里就结束了
      ↓
③ include 开始工作 → 认出 php://filter 协议 → 打开 flag.php
      ↓
④ 对 flag.php 的【文件内容】做 base64 编码               ← base64 在这里才登场
      ↓
⑤ 编码结果没有 <?php 标签 → 当纯文本输出
```

## 踩过的坑（别学我啊。。。）

1. **大小写搞反** —— 黑白名单看反了，白名单题传大写，页面回 `Hacker!!` 还以为是文件名错
2. **`resource=` 漏写** —— 流不知道读谁，包含失败；又碰上 `error_reporting(0)` 吞报错，页面空白以为题坏了
3. **页面空白就放弃** —— 空白可能是：文件名猜错 / resource 少写 / 关键字被 ban。逐个排查而不是换题
4. **把输出的 base64 直接当 flag 提交** —— 还要解码一步，解码后的**源码里**才是 flag
5. **`read=` 忘写以为错了** —— 其实 `read=` 可以省略，`php://filter/convert.base64-encode/resource=flag.php` 等价
6. 漏了一行提示。。。。