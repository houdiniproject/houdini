jQuery(function($){
  $("input[name='bic']").closest("fieldset").hide();
  $("input[name='iban']").closest("fieldset").removeClass("col-8").addClass("col-12");
});
