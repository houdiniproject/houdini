// License: LGPL-3.0-or-later
jQuery(function($){
$(".donationWizard").on("render:post", function(){
  var cb=document.getElementsByName("anonymous")[0];
  cb || console.log("ERROR: the checkbox anonymous ain't no more");
  cb.checked = true;
  cb.parentNode.style.display="none";

});

});
