// License: LGPL-3.0-or-later
var _paq = _paq || [];
/* tracker methods like "setCustomDimension" should be called before "trackPageView" */
_paq.push(['trackPageView']);
_paq.push(['enableLinkTracking']);
var tracker=null;
(function() {
var u="//s.wemove.eu/";
_paq.push(['setTrackerUrl', u+'piwik.php']);
_paq.push(['setSiteId', '5']);
var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
g.onload = function() {
  tracker=Piwik.getTracker("https://s.wemove.eu/piwik.php",5);
  tracker.trackContentImpressionsWithinNode(document.getElementsByClassName("amount-step")[0]);
//trakcer.trackContentInteractionNode', document.getElementsByClassName("amount-step")[0], 'amount-step']);
  tracker.trackContentImpressionsWithinNode(document.getElementsByClassName("info-step")[0]);
  tracker.trackContentImpressionsWithinNode(document.getElementsByClassName("payment-step")[0]);

  tracker.trackContentImpressionsWithinNode(document.getElementsByClassName("ff-wizard-followup")[0])
};
g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
//_paq.push(["setHeartBeatTimer",30]);
})();
