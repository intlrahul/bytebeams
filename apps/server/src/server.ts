import { createApp } from './app.js';
import { readServerConfig } from './config.js';

const config = readServerConfig(process.env);
const app = createApp();

app.listen(config.port, () => {
  process.stdout.write(`ByteBeams demo server listening on port ${String(config.port)}\n`);
});
