# Flutter Integration-Test Template

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'given_bootstrapped_fleet_when_alert_is_dismissed_and_undone_then_state_persists',
    (tester) async {
      // Given
      final harness = await IntegrationHarness.create(
        clock: FakeClock(DateTime.utc(2026, 1, 1, 12)),
        scenario: const DemoScenario.alertingVehicle(),
      );
      addTearDown(harness.dispose);

      // When
      await tester.pumpWidget(harness.app);
      await harness.waitForBootstrap(tester);
      await tester.tap(find.byKey(const Key('vehicle-alert')));
      await tester.tap(find.text('I am on it'));
      await tester.tap(find.text('UNDO'));

      // Then
      await harness.waitForCondition(tester, harness.alertIsActive);
      expect(await harness.persistedAlertIsActive(), isTrue);
    },
  );
}
```

## Rules

- Use deterministic server scenarios, clock, IDs, and isolated databases.
- Wait for observable conditions, not arbitrary sleeps.
- Exercise real application boundaries appropriate to the scenario.
- Capture useful diagnostics/screenshots on failure without sensitive data.
- Keep the suite small: critical interview flows and event-time correction behavior.
