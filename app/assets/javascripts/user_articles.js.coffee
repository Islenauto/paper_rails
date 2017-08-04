@registReadStatus = (article_id, read_status) ->
  elems = $('.read_status')[read_status]
  pre_elem = $('.read_status.uk-active')[0]
  $.ajax
    url: '/user_articles/regist_read_status'
    type: 'GET'
    data: { article_id: article_id, read_status: read_status }
    dataType: 'json'
    success: (data) ->
      pre_elem.className = pre_elem.className.replace('uk-active', '')
      elems.className = elems.className.replace('read_status', 'read_status uk-active')
    error: (data) ->
      console.log 'error'
