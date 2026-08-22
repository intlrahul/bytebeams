import { z } from 'zod';

const environmentSchema = z.object({
  DATABASE_PATH: z.string().min(1).default('.data/bytebeams-demo.sqlite'),
  DEMO_CLOCK_MODE: z.literal('scripted').default('scripted'),
  DEMO_SEED: z.string().min(1).default('bytebeams-demo-v1'),
  DEMO_START_AT: z.iso.datetime().default('2026-08-21T00:00:00Z'),
  PORT: z.coerce.number().int().min(1).max(65_535).default(3000),
  SIMULATION_INTERVAL_MS: z.coerce.number().int().min(1).default(1000),
});

export type ServerConfig = Readonly<{
  databasePath: string;
  demoClockMode: 'scripted';
  demoSeed: string;
  demoStartAtUtc: Date;
  port: number;
  simulationIntervalMs: number;
}>;

export function readServerConfig(environment: NodeJS.ProcessEnv): ServerConfig {
  const parsed = environmentSchema.parse(environment);
  return {
    databasePath: parsed.DATABASE_PATH,
    demoClockMode: parsed.DEMO_CLOCK_MODE,
    demoSeed: parsed.DEMO_SEED,
    demoStartAtUtc: new Date(parsed.DEMO_START_AT),
    port: parsed.PORT,
    simulationIntervalMs: parsed.SIMULATION_INTERVAL_MS,
  };
}
