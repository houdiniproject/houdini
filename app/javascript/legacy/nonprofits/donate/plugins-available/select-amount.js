// License: LGPL-3.0-or-later
// This plugin allows to automatically chose an amount if the url query has "amount"=xz
jQuery(function($){
$(".donationWizard").on("render:post", function(){

  if (!app.params$().amount) return;
  var amount= parseInt(app.params$().amount,10);
  if (!amount > 0) return;
  // TODO: check if the pre-selected amount is one of the buttons, instead of only putting it in "other"
  $(".amount.other").val(amount).addClass("is-selected");
  $('.amount-step button.button').removeClass("is-selected");
  document.getElementsByName("amount")[0].dispatchEvent(new Event('change'));
  $(".btn-next").click();
});
});
