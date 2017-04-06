# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('.my-thumbnail').click ->
    if $(this).hasClass('checked')
      $(this).removeClass('checked')
      $(this).next('.multiple_checkbox').prop('checked', false)
    else
      $(this).addClass('checked')
      $(this).next('.multiple_checkbox').prop('checked', true)

  $container = $('#masonry-container')
  $container.imagesLoaded ->
    $container.masonry
      itemSelector: '.picture'
      isFitWidth: true
      isAnimated: true
      isResizable: true
    return

  $container.infinitescroll {
    loading:
      img:     '/assets/item/loading.gif'
      msgText: ''
    navSelector: "nav .pagination"
    nextSelector: "nav .pagination a[rel=next]"
    itemSelector: ".picture"
    animate: true
    }, (newElements) ->
      $newElems = $(newElements)
      $newElems.imagesLoaded ->
        $container.masonry 'appended', $newElems, true
      $newElems.children('.my-thumbnail').click ->
        if $(this).hasClass('checked')
          $(this).removeClass('checked')
          $(this).next('.multiple_checkbox').prop('checked', false)
        else
          $(this).addClass('checked')
          $(this).next('.multiple_checkbox').prop('checked', true)
