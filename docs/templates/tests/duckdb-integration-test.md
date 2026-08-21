# DuckDB Integration-Test Template

Use a unique temporary database for each test and a real DuckDB adapter.

```dart
void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('example_db_');
    database = await AppDatabase.open(
      path: p.join(temporaryDirectory.path, 'test.duckdb'),
    );
    await database.migrate();
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'given_duplicate_packet_when_ingested_twice_then_only_one_event_exists',
    () async {
      // Given
      final packet = packetFixture(id: 'packet-001');

      // When
      await database.ingest(packet);
      await database.ingest(packet);

      // Then
      expect(await database.countPackets(id: packet.id), 1);
    },
  );
}
```

The cleanup calls are illustrative; use the approved platform-safe temporary-file helper.

## Required patterns

- Close/reopen before durability assertions.
- Test clean migrations and upgrades from supported prior schemas.
- Run packet-order permutations against fresh databases and compare the same final projection.
- Verify transaction rollback, cursor atomicity, replay deletion/upsert, SQL counts, and retention boundaries.
- Never share a database between tests or depend on execution order.
