console.log("Checking if custom.js is loaded...");


$(document).on('shiny:connected', function() {
  $('.custom-button-group').each(function() {
    let inputId = $(this).attr('id');
    let multi = $(this).data('multi') === true;
    let selectedValues = $(this).data('selected');

    if (typeof selectedValues === 'string') {
      selectedValues = JSON.parse(selectedValues);
    }
    if (!Array.isArray(selectedValues)) {
      selectedValues = [selectedValues];
    }
    
    // Apply 'active' class on load
    selectedValues.forEach(function(val) {
      $(this).find(`.custom-button[data-value='${val}']`).addClass('active');
    }.bind(this));

    // Ensure Shiny receives a properly formatted value
    let initialValue = multi ? selectedValues : (selectedValues.length > 0 ? selectedValues[0] : null);
    if (!multi && initialValue !== null) {
      initialValue = initialValue.toString();  // Ensure it's not wrapped as JSON
    }
    
    Shiny.setInputValue(inputId, initialValue, {priority: 'event'});

    // Attach click event
    $(this).on('click', '.custom-button', function() {
      if (!multi) {
        $(this).siblings().removeClass('active');
      }
      $(this).toggleClass('active');

      let selected = $(this).parent().find('.custom-button.active').map(function() {
        return $(this).data('value');
      }).get();

      if (!multi) {
        selected = selected.length > 0 ? selected[0] : null;
      }

      Shiny.setInputValue(inputId, selected, {priority: 'event'});
    });
  });
});