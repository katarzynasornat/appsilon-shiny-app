document.addEventListener('DOMContentLoaded', function() {
    var infoBtn = document.getElementById('info_btn');
    if (infoBtn) {
      infoBtn.addEventListener('click', function() {
        Shiny.setInputValue('info_btn', Math.random());
      });
    }
  });

  
  
/*document.addEventListener('shiny:connected', function() {
  // Use a CSS selector instead of hardcoded ID, looking for buttons with id ending in "info_btn"
  const infoBtns = document.querySelectorAll('[id$="-info_btn"]');
  
  infoBtns.forEach(btn => {
    btn.addEventListener('click', function() {
      Shiny.setInputValue(btn.id, Math.random());
    });
  });
});*/
