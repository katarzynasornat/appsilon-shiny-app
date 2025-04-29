/*navigator.geolocation.getCurrentPosition(
  function(position) {
    Shiny.setInputValue('user_location', {
      lat: position.coords.latitude,
      lon: position.coords.longitude,
      found: true
    });
  },
  function(error) {
    Shiny.setInputValue('user_location', {
      found: false
    });
  }
);*/

navigator.geolocation.getCurrentPosition(
  function(position) {
    // Wait for Shiny to be connected before setting input value
    $(document).on('shiny:connected', function() {
      Shiny.setInputValue('user_location', {
        lat: position.coords.latitude,
        lon: position.coords.longitude,
        found: true
      });
    });
  },
  function(error) {
    // Wait for Shiny to be connected before setting input value
    $(document).on('shiny:connected', function() {
      Shiny.setInputValue('user_location', {
        found: false
      });
    });
  }
);
