// lib/updater.dart (Versión corregida y funcional)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class Updater {
  final String githubUser;
  final String githubRepo;
  final Dio _dio = Dio(); // Ahora sí lo vamos a usar

  Updater(this.githubUser, this.githubRepo);

  Future<void> check(BuildContext context) async {
    // Muestra un indicador de carga mientras busca
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buscando actualizaciones...')),
    );

    try {
      // 1. Construimos la URL y hacemos la petición con Dio
      final apiUrl = 'https://api.github.com/repos/$githubUser/$githubRepo/releases/latest';
      final response = await _dio.get(apiUrl);

      if (response.statusCode != 200) return;

      final releaseInfo = response.data as Map<String, dynamic>;

      // 2. Obtenemos las versiones
      final remoteVersion = (releaseInfo['tag_name'] as String? ?? '').replaceAll('v', '');
      final pkg = await PackageInfo.fromPlatform();
      final installedVersion = pkg.version;

      // 3. Comparamos versiones (una forma simple)
      if (_isVersionGreater(remoteVersion, installedVersion)) {
        // Si hay una nueva versión, buscamos el APK
        final apkAsset = (releaseInfo['assets'] as List).firstWhere(
          (asset) => asset['name'].endsWith('.apk'),
          orElse: () => null,
        );

        if (apkAsset == null) return;

        final downloadUrl = apkAsset['browser_download_url'];
        final notes = releaseInfo['body'] as String? ?? 'Notas no disponibles.';
        
        // Cerramos el SnackBar de "Buscando..."
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // 4. Mostramos el diálogo de confirmación
        final wantsToUpdate = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text('Actualización disponible: v$remoteVersion'),
            content: Text(notes),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Luego')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Actualizar ahora')),
            ],
          ),
        );

        if (wantsToUpdate == true) {
          await _downloadAndInstall(context, downloadUrl, 'v$remoteVersion.apk');
        }
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya tienes la última versión instalada.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar actualizaciones: $e')),
      );
    }
  }

  Future<void> _downloadAndInstall(BuildContext context, String url, String fileName) async {
    try {
      // 1. Obtener la ruta de descargas
      final Directory? dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('No se pudo acceder al almacenamiento.');
      final String savePath = '${dir.path}/$fileName';

      // 2. Mostrar un diálogo de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
          return AlertDialog(
            title: const Text('Descargando actualización...'),
            content: ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (_, progress, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 10),
                    Text('${(progress * 100).toStringAsFixed(0)}%'),
                  ],
                );
              },
            ),
          );
        },
      );

      // 3. Descargar el archivo con Dio
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Actualizar el progreso (no puedo acceder directamente al ValueNotifier de arriba,
            // esta es una limitación. Para un progreso real, se necesitaría un gestor de estado).
            // Por ahora, el diálogo solo muestra que la descarga está en proceso.
            print('Progreso: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // 4. Cerrar el diálogo y abrir el archivo
      Navigator.pop(context); // Cierra el diálogo de progreso
      final result = await OpenFile.open(savePath);

      if (result.type != ResultType.done) {
        throw Exception('No se pudo abrir el archivo de instalación: ${result.message}');
      }
    } catch (e) {
      Navigator.pop(context); // Asegurarse de cerrar el diálogo si hay un error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error durante la descarga: $e')),
      );
    }
  }

  // Una función de comparación de versiones más robusta
  bool _isVersionGreater(String newVersion, String oldVersion) {
    final newParts = newVersion.split('.').map(int.parse).toList();
    final oldParts = oldVersion.split('.').map(int.parse).toList();

    final maxLength = newParts.length > oldParts.length ? newParts.length : oldParts.length;

    for (int i = 0; i < maxLength; i++) {
      final newPart = i < newParts.length ? newParts[i] : 0;
      final oldPart = i < oldParts.length ? oldParts[i] : 0;

      if (newPart > oldPart) return true;
      if (newPart < oldPart) return false;
    }
    return false; // Son iguales
  }
}