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



LICENSE
-----------
MIT License
