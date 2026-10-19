---
title: Web基础-前端三件套
description: HTML，CSS，JS 
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

![Snipaste_2026-10-19_15-09-19](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/Snipaste_2026-10-19_15-09-19.png)

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
        用户名：<input type="text" name="uername"/>
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