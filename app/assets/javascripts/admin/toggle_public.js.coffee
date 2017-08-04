@togglePublic = (article_id) ->
  $.ajax
    url: "/admin/articles/#{article_id}/toggle_public"
    type: 'GET'
    dataType: 'json'
    success: (data) ->
      target_button = $("\##{article_id} .public_status")
      status_text = target_button[0].value
      if status_text == '公開'
        target_button[0].value = '非公開'
        target_button.removeClass('uk-button-success')
      else
        target_button[0].value = '公開'
        target_button.addClass('uk-button-success')
    error: (data) ->
      console.log 'error'
