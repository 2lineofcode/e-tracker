import 'dart:math' as math;

import 'package:fleather/fleather.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:uuid/v4.dart';

class NotesMarkdownClipboardManager extends ClipboardManager {
  NotesMarkdownClipboardManager(this.controller);

  final FleatherController controller;
  static const _plainText = PlainTextClipboardManager();

  @override
  Future<void> setData(FleatherClipboardData data) {
    return _plainText.setData(data);
  }

  @override
  Future<FleatherClipboardData?> getData() async {
    final data = await _plainText.getData();
    final text = data?.plainText;
    if (text == null) return data;

    final selection = controller.selection;
    final document = controller.document.toPlainText();
    final start = math.min(selection.start, selection.end);
    final end = math.max(selection.start, selection.end);
    final delta = markdownToParchmentDelta(
      text,
      atLineStart: start <= 0 || document[start - 1] == '\n',
      replaceTrailingBreak: end < document.length && document[end] == '\n',
    );
    return delta == null
        ? data
        : FleatherClipboardData(plainText: text, delta: delta);
  }
}

Delta? markdownToParchmentDelta(
  String source, {
  bool atLineStart = true,
  bool replaceTrailingBreak = false,
}) {
  if (!_looksLikeMarkdown(source)) return null;

  final document = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
  );
  final nodes = document.parseLines(
    source.replaceAll('\r\n', '\n').split('\n'),
  );
  final isBlock = nodes.length > 1 ||
      nodes.any((node) => node is md.Element && node.tag != 'p');
  final renderer = _MarkdownDeltaRenderer();

  if (!isBlock && nodes.singleOrNull is md.Element) {
    renderer.renderInline((nodes.single as md.Element).children ?? []);
  } else {
    if (!atLineStart) renderer.delta.insert('\n');
    renderer.renderBlocks(nodes);
    if (replaceTrailingBreak && renderer.endsWithNewline) {
      renderer.delta.delete(1);
    }
  }
  return renderer.delta;
}

bool _looksLikeMarkdown(String text) {
  if (RegExp(
    r'^\s{0,3}(#{1,6}\s+|>\s?|[-+*]\s+|\d+[.)]\s+|```|~~~)',
    multiLine: true,
  ).hasMatch(text)) {
    return true;
  }
  if (RegExp(
    r'^\s*\|?.+\|.+\r?\n\s*\|?\s*:?-{3,}',
    multiLine: true,
  ).hasMatch(text)) {
    return true;
  }
  return RegExp(
    r'(\*\*[^\s*\n](?:[^*\n]*[^\s*\n])?\*\*|__[^\s_\n](?:[^_\n]*[^\s_\n])?__|~~[^\s~\n](?:[^~\n]*[^\s~\n])?~~|`[^`\n]+`|!?\[[^\]]+\]\([^)]+\)|\*[^\s*\n][^*\n]*\*|_[^\s_\n][^_\n]*_)',
  ).hasMatch(text);
}

class _MarkdownDeltaRenderer {
  final delta = Delta();

  bool get endsWithNewline {
    if (delta.isEmpty) return false;
    final data = delta.last.data;
    return data is String && data.endsWith('\n');
  }

  void renderBlocks(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is md.Text) {
        _insert(node.text);
        continue;
      }
      if (node is! md.Element) continue;

      switch (node.tag) {
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          renderInline(node.children ?? []);
          _line({'heading': int.parse(node.tag.substring(1))});
        case 'ul':
        case 'ol':
          _renderList(node);
        case 'blockquote':
          _renderQuote(node);
        case 'pre':
          _renderCodeBlock(node.textContent);
        case 'table':
          _renderTable(node);
        case 'hr':
          delta.insert(BlockEmbed.horizontalRule.toJson());
          _line();
        default:
          renderInline(node.children ?? []);
          _line();
      }
    }
  }

  void renderInline(
    List<md.Node> nodes, [
    Map<String, dynamic> attributes = const {},
  ]) {
    for (final node in nodes) {
      if (node is md.Text) {
        _insert(node.text, attributes);
        continue;
      }
      if (node is! md.Element) continue;

      final next = Map<String, dynamic>.from(attributes);
      switch (node.tag) {
        case 'strong':
          next['b'] = true;
        case 'em':
          next['i'] = true;
        case 'del':
          next['s'] = true;
        case 'code':
          next['c'] = true;
        case 'a':
          next['a'] = node.attributes['href'];
        case 'img':
          _insert(node.attributes['src'] ?? node.textContent, attributes);
          continue;
        case 'br':
          _insert('\n');
          continue;
        case 'input':
          continue;
      }
      renderInline(node.children ?? [], next);
    }
  }

  void _renderList(md.Element list, [int indent = 0]) {
    final items = list.children ?? const <md.Node>[];
    for (final item in items.whereType<md.Element>()) {
      if (item.tag != 'li') continue;
      final checkbox = _checkbox(item);
      final children = item.children ?? [];
      renderInline(
        children.where((node) {
          return node is! md.Element ||
              (node.tag != 'ul' && node.tag != 'ol');
        }).toList(),
      );
      _line({
        'block': checkbox == null
            ? list.tag == 'ol'
                ? 'ol'
                : 'ul'
            : 'cl',
        if (checkbox == true) 'checked': true,
        if (indent > 0) 'indent': indent,
      });
      for (final child in children.whereType<md.Element>()) {
        if (child.tag == 'ul' || child.tag == 'ol') {
          _renderList(child, indent + 1);
        }
      }
    }
  }

  void _renderQuote(md.Element quote) {
    for (final child in quote.children ?? const <md.Node>[]) {
      if (child is md.Element) {
        renderInline(child.children ?? []);
      } else if (child is md.Text) {
        _insert(child.text);
      }
      _line({'block': 'quote'});
    }
  }

  void _renderCodeBlock(String code) {
    final lines = code.replaceFirst(RegExp(r'\n$'), '').split('\n');
    for (final line in lines) {
      _insert(line);
      _line({'block': 'code'});
    }
  }

  void _renderTable(md.Element table) {
    final rows = <List<String>>[];
    void collect(md.Node node) {
      if (node is! md.Element) return;
      if (node.tag == 'tr') {
        rows.add(
          (node.children ?? const <md.Node>[])
              .whereType<md.Element>()
              .map((cell) => cell.textContent.trim())
              .toList(),
        );
        return;
      }
      for (final child in node.children ?? const <md.Node>[]) {
        collect(child);
      }
    }

    collect(table);
    if (rows.isEmpty) return;
    delta.insert(
      BlockEmbed('table', data: {
        'id': UuidV4().generate(),
        'rows': rows,
      }).toJson(),
    );
    _line();
  }

  bool? _checkbox(md.Element item) {
    bool? result;
    void find(md.Node node) {
      if (node is! md.Element || result != null) return;
      if (node.tag == 'input' && node.attributes['type'] == 'checkbox') {
        result = node.attributes['checked'] == 'true';
        return;
      }
      for (final child in node.children ?? const <md.Node>[]) {
        find(child);
      }
    }

    find(item);
    return result;
  }

  void _insert(
    String text, [
    Map<String, dynamic> attributes = const {},
  ]) {
    if (text.isEmpty) return;
    delta.insert(text, attributes.isEmpty ? null : attributes);
  }

  void _line([Map<String, dynamic> attributes = const {}]) {
    delta.insert('\n', attributes.isEmpty ? null : attributes);
  }
}
