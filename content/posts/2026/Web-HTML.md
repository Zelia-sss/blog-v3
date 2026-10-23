---
title: Web基础
description: HTML，CSS，JS ,php
date: 2026-10-19 13:44:25
updated: 2026-10-19 
image: /images/HTML/6024DB8AC1F771C2822693DDD9BBA4D7.jpg
categories: [web]
tags: [Web, 基础, HTML, CSS, JS]

---

---

## HTML

HTML—— 搭骨架：决定页面里`有什么内容`（标题、段落、图片、按钮、输入框…）



在写ctf-web题目的过程中，我们会经常与网站打交道也会经常碰到html，所以对HTML有所了解，是必不可少的，话不多说，马上开始

**在写html之前我们需要用到php,一般情况下，html文件都是在www文件夹下,`后缀名为.html`**

### 标题

````html
<!DOCTYPE html> 
<!-- 声明类型为HTML文档-->
<html lang='zh-CN'> 
<!--中文，英文：lang='en' -->

<head>
<!--head的内容不会在浏览器窗口显示 -->
    <title>zelia小贴 </title>
    <!--标题 -->
</head>

<body>
<!--body里边的内容是网页的主体内容-->

 <h1>大标题：网页设计</h1>

  <h2>小标题：随便写写</h2>

  <h3>更小的标题</h3>

  <!--h1-h3标题会越来越小-->

</body>

</html>

<!--结束标记 -->
````

**效果**

![Snipaste_2026-10-19_15-02-26](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_15-02-26.png)



### 有序列表

````html
 <h1>有序列表标签</h1>
    <ol>
        <ol>Zelia</ol>
        <ol>Zelia</ol>  
````

**效果**

![image-20261021211644857](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261021211644857.png)

### 无序列标签

````html
<h1>无序列表标签</h1>
    <ul>
        <li>Zelia-1</li>
        <li>Zelia-2</li>
    </ul>
````

**效果**

![Snipaste_2026-10-19_15-09-19](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_15-09-19.png)

### 超链接标签+图片

````html
<h1>超链接标签</h1>
    <a href="https://blog.ss0t-hacked.top/beginner-tutorial">会跳转到哪里呢？？？</a>

    <img src="要跳转的网站的路径" />
````

**效果**

![Snipaste_2026-10-19_15-10-43](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_15-10-43.png)

### input标签（交互）

````html
 <h1>input标签（交互）</h1>
    <div>
        用户名：<input type="text" name="username"/>
    </div>
    <div>
        密码：<input type="text" name="password"/>
        邮箱：<input type="text" name="email"/>
    </div>
    <div>
        性别：<input type="radio" name="sex" value='1'>男 
    <input type="radio" name="sex" value='2'>女
        
    </div>
````

![Snipaste_2026-10-19_15-11-14](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_15-11-14.png)



---

## CSS

CSS —— 做装修：决定这些内容`长什么样`（颜色、大小、位置、边框…）



CSS 要生效，必须和 HTML 关联起来，有三种方式：

1. 外部样式表—单独一个 `.css` 文件，在 HTML 的 `<head>` 里引入

2. 内部样式——CSS 写在 HTML 文件内部的 `<style>` 标签里
3. 内联样式——直接写在标签的 `style` 属性上（只管这一个标签）

**这里用到的是内部样式**

### style写在html的head部分

````html
<!DOCTYPE html> 
<!-- 声明类型为HTML文档-->
<html lang='zh-CN'> 
<!--中文，英文：lang='en' -->
<head>
<!--head的内容不会在浏览器窗口显示 -->
    <title>zelia小贴 </title>
    <!--标题 -->




   	<style>
        div{
            color:rgb(236, 97, 4);/* 这里设置了所有用了 div标签的 都是天蓝色 */
        }

        /* id 选择器：管住 id="d1" 这一个元素 */
        #di{
            font-size:x-large;
        }

         /* 类选择器：管住所有 class="c1" 的元素 */
        .c1{
            color:blue;
        }

    </style>



</head>
````

### 在body里使用标签

````css
	<div id="di">利用 id 属性来找标签,id属性里写的字体是x-large，这里的字体就大</div>
  
 	<div class="c1">利用 class 属性来找标签,class里是color颜色，就让文字都是class写的那种颜色</div>
````

**效果**

![Snipaste_2026-10-19_16-13-34](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_16-13-34.png)

---

## JS

JavaScript（`负责交互行为`)

```` javascript
<button onclick="alert('我是提示弹窗！')">1. 提示弹窗</button> 
   
    <button onclick="askConfirm()">2. 确认弹窗</button>
    <button onclick="askPrompt()">3. 输入弹窗</button>
    <p id="result"></p>
   <script>
    function askConfirm() {
            if (confirm('确定要继续吗？')) {
                let box = document.getElementById('result');  // 第①步：拿到盒子
                box.innerText = '你点了确定';                  // 第②③步：往盒子里放字
            } else {
                let box = document.getElementById('result');  // 第①步：拿到盒子
                box.innerText = '你点了取消';                  // 第②③步：往盒子里放字
            }
        }

     function askPrompt() {
            let name = prompt('你叫什么名字？', 'zelia');
            if (name != null && name != '') {
                alert('你好呀，' + name + '！');
            }
        }

   </script>
````

**效果**

![Snipaste_2026-10-19_16-37-39](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_16-37-39.png)

![Snipaste_2026-10-19_16-38-33](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_16-38-33.png)

## PHP

php常用于生成动态的html文档（往html中塞了动态文本）

### 开始标记和结束标记

首先呢，php需要有开始标记,和结束标记，我们的代码就包括在这两个首尾标记之间

```php
<?php
//开始标记
    
...//具体代码

?>
//结束标记
```

### 变量和常量

```php
$变量名=值；//变量一般用小写字母
$n=1;


//define("常量名",常量值)；
define("Num1",11);
echo Num1,"<br>";
//const 常量名=常量值；
const Num2=22;
echo Num2,"<br>";


```

![image-20261023161230322](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261023161230322.png)

### php数据类型

- 布尔型：0、1 ；false,true

- 整型int

- 浮点型

- 字符串string

- 数组（可存放多种数据类型）array

  ```php
  <?php
  $d=array('a',1,'c',array(1,2,3));
  echo $d;//会报错，为啥？这里先不说，我留个悬念,看echo
  echo $d[0];//bingo
  ?>
  ```

  

- 对象object

- 资源类型Resource

既然写到了数据类型，就在这里解释两个与数据类型相关的函数

#### gettype()

```
gettype(变量)
```

![image-20261023161543358](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261023161543358.png)



### 关于echo

echo是最常见的,看起来可能不起眼，就输出嘛，但是却很重要，后续的很多web漏洞可能都是因为它

首先，它是语言结构，**不是函数**

其次，echo,是用来输出**字符串型**的数据的，这也就是为什么上边的`echo $d;`会报错的原因，因为数组里边，不只有字符串型还有整型数据

### 运算符

**加减乘除** ：`+,-,*,%`

**并置**：连接两个字符串 

```php
echo "Hi"."hi","<br>";
echo 7.3,"<br>";//原本是整数，并置之后，表现形式变成了字符串，但并不是数据类型变了
```

`7.3` 在内存里**不是**以字符 `"7.3"` 存的，而是 IEEE 754 的二进制浮点数；只有在你拼接、`echo`、比较的时候，PHP 才**临时**把它转成字符串。所以“字符串形式”只是它在某个操作中的**表现形式**，不是它的存储类型。

**自增，自减**

++X,X++

--X ,X--

### 比较运算符（一般和if一起用）

**弱等于**：==

**强等于**：===

**不等于**：！=   or   <>

**大于，小于，大于等于，小于等于**：>/</>=/<=

### 逻辑运算符（结果是布尔型）

```php
x and y //与
x && y

x or y//或
x || y

!y//取反

x xor y //抑或，当且仅当一个为真才为真
```

### 三元运算

``` php
$a=1;
$b=2;
$a>$b ? $n=10:$n=20;
echo $n; 
```

结果是20

### 循环

for

#### 数组循环用foreach

```php
$c=array("一号"=>"Zelia","二号"=>"tutu","三号"=>"刷子");//=> 左边是键，右边是值。
echo "<table border='1' cellpadding='6'>";
echo "<tr><th>编号</th><th>名字</th></tr>";   
foreach($c as $key=>$val){
$info="<tr><td>$key</td><td>$val</td></tr>";
echo "$info";
}
echo "</table>";        

```

- `<tr>` = table row（一行）
- `<th>` = table header（表头单元格，默认加粗居中）

输出表格的**开始标签**（PHP 里 HTML 就是普通字符串）：

- `border='1'` → 显示 1 像素边框
- `cellpadding='6'` → 单元格内容和边框之间留 6 像素空白

**遍历数组**，每轮取出一个键值对：

- `$key` ← 当前键（一号、二号、三号）
- `$val` ← 当前值（Zelia、tutu、刷子）
- `$c` 有 3 个元素，所以循环 **3 次**，顺序和定义时一致



![image-20261023170006159](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261023170006159.png)

**用 PHP 循环，把“关联数组”里的数据拼成一张 HTML 表格，输出给浏览器。**

 语法到这里，基本上就大差不差了

### 最最最最重要的（ctf-web常出现）

刚开始，可能对这些没感觉，再web题中，还会看到，在这里，浏览一遍，了解即可

- 代码中出现

  eval($str)              // 把字符串当 PHP 代码跑
  assert($str)            // PHP 7 可执行代码，8 起不会
  include / require       // 包含文件，路径可控就能包含任意文件
  call_user_func($f, ...) // 回调可控 = 任意函数调用
  $f()  ${$name}  $$var   // 变量函数，变量名可控就危险
  create_function()       // 已移除，老代码里还能见到

- 危险命令

system()  exec()  shell_exec()  passthru()
popen()   proc_open()  pcntl_exec()
`ls`      // 反引号，等价 shell_exec

- 文件读取、写入，包含

file_get_contents()  readfile()  fopen()  file()
file_put_contents()  fwrite()    unlink()  copy()  rename()
move_uploaded_file()
highlight_file() / show_source()
scandir() / glob()

- 数据库查询

mysqli_query()      // 字符串拼接就注入
PDO::query() / exec()
$pdo->prepare()     // 用错照样注入（假预处理）

- 反序列化

unserialize($data)
以及 phar:// 触发的隐式反序列化

