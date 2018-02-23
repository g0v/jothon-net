<- $(document).ready _
imgs = Array.from(document.querySelectorAll \.reveal)
shadow = document.createElement \div
shadowImage = document.createElement \div
shadow.setAttribute \class, \reveal-shadow
document.body.appendChild shadow
shadow.appendChild shadowImage
shadow.addEventListener \click, ->
  shadow.style <<< shadow.source <<< do
    opacity: 0, zIndex: -1
  
Array.from(document.querySelectorAll \.lightbox).map (img) ->
  img.addEventListener \click, ->
    box = img.getBoundingClientRect!
    shadow.setAttribute \class, 'reveal-shadow'
    shadow.box = box
    shadow.source = do
      width: "#{box.width}px", height: "#{box.height}px"
      top: "#{box.top}px", left: "#{box.left}px", zIndex: 9999
    shadow.style <<< shadow.source
    shadowImage.style.backgroundImage = "url(#{img.getAttribute(\data-lg-src) or img.getAttribute(\data-src)})"
    setTimeout (->
      shadow.setAttribute \class, 'reveal-shadow active'
      shadow.style <<< do
        width: "100%", height: "100%"
        top: "0", left: "0", opacity: 1
    ), 10
    

window.addEventListener \scroll, -> 
  h = window.innerHeight
  y = window.pageYOffset
  imgs.map (img) ->
    top = img.getBoundingClientRect!top
    if top < h * 0.8 and !img.revealed =>
      img.revealed = true
      img.node = new Image!
      img.node.onload = ->
        setTimeout (-> 
          img.style.backgroundImage = "url(#{img.getAttribute(\data-src) or ''})"
          cls = img.getAttribute(\class).split(' ')
          if !(~cls.indexOf(\on)) => cls.push \on
          img.setAttribute(\class, cls.join(' '))
        ), Math.random! * 200
      img.node.src = img.getAttribute(\data-src) or ''

window.scrollto = (node, dur = 500) ->
  element = document.documentElement or document.body
  if typeof(node) == \string => node = document.querySelector node
  [des, src]= [node.getBoundingClientRect!top, window.pageYOffset]
  [diff,start] = [des - src, -1]
  animateScroll = (timestamp) ->
    if start < 0 => start := timestamp
    val = easeInOutQuad timestamp - start, src, diff, dur
    element.scrollTop = val
    if timestamp <= start + dur => requestAnimationFrame animateScroll
  requestAnimationFrame animateScroll

easeInOutQuad = (t,b,c,d) ->
  t = t / (d * 0.5)
  if t < 1 => return c * 0.5 * t * t + b
  t = t - 1
  return -c * 0.5 * ( t * (t - 2) - 1 ) + b

window.search = ->
  document.body.setAttribute \class, document.body.getAttribute("class") + " running"
  keyword = (document.getElementById(\search-input) or {}).value or ''
  if !keyword =>
    ret = /q=(.+)/.exec(window.location.search)
    if ret => keyword = ret.1
  if keyword and !/search/.exec(window.location.href) => window.location.href = "/search/?q=#keyword"
  if keyword =>
    keyword = decodeURIComponent(keyword)
    document.querySelector(\#search-hint).innerText = "搜尋「#{keyword}」的搜尋結果"
  payload = {"query":{"query_string":{"query":keyword}},"from":0,"highlight":{"fields":{"content":{}}},"aggs":{"source_count":{"terms":{"field":"source"}}},"sort":[{"updated_at":"desc"}]}
  url = ("https://api.search.g0v.io/query.php?query=#{encodeURIComponent(JSON.stringify(payload))}")

  req = new XMLHttpRequest!
  req.addEventListener \load, ->
    payload = JSON.parse req.responseText
    ret = payload.hits.hits.map ->
      {title, url, content, source} = it._source{title, url, content, source}
      if content.length > 100 => content = content.substring(0, 100) + '...'
      [title, url, content] = [title, url, content].map -> it.replace /[<>\&]/gim, -> "&\##{it.charCodeAt(0)};"
      content = content.replace new RegExp("#keyword", "g"), -> "<b>#keyword</b>"
      """<div class="search-result"><a href="#url">#{title}</a><div class='url'>#{url}</div><div class='desc'>#content</div><div class='type'>#source</div></div>"""
    container = document.querySelector('.search-results')
    if !container => return
    container.innerHTML = ret.join('')
    document.body.setAttribute \class, document.body.getAttribute("class").replace("running","")
  req.open \GET, url
  req.send!
