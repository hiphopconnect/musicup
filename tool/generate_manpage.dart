import 'dart:io';

import 'package:music_up/help/help_content.dart';

/// Generates a troff-formatted man page from HelpContent.
/// Usage: dart run tool/generate_manpage.dart > docs/musicup.1
void main() {
  final version = _readVersion();
  final date = _formatDate(DateTime.now());

  final buffer = StringBuffer();

  buffer.writeln(
    '.TH MUSICUP 1 "$date" "$version" "MusicUp Manual"',
  );

  buffer.writeln('.SH NAME');
  buffer.writeln(
    'musicup \\- ${HelpContent.shortDescriptionDe}',
  );

  buffer.writeln('.SH SYNOPSIS');
  buffer.writeln('.B musicup');
  buffer.writeln('[\\fIOPTIONEN\\fR]');

  for (final section in HelpContent.sectionsDe) {
    buffer.writeln('.SH ${section.title}');
    _writeBody(buffer, section.body);
  }

  stdout.write(buffer.toString());
}

/// Reads the version from pubspec.yaml.
String _readVersion() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('pubspec.yaml nicht gefunden. '
        'Bitte aus dem Projektverzeichnis ausfuehren.');
    exit(1);
  }
  for (final line in pubspec.readAsLinesSync()) {
    if (line.startsWith('version:')) {
      final full = line.split(':').last.trim();
      return full.split('+').first;
    }
  }
  stderr.writeln('Keine version: Zeile in pubspec.yaml gefunden.');
  exit(1);
}

/// Formats a DateTime as "Monat YYYY" in German.
String _formatDate(DateTime dt) {
  const months = [
    'Januar',
    'Februar',
    'Maerz',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  return '${months[dt.month - 1]} ${dt.year}';
}

/// Converts a section body to troff format.
///
/// Lines starting with "- " (bullet) become tagged paragraphs (.TP).
/// Empty lines become paragraph breaks (.PP).
/// Consecutive lines get .br between them to preserve line structure.
void _writeBody(StringBuffer buffer, String body) {
  final lines = body.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    if (trimmed.isEmpty) {
      buffer.writeln('.PP');
    } else if (trimmed.startsWith('- ')) {
      buffer.writeln('.TP');
      buffer.writeln('.B ${_escTroff(trimmed.substring(2))}');
    } else {
      buffer.writeln(_escTroff(trimmed));
      // Insert line break between consecutive non-empty lines
      if (i + 1 < lines.length && lines[i + 1].trim().isNotEmpty &&
          !lines[i + 1].trim().startsWith('- ')) {
        buffer.writeln('.br');
      }
    }
  }
}

/// Escapes characters that have special meaning in troff.
String _escTroff(String text) {
  return text.replaceAll('\\', '\\\\').replaceAll('.', '\\&.');
}
