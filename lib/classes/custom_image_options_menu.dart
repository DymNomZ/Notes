import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart' show showCupertinoModalPopup;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill_extensions/src/editor/image/widgets/image.dart' show ImageTapWrapper, getImageStyleString;
import 'package:flutter_quill_extensions/src/editor/image/widgets/image_resizer.dart' show ImageResizer;
import 'package:flutter_quill_extensions/src/common/utils/string.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show QuillController, StyleAttribute, getEmbedNode;

import 'package:flutter_quill_extensions/src/common/utils/element_utils/element_utils.dart';
import 'package:flutter_quill_extensions/src/editor/image/image_load_utils.dart';

class CustomImageOptionsMenu extends StatelessWidget {
  const CustomImageOptionsMenu({
    required this.controller,
    required this.config,
    required this.imageSource,
    required this.imageSize,
    required this.readOnly,
    required this.imageProvider,
    this.prefersGallerySave = true,
    super.key,
  });

  final QuillController controller;
  final QuillEditorImageEmbedConfig config;
  final String imageSource;
  final ElementSize imageSize;
  final bool readOnly;
  final ImageProvider imageProvider;
  final bool prefersGallerySave;

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: SimpleDialog(
        title: Text(context.loc.image),
        children: [
          if (!readOnly)
            ListTile(
              title: Text(context.loc.resize),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                Navigator.pop(context);
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (modalContext) {
                    final screenSize = MediaQuery.sizeOf(modalContext);
                    return ImageResizer(
                      onImageResize: (width, height) {
                        final res = getEmbedNode(
                          controller,
                          controller.selection.start,
                        );

                        final attr = replaceStyleStringWithSize(
                          getImageStyleString(controller),
                          width: width,
                          height: height,
                        );
                        controller
                          ..skipRequestKeyboard = true
                          ..formatText(
                            res.offset,
                            1,
                            StyleAttribute(attr),
                          );
                      },
                      imageWidth: imageSize.width,
                      imageHeight: imageSize.height,
                      maxWidth: screenSize.width,
                      maxHeight: screenSize.height,
                    );
                  },
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(context.loc.copy),
            onTap: () async {
              Navigator.of(context).pop();
              controller.copiedImageUrl = ImageUrl(
                imageSource,
                getImageStyleString(controller),
              );

              final imageBytes = await ImageLoader.instance
                  .loadImageBytesFromImageProvider(
                      imageProvider: imageProvider);
              if (imageBytes != null) {
                await ClipboardServiceProvider.instance.copyImage(imageBytes);
              }
            },
          ),
          if (!readOnly)
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: materialTheme.colorScheme.error,
              ),
              title: Text(context.loc.remove),
              onTap: () async {
                Navigator.of(context).pop();

                // Call the remove check callback if set
                if (await config.shouldRemoveImageCallback?.call(imageSource) ==
                    false) {
                  return;
                }

                final offset = getEmbedNode(
                  controller,
                  controller.selection.start,
                ).offset;
                controller.replaceText(
                  offset,
                  1,
                  '',
                  TextSelection.collapsed(offset: offset),
                );
                // Call the post remove callback if set
                await config.onImageRemovedCallback.call(imageSource);
              },
            ),
          ListTile(
            leading: const Icon(Icons.zoom_in),
            title: Text(context.loc.zoom),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ImageTapWrapper(
                  imageUrl: imageSource,
                  config: config,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleImageResizer extends StatefulWidget {
  final double currentWidth;
  final double currentHeight;
  final Function(double, double) onResize;

  const SimpleImageResizer({super.key, required this.currentWidth, required this.currentHeight, required this.onResize});

  @override
  State<SimpleImageResizer> createState() => _SimpleImageResizerState();
}

class _SimpleImageResizerState extends State<SimpleImageResizer> {
  late double _width;
  late double _height;

  @override
  void initState() {
    _width = widget.currentWidth;
    _height = widget.currentHeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Resize Image"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Width"),
          Slider(
            min: 50,
            max: 1000,
            value: _width, 
            onChanged: (val) {
              setState(() => _width = val);
              // Proportional scaling
              double ratio = widget.currentHeight / widget.currentWidth;
              setState(() => _height = val * ratio);
              widget.onResize(_width, _height);
            }
          ),
          const Text("Height"),
          Slider(
            min: 50,
            max: 1000,
            value: _height,
            onChanged: (val) {
               setState(() => _height = val);
               // Proportional scaling
               double ratio = widget.currentWidth / widget.currentHeight;
               setState(() => _width = val * ratio);
               widget.onResize(_width, _height);
            }
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))
      ],
    );
  }
}