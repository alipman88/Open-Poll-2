require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

// record desired order of poll questions via hidden .position input on drag & drop re-order
$( document ).on('turbolinks:load', function() {
  $(".sortable").sortable({
    update: function() {
      $('input.position').each(function(index) {
        $(this).val(index);
      });
    }
  });
});
