import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class Updater {
  final String versionUrl;
  final Dio _dio = Dio();

  Updater(this.versionUrl);

  Future<void> check(BuildContext context) async {
    try {
      final info = await _fetch();
      if (info == null) return;

      final pkg = await PackageInfo.fromPlatform();
      final installed = int.tryParse(pkg.buildNumber) ?? 0;
      final remote = (info['code'] as int?) ?? 0;

      if (remote > installed) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Actualización disponible'),
            content: Text('Versión ${info['version']}\n\n${info['notes'] ?? ''}'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Luego')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Actualizar')),
            ],
          ),
        );
        if (ok == true) await _downloadAndInstall(context, info['url'] as String);
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _fetch() async {
    final r = await http.get(Uri.parse(versionUrl));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    return null;
  }

  Future<void> _downloadAndInstall(BuildContext context, String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/update.apk';
      await _dio.download(url, path);
      await OpenFilex.open(path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e')),
      );
    }
  }
}
