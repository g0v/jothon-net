jothon-net
===========

揪松網 2.0。 https://hack.g0v.tw/

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

網站使用 nodejs 搭配 jade, stylus, livescript 產生靜態頁面，需先安裝 nodejs，並確定 nodejs 的版本至少在 7.6.0 以上。版本檢驗方式：

```
    node --version
```


接著，請執行：

```
    npm i
    cp secret-default.ls secret.ls
    ./node_modules/.bin/lsc server.ls
```

然後使用瀏覽器開啟 [http://localhost:9000/](http://localhost:9000/).


Configuration for Production
------------

* install NodeJS ( version >= 9.2.1 )
* install PostgreSQL ( version >= 9.6.0 )
* create jothon database ( create database jothon )
* create jothon user ( create user jothon with superuser )
* git clone https://github.com/g0v/jothon-net/
* npm install under repo directory
* config secret.ls from secret-default.ls
  - usedb = true
  - setup io-pg uri
* config config/site/default.ls
  - domain = [desired domain]
* config config/nginx/production.nginx from config/nginx/sample.nginx
  - change server_name from localhost to your desired host
  - change project-root to where your repo locates
* generate keys for openid-connect provider
  - run ```lsc tools/openid-keygen```
  - move generated keystore.json to config/keys/openid-keystore.json
* start server
  - lsc server
* (bonus) config ssl: ( example with webroot authentication )
  - might need prepare a temp nginx config and run it
  - sudo certbot certonly --webroot -w [temp-webroot-dir] -d [domain-name]
  - config production nginx to adapt SSL cert and key files. in server block:
    ```
    listen 443;
    ssl on;
    ssl_certificate /path/to/your/fullchain.pem;
    ssl_certificate_key /path/to/your/privatekey.pem;
    ```


LICENSE
-----------
MIT License
