# SVIP Pulse Team · 团队共享版

保留 v1.3 的四个 Tab、彩色状态标签、UID 匹配导入以及访谈记录。改为 Netlify Functions + Supabase 云端共享数据库；所有人使用**一个团队密码**，无需个人邮箱账号。

## 0. 注意
- 请不要直接把压缩包拖到 Netlify Drop：服务器函数和环境变量要通过 **GitHub 导入部署** 才能按本说明可靠生效。
- **不要把团队密码、数据库 service_role key 写进 index.html、GitHub 仓库或聊天截图。** 只填入 Netlify 的环境变量。
- 本方案无个人账号，因此无法确认具体是谁修改了记录；请不要把它用作精确的员工操作审计系统。
- 团队密码只是访问门槛。分享密码的人都能查看和编辑全部 SVIP 信息。建议设置长随机密码（如 20 位以上），不要使用常见词或工作群名称，并在人员离职时及时更换。
- 本演示版不包含完善的服务端登录限速/异常流量防护，正式存储敏感个人信息前请加上 Netlify WAF / 限速等保护，并核对组织的数据隐私要求。

## 第一步：创建 Supabase 数据库
1. 打开 https://supabase.com 注册/登录，点击 New project，给项目命名 `svip-pulse`，选择地区和数据库密码。
2. 等项目创建后打开 **SQL Editor** > New query，将本文件夹 `setup.sql` 的全部内容粘贴进去，点击 Run。
3. 在 **Project Settings > API**（不同版本菜单可能是 **Connect / API Keys**）找到项目 URL 和 **service_role** 密钥，妥善保存，不要放到网站文件中。不要误用 `anon`/`publishable` key。

## 第二步：上传代码到 GitHub
1. 到 https://github.com 登录，创建新仓库，例如 `svip-pulse-team`；建议设为 Private。
2. 通过 **Add file > Upload files** 上传本文件夹的文件。注意 GitHub 网页上传时，目录结构需保持：根目录有 `index.html`、`netlify.toml`，并包含 `netlify/functions/api.cjs`。如果网页上传不能保持嵌套目录，请通过 GitHub Desktop 或 git 上传。
3. `setup.sql`、`README.md` 可一并上传；**不要上传密码或密钥**。

## 第三步：连接 Netlify
1. 打开 https://app.netlify.com > Add new project > Import an existing project > GitHub，选择刚创建的仓库。
2. 发布目录（Publish directory）为 `.`；函数目录会由 `netlify.toml` 自动指定为 `netlify/functions`。无需构建命令。
3. 到 Netlify 网站的 **Project configuration > Environment variables** 添加以下四项（scope 包括 Functions，production 生效）：
   - `SUPABASE_URL` = Supabase 项目 URL，如 `https://xxxx.supabase.co`
   - `SUPABASE_SERVICE_ROLE_KEY` = Supabase 的 **service_role** 密钥（不是 anon）
   - `TEAM_PASSWORD` = 你自己设置的长随机团队访问密码
   - `SESSION_SECRET` = 独立生成的长随机字符串，推荐至少 32 字节随机值（与团队密码不能相同）
4. 保存环境变量后 **Trigger deploy > Deploy project**（必要时 Clear cache and deploy）。
5. 用 Netlify 提供的 `https://xxxx.netlify.app` 打开网站，输入团队密码。

## 第四步：迁移旧网站数据
旧版 v1.3 的浏览器本地数据**不会自动搬到云端**：
1. 在旧网站打开「数据导入」点击「备份数据」，下载 `.json`。
2. 在团队新版网站登录后，打开「数据导入」的「恢复备份」，上传 `.json`。**仅第一次迁移这样做，恢复会覆盖团队云端当前全部数据。**
3. 进入用户档案检查人数、几个 UID、访谈状态及备注。让同事打开相同网址，确认结果一致。
4. 建议先在 Supabase 做好备份策略并测试恢复流程，再用于正式运营。

## Excel 导入
- 继续识别 `User UID`、`SVIP Tier` 和其他 v1.3 英文表头。
- 导入界面有预览、确认两步；只有确认之后才更新云端。
- UID 匹配只覆盖快照字段，不覆盖 `contacted`、`status`、`interviewDate`、`notes`。
- 旧快照保留，最新名单里没有的 UID 标为历史用户，不删除。
- 不允许导入早于最新快照的日期；同一天重传会替换当日快照。

## 使用限制和建议
- 在数据更新后，同事刷新网页能马上看到；网站在无编辑操作时大约每 30 秒自动刷新。
- 一个团队密码意味着所有成员权限完全相同，无个人责任追踪。按团队需求进一步引入账号和权限系统更安全。
- 当前数据存储在单条 JSONB 文档中，适合人数较少、并发较低的内部试用；用户/快照数据很大时建议升级为独立的 users / snapshots / interviews 表。
- 同一个 UID 的同一个字段如果被两人先后修改，以服务器最后收到的为准；编辑不同用户时通过版本条件更新避免整库丢失。
- 如果页面出现 “数据库错误” 请检查环境变量、SQL 是否运行以及 Netlify Functions 日志。

## 中文 / Español 语言切换
- 登录页和网站右上角提供 **中文 / Español** 切换，不需要重新部署两份网站。
- 语言选择仅保存在各自浏览器，所有人继续共享相同的 Supabase 数据。
- SVIP 访谈状态内部仍使用规范化中文值作为数据库值，西班牙语只是界面展示，不会产生重复状态。
- 用户昵称、国家、UID、备注等用户原始数据不自动翻译。
- 导入文件仍兼容既有中文及英文后台表头。
- 当前主要界面和状态已双语化；复杂提示和某些历史动态消息可能仍出现中文，后续可逐项补齐。
