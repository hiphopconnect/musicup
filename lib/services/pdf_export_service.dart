// lib/services/pdf_export_service.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  /// Exportiert eine Liste von Alben als PDF-Datei.
  /// [title] wird als Ueberschrift verwendet (z.B. "MusicUp Sammlung").
  /// [fileName] ist der vorgeschlagene Dateiname (z.B. "sammlung.pdf").
  /// [dialogTitle] ist der Titel des Speichern-Dialogs.
  /// Gibt den Dateipfad zurueck oder null bei Abbruch.
  static Future<String?> exportAsPdf({
    required List<Album> albums,
    required String title,
    required String fileName,
    required String dialogTitle,
  }) async {
    LoggerService.info('PDF-Export', 'Starte Export "$title" (${albums.length} Alben)');

    try {
      final savePath = await _selectSaveLocation(dialogTitle, fileName);
      if (savePath == null) {
        LoggerService.info('PDF-Export', 'Vom Benutzer abgebrochen');
        return null;
      }

      final sorted = List<Album>.from(albums)
        ..sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));

      final pdf = _buildPdf(sorted, title);

      final file = File(savePath);
      await file.writeAsBytes(await pdf.save());

      LoggerService.success('PDF-Export', 'Gespeichert unter $savePath');
      return savePath;
    } catch (e) {
      LoggerService.error('PDF-Export', e);
      rethrow;
    }
  }

  static pw.Document _buildPdf(List<Album> albums, String title) {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${_pad(now.day)}.${_pad(now.month)}.${now.year}';

    pdf.addPage(
      pw.MultiPage(
        maxPages: 200,
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader(title, dateStr),
        footer: (context) => _buildFooter(albums.length, context),
        build: (context) => [
          pw.SizedBox(height: 8),
          _buildTable(albums),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(String title, String dateStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Exportiert am $dateStr',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildFooter(int totalAlbums, pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Gesamt: $totalAlbums Alben',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.Text(
          'Seite ${context.pageNumber} von ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(List<Album> albums) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 11,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
      },
      headers: ['Kuenstler', 'Album', 'Medium'],
      data: albums
          .map((a) => [a.artist, a.name, a.medium])
          .toList(),
    );
  }

  static Future<String?> _selectSaveLocation(String dialogTitle, String fileName) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    return result;
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
