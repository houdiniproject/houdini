// License: LGPL-3.0-or-later
(function () {

var container = document.querySelector('.js-donateForm');

container.addEventListener('render:pre', function (e) {
  console.log(e);
  // e.target matches elem
}, false);

container.addEventListener('render:post', function (e) {
  console.log(e);
  // e.target matches elem
}, false);

})();
