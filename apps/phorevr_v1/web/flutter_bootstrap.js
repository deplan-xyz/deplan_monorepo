{{flutter_js}}
{{flutter_build_config}}

(() => {
  const loaderDiv = document.createElement('div');
  loaderDiv.style = 'position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-color: #fff; display: flex; justify-content: center; align-items: center; flex-direction: column;';
  loaderDiv.innerHTML = '<img alt="loader" src="assets/circular_progress_indicator_square_large.gif" style="width: 50px; filter: brightness(0.5);" />';
  document.body.appendChild(loaderDiv);

  _flutter.loader.load({
    onEntrypointLoaded: function (engineInitializer) {
      engineInitializer.initializeEngine().then(function (appRunner) {
        appRunner.runApp();
        loaderDiv.remove();
      });
    }
  });
})();