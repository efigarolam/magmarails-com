@Magma ||= {}

class Magma.home

  constructor: ->
    @init_slide_sizes()
    @init_unmask()
    @init_rotation_event()
    @init_backbone()

  init_slide_sizes: () ->
    width = $(window).width()

  init_rotation_event: () ->
    $(window).bind 'orientationchange', () ->
      window.location.reload()

  init_unmask: () ->
    $(window).scroll =>
      if $(window).scrollTop() > 10 and  $(window).width() < 700   then $('.main-nav').hide('slow')
      val = 750
      if navigator.platform == 'iPad' then val = 470
      if $(window).scrollTop() > val && $('.active').hasClass 'mask'
        @color_transition('remove-mask')
        $('#slider.mask').removeClass 'mask'
        $('#unmask').animate
          right: "#{$(window).width() + 590}px"
          display: 'none'
        ,
          duration: 4000
          step: (now, fx) ->
            val = 360
            if parseInt(now) > val
              $('.slide .img-gray').animate
                opacity: 0
              , 1000
              $('.slide .img-color').animate
                opacity: 1
              , 1000

              $('.slide').removeClass('mask')

  init_svg_fallbacks: () ->
    unless Modernizr.svg
      imgs = $("img")
      $.each imgs, (i, img) ->
        fallback = $(img).attr('src').split('.')[0] + '.png'
        $(img).attr "src", fallback


  color_transition: (section_name) ->
    switch section_name
      when "remove-mask" then $('#slider').animate({backgroundColor: "#a2cebd"}, {queue: false, duration: 'fast'})
      when "spotlight" then $('#slider').animate({backgroundColor: "#a2cebd"}, {queue: false, duration: 'fast'})
      when "call-for-papers" then $('#slider').animate({backgroundColor: "#84171a"}, {queue: false, duration: 'fast'})
      when "keynotes" then $('#slider').animate({backgroundColor: "#e2a63c"}, {queue: false, duration: 'fast'})


  init_backbone: () ->
    # Helper to get template text.
    getTemplate = (section) ->
      console.log section
      $("#temp-#{section}").html()

    MenuView = Backbone.View.extend
      el: $('ul.main-nav')

      events:
        "click a" : 'loadPage'

      initialize: ->
        @render()

      render: ->
        html = $('#temp-menu').html()
        @$el.html html

      loadPage: (e)->
        e.preventDefault()
        router.navigate $(e.target).data('action'),
          trigger: true


    # Simple view to render a template
    PageView = Backbone.View.extend
      index_: null

      initialize: (options) ->
        @index_ = options.section

      render: ->
        html = getTemplate(@index_)
        @$el.html html


    # Router handling a default page, and the page urls.
    Router = Backbone.Router.extend
      initialize: ->
        new MenuView()

      routes:
        ":section": "loadPage"
        "*notFound": "defaultPage"

      defaultPage: ->
        @loadPage()

      loadPage: (section) ->
        section = 'spotlight' if section == undefined
        @pageView_.remove()  if @pageView_
        @pageView_ = new PageView(section: section)
        @pageView_.render()
        @pageView_.$el.appendTo "#slider"
        @start_transitions section

      start_transitions: (section) =>
        @init_svg_fallbacks()
        $(".active").removeClass 'active'
        $("##{section}").addClass 'active'
        @color_transition section
        $('.main-nav a.selected').removeClass 'selected'
        $(".main-nav a[data-action='#{section}']").addClass 'selected'
        $('#slider').removeClass()
        $('#slider').addClass section

        $('.container').animate
          opacity: 1;
        ,
          duration: 500

    router = undefined
    $ ->
      router = new Router()
      Backbone.history.start pushState: true

