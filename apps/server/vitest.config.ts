import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      exclude: ['src/generated/**', 'src/server.ts'],
      provider: 'v8',
      reporter: ['text', 'json-summary', 'lcov'],
      thresholds: { lines: 90 },
    },
    environment: 'node',
    restoreMocks: true,
  },
});
