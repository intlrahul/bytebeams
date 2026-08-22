import 'dart:convert';

final class SseFrame {
  const SseFrame({this.id, this.event, required this.data});

  final String? id;
  final String? event;
  final String data;
}

/// Minimal deterministic SSE framing parser. It accepts CRLF/LF, joins repeated
/// data fields per the SSE specification, and ignores comments.
final class SseFrameParser {
  const SseFrameParser();

  Stream<SseFrame> parse(Stream<List<int>> bytes) async* {
    var buffer = '';
    await for (final chunk in bytes.cast<List<int>>().transform(utf8.decoder)) {
      buffer += chunk.replaceAll('\r\n', '\n');
      while (true) {
        final boundary = buffer.indexOf('\n\n');
        if (boundary < 0) {
          break;
        }
        final rawFrame = buffer.substring(0, boundary);
        buffer = buffer.substring(boundary + 2);
        final frame = _frame(rawFrame);
        if (frame != null) {
          yield frame;
        }
      }
    }
    final frame = _frame(buffer);
    if (frame != null) {
      yield frame;
    }
  }

  SseFrame? _frame(String rawFrame) {
    String? id;
    String? event;
    final data = <String>[];
    for (final line in const LineSplitter().convert(rawFrame)) {
      if (line.isEmpty || line.startsWith(':')) {
        continue;
      }
      final separator = line.indexOf(':');
      final field = separator < 0 ? line : line.substring(0, separator);
      final value = separator < 0
          ? ''
          : line.substring(separator + 1).replaceFirst(' ', '');
      switch (field) {
        case 'id':
          id = value;
        case 'event':
          event = value;
        case 'data':
          data.add(value);
      }
    }
    return data.isEmpty
        ? null
        : SseFrame(id: id, event: event, data: data.join('\n'));
  }
}
