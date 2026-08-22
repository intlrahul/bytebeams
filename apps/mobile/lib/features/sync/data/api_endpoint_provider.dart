abstract interface class ApiEndpointProvider {
  Uri baseUri();
}

final class DefaultApiEndpointProvider implements ApiEndpointProvider {
  const DefaultApiEndpointProvider({required this.isAndroidEmulator});

  final bool isAndroidEmulator;

  @override
  Uri baseUri() => Uri.parse(
    isAndroidEmulator ? 'http://10.0.2.2:3000' : 'http://localhost:3000',
  );
}
