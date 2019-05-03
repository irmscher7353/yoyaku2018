# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@names =
  toggle_checkbox: (element) ->
    # names-index の checkbox がクリックされた時の処理．
    id = element.attr('id')
    name_id = element.attr('name_id')
    # コミット用の checkbox を同期させる．
    $('input#new_'+id).prop('checked', element.prop('checked'))
    # 値が変更されていたら，背景色を変える．
    if $('input#old_'+id).prop('checked') != element.prop('checked')
      element.parent().addClass('modified')
    else
      element.parent().removeClass('modified')
    # 何れかの checkbox が変更されていたら，更新ボタンを有効にする．
    disabled = true
    if $('input#old_is_shamei-'+name_id).prop('checked') != $('input#is_shamei-'+name_id).prop('checked')
      disabled = false
    if $('input#old_is_sitenmei-'+name_id).prop('checked') != $('input#is_sitenmei-'+name_id).prop('checked')
      disabled = false
    if $('input#old_is_mei-'+name_id).prop('checked') != $('input#is_mei-'+name_id).prop('checked')
      disabled = false
    if $('input#old_is_sei-'+name_id).prop('checked') != $('input#is_sei-'+name_id).prop('checked')
      disabled = false
    if $('input#old_is_title-'+name_id).prop('checked') != $('input#is_title-'+name_id).prop('checked')
      disabled = false
    $('input#inline-update-'+name_id).prop('disabled', disabled)

$(document).on 'turbolinks:load', ->
  if 0 < $('table#names-index').length
    $('a.name').on 'click', (event) =>
      $('.current-name').removeClass('current-name')
      $(event.target).parent().addClass('current-name')
    $('a.phone').on 'click', (event) =>
      $('.current-phone').removeClass('current-phone')
      $(event.target).parent().parent().addClass('current-phone')
    $('input.checkbox').on 'click', (event) =>
      names.toggle_checkbox($(event.target))
