# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('.word').on 'click', ->
    class_name = $(this)[0].className
    word = $(this).text().toLowerCase().replace(/\s+/g, "")
    $.ajax
      url: '/word_histories/change_known'
      type: 'GET'
      data: { word: word }
      dataType: 'json'
      success: (data) ->
        elems = $(".#{word}")
        i = 0
        while i < elems.length
          if class_name.match(/unknown/)
            elems[i].className = elems[i].className.replace('unknown', 'known')
          else
            elems[i].className = elems[i].className.replace('known', 'unknown')
          i++
        console.log 'success'
      error: (data) ->
        console.log 'error'

@toggleSlash = (is_active) ->
  elems = $('.slash')
  for i, elem of elems
    if is_active
      elem.className = 'slash slash-active'
    else
      elem.className = 'slash slash-inactive'
    
@togglePosColor = (is_active) ->
  elems = $('.pos')
  for i, elem of elems
    if is_active
      elem.className = elem.className.replace('pos-inactive', 'pos-active')
    else
      elem.className = elem.className.replace('pos-active', 'pos-inactive')
    
