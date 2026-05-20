import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GeneratedOutputMetaCard extends StatelessWidget {
  const GeneratedOutputMetaCard({required this.items, super.key});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final clean = items.where((item) => item.$2.trim().isNotEmpty).toList();
    if (clean.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in clean)
              SizedBox(
                width: compact ? double.infinity : 180,
                child: _SoftBlock(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$2,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13.5,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class GeneratedOutputEmptyState extends StatelessWidget {
  const GeneratedOutputEmptyState({
    this.title = 'Görüntülenecek çıktı bulunamadı',
    this.message = 'Çıktı tamamlandı ancak gösterilecek içerik boş döndü.',
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StateBox(
      icon: Icons.inbox_outlined,
      title: title,
      message: message,
    );
  }
}

class GeneratedOutputErrorState extends StatelessWidget {
  const GeneratedOutputErrorState({
    this.title = 'Çıktı görüntülenemedi',
    this.message = 'Sayfayı yenilemeyi veya tekrar denemeyi deneyebilirsin.',
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StateBox(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
    );
  }
}

class GeneratedOutputReadableContent extends StatelessWidget {
  const GeneratedOutputReadableContent({
    required this.outputType,
    required this.content,
    this.title,
    super.key,
  });

  final String outputType;
  final Object? content;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final value = _decodeMaybeJson(content);
    if (_isEmpty(value)) return const GeneratedOutputEmptyState();
    final type = outputType.toLowerCase();
    if (type.contains('flashcard')) return _FlashcardReader(content: value);
    if (type.contains('question') || type.contains('quiz')) {
      return _QuestionReader(content: value);
    }
    if (type.contains('table') || type.contains('comparison')) {
      return _TableReader(content: value);
    }
    if (type.contains('algorithm') || type.contains('flow')) {
      return _FlowReader(content: value);
    }
    if (type.contains('podcast')) return _PodcastReader(content: value);
    if (type.contains('infographic')) return _InfographicReader(content: value);
    if (type.contains('mind') || type.contains('map')) {
      return _MindMapReader(content: value);
    }
    if (type.contains('summary') || type.contains('özet')) {
      return _SummaryReader(content: value, title: title);
    }
    return _GenericReader(content: value);
  }
}

class _FlashcardReader extends StatelessWidget {
  const _FlashcardReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    final cards = _preferredList(content, const [
      'cards',
      'flashcards',
      'items',
    ]);
    if (cards.isEmpty) return _GenericReader(content: content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReaderIntro(
          title: 'Flashcard’lar hazır',
          message:
              'Kaynağından oluşturulan tekrar kartlarını aşağıda inceleyebilirsin.',
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < cards.length; i++)
          _NumberedCard(
            number: i + 1,
            child: _FlashcardBody(value: cards[i]),
          ),
      ],
    );
  }
}

class _FlashcardBody extends StatelessWidget {
  const _FlashcardBody({required this.value});

  final Object? value;

  @override
  Widget build(BuildContext context) {
    final rawValue = value;
    final Map<dynamic, dynamic> map = rawValue is Map
        ? rawValue.cast<dynamic, dynamic>()
        : const {};
    final front = _firstText(map, const [
      'front',
      'question',
      'prompt',
      'term',
      'title',
      'on_yuz',
    ]);
    final back = _firstText(map, const [
      'back',
      'answer',
      'definition',
      'explanation',
      'arka_yuz',
      'cevap',
    ]);
    if (front.isEmpty && back.isEmpty) return _ReadableText(_plainText(value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabeledText(label: 'Ön yüz', text: front.isEmpty ? '-' : front),
        const SizedBox(height: 12),
        _LabeledText(label: 'Arka yüz', text: back.isEmpty ? '-' : back),
      ],
    );
  }
}

class _QuestionReader extends StatelessWidget {
  const _QuestionReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    final questions = _preferredList(content, const [
      'questions',
      'items',
      'quiz',
    ]);
    if (questions.isEmpty) return _GenericReader(content: content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReaderIntro(
          title: 'Sorular hazır',
          message:
              'Kaynağından oluşturulan soruları okunabilir düzende incele.',
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < questions.length; i++)
          _NumberedCard(
            number: i + 1,
            child: _QuestionBody(value: questions[i]),
          ),
      ],
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.value});

  final Object? value;

  @override
  Widget build(BuildContext context) {
    final rawValue = value;
    final Map<dynamic, dynamic> map = rawValue is Map
        ? rawValue.cast<dynamic, dynamic>()
        : const {};
    final question = _firstText(map, const [
      'question',
      'soru',
      'stem',
      'prompt',
    ]);
    final answer = _firstText(map, const [
      'correctAnswer',
      'correct_answer',
      'answer',
      'cevap',
    ]);
    final explanation = _firstText(map, const [
      'explanation',
      'rationale',
      'aciklama',
      'çözüm',
    ]);
    final options = _optionsFrom(map);
    if (question.isEmpty && options.isEmpty && answer.isEmpty) {
      return _ReadableText(_plainText(value));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabeledText(label: 'Soru', text: question.isEmpty ? '-' : question),
        if (options.isNotEmpty) ...[
          const SizedBox(height: 12),
          const _MiniLabel('Seçenekler'),
          const SizedBox(height: 8),
          for (var i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OptionRow(index: i, text: options[i]),
            ),
        ],
        if (answer.isNotEmpty) ...[
          const SizedBox(height: 12),
          _LabeledText(label: 'Doğru cevap', text: answer),
        ],
        if (explanation.isNotEmpty) ...[
          const SizedBox(height: 12),
          _LabeledText(label: 'Açıklama', text: explanation),
        ],
      ],
    );
  }
}

class _SummaryReader extends StatelessWidget {
  const _SummaryReader({required this.content, this.title});

  final Object? content;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final sections = _sectionsFrom(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReaderIntro(
          title: title?.trim().isNotEmpty == true
              ? title!.trim()
              : 'Sınav sabahı özeti',
          message: 'Son tekrar için yoğunlaştırılmış kaynak özeti.',
        ),
        const SizedBox(height: 14),
        if (sections.isEmpty)
          _ReadableText(_plainText(content))
        else
          for (final section in sections)
            _SectionCard(title: section.$1, text: section.$2),
      ],
    );
  }
}

class _FlowReader extends StatelessWidget {
  const _FlowReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    final steps = _preferredList(content, const [
      'steps',
      'nodes',
      'decision_nodes',
      'algorithm_flow',
      'flow',
    ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReaderIntro(
          title: 'Yapılandırılmış akış',
          message:
              'Bu çıktı, kaynağındaki süreci adım adım takip edilebilir şekilde yapılandırır.',
        ),
        const SizedBox(height: 14),
        if (steps.isEmpty)
          _ReadableText(_plainText(content))
        else
          for (var i = 0; i < steps.length; i++)
            _NumberedCard(
              number: i + 1,
              child: _ReadableText(_plainText(steps[i])),
            ),
      ],
    );
  }
}

class _TableReader extends StatelessWidget {
  const _TableReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    final table = _tableFrom(content);
    if (table == null) return _GenericReader(content: content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReaderIntro(
          title: 'Karşılaştırma tablosu',
          message: 'Satır ve sütun ilişkileri mobilde kart olarak gösterilir.',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 680) {
              return Column(
                children: [
                  for (final row in table.rows)
                    _SoftBlock(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < table.headers.length; i++) ...[
                            _MiniLabel(table.headers[i]),
                            const SizedBox(height: 4),
                            _ReadableText(i < row.length ? row[i] : ''),
                            if (i != table.headers.length - 1)
                              const Divider(
                                height: 18,
                                color: AppColors.softLine,
                              ),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            }
            return Table(
              border: TableBorder.all(color: AppColors.line),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF5FAFF)),
                  children: [
                    for (final header in table.headers)
                      _TableCell(text: header, bold: true),
                  ],
                ),
                for (final row in table.rows)
                  TableRow(
                    children: [
                      for (var i = 0; i < table.headers.length; i++)
                        _TableCell(text: i < row.length ? row[i] : ''),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PodcastReader extends StatelessWidget {
  const _PodcastReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReaderIntro(
          title: 'Podcast özeti',
          message:
              'Bu çıktı, dinlenebilir anlatım formatında hazırlanmış metinsel bir özettir.',
        ),
        const SizedBox(height: 14),
        _SummaryReader(content: content, title: 'Anlatım akışı'),
      ],
    );
  }
}

class _InfographicReader extends StatelessWidget {
  const _InfographicReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReaderIntro(
          title: 'İnfografik taslağı',
          message:
              'Bu çıktı, infografik tasarımı için yapılandırılmış içerik taslağıdır.',
        ),
        const SizedBox(height: 14),
        _GenericReader(content: content),
      ],
    );
  }
}

class _MindMapReader extends StatelessWidget {
  const _MindMapReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    final map = content is Map ? content as Map : const {};
    final center = _firstText(map, const [
      'centralTopic',
      'central_topic',
      'center',
      'root',
      'title',
    ]);
    final branches = _preferredList(content, const [
      'branches',
      'mainBranches',
      'main_branches',
      'nodes',
      'children',
    ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReaderIntro(
          title: 'Zihin haritası',
          message:
              'Bu çıktı, zihin haritası için yapılandırılmış metinsel bir iskelettir.',
        ),
        const SizedBox(height: 14),
        if (center.isNotEmpty)
          _SectionCard(title: 'Merkez kavram', text: center),
        if (branches.isEmpty)
          _GenericReader(content: content)
        else
          for (var i = 0; i < branches.length; i++)
            _NumberedCard(
              number: i + 1,
              child: _ReadableText(_plainText(branches[i])),
            ),
      ],
    );
  }
}

class _GenericReader extends StatelessWidget {
  const _GenericReader({required this.content});

  final Object? content;

  @override
  Widget build(BuildContext context) {
    final value = _decodeMaybeJson(content);
    if (_isEmpty(value)) return const GeneratedOutputEmptyState();
    if (value is List) {
      return Column(
        children: [
          for (var i = 0; i < value.length; i++)
            _NumberedCard(
              number: i + 1,
              child: _ReadableText(_plainText(value[i])),
            ),
        ],
      );
    }
    if (value is Map) {
      final sections = _sectionsFrom(value);
      if (sections.isNotEmpty) {
        return Column(
          children: [
            for (final section in sections)
              _SectionCard(title: section.$1, text: section.$2),
          ],
        );
      }
    }
    return _ReadableText(_plainText(value));
  }
}

class _ReaderIntro extends StatelessWidget {
  const _ReaderIntro({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _SoftBlock(
      color: const Color(0xFFEAF5FF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.article_outlined, color: AppColors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedCard extends StatelessWidget {
  const _NumberedCard({required this.number, required this.child});

  final int number;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _SoftBlock(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.selectedBlue,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _SoftBlock(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniLabel(title),
          const SizedBox(height: 8),
          _ReadableText(text),
        ],
      ),
    );
  }
}

class _LabeledText extends StatelessWidget {
  const _LabeledText({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MiniLabel(label),
        const SizedBox(height: 6),
        _ReadableText(text),
      ],
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      _humanize(text),
      style: const TextStyle(
        color: AppColors.blue,
        fontSize: 12.5,
        height: 1.2,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final label = String.fromCharCode(65 + index);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.selectedBlue,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(child: _ReadableText(text)),
      ],
    );
  }
}

class _ReadableText extends StatelessWidget {
  const _ReadableText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final clean = _cleanMarkdown(text);
    final lines = clean
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length > 1 && lines.every(_looksLikeBullet)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(Icons.circle, size: 6, color: AppColors.blue),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(_stripBullet(line), style: _bodyStyle)),
                ],
              ),
            ),
        ],
      );
    }
    return Text(clean.isEmpty ? '-' : clean, softWrap: true, style: _bodyStyle);
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({required this.text, this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        softWrap: true,
        style: TextStyle(
          color: AppColors.navy,
          fontSize: 13,
          height: 1.35,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }
}

class _SoftBlock extends StatelessWidget {
  const _SoftBlock({
    required this.child,
    this.margin = EdgeInsets.zero,
    this.color = const Color(0xFFF8FBFF),
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _SoftBlock(
      child: Column(
        children: [
          Icon(icon, color: AppColors.blue, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const _bodyStyle = TextStyle(
  color: AppColors.navy,
  fontSize: 15.5,
  height: 1.5,
  fontWeight: FontWeight.w600,
);

Object? _decodeMaybeJson(Object? value) {
  if (value is String) {
    final text = value.trim();
    if ((text.startsWith('{') && text.endsWith('}')) ||
        (text.startsWith('[') && text.endsWith(']'))) {
      try {
        return jsonDecode(text);
      } catch (_) {
        return value;
      }
    }
  }
  return value;
}

bool _isEmpty(Object? value) {
  return value == null ||
      value is String && value.trim().isEmpty ||
      value is List && value.isEmpty ||
      value is Map && value.isEmpty;
}

List<Object?> _preferredList(Object? content, List<String> keys) {
  final value = _decodeMaybeJson(content);
  if (value is List) return value.cast<Object?>();
  if (value is Map) {
    for (final key in keys) {
      final direct = value[key];
      if (direct is List) return direct.cast<Object?>();
    }
    final normalized = keys.map(_normalize).toSet();
    for (final entry in value.entries) {
      if (normalized.contains(_normalize(entry.key.toString())) &&
          entry.value is List) {
        return (entry.value as List).cast<Object?>();
      }
    }
  }
  return const [];
}

String _firstText(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final text = _scalarText(map[key]);
    if (text.isNotEmpty) return text;
  }
  final normalized = keys.map(_normalize).toSet();
  for (final entry in map.entries) {
    if (normalized.contains(_normalize(entry.key.toString()))) {
      final text = _scalarText(entry.value);
      if (text.isNotEmpty) return text;
    }
  }
  return '';
}

String _scalarText(Object? value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString();
  return '';
}

List<String> _optionsFrom(Map<dynamic, dynamic> map) {
  final raw = map['options'] ?? map['choices'] ?? map['secenekler'];
  if (raw is List) {
    return raw.map(_plainText).where((e) => e.isNotEmpty).toList();
  }
  if (raw is Map) {
    return raw.entries
        .map((entry) => '${entry.key}. ${_plainText(entry.value)}')
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }
  return const [];
}

List<(String, String)> _sectionsFrom(Object? content) {
  final value = _decodeMaybeJson(content);
  if (value is Map) {
    return value.entries
        .where((entry) => !_isEmpty(entry.value))
        .map(
          (entry) => (_humanize(entry.key.toString()), _plainText(entry.value)),
        )
        .where((entry) => entry.$2.trim().isNotEmpty)
        .toList();
  }
  if (value is String) {
    final lines = value.trim().split('\n');
    final sections = <(String, String)>[];
    String? title;
    final buffer = <String>[];
    for (final line in lines) {
      final heading = RegExp(
        r'^(#{1,4}\s+|[0-9]+[.)]\s+)(.+)$',
      ).firstMatch(line.trim());
      if (heading != null) {
        if (title != null && buffer.isNotEmpty) {
          sections.add((title, buffer.join('\n').trim()));
        }
        title = heading.group(2)!.trim();
        buffer.clear();
      } else {
        buffer.add(line);
      }
    }
    if (title != null && buffer.isNotEmpty) {
      sections.add((title, buffer.join('\n').trim()));
    }
    return sections;
  }
  return const [];
}

_TableData? _tableFrom(Object? content) {
  final value = _decodeMaybeJson(content);
  if (value is String) return _tableFromMarkdown(value);
  final map = value is Map ? value : const {};
  final tableValue = map['table'] ?? map['comparison_table'] ?? map['matrix'];
  if (tableValue is String) return _tableFromMarkdown(tableValue);
  final tableMap = tableValue is Map ? tableValue : map;
  final headersRaw = tableMap['headers'] ?? tableMap['columns'];
  final rowsRaw = tableMap['rows'] ?? tableMap['items'] ?? tableMap['data'];
  if (headersRaw is! List || rowsRaw is! List) return null;
  final headers = headersRaw
      .map(_plainText)
      .where((e) => e.isNotEmpty)
      .toList();
  final rows = rowsRaw
      .map((row) {
        if (row is List) return row.map(_plainText).toList();
        if (row is Map) {
          return headers.map((header) {
            return _plainText(
              row[header] ??
                  row[_normalize(header)] ??
                  row[header.toLowerCase()],
            );
          }).toList();
        }
        return [_plainText(row)];
      })
      .where((row) => row.any((cell) => cell.trim().isNotEmpty))
      .toList();
  if (headers.isEmpty || rows.isEmpty) return null;
  return _TableData(headers: headers, rows: rows);
}

_TableData? _tableFromMarkdown(String value) {
  final lines = value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.startsWith('|') && line.endsWith('|'))
      .toList();
  if (lines.length < 2) return null;
  final parsed = lines
      .map((line) => line.substring(1, line.length - 1).split('|'))
      .map((cells) => cells.map((cell) => _cleanMarkdown(cell.trim())).toList())
      .toList();
  final headers = parsed.first;
  final rows = parsed.skip(1).where((row) {
    return !row.every((cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell));
  }).toList();
  if (headers.isEmpty || rows.isEmpty) return null;
  return _TableData(headers: headers, rows: rows);
}

class _TableData {
  const _TableData({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;
}

String _plainText(Object? value) {
  final decoded = _decodeMaybeJson(value);
  if (decoded == null) return '';
  if (decoded is String) return _cleanMarkdown(decoded);
  if (decoded is num || decoded is bool) return decoded.toString();
  if (decoded is List) {
    return decoded
        .map(_plainText)
        .where((text) => text.trim().isNotEmpty)
        .join('\n');
  }
  if (decoded is Map) {
    return decoded.entries
        .map((entry) {
          final text = _plainText(entry.value);
          if (text.trim().isEmpty) return '';
          return '${_humanize(entry.key.toString())}: $text';
        })
        .where((text) => text.trim().isNotEmpty)
        .join('\n');
  }
  return decoded.toString().trim();
}

String _cleanMarkdown(String value) {
  return value
      .replaceAll(RegExp(r'```[a-zA-Z]*'), '')
      .replaceAll('```', '')
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
      .replaceAll(RegExp(r'__(.*?)__'), r'$1')
      .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
      .trim();
}

bool _looksLikeBullet(String line) {
  return RegExp(r'^([-*•]|\d+[.)])\s+').hasMatch(line.trim());
}

String _stripBullet(String line) {
  return line.replaceFirst(RegExp(r'^([-*•]|\d+[.)])\s+'), '').trim();
}

String _humanize(String value) {
  final spaced = value
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .trim();
  if (spaced.isEmpty) return value;
  return spaced[0].toUpperCase() + spaced.substring(1);
}

String _normalize(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9ğüşöçıİĞÜŞÖÇ]'), '');
}
