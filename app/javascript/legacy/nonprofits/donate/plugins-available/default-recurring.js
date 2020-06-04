// License: LGPL-3.0-or-later
// This plugin allows to simplify the form (remove phone, address and city fields) if the url query has "minimal"
jQuery(function($){
  $(".donationWizard").on("render:post", function(){
    if (app.params$().default !== "recurring") return;
    $("#checkbox-recurring").prop("checked",true);
    document.getElementById("checkbox-recurring").dispatchEvent(new Event('change'));
  });
})
