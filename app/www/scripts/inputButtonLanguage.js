Shiny.inputBindings.register({
  find: function(scope) {
  return $(scope).find('.custom-button-group');
  },
  getId: function(el) {
  return $(el).attr('data-input-id');
  },
  getValue: function(el) {
  let multi = $(el).attr('data-multi') === 'true';
  let selected = [];
  $(el).find('.custom-button.active').each(function() {
  selected.push($(this).attr('data-value'));
  });
  return multi ? selected : (selected.length > 0 ? selected[0] : null);
  },
  setValue: function(el, value) {
  $(el).find('.custom-button').removeClass('active');
  if (Array.isArray(value)) {
  value.forEach(val => {
  $(el).find(`.custom-button[data-value="${val}"]`).addClass('active');
  });
  } else {
  $(el).find(`.custom-button[data-value="${value}"]`).addClass('active');
  }
  },
  subscribe: function(el, callback) {
  $(el).on('click', '.custom-button', function() {
  let multi = $(el).attr('data-multi') === 'true';
  if (!multi) {
  $(el).find('.custom-button').removeClass('active');
  }
  $(this).toggleClass('active');
  callback();
  });
  }
  }, 'customButtonInputBinding');