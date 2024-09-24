function blobToBase64(blob) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onerror = reject;
    reader.onload = () => {
      resolve(reader.result);
    };
    reader.readAsDataURL(blob);
  });
}

async function resizeImage(imageBase64, contentType) {
  const base64Response = await fetch(`data:${contentType};base64,${imageBase64}`);
  const blob = await base64Response.blob();
  const oBitmap = await createImageBitmap(blob);
  const oWidth = oBitmap.width;
  const oHeight = oBitmap.height;
  const resizeRatio = 1000 / oWidth;
  const resizeWidth = parseInt(oWidth * resizeRatio);
  if (resizeWidth >= oWidth) {
    return imageBase64;
  }
  const resizeHeight = parseInt(oHeight * resizeRatio);
  const bitmap = await createImageBitmap(blob, { resizeWidth, resizeHeight, resizeQuality: 'pixelated' });
  const canvas = new OffscreenCanvas(resizeWidth, resizeHeight);
  const ctx = canvas.getContext('2d');
  ctx.drawImage(bitmap, 0, 0);
  const resizedBlob = await canvas.convertToBlob({ type: contentType, quality: 0.2 });
  const resizedBase64 = await blobToBase64(resizedBlob);
  return resizedBase64.split(',')[1];
}

onmessage = async (event) => {
  const { action, imageBase64, contentType } = event.data;
  try {
    if (action == 'resize') {
      postMessage(await resizeImage(imageBase64, contentType));
    }
  } catch (err) {
    postMessage({ err: err.message });
  }
};