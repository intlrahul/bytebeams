import 'dart:convert';

import 'package:bytebeams/features/sync/data/sse_frame_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = SseFrameParser();

  test(
    'given_fragmented_sse_delivery_when_parsed_then_emits_one_frame',
    () async {
      final frames = await parser
          .parse(
            Stream.fromIterable([
              utf8.encode('id: 7\ndata: {"deliveryId"'),
              utf8.encode(':"7"}\n\n'),
            ]),
          )
          .toList();

      expect(frames, hasLength(1));
      expect(frames.single.id, '7');
      expect(frames.single.data, '{"deliveryId":"7"}');
    },
  );

  test(
    'given_comment_and_repeated_data_when_parsed_then_joins_data_lines',
    () async {
      final frames = await parser
          .parse(
            Stream.value(
              utf8.encode(
                ': heartbeat\nevent: telemetry\ndata: one\ndata: two\n\n',
              ),
            ),
          )
          .toList();

      expect(frames.single.event, 'telemetry');
      expect(frames.single.data, 'one\ntwo');
    },
  );
}
