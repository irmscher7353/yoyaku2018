$(document).on 'turbolinks:load', ->
	# ブラウザの戻るボタンを無効化する．
	history.pushState(null, null, null)

