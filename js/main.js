// Generated by LiveScript 1.3.1
$(document).ready(function(){
  var imgs, shadow, shadowImage, easeInOutQuad;
  imgs = Array.from(document.querySelectorAll('.reveal'));
  shadow = document.createElement('div');
  shadowImage = document.createElement('div');
  shadow.setAttribute('class', 'reveal-shadow');
  document.body.appendChild(shadow);
  shadow.appendChild(shadowImage);
  shadow.addEventListener('click', function(){
    return import$(import$(shadow.style, shadow.source), {
      opacity: 0,
      zIndex: -1
    });
  });
  Array.from(document.querySelectorAll('.lightbox')).map(function(img){
    return img.addEventListener('click', function(){
      var box;
      box = img.getBoundingClientRect();
      shadow.setAttribute('class', 'reveal-shadow');
      shadow.box = box;
      shadow.source = {
        width: box.width + "px",
        height: box.height + "px",
        top: box.top + "px",
        left: box.left + "px",
        zIndex: 9999
      };
      import$(shadow.style, shadow.source);
      shadowImage.style.backgroundImage = "url(" + (img.getAttribute('data-lg-src') || img.getAttribute('data-src')) + ")";
      return setTimeout(function(){
        shadow.setAttribute('class', 'reveal-shadow active');
        return import$(shadow.style, {
          width: "100%",
          height: "100%",
          top: "0",
          left: "0",
          opacity: 1
        });
      }, 10);
    });
  });
  window.addEventListener('scroll', function(){
    var h, y;
    h = window.innerHeight;
    y = window.pageYOffset;
    return imgs.map(function(img){
      var top;
      top = img.getBoundingClientRect().top;
      if (top < h * 0.8 && !img.revealed) {
        img.revealed = true;
        img.node = new Image();
        img.node.onload = function(){
          return setTimeout(function(){
            var cls;
            img.style.backgroundImage = "url(" + (img.getAttribute('data-src') || '') + ")";
            cls = img.getAttribute('class').split(' ');
            if (!~cls.indexOf('on')) {
              cls.push('on');
            }
            return img.setAttribute('class', cls.join(' '));
          }, Math.random() * 200);
        };
        return img.node.src = img.getAttribute('data-src') || '';
      }
    });
  });
  window.scrollto = function(node, dur){
    var element, ref$, des, src, diff, start, animateScroll;
    dur == null && (dur = 500);
    element = document.documentElement || document.body;
    if (typeof node === 'string') {
      node = document.querySelector(node);
    }
    ref$ = [node.getBoundingClientRect().top, window.pageYOffset], des = ref$[0], src = ref$[1];
    ref$ = [des - src, -1], diff = ref$[0], start = ref$[1];
    animateScroll = function(timestamp){
      var val;
      if (start < 0) {
        start = timestamp;
      }
      val = easeInOutQuad(timestamp - start, src, diff, dur);
      element.scrollTop = val;
      if (timestamp <= start + dur) {
        return requestAnimationFrame(animateScroll);
      }
    };
    return requestAnimationFrame(animateScroll);
  };
  easeInOutQuad = function(t, b, c, d){
    t = t / (d * 0.5);
    if (t < 1) {
      return c * 0.5 * t * t + b;
    }
    t = t - 1;
    return -c * 0.5 * (t * (t - 2) - 1) + b;
  };
  return window.search = function(){
    var keyword, ret, payload, url, req;
    document.body.setAttribute('class', document.body.getAttribute("class") + " running");
    keyword = (document.getElementById('search-input') || {}).value || '';
    if (!keyword) {
      ret = /q=(.+)/.exec(window.location.search);
      if (ret) {
        keyword = ret[1];
      }
    }
    if (keyword && !/search/.exec(window.location.href)) {
      window.location.href = "/search/?q=" + keyword;
    }
    if (keyword) {
      keyword = decodeURIComponent(keyword);
      document.querySelector('#search-hint').innerText = "搜尋「" + keyword + "」的搜尋結果";
    }
    payload = {
      "query": {
        "query_string": {
          "query": keyword
        }
      },
      "from": 0,
      "highlight": {
        "fields": {
          "content": {}
        }
      },
      "aggs": {
        "source_count": {
          "terms": {
            "field": "source"
          }
        }
      },
      "sort": [{
        "updated_at": "desc"
      }]
    };
    url = "https://api.search.g0v.io/query.php?query=" + encodeURIComponent(JSON.stringify(payload));
    req = new XMLHttpRequest();
    req.addEventListener('load', function(){
      var payload, ret, container;
      payload = JSON.parse(req.responseText);
      ret = payload.hits.hits.map(function(it){
        var ref$, title, url, content, source;
        ref$ = {
          title: (ref$ = it._source).title,
          url: ref$.url,
          content: ref$.content,
          source: ref$.source
        }, title = ref$.title, url = ref$.url, content = ref$.content, source = ref$.source;
        if (content.length > 100) {
          content = content.substring(0, 100) + '...';
        }
        ref$ = [title, url, content].map(function(it){
          return it.replace(/[<>\&]/gim, function(it){
            return "&#" + it.charCodeAt(0) + ";";
          });
        }), title = ref$[0], url = ref$[1], content = ref$[2];
        content = content.replace(new RegExp(keyword + "", "g"), function(){
          return "<b>" + keyword + "</b>";
        });
        return "<div class=\"search-result\"><a href=\"" + url + "\">" + title + "</a><div class='url'>" + url + "</div><div class='desc'>" + content + "</div><div class='type'>" + source + "</div></div>";
      });
      container = document.querySelector('.search-results');
      if (!container) {
        return;
      }
      container.innerHTML = ret.join('');
      return document.body.setAttribute('class', document.body.getAttribute("class").replace("running", ""));
    });
    req.open('GET', url);
    return req.send();
  };
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}