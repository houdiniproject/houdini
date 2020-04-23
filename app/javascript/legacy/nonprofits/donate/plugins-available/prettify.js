// License: LGPL-3.0-or-later
jQuery(function($){
  $(".closeButton").hide();
  if (app.currency_symbol != "€") $("button.sepa").hide();
  $("button.sepa").prepend('<span class="badge">S€PA</span>&nbsp;').addClass("u-marginRight--10");
  $("button.credit_card").prepend('<i class="icon-credit-card"></i>&nbsp;');

  $(".ff-wizard-followup a, .ff-wizard-followup button").hide(); // buttons FB and twitter bogus, finish too
});
