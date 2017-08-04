$('#articles').html('<%= escape_javascript(render partial: "articles", locals: {articles: @articles}) %>')
