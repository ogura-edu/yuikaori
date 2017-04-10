# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $(document.twitter.type).change ->
    $('.switch').css('display', 'none')
    $('.switch input').removeAttr('required')
    switch document.twitter.type.value
      when 'period'
        $('.period').css('display', 'block')
        $('.period input').attr('required', 'required')
      when 'number'
        $('.number').css('display', 'block')
        $('.number input').attr('required', 'required')
      when 'tweet'
        $('.tweet').css('display', 'block')
        $('.tweet input').attr('required', 'required')
