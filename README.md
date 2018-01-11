jothon-net
===========

揪松網重建工程專案。目前為 mockup 建設區。


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
