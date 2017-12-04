<- $(document).ready _
imgs = Array.from(document.querySelectorAll \.reveal)
imgs.map (img) ->
  img.node = new Image!
  img.node.src = img.getAttribute(\data-src)

window.addEventListener \scroll, -> 
  h = window.innerHeight
  y = window.pageYOffset
  imgs.map (img) ->
    top = img.getBoundingClientRect!top
    if top < h =>
      img.style.backgroundImage = "url(#{img.getAttribute \data-src})"
      img.style.backgroundSize = "contain"

