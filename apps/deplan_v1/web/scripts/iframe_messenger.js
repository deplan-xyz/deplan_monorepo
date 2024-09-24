function postWebMessage(selector, data, targetOrigin) {
  document.querySelector(selector).contentWindow.postMessage(data, targetOrigin);
}
