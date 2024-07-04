jothon-net
===========

揪松網 2.0。 https://jothon.g0v.tw/

改進部份
-----------

 * 資訊架構重新規畫
 * 更清楚具體的黑客松介紹
 * 內容與網站抽離
 * 登入系統 ( 為了未來的媒合、提案與報名系統做準備 )
 * g0v login ( 建立 g0v 系統生態系 )


未來規劃
-----------

 * Marketing
   * i18n ( 讓國外看見 )
   * 自動化 g0v 資訊收集與視覺化 ( 成果展示 / 募資與贊助 / 行銷與推廣 )
 * Community / Retention
   * 一鍵分支大松 - 開松工具包 ( 加速專案多中心化 )
   * 提案系統 - Project Hub ( 完善提案資訊匯整並合併 g0v 獎助金 / 大松提案 / 線下提案 )
   * 人物誌 - People Hub ( 提升媒合效率, 平台黏著度 )
   * 坑主真經 ( 協助坑主管理專案的工具與手冊 )
 * Acquisition
   * 新參者分類帽 - 給新手的遊戲化指南書 ( 降低進入門檻 )
   * 報名系統 ( 提升平台黏著度 )


Usage
-----------

網站使用 `nodejs` 搭配 `jade`, `stylus`, `livescript` 產生靜態頁面，需先安裝 `nodejs`，並確定 `nodejs` 的版本至少在 `7.6.0` 以上。版本檢驗方式：

```bash
$ node --version
```


接著，請執行：

```bash
$ npm i
$ cp secret-default.ls secret.ls
$ ./node_modules/.bin/lsc server.ls
```

以上為舊版，目前將登入與驗證暫時移除，僅留下靜態網頁部份

```bash
$ npm i
$ npm run build
$ npm start
```

然後使用瀏覽器開啟 [http://localhost:3000/](http://localhost:3000/).


如何更新揪松網大松訊息
------------

### Update Files

1. Modify the data for the <code>n<sup>th</sup></code> Hackathon:

   ```bash
   jothon-net/data/featuring.yaml	# 修改成第 N 次黑客松資料
   ```

2. Add new files:

   ```bash
   jothon-net/data/events/OO.yaml  # 第 N 次黑客松資料
   jothon-net/static/assets/img/events/OO.jpg  # 上傳第 N 次黑客松主圖 (size 1200 x 628 px)
   ```

### Rebuild and Start

1. Rebuild the project:

   ```bash
   $ npm run build
   $ npm start
   ```

### Commit and Deploy

1. Commit your changes and deploy:

   ```bash
   $ git add .
   $ git commit -m "Update nth Hackathon data"
   $ ./deploy
   ```

Configuration for Production
------------

1. **Install NodeJS**
   - Version >= `9.2.1`

2. **Install PostgreSQL**
   - Version >= `9.6.0`

3. **Create Database and User**
   ```sql
   CREATE DATABASE jothon;
   CREATE USER jothon WITH SUPERUSER;
   ```

4. **Clone Repository**
   ```bash
   $ git clone https://github.com/g0v/jothon-net/
   $ cd jothon-net
   ```
5. **Install Dependencies**
   ```bash
   $ npm install
   ```

6. **Configure Secrets**
   - Copy `secret-default.ls` to `secret.ls`
   - Set `usedb = true`
   - Setup PostgreSQL URI in `io-pg`

7. **Configure Site**
   - Edit `config/site/default.ls`
   - Set `domain` to your desired domain

8. **Configure Nginx**
   - Copy `config/nginx/sample.nginx` to `config/nginx/production.nginx`
   - Update `server_name` to your desired host
   - Set `project-root` to your repo location

9. **Generate OpenID-Connect Keys**
   ```bash
   $ lsc tools/openid-keygen
   $ mv keystore.json config/keys/openid-keystore.json
   ```

10. **Start Server**
    ```bash
    $ lsc server
    ```

11. **(Optional) Configure SSL**
    - Prepare a temporary Nginx config and run Certbot:

      ```bash
      $ sudo certbot certonly --webroot -w [temp-webroot-dir] -d [domain-name]
      ```
    - Update production Nginx config to use SSL:

      ```nginx
      listen 443;
      ssl on;
      ssl_certificate /path/to/your/fullchain.pem;
      ssl_certificate_key /path/to/your/privatekey.pem;
      ```


LICENSE
-----------
MIT License
