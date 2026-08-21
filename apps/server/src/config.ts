import { z } from 'zod';

const environmentSchema = z.object({
  PORT: z.coerce.number().int().min(1).max(65_535).default(3000),
});

export type ServerConfig = Readonly<{ port: number }>;

export function readServerConfig(environment: NodeJS.ProcessEnv): ServerConfig {
  const parsed = environmentSchema.parse(environment);
  return { port: parsed.PORT };
}
