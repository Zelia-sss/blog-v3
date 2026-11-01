# Zelia 的博客

基于 [Clarity](https://github.com/L33Z22L11/blog-v3) 主题搭建的个人博客，记录 Web 安全、CTF 与开发学习笔记。

- 站点：<https://zelia.top/>
- 主题：Clarity v3.7.2，作者 [L33Z22L11](https://github.com/L33Z22L11)
- 本站文章：[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans)
- 站点源码：<https://github.com/Zelia-sss/blog-v3>

## 版权与致谢

- 主题本体遵循 [MIT](LICENSE) 协议，版权归原作者 Zhilu 所有，`LICENSE` 文件保留。
- `content/` 下的文章由本站作者原创（另有注明除外），采用 CC BY-NC-SA 4.0 协议。
- 未将主题作者的文章以本站名义发布；主题作者与项目链接保留在页脚。
- 主题设计参考了 [Stellar](https://github.com/xaoxuu/hexo-theme-stellar)。

## 本地开发

需要 Node.js 22.19+（22.x）、24.11+（24.x）或 26+，推荐使用最新 LTS 版本。

```sh
pnpm i
pnpm dev
```

常用命令：

```sh
pnpm new        # 新建文章
pnpm generate   # 生成静态站点到 dist
pnpm preview    # 预览构建结果
pnpm lint       # 代码检查
```

## 内容与配置

- `content/posts`：正式文章；`content/previews`：草稿/预览（**不是私密区域**，只隐藏了入口，构建后仍可通过链接或 `/raw` 访问）
- `blog.config.ts`：站点名称、作者、域名、分类、订阅源等静态配置
- `app/app.config.ts`：页脚导航、侧栏导航、分页与精选文章样式
- `app/feeds.ts`：友链列表
- `content/link.md`：友链申请说明

## 安全说明

- `content/previews` 不是访问控制：敏感草稿请放在私有分支或私有仓库，不要放进会部署的内容目录。
- 仓库只存放可公开内容；`SecretKey.csv`、`.env`、证书私钥等已加入 `.gitignore`，不要提交。
- 线上应开启 EdgeOne 控制台的“强制 HTTPS 访问”；本项目同时通过 `edgeone.json` 下发 HSTS、CSP 等安全响应头。
- `@bikariya/shiki` 固定为 0.0.8，并通过 `patches/` 将代码高亮语言包改为本地打包；升级前需同步更新补丁。

## 部署

静态构建命令为 `pnpm generate`，输出目录为 `dist`，安装命令为 `pnpm i`。

推送到 GitHub 后由 EdgeOne 自动部署；本地可直接运行 `publish.cmd` 完成提交与推送。

## 许可证

- 项目本体：[MIT](LICENSE)，Copyright (c) 2024 Zhilu
- 博客文章：[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans)
