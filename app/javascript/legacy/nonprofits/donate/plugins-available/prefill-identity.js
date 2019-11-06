// License: LGPL-3.0-or-later
// This plugin allows to automatically fill the form (name, address..) based on the url params

jQuery(function($){
$(".donationWizard").on("render:post", function(){
  ["email","first_name","last_name","city","zip_code","country"].forEach(function(k){
    var v=app.params$()[k];
    if (!v) return;
    document.getElementsByName(k)[0].value=v;
  });

  var name ="";
  if (app.params$().first_name)
    name = app.params$().first_name + " ";
  if (app.params$().last_name)
   name += app.params$().last_name;
  if (name.length > 1) {
    document.getElementsByName("name").forEach(function(d){
      d.value=name;
    });
  }
});
});
