# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('.new-record').on 'click', ->
    if $(this).parent().hasClass('event-form')
      $(this).parent().append('<input placeholder="event title" type="text" name="event_attributes[name]" id="event_attributes_name">')
      $(this).css('display', 'none')
  
  $(document.twitter.twitter_type).change ->
    $('.switch').css('display', 'none')
    $('.switch input').removeAttr('required')
    switch document.twitter.twitter_type.value
      when 'date'
        $('.date').css('display', 'block')
        $('.date input').attr('required', 'required')
      when 'number'
        $('.number').css('display', 'block')
        $('.number input').attr('required', 'required')
      when 'tweet'
        $('.tweet').css('display', 'block')
        $('.tweet input').attr('required', 'required')
      else null
