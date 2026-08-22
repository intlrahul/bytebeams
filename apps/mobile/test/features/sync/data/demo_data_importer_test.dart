import 'dart:convert';
import 'package:bytebeams/features/sync/data/demo_data_importer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_valid_packaged_bootstrap_when_loaded_then_maps_deterministic_demo_data', () async {
    final importer = AssetDemoDataImporter(assetBundle: _Bundle(_bootstrap));

    final data = await importer.load();

    expect(data.deliveryCursor, 'demo-1');
    expect(data.vehicles.single.vehicleId, 'demo:vehicle-001');
    expect(data.telemetry.single.packetId, 'demo:packet-001');
  });

  test('given_malformed_packaged_bootstrap_when_loaded_then_preserves_decode_failure', () async {
    final importer = AssetDemoDataImporter(assetBundle: _Bundle('{'));

    await expectLater(importer.load(), throwsFormatException);
  });
}

final class _Bundle extends CachingAssetBundle {
  _Bundle(this.contents);

  final String contents;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(contents)));
}

const _bootstrap = '''
{
  "vehicles": [{"vehicleId": "demo:vehicle-001", "registrationNumber": "DEMO-001", "model": "E-Truck"}],
  "telemetry": [{"packetId": "demo:packet-001", "vehicleId": "demo:vehicle-001", "eventTimestamp": "2026-08-21T00:00:00.000Z", "signalName": "soc", "value": {"kind": "number", "numberValue": 75}}],
  "deliveryCursor": "demo-1"
}
''';
