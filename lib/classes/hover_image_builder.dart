import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import 'package:flutter_quill_extensions/src/common/utils/element_utils/element_utils.dart';
import 'package:flutter_quill_extensions/src/editor/image/widgets/image.dart';
import 'package:notesclonedym/classes/custom_image_options_menu.dart';
import 'package:notesclonedym/variables.dart';

class HoverableImageEmbedBuilder extends EmbedBuilder {
  HoverableImageEmbedBuilder({
    required this.config,
  });
  
  final QuillEditorImageEmbedConfig config;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final imageSource = standardizeImageUrl(embedContext.node.value.data);
    final ((imageSize), margin, alignment) = getElementAttributes(
      embedContext.node,
      context,
    );

    final width = imageSize.width;
    final height = imageSize.height;

    final imageWidget = getImageWidgetByImageSource(
      context: context,
      imageSource,
      imageProviderBuilder: config.imageProviderBuilder,
      imageErrorWidgetBuilder: config.imageErrorWidgetBuilder,
      alignment: alignment,
      height: height,
      width: width,
    );

    final gestureWidget = GestureDetector(
      onTap: () {
        final onImageClicked = config.onImageClicked;
        if (onImageClicked != null) {
          onImageClicked(imageSource);
          return;
        }
      },
      child: Builder(
        builder: (context) {
          if (margin != null) {
            return Padding(
              padding: EdgeInsets.all(margin),
              child: imageWidget,
            );
          }
          return imageWidget;
        },
      ),
    );

    return _ImageHoverWrapper(child: gestureWidget);
  }
}

class _ImageHoverWrapper extends StatefulWidget {
  final Widget child;
  const _ImageHoverWrapper({required this.child});

  @override
  State<_ImageHoverWrapper> createState() => _ImageHoverWrapperState();
}

class _ImageHoverWrapperState extends State<_ImageHoverWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          color:_isHovered 
            ? selectionColor
            : null
        ),
        child: widget.child,
      ),
    );
  }
}