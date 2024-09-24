function callWorker(workerPath, data) {
  const worker = new Worker(workerPath);
  return new Promise((resolve, reject) => {
    worker.postMessage(data);
    worker.onmessage = event => {
      if (event.data.err) {
        reject(event.data.err);
      } else {
        resolve(event.data);
      }
      worker.terminate();
    };
  });
};

function encrypt(data, key, iv) {
  return callWorker('scripts/crypto_worker.js', { action: 'encrypt', data, key, iv });
};

function decrypt(data, key, iv) {
  return callWorker('scripts/crypto_worker.js', { action: 'decrypt', data, key, iv });
};

function resizeImage(imageBase64, contentType) {
  if (typeof OffscreenCanvas === "undefined") {
    return resizeImageFallback(imageBase64, contentType);
  }
  return callWorker(
    'scripts/image_processor_worker.js',
    { action: 'resize', imageBase64, contentType },
  );
}