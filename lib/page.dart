import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class TelegramPage extends StatefulWidget {
  const TelegramPage({Key? key}) : super(key: key);

  @override
  _TelegramPageState createState() => _TelegramPageState();
}

class _TelegramPageState extends State<TelegramPage> {
  List<Medium>? _mediums;

  @override
  void initState() {
    super.initState();
    _fetchMediums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: Container(
            color: Colors.black87,
          )),
          Container(
            height: 60,
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.red,
                  ),
                  onPressed: () => showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    enableDrag: true,
                    isScrollControlled: true,
                    builder: (ctx) {
                      return _buildSheet();
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }

  Future<void> _fetchMediums() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      Album album = albums.first;
      MediaPage mediaPage = await album.listMedia();
      setState(() {
        _mediums = mediaPage.items;
      });
    }
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Widget _buildSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      builder: (ctx, controller) {
        return Container(
          padding: const EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
          ),
          decoration: const BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _mediums!.length,
            controller: controller,
            itemBuilder: (ctx, index) {
              return FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: PhotoProvider(mediumId: _mediums![index].id),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              );
            },
          ),
        );
      },
    );
  }
}
