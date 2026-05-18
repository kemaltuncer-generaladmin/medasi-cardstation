// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'drive_upload_payload.dart';

class DriveUploadService {
  const DriveUploadService();

  Future<PickedDriveFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (result == null || result.files.isEmpty) return null;

    final selected = result.files.first;
    final fileName = selected.name.trim();
    final bytes = selected.bytes;
    final sizeBytes = selected.size;
    if (fileName.isEmpty || bytes == null || bytes.isEmpty) {
      final safeName = fileName.isEmpty ? '<unknown>' : fileName;
      throw StateError(
        'Dosya okunamadı veya boş görünüyor. '
        'name=$safeName size=$sizeBytes bytes=${bytes?.length ?? 0}',
      );
    }

    return PickedDriveFile(
      name: fileName,
      contentType: _fallbackContentType(fileName),
      sizeBytes: sizeBytes,
      bytes: Uint8List.fromList(bytes),
    );
  }

  Future<void> uploadBytes({
    required String uploadUrl,
    required Map<String, String> headers,
    required PickedDriveFile file,
    ValueChanged<double>? onProgress,
  }) async {
    onProgress?.call(0);
    final request = html.HttpRequest();
    request.open('PUT', uploadUrl);
    var hasContentType = false;
    for (final entry in headers.entries) {
      try {
        request.setRequestHeader(entry.key, entry.value);
        hasContentType =
            hasContentType || entry.key.toLowerCase() == 'content-type';
      } catch (_) {
        // browser may block cross-origin header
      }
    }
    if (!hasContentType && file.contentType.trim().isNotEmpty) {
      request.setRequestHeader('Content-Type', file.contentType);
    }
    final completed = Completer<void>();
    request.upload.onProgress.listen((event) {
      final total = event.total ?? file.sizeBytes;
      if (total > 0) {
        onProgress?.call((event.loaded ?? 0) / total);
      }
    });
    request.onLoadEnd.listen((_) {
      if (request.status != null &&
          request.status! >= 200 &&
          request.status! < 300) {
        onProgress?.call(1);
        if (!completed.isCompleted) completed.complete();
      } else {
        if (!completed.isCompleted) {
          completed.completeError(
            StateError('GCS upload failed: HTTP ${request.status}'),
          );
        }
      }
    });
    request.onError.listen((_) {
      if (!completed.isCompleted) {
        completed.completeError(StateError('GCS upload failed.'));
      }
    });
    request.send(html.Blob([file.bytes], file.contentType));
    await completed.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        request.abort();
        throw StateError('GCS upload failed: timeout');
      },
    );
  }

  String _fallbackContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.ppt')) return 'application/vnd.ms-powerpoint';
    if (lower.endsWith('.pptx')) {
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    }
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.zip')) return 'application/zip';
    return 'application/octet-stream';
  }
}
