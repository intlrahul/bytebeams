# Widget-Test Template

```dart
void main() {
  testWidgets(
    'given_empty_success_state_when_rendered_then_shows_empty_message',
    (tester) async {
      // Given
      final bloc = FakeExampleBloc(
        initialState: const ExampleState.success(ExampleViewData.empty()),
      );

      // When
      await tester.pumpWidget(testApp(bloc: bloc, child: const ExampleView()));
      await tester.pump();

      // Then
      expect(find.byKey(const Key('example-empty-state')), findsOneWidget);
      expect(find.text('No results'), findsOneWidget);
    },
  );
}
```

## Rules

- Provide fixed screen size, locale, theme, clock, and BLoC state where relevant.
- Assert user-visible behavior and semantics, not private widget structure.
- Cover loading, empty, success, stale/degraded, failure, and interaction states that apply.
- Verify BLoC events from user actions and navigation effects separately.
- No golden tests unless scope changes explicitly.
