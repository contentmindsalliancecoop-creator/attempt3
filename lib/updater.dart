// updater.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';

class Updater {
  // Ya no necesita la URL del JSON, sino el usuario y el repo
  final String githubUser;
  final String githubRepo;
  final Dio _dio = Dio();

  Updater(this.githubUser, this.githubRepo);

  Future<void> check(BuildContext context) async {
    try {
      // 1. Construimos la URL de la API de GitHub
      final apiUrl = 'https://api.github.com/repos/$githubUser/$githubRepo/releases/latest';
      
      // 2. Hacemos la petición para obtener los datos del último release
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) return; // Si hay error, salimos

      final releaseInfo = jsonDecode(response.body) as Map<String, dynamic>;
      
      // 3. Obtenemos la versión remota (tag) y la instalada
      final remoteVersion = releaseInfo['tag_name'] as String? ?? '';
      final pkg = await PackageInfo.fromPlatform();
      final installedVersion = 'v${pkg.version}'; // Añadimos 'v' para comparar con el tag (ej: v1.1.4)

      // 4. Comparamos las versiones
      if (remoteVersion.compareTo(installedVersion) > 0) {
        // Si la versión remota es "mayor" que la instalada, mostramos el diálogo
        final apkAsset = (releaseInfo['assets'] as List).firstWhere(
            (asset) => asset['name'].endsWith('.apk'),
            orElse: () => null,
        );

        if (apkAsset == null) return; // No hay un APK en este release

        final downloadUrl = apkAsset['browser_download_url'];
        final notes = releaseInfo['body'] as String? ?? 'Notas no disponibles.';

        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Actualización disponible'),
            content: Text('Versión $remoteVersion\n\n$notes'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Luego')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Actualizar')),
            ],
          ),
        );

        if (ok == true) await _downloadAndInstall(context, downloadUrl);
      } else {
        // Opcional: Informar al usuario que ya tiene la última versión
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya tienes la última versión instalada.')),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar actualizaciones: $e')),
        );
    }
  }

  // _downloadAndInstall no necesita cambios
  Future<void> _downloadAndInstall(BuildContext context, String url) async {
    // ... (este método se queda igual)
  }}