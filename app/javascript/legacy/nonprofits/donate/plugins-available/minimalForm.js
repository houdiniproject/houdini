// License: LGPL-3.0-or-later
// This plugin allows to simplify the form (remove phone, address and city fields) if the url query has "minimal"
jQuery(function($){
$(".donationWizard").on("render:post", function(){

  if (!app.params$().minimal) return;
  document.getElementsByName("phone")[0].style.display="none";
  document.getElementsByName("city")[0].style.display="none";
  document.getElementsByName("address")[0].style.display="none";

  document.getElementsByName("first_name")[0].parentNode.classList.add('col-right-6');
  document.getElementsByName("first_name")[0].parentNode.classList.remove('col-right-4');
  document.getElementsByName("last_name")[0].parentNode.classList.add('col-right-6');
  document.getElementsByName("last_name")[0].parentNode.classList.remove('col-right-4');

  document.getElementsByName("country")[0].parentNode.classList.add('col-right-8');
  document.getElementsByName("country")[0].parentNode.classList.remove('col-right-4');

});
});
