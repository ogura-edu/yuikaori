# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#modalを閉じたらvideoタグにpause()を実行する
$(document).on 'click.dismiss.bs.modal', "#show_modal", ->
  if $('#modal-video')[0]
    video = document.getElementById('modal-video')
    video.pause()
