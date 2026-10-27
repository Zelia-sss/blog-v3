---
title: ctfshow-web-爆破
description: web-wp
permalink: /2026/ctfshow-web-baopo
date: 2026-10-25 01:15:00
updated: 2026-10-25 00:00:00
image: /images/baopo/1.jpg
categories: [web]
tags: [web,爆破]
---

---

## web21

![image-20261025011708989](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261025011708989.png)

打开以后发现，这是一个有登录弹窗的网站，先`F12`或者`ctrl+shift+I`,查看源码，网络这些，发现什么也没有



![image-20261025012642744](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261025012642744.png)



尝试弱口令登录，admin/1234,会发现，网络会有一条新的信息，点击查看，会看到一串多出来的，有=的，感觉像base64

![image-20261025012955971](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261025012955971.png)

解码之后发现，返回了我刚才输入的admin和密码

![image-20261025013056117](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261025013056117.png)

到了这一步，**没有别的提示了，用户登录界面，那就使用爆破**

![image-20261026161145887](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026161145887.png)

点击右边的红色小筐里的三条横杠，`send to intruder`

![image-20261026161300719](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026161300719.png)



点击add ,添加爆破点，注意一下格式，两个S把爆破点包围起来，`s+爆破点+s`

![image-20261026162107721](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026162107721.png)

### 为什么这里是爆破点？为什么选择这里而不选择别的地方？

因为这是个登录账户和密码的界面啊，我们要通过爆破去实现我们成功登录的目的，这样才能拿到flag,所以说，我们的目标就是成功登录，而这里，我们刚刚解码发现，这里是与账户和密码有关的，admin/1234就是刚刚我们试的弱口令，所以选择这里是有原因的，并不是我们乱选的，当然，如果乱选也能选中这，那很敏锐了。



这题是给了爆破字典的，下载下来，

![image-20261026163012597](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026163012597.png)



配置一下

![image-20261026163757460](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026163757460.png)

### 为什么是这里选的是encode不是decode?

我们的爆破点的Basic认证的地方，basic认证是客户端编码，服务器解码，我们上方解码是为了看懂这个包，因为我们得到的是编码过后的内容，但是这个内容不是人类的自然语言。

可以理解为，客户端和服务器沟通是通过编码这种方式，而我们人类要想看懂它们之间的沟通内容，就要解码。

那在这里选择encode(编码)，是为了使用它们之间沟通的这种方式，不断的试字典里的密码，最终拿到结果

### 为什么要添加admin:的prefix?

Basic认证负载的是整体，base64(用户名:密码)，用户名和密码之间用冒号：分隔开。

 我们解码后也看到了它的格式是`admin:1234`，还有一点，看看字典里的内容，只有密码，没有帐户，所以admin:是固定的，不停的在试的，在爆破的是密码

还有一个方法就是：可以在字典里，每一行都加上admin:然后再进行爆破，但是这个方法明显就比加prefix的操作步骤要多

### 很关键但是易忽略的一点

Burp里的payload processing是自上而下执行的，所以prefix-admin:必须在base64前面，如果base64在prefix-admin:前面，就让admin:无法被编码，无法满足basic的格式



![image-20261026163836402](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026163836402.png)



![image-20261026163922816](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026163922816.png)

取消勾选下图中的红框部分，因为红框部分有`=`会导致一会编码错误

### 为什么勾选后会在=发生错误呢？

前边我们已经给密码base64编码了，如果勾选url,那就是又进行一次url编码，那就会把原来的等号=变成%3D,就不对了，服务器不认%3D,它认base64的编码内容，所以我们要取消勾选



![image-20261026164214001](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026164214001.png)

这里我们把`Maximum concurrent requests`（并发/线程）**减小**，更稳

![image-20261026164049518](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026164049518.png)



配置完，点击爆破

![image-20261026164725104](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026164725104.png)

会发现一堆401里边，有一个200

### 关于为什么是200,而不是401？

一堆401里有200，200可能性更大，并且200是存在，放这里就是密码正确的意思

401是未认证，认证失败，在这题就是，密码不对

![image-20261026164835366](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026164835366.png)

点击查看一下

![image-20261026164920504](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026164920504.png)



---

## web22

web22提示了，要去爆破子域名，flag.ctf.show,使用子域名在线爆破工具发现得到

![image-20261026174848329](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026174848329.png)

去访问这几个，发现都拿不到flag,于是按别人的wp试了一下，去访问vip.ctf.show/wp.ctf.show发现都没有，按照描述，应当是题目现在访问vip.ctf.show拿不到flag了，题目问题，不纠结

---

## web23

![image-20261026201518245](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026201518245.png)

打开之后就看到这样一段代码，黄色区域的代码是注释，可以知道这是出题人留下来的，一些信息，重点关注下方的php代码

### 读懂代码

```php
error_reporting(0);/*关闭所有错误或警告输出，让代码看起来没有报错*/

include('flag.php');
if(isset($_GET['token'])){
    $token = md5($_GET['token']);/*1.获取参数，我们在url写？token=...,GET就会获取我们输入的参数，2.对传入的参数进行运算3.把哈希值赋值给token*/
    if(substr($token, 1,1)===substr($token, 14,1) && substr($token, 14,1) ===substr($token, 17,1)){/*substr函数的作用*/
        if((intval(substr($token, 1,1))+intval(substr($token, 14,1))+substr($token, 17,1))/substr($token, 1,1)===intval(substr($token, 31,1))){
            echo $flag;
        }
    }
}else{
    highlight_file(__FILE__);

}

```

### substr()函数的作用

又遇到substr了，记得在php伪协议里边遇到过，substr（）就是截取的作用，**返回的数据类型是字符串**具体就是

substr(要截取的东西，截取开始的位置，截取多少个字符)  加上===强等于，

第一个条件判断的意思是，截取token里存储的哈希值的第2个字符，它要强等于第15个字符，数据类型和数据内容都要相等，并且，第15个字符要强等于第18个字符串，因为这里有substr所以它们的数据类型都是字符串型，只需比较数据内容

在理解代码之前要限制的intval的作用

#### 关于intval

其实就是把变量换成整数

第一个条件判断的意思是，**取哈希值的第二个字符，转换成整数，+哈希值的第十五个字符转换成整数+第十八个哈希值（这里没有intval所以这里不用转换**）  除以  **哈希值的第二个字符**，要强等于 **哈希值的第三十二个字符转换成整数的值**

满足两个条件判断才能输出flag.

 ### 采用脚本爆破

![image-20261026205004800](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026205004800.png)

```php
<?php
for($i=0;$i<10000;$i++){/*先用for循环，循环1-10000里边的数，总有一个能有吧*/
        $token=md5($i);/*把每一次试的值的哈希值给token*/
        if(substr($token, 1,1)===substr($token, 14,1) && substr($token, 14,1) ===substr($token, 17,1)){/*两个条件判断我都是复制粘贴过来的*/
                if((intval(substr($token, 1,1))+intval(substr($token, 14,1))+substr($token, 17,1))/substr($token, 1,1)===intval(substr($token, 31,1))){
                         echo 'tokrn='.$i.'md5='.$token;/*如果符合两个条件，说明是题目想要的token了，那就输出它原本的值，并且把哈希值也输出出来*/
                }
               
        }
}
?>
```

`echo 'tokrn='.$i.'md5='.$token;`其实就是用`.`把它们拼起来

**非常重要的一点是，这个脚本我是本地访问，需要自己创建一个.php文件**

访问

![image-20261026205348471](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026205348471.png)

得到了两个符合条件判断的值，一个是422 另一个是1202，那就两个都试试呗

![image-20261026205441083](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026205441083.png)

![image-20261026205456466](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026205456466.png)

可以看到，这俩的flag都一样

---

## web24

![image-20261026211504892](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261026211504892.png)

### 读懂代码

```php
error_reporting(0);/*关闭所有错误或警告输出，让代码看起来没有报错*/
include("flag.php");
if(isset($_GET['r'])){/*传入参数r*/
    $r = $_GET['r'];
    mt_srand(372619038);/*播种*/
    if(intval($r)===intval(mt_rand())){/*r要强等于mt_rand*/
        echo $flag;
    }
}else{
    highlight_file(__FILE__);
    echo system('cat /proc/version');/*提醒了你版本问题*/
}

```



#### 关于mt_srand()设置种子函数（播种）

设置随机种子序列，没有返回值

#### 关于mt_rand()取种子函数

从随机种子序列中，取出随机数



这段代码的大致意思就是，播种完之后，传入参数取整数，要强等于取种子函数取出来的随机数

所以我们现在的目标就是要找出随机数，然后就让r=这个随机数，可以通过写脚本的方式来实现

![image-20261027004935192](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027004935192.png)



```php
<?php
mt_srand(372619038);/*设置随机序列-播种*/
echo intval(mt_rand());/*打出-从随机序列中取出的随机数*/
?>
```

本地访问

![image-20261027005542073](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027005542073.png)

现在我们已经拿到随机数了，接下来就让r=拿到的这个随机数

![image-20261027005759172](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027005759172.png)



---

## web25（有点巧妙）

![image-20261027153615290](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027153615290.png)

一打开又是php代码，还是一样的先读懂代码要干什么才能拿到flag,再开始干活

```php
error_reporting(0);/*关闭所有错误或警告输出，让代码看起来没有报错*/
include("flag.php");/*把 flag.php 的代码包含进来执行，$flag 也就跟着进来了*/
if(isset($_GET['r'])){
    $r = $_GET['r'];/*需要传入一个参数给r*/
    mt_srand(hexdec(substr(md5($flag), 0,8)));/*从第一位开始，连续取8个字符，这8个字符是从flag进行MD5运算之后的结果中取的，取的是哈希值,或许你会疑惑，我都不知道flag啊，也没有在这串代码之前看到过$flag,那是哪里来的呢？别急，先往下看*/
    $rand = intval($r)-intval(mt_rand());/*rand=r-第一个取随机数*/
    if((!$rand)){/*$rand 为 0 时 !$rand 为真，才算过第一关*/
        if($_COOKIE['token']==(mt_rand()+mt_rand())){/*需要在cookie里传入token,并且要弱等于 第二个取随机数 和 第三个取随机数的和*/
            echo $flag;
        }
    }else{
        echo $rand;/*如果r-第一次取随机数不等于0，那就输出他们之间的差值*/
    }
}else{
    highlight_file(__FILE__);
    echo system('cat /proc/version');
}
```

### 关于include()

include有包含的作用，`include("flag.php");`在这里，包含的内容是flag.php 里的flag，包括里边的 `$flag`，并且 `$flag` 还是**全局变量**，这也就解释了为什么在 `mt_srand(hexdec(substr(md5($flag), 0,8)));` 这串代码执行之前，我们并没有看到定义或初始化 `$flag`，但是这一串代码里又可以使用 `$flag`。因为 `$flag` 本来就是 flag.php 里定义的，经过 include 之后，它落在当前作用域（这里是全局作用域）里，所以这里可以直接用 `md5($flag)`。

那为什么既然flag.php里已经包含了flag,我们不能直接拿到flag呢？

这就是include函数的作用了，包含，但是**包含并不等同于会输出**，它是把flag.php包含了，也把flag包含了，但是**没有echo flag**,就不会显示flag，我们**就无法看到flag**。

所以我们才需要满足下方的条件判断，让它 `echo $flag`

### 关于hexdec()

- hexdec：按 16 进制读取，输出 10 进制
- `mt_srand(hexdec(substr(md5($flag), 0, 8)));` 这一行可以拆开来，一步步看
- `substr(md5($flag), 0, 8)` 从 flag.php 中的 `$flag` 全局变量，让它进行 MD5 运算，从第一位开始取 8 个字符
- `hexdec(substr(md5($flag), 0, 8))` 取完字符后，hexdec 按 16 进制读取，10 进制输出
- `mt_srand(hexdec(substr(md5($flag), 0, 8)));` mt_srand() 把输出的 10 进制值，当成种子
- 由此可见，`mt_srand(hexdec(substr(md5($flag), 0, 8)));` 这一行的作用就是**用 flag 造种子**

### 捋捋逻辑，看拿到flag要满足什么，从终点往前推

根据代码，要echo flag 就需要满足两个条件判断

1. r-第一次取随机数=rand要等于0，那说明r要等于第一个随机数，那我怎么知道第一个随机数是啥

   #### 巧妙之处

   **让r=0**,0-第一个随机数=第一个随机数的负数，这就可以知道第一个随机数了

2.    token=第二个随机数 +第三个随机数 ，我怎么能知道剩下的随机数呢？

      #### 逆推的思维

      **已知：种子是固定的，随机数序列固定。现在手上已经有了第一个随机数，可以用工具（php_mt_seed）逆推种子，再按顺序取 3 次 mt_rand()，就能拿到第二个和第三个随机数**

      #### 为什么可以逆推种子，拿到第二，第三个随机数？

      因为mt_srand()利用flag造种子已经把种子固定了，种子固定，随机序列也是固定的，通过逆推得到种子后，第一次取随机值mt_rand()，对应的就是第一个随机数，第二次取随机值mt_rand()，对应的就是第二个随机数，第三次取随机值mt_rand()，对应的就是第三个随机数

      

### 具体操作

- 利用r=0先拿到第一个随机数

  ![image-20261027164909949](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027164909949.png)

- 我们现在需要利用工具逆推出种子，根据版本选择，种子可能输出一两个，都试试

  ![image-20261027172606413](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027172606413.png)

- 拿到种子后，写脚本检验第一个随机数是否与 r=0 时试出来的一样

  > 注意：第一个随机数相同只能说明它是**候选种子之一**。因为种子是 32 位、而一次输出只有 31 位，平均会有两个不同的种子算出同一个第一个随机数，所以工具给出的候选种子都要逐个试 token，直到出 flag。

- 确认种子后，再取第二个+第三个随机数

![image-20261027172919739](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027172919739.png)

```php
<?php
mt_srand(0x60eda542);/*根据逆推工具得到的种子，播种*/
echo mt_rand(),"<br>";/*查看种子的第一个随机序列是否正确，检验种子*/
echo  mt_rand()+mt_rand();/*输出第二个序列+第三个序列 */
?>
```

- r=第一个随机数；写token到cookie中

![image-20261027173031473](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261027173031473.png)
