async function resizeImageFallback(imageBase64, contentType) {
  const base64Response = await fetch(`data:${contentType};base64,${imageBase64}`);
  const blob = await base64Response.blob();
  const imgData = await blobToImg(blob);
  const oWidth = imgData.width;
  const oHeight = imgData.height;
  const resizeRatio = 1000 / oWidth;
  const resizeWidth = parseInt(oWidth * resizeRatio);
  if (resizeWidth >= oWidth) {
    return imageBase64;
  }
  const resizeHeight = parseInt(oHeight * resizeRatio);
  const bitmap = await createImageBitmap(imgData, { resizeWidth, resizeHeight, resizeQuality: 'pixelated' });
  const canvas = document.createElement("canvas");
  canvas.width = resizeWidth;
  canvas.height = resizeHeight;
  const ctx = canvas.getContext('bitmaprenderer');
  ctx.transferFromImageBitmap(bitmap);
  const resizedBase64 = canvas.toDataURL(contentType, 0.2);
  return resizedBase64.split(',')[1];
}

async function blobToImg(file) {
  const url = URL.createObjectURL(file);
  const img = new Image();
  img.decoding = "async";
  img.src = url;
  const loaded = new Promise((resolve, reject) => {
    img.onload = () => resolve();
    img.onerror = () => reject(Error("Image loading error"));
  });
  if (img.decode) {
    await img.decode().catch(() => null);
  }
  await loaded;
  return img;
}