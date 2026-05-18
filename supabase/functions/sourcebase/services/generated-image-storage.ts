import { getGcsConfig } from "../config.ts";
import { SafeError } from "../types.ts";

export interface StoredGeneratedImage {
  bucket: string;
  objectName: string;
  storageUrl: string;
}

export async function storeGeneratedImageFromDataUrl(input: {
  userId: string;
  jobId: string;
  dataUrl?: string;
}): Promise<StoredGeneratedImage | undefined> {
  const parsed = parseDataUrl(input.dataUrl);
  if (!parsed) return undefined;

  const gcs = getGcsConfig();
  const extension = parsed.mimeType === "image/jpeg" ? "jpg" : "png";
  const objectName =
    `user/${input.userId}/generated/infographics/${input.jobId}.${extension}`;
  const uploadUrl = await createGcsV4SignedPutUrl({
    bucket: gcs.bucket,
    objectName,
    serviceAccountJson: gcs.serviceAccountJson,
    expiresInSeconds: 300,
  });

  const response = await fetch(uploadUrl, {
    method: "PUT",
    headers: { "content-type": parsed.mimeType },
    body: parsed.bytes,
  });
  if (!response.ok) {
    throw new SafeError(
      "IMAGE_STORAGE_FAILED",
      "İnfografik görseli depolanamadı.",
      500,
    );
  }

  return {
    bucket: gcs.bucket,
    objectName,
    storageUrl: `gs://${gcs.bucket}/${objectName}`,
  };
}

function parseDataUrl(dataUrl: string | undefined) {
  const text = dataUrl?.trim() ?? "";
  const match = /^data:(image\/[a-z0-9.+-]+);base64,(.+)$/i.exec(text);
  if (!match) return undefined;
  try {
    const binary = atob(match[2]);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return { mimeType: match[1].toLowerCase(), bytes };
  } catch (_error) {
    throw new SafeError(
      "IMAGE_STORAGE_INVALID_DATA",
      "İnfografik görsel verisi işlenemedi.",
      500,
    );
  }
}

async function createGcsV4SignedPutUrl(input: {
  bucket: string;
  objectName: string;
  serviceAccountJson: string;
  expiresInSeconds: number;
}) {
  const serviceAccount = JSON.parse(input.serviceAccountJson);
  const clientEmail = String(serviceAccount.client_email ?? "");
  const privateKey = String(serviceAccount.private_key ?? "").replaceAll(
    "\\n",
    "\n",
  );
  if (!clientEmail || !privateKey) {
    throw new SafeError(
      "GCS_SERVICE_ACCOUNT_INVALID",
      "GCS service JSON geçersiz.",
      500,
    );
  }

  const now = new Date();
  const date = formatDate(now);
  const timestamp = `${date}T${formatTime(now)}Z`;
  const scope = `${date}/auto/storage/goog4_request`;
  const credential = `${clientEmail}/${scope}`;
  const canonicalUri = `/${encodePath(input.bucket)}/${
    encodePath(input.objectName)
  }`;
  const query: Record<string, string> = {
    "X-Goog-Algorithm": "GOOG4-RSA-SHA256",
    "X-Goog-Credential": credential,
    "X-Goog-Date": timestamp,
    "X-Goog-Expires": String(input.expiresInSeconds),
    "X-Goog-SignedHeaders": "host",
  };
  const canonicalQuery = canonicalQueryString(query);
  const canonicalRequest = [
    "PUT",
    canonicalUri,
    canonicalQuery,
    "host:storage.googleapis.com\n",
    "host",
    "UNSIGNED-PAYLOAD",
  ].join("\n");
  const stringToSign = [
    "GOOG4-RSA-SHA256",
    timestamp,
    scope,
    await sha256Hex(canonicalRequest),
  ].join("\n");
  const signature = await rsaSha256(privateKey, stringToSign);
  return `https://storage.googleapis.com${canonicalUri}?${canonicalQuery}&X-Goog-Signature=${signature}`;
}

function formatDate(date: Date) {
  return date.toISOString().slice(0, 10).replaceAll("-", "");
}

function formatTime(date: Date) {
  return date.toISOString().slice(11, 19).replaceAll(":", "");
}

function encodePath(path: string) {
  return path.split("/").map(rfc3986Encode).join("/");
}

function canonicalQueryString(query: Record<string, string>) {
  return Object.entries(query)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${rfc3986Encode(key)}=${rfc3986Encode(value)}`)
    .join("&");
}

function rfc3986Encode(value: string) {
  return encodeURIComponent(value).replace(
    /[!'()*]/g,
    (char) => `%${char.charCodeAt(0).toString(16).toUpperCase()}`,
  );
}

async function sha256Hex(text: string) {
  const hash = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(text),
  );
  return [...new Uint8Array(hash)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function rsaSha256(privateKeyPem: string, text: string) {
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(privateKeyPem),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(text),
  );
  return [...new Uint8Array(signature)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function pemToArrayBuffer(pem: string) {
  const clean = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const binary = atob(clean);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}
