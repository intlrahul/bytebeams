# Page, View, and Widget Template

## Responsibilities

- `ExamplePage`: route-level composition and BLoC provision.
- `ExampleView`: renders and reacts to the owning BLoC.
- Focused widgets: reusable or independently testable UI pieces.

```dart
final class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createExampleBloc()
        ..add(const ExampleEvent.loadRequested()),
      child: const ExampleView(),
    );
  }
}

final class ExampleView extends StatelessWidget {
  const ExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExampleBloc, ExampleState>(
      listenWhen: shouldHandleEffect,
      listener: handleEffect,
      child: BlocBuilder<ExampleBloc, ExampleState>(
        builder: (context, state) => state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const ExampleLoadingView(),
          success: (data) => ExampleContent(data: data),
          failure: (failure) => ExampleFailureView(failure: failure),
        ),
      ),
    );
  }
}
```

`createExampleBloc` represents composition-root wiring, not a required global function.

## Rules

- Widgets never query repositories or databases directly.
- Do not perform navigation, analytics, or other side effects from `build`.
- Model loading, empty, syncing, stale/degraded, success, and failure states explicitly when relevant.
- Add semantic labels, adequate touch targets, and deterministic keys only where tests or accessibility need them.
- Avoid rebuilding unrelated subtrees; optimize only after measurement.
