# Unit-Test Template

Use names in the form `given_<condition>_when_<action>_then_<result>`.

```dart
void main() {
  group('CalculateExampleStatus', () {
    test(
      'given_fresh_positive_speed_when_calculated_then_returns_moving',
      () {
        // Given
        final clock = FakeClock(DateTime.utc(2026, 1, 1, 12));
        final subject = CalculateExampleStatus(clock: clock);
        final input = exampleReading(speed: 10, ignition: true);

        // When
        final result = subject(input);

        // Then
        expect(result, ExampleStatus.moving);
      },
    );
  });
}
```

## Rules

- One behavior per test; table-driven cases are encouraged for boundaries.
- Use fixed UTC timestamps, deterministic IDs, and explicit units.
- Inject clocks, IDs, random sources, and schedulers.
- Do not use current time, real network/storage, random fixture values, or cross-test state.
- Include exact threshold equality, just-below, and just-above cases.
