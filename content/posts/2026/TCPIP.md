---
title: TCP/IP
description: TCP/IP
date: 2026-11-01 10:15:00
updated: 2026-11-03 16:27:00
image: https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/tcp.jpg
categories: [study]
tags: [web,basic]
---

---

---

写这篇文章主要是因为，在学习TCP三次握手四次挥手的时候看到了一篇非常详细的文章，给了我很多灵感，详细内容可以点击观看，我就是看这个文章学的，非常非常仔细，读完，茅塞顿开，可以放心食用：😋

（[超超超详细讲解TCP三次握手与四次挥手（大图解），值得收藏 - 知乎](https://zhuanlan.zhihu.com/p/591865232)）

## TCP

首先我们要知道TCP/IP四层模型，分别是网络接入层，网络层，传输层，然后我们要知道TCP在哪一层，TCP在传输层

![image-20261109200304750](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109200304750.png)

接下来，就是深入了解一下TCP

## TCP三握手连接

TCP是一钟面向连接的，可靠的，有序传输层协议

![image-20261109200317982](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109200317982.png)

![image-20261109200449791](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109200449791.png)

![image-20261109200503281](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109200503281.png)

第一次握手，客户（左边）这边发送了一个SYN，然后发送的内容还包括客户这随机生成的初始序号seq=x,此时客户端进入SYN_SENT状态，等服务器这边作出反应

第二次握手，服务端（右边）这端，接收到客户端SYN报文之后，会向客户端发一个SYN+ACK,然后服务器自己会生成一个随机的序号seq=y,同时将第一次握手时，客户端传给服务器的seq=x，序号加一作为确认好ack=x+1,表示客户端已经接收到报文了，并进入SYN_RCVD状态

第三次握手，客户这边收到服务端报文之后，像服务器发送一个ack，把服务器的随机序号+1作为确认序号：ack=y+1;自己，由于之前第一次握手发过seq=x,这里是第二次发了，所以加1，这个时候，客户这边和服务器这边都进入了ESTABLISHED状态，表示连接建立成功

## 为什么握手是三次不是两次或四次？

### 先看三次握手的作用

#### 1.防止旧的历史连接初始化了连接

![image-20261109200535732](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109200535732.png)



可以看到，旧的连接在第三次握手的时候会强制断开连接，直到新的SYN到达之后才会开始，所以可以防止旧的历史连接初始化

#### 2.同步双方初始序列号

当客户端发送初始序列号之后，服务端接收到，要回一个ACK应答报文，表示成功接收到信息

当服务端发送初始序列号之后，客户端接收到也是一样的，回一个ACK,表示成功收到

这样一来一回，才能保证同步

#### 3.避免资源浪费

### 看看如果是两次握手会怎么样？

如果是两次握手，会无法阻止历史连接初始化了连接

![image-20261109200717354](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109200717354.png)

和三次握手不一样的是，两次握手在第一次握手就建立了连接，之后才强制断开连接的，

可以看右边，如果是两次握手，会建立两个连接，但其实第二个连接才是我们所需要的，所以，第一个多出来的连接会造成浪费，如果是**三次握手就可以避免资源浪费**

## 四次握手呢？

![image-20261109200738380](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261109200738380.png)

由于第二第三步可以合并为一步，所以就是三次握手

## 来看看，三次握手，每一次丢失了会怎么样？

### 第一次丢失

![image-20261104205652624](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104205652624.png)

丢失了会重新发SYN,但是超时之后就会显示连接失败

### 第二次丢失

第二次丢失，会以为是客户端没发过去，所以客户端会重发，服务端也会重发，一样的，超时会断开连接

![image-20261104205811559](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104205811559.png)

### 第三次丢失

服务端丢失了重传

![image-20261104205834920](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104205834920.png)

## 四次挥手

![image-20261104210129613](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104210129613.png)

四次挥手其实和四次握手有点像，左边，客户端这里会有个2MSL,我们细细来看

### 为啥挥手是四次不是三次？

TCP是全双工模式，它发送FIN,表示它不在发送数据，但是它还可以接受数据啊，所以，客户端，服务端都要发送两个东西，一个FIN表示，它不再发送数据，一个ACK表示它不再接收数据

### 为什么客户端这边会有2MSL?

2MSL其实可理解成一来一回

因为，如果它不等待接受到ACK，一发送ACK就close，那会出现，如果，ACK丢失，就无法再次发送了，所以其实一来一回，允许丢一次包，第二次发送ACK,刚好到2MSL,

## 来看看四次挥手，每一次丢失了会怎么样？

### 第一次挥手丢失

会重新发

![image-20261104211255792](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104211255792.png)



### 第二次挥手丢失

![image-20261104211329772](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104211329772.png)

### 第三次挥手

![image-20261104211422562](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104211422562.png)

### 第四次挥手

![image-20261104211443189](https://zelia-avatar-1471520438.cos.ap-guangzhou.myqcloud.com/blog/images/image-20261104211443189.png)