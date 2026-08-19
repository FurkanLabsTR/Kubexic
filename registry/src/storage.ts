import { sha256 } from './crypto';

export interface PackageFile {
  key: string;
  body: ReadableStream;
  checksum: string;
}

export async function uploadPackage(
  bucket: R2Bucket,
  packageName: string,
  version: string,
  data: ArrayBuffer
): Promise<{ checksum: string; key: string }> {
  const key = `packages/${packageName}/${version}/${packageName}-${version}.kxpkg`;
  const checksum = await sha256(data);

  await bucket.put(key, data, {
    httpMetadata: {
      contentType: 'application/octet-stream',
      contentDisposition: `attachment; filename="${packageName}-${version}.kxpkg"`,
    },
    customMetadata: { checksum },
  });

  return { checksum, key };
}

export async function downloadPackage(
  bucket: R2Bucket,
  packageName: string,
  version: string,
  expectedChecksum?: string
): Promise<{ data: ArrayBuffer; checksum: string } | { error: string }> {
  const key = `packages/${packageName}/${version}/${packageName}-${version}.kxpkg`;
  const object = await bucket.get(key);

  if (!object) return { error: 'Package file not found in storage' };

  const data = await object.arrayBuffer();
  const checksum = (object.customMetadata?.checksum as string) || (await sha256(data));

  if (expectedChecksum && checksum !== expectedChecksum) {
    return { error: 'Checksum mismatch: package file has been tampered with' };
  }

  return { data, checksum };
}

export function generateDownloadUrl(
  packageName: string,
  version: string
): string {
  return `/v1/packages/${packageName}/${version}/download`;
}
