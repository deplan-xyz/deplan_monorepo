function binaryToArrayBuffer(binary) {
  const binaryString = binary;
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
};

function base64ToArrayBuffer(base64) {
  const binaryString = atob(base64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
};

function arrayBufferToBinary(buffer) {
  let binary = '';
  const bytes = new Uint8Array(buffer);
  const len = bytes.byteLength;
  for (let i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return binary;
}

async function importSecretKey(rawKey) {
  const key = await crypto.subtle.importKey(
    'raw',
    rawKey,
    { name: "AES-CTR" },
    false,
    ['encrypt', 'decrypt'],
  );
  return key;
}

async function encrypt(data, key, iv) {
  const dataBuffer = binaryToArrayBuffer(data);
  const ivBuffer = base64ToArrayBuffer(iv);
  const keyBuffer = await importSecretKey(base64ToArrayBuffer(key));
  const pkcs7Padding = 16 - (dataBuffer.byteLength % 16);
  const paddedData = new Uint8Array(dataBuffer.byteLength + pkcs7Padding);

  paddedData.set(new Uint8Array(dataBuffer));
  for (let i = dataBuffer.byteLength; i < paddedData.byteLength; i++) {
    paddedData[i] = pkcs7Padding;
  }
  const encrypted = await crypto.subtle.encrypt(
    { name: "AES-CTR", counter: ivBuffer, length: 64 },
    keyBuffer,
    paddedData,
  );
  const result = new Uint8Array(ivBuffer.byteLength + encrypted.byteLength);
  result.set(new Uint8Array(ivBuffer), 0);
  result.set(new Uint8Array(encrypted), ivBuffer.byteLength);
  return arrayBufferToBinary(result.buffer);
};

async function decrypt(data, key, iv) {
  const dataBuffer = binaryToArrayBuffer(data);
  const ivBuffer = base64ToArrayBuffer(iv);
  const keyBuffer = await importSecretKey(base64ToArrayBuffer(key));
  const decrypted = await crypto.subtle.decrypt(
    { name: "AES-CTR", counter: ivBuffer, length: 64 },
    keyBuffer,
    dataBuffer,
  );
  const tmp = new Uint8Array(decrypted);
  const paddingLength = tmp[tmp.length - 1];
  const unpaddedData = tmp.slice(0, tmp.length - paddingLength);
  return arrayBufferToBinary(unpaddedData.buffer);
};

onmessage = async (event) => {
  const { action, data, key, iv } = event.data;
  try {
    if (action == 'encrypt') {
      postMessage(await encrypt(data, key, iv));
    } else if (action == 'decrypt') {
      postMessage(await decrypt(data, key, iv));
    }
  } catch (err) {
    postMessage({ err: err.message });
  }
};