// Get query parameters
window.getParameterByName = function(name, url) {
  if (!url) url = window.location.href;
  name = name.replace(/[\[\]]/g, '\\$&');
  var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
      results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

// Sticky header
window.initializeStickyHeader = function() {
  window.onscroll = function() {
    var header = document.getElementById("header");
    var stickyHeader = document.getElementById("sticky-header");

    if (header && stickyHeader) {
      var offset = header.offsetHeight;

      if (window.pageYOffset > offset) {
        stickyHeader.classList.add("sticky");
        document.body.classList.add("padded");
      } else {
        stickyHeader.classList.remove("sticky");
        document.body.classList.remove("padded");
      }
    }
  }
}

$(document).on('turbolinks:load', function() {
  // Social media buttons
  $('.social').click(function(){
    var width = window.innerWidth;
    var left = (width - 574)/2;
    return !window.open(this.href, '_blank', 'height=436, width=574, top=100, left=' + left);
  });

  // SMS Disclaimer dropdown
  window.showSmsIfCompletePhone = function(duration) {
    if ( $("#dragPhone").length > 0 && $("#dragPhone").val().replace(/[^0-9]/g,"").length >= 10 ) {
      if ( duration > 0 ) { $("#dragSmsOptIn").prop('checked', true); }
      $("#smsDisclaimer").slideDown(duration);
    }
  }

  $("#dragPhone").on('change keyup', function() { showSmsIfCompletePhone(500); });
  showSmsIfCompletePhone(0);

  $("input.write-in").on('change keyup', function() {
    $(this).closest('.draggable').find('.field-value.write-in-value').text( $(this).val() );
  })
});

// Drag and drop functionality
window.initializeDrag = function() {
  window.respondToDragStop = function() {
    if ( $(".drop-div").eq(currentQuestion).find("input.choice").length > 0 ) {
      $("#next").text("Next").show();

      if (currentQuestion == 0) {
        $("#instructions").hide();
        $(".drop-div").css('visibility', 'visible');
      }
    } else {
      $("#next").text("Skip");

      if (currentQuestion == 0) {
        $("#next").hide();
        $("#instructions").show();
        $(".drop-div").css('visibility', 'hidden');
      }
    }
  }

  window.togglePrevAndNextButtons = function() {
    $("#prev").toggle(currentQuestion > 0);
    $("#next").toggle(currentQuestion < questionCount);
  }

  window.displayAppropriateFields = function() {
    $("#contact-fields").hide();
    $(".drag-div").hide();
    $(".drop-div").hide();

    if (currentQuestion < questionCount) {
      $(".drag-div").eq(currentQuestion).show();
      $(".drop-div").eq(currentQuestion).show();
    } else {
      $("#prev").show();
      $(".drop-div").css('visibility', 'visible');
      $("#instructions").hide();
      $(".drop-div").eq(0).show();
      $("#contact-fields").show();
    }

    if ( $(".drop-div").eq(currentQuestion).find("input.choice").length > 0 ) {
      $("#instructions").hide();
      $(".drop-div").css('visibility', 'visible');
      $("#next").text("Next").show();
    }
  }

  window.prevQuestion = function() {
    currentQuestion--;
    togglePrevAndNextButtons();
    displayAppropriateFields();
    respondToDragStop();
    return false;
  }

  window.nextQuestion = function() {
    currentQuestion++;
    togglePrevAndNextButtons();
    displayAppropriateFields();
    respondToDragStop();
    return false;
  }

  window.manualVote = function(payload) {
    var target = $(".drop-div").eq(currentQuestion).find(".droppable:not(:has(.draggable))")[0] || $(".drop-div").eq(currentQuestion).find(".droppable.thrd")[0];
    var swap = $(target).children()[0];
    $(payload).parent().prepend( $(swap) );
    $(target).prepend( $(payload) );
    window.respondToDragStop();
  }

  $(".draggable").draggable({
    start: function(event, ui) {
      $("#instructions").hide();
      $(".drop-div").css('visibility', 'visible');
      $(this).draggable('instance').offset.click = {
        left: Math.floor(ui.helper.width() / 2),
        top: Math.floor(ui.helper.height() / 2)
      };
      window.inMotion = 1; // kludge to prevent duplicate drop events from firing
    },
    drag: function(event, ui) {
      // kludge to prevent jerky behavior on scrolling
      $(this).draggable('instance')._refreshOffsets(event);
    },
    scroll: false,
    stop: respondToDragStop,
    handle: ".handle",
    distance: 0,
    revert: true,
    revertDuration: 0,
    zIndex: 100,
  });

  $(".droppable").droppable({
    drop: function(event, ui) {
      while (window.inMotion > 0) {
        var payload = $(ui.draggable[0]);
        var swap = $(event.target).children()[0];
        payload.parent().prepend(swap);
        $(event.target).prepend(payload);
        window.inMotion--;
      }
    },
    tolerance: "pointer"
  });

  window.displayAppropriateFields();
  $("#interactive").show();
}

// modal
window.hideModal = function() {
  $("#modal").animate({top: "100%"}, 500, function() {
    $("#modalContent iframe").remove();
    $("#modalVote").text("");
    $("#modalOffice").text("");
    $("#modalContent").html("");
    $("a.overlay").hide();
  });
  return true;
}