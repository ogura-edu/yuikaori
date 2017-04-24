# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

new_tags = 0
$(document).on 'click', '.new-record',->
  if $(this).hasClass('event')
    $('.event-form').append('<input placeholder="イベント名" type="text" name="picture[event_attributes][event]" id="picture_event_attributes_event">')
    $(this).css('display', 'none')
  else if $(this).hasClass('tags')
    $('.tags-form').append("<input placeholder='タグ名' type='text' name='picture[tags_attributes][#{new_tags}][tag]' id='picture_tags_attributes_#{new_tags}_tag'>")
    new_tags++

$(document).on 'turbolinks:load', ->
  $('.my-thumbnail.selectable').click ->
    if $(this).hasClass('checked')
      $(this).removeClass('checked')
      $(this).next('.multiple_checkbox').prop('checked', false)
    else
      $(this).addClass('checked')
      $(this).next('.multiple_checkbox').prop('checked', true)

  $container = $('#masonry-container')
  num = $container.find('.picture').length
  while num < 4
    $container.find('.page').append('<div class="picture dummy"></div>')
    num++
  $container.imagesLoaded ->
    $container.masonry
      itemSelector: '.picture'
      columnWidth: '.sizer'
      gutter: 10
      percentPosition: true
      isFitWidth: true
      isAnimated: true
      resize: true
    return

  $container.infinitescroll {
    loading:
      img:     '/images/item/loading.gif'
      msgText: ''
    navSelector: "nav .pagination"
    nextSelector: "nav .pagination a[rel=next]"
    itemSelector: ".picture"
    animate: true
    }, (newElements) ->
      $newElems = $(newElements)
      $newElems.imagesLoaded ->
        $container.masonry 'appended', $newElems, true
      $newElems.children('.my-thumbnail.selectable').click ->
        if $(this).hasClass('checked')
          $(this).removeClass('checked')
          $(this).next('.multiple_checkbox').prop('checked', false)
        else
          $(this).addClass('checked')
          $(this).next('.multiple_checkbox').prop('checked', true)
  
  $('#check_all').click ->
    for element in $('.my-thumbnail.selectable')
      if $(element).not('.checked')
        $(element).addClass('checked')
        $(element).next('.multiple_checkbox').prop('checked', true)
  $('#uncheck_all').click ->
    for element in $('.my-thumbnail.selectable')
      if $(element).hasClass('checked')
        $(element).removeClass('checked')
        $(element).next('.multiple_checkbox').prop('checked', false)
