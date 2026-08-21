import { describe, expect, it } from 'vitest';

import { readServerConfig } from '../src/config.js';

describe('readServerConfig', () => {
  it('given_no_port_when_config_read_then_uses_deterministic_default', () => {
    // Given
    const environment = {};

    // When
    const config = readServerConfig(environment);

    // Then
    expect(config).toEqual({ port: 3000 });
  });

  it('given_invalid_port_when_config_read_then_throws_validation_error', () => {
    // Given
    const environment = { PORT: 'invalid' };

    // When / Then
    expect(() => readServerConfig(environment)).toThrow();
  });
});
