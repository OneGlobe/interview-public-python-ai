import client from '@kubb/plugin-client/clients/axios';
import type {
  RequestConfig as KubbRequestConfig,
  ResponseConfig as KubbResponseConfig,
  ResponseErrorConfig as KubbResponseErrorConfig,
} from '@kubb/plugin-client/clients/axios';

// Set the base URL for all requests
// Only set baseURL if explicitly provided, otherwise use relative URLs
const apiUrl = import.meta.env.VITE_API_URL;
if (apiUrl && apiUrl !== '') {
  client.setConfig({
    baseURL: apiUrl,
  });
} else {
  // Use relative URLs for production (proxied through nginx)
  client.setConfig({
    baseURL: window.location.origin,
  });
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type RequestConfig<TData = any> = KubbRequestConfig<TData>;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type ResponseConfig<TData = any> = KubbResponseConfig<TData>;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type ResponseErrorConfig<TData = any> = KubbResponseErrorConfig<TData>;

export default client;
