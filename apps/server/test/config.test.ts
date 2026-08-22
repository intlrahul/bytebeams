import { describe, expect, it } from 'vitest';

import { readServerConfig } from '../src/config.js';

describe('readServerConfig', () => {
  it('given_no_port_when_config_read_then_uses_deterministic_default', () => {
    // Given
    const environment = {};

    // When
    const config = readServerConfig(environment);

    // Then
    expect(config.port).toBe(3000);
  });

  it('given_invalid_port_when_config_read_then_throws_validation_error', () => {
    // Given
    const environment = { PORT: 'invalid' };

    // When / Then
    expect(() => readServerConfig(environment)).toThrow();
  });

  it('given_no_demo_controls_when_config_read_then_uses_approved_defaults', () => {
    expect(readServerConfig({})).toMatchObject({
      databasePath: '.data/bytebeams-demo.sqlite',
      demoClockMode: 'scripted',
      demoSeed: 'bytebeams-demo-v1',
      simulationIntervalMs: 1000,
    });
  });

  it('given_non_scripted_clock_when_config_read_then_rejects_it', () => {
    expect(() => readServerConfig({ DEMO_CLOCK_MODE: 'wall' })).toThrow();
  });
});
