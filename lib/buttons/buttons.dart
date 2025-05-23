import 'package:flutter/material.dart';
import 'package:notesclonedym/classes/note.dart';
import 'package:notesclonedym/functions/functions.dart';

class SettingsButton extends StatelessWidget {
  final void Function() onPressed;
  const SettingsButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        Icons.settings,
        size: 20,
        color: windowBarDarkMode(),
      )
    );
  }
}
class AddNoteButton extends StatelessWidget {
  final void Function() onPressed;
  const AddNoteButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        Icons.add,
        size: 20,
        color: windowBarDarkMode(),
      )
    );
  }
}

class ShowInfoButton extends StatelessWidget {
  final void Function() onPressed;
  const ShowInfoButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        Icons.more_horiz,
        size: 20,
        color: windowBarDarkMode(),
      )
    );
  }
}

class ChoseColorButton extends StatelessWidget {
  final void Function() onPressed;
  final int darkModeType;
  final Note? note;
  final Color color;
  const ChoseColorButton({required this.onPressed, required this.darkModeType, this.note, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        Icons.palette,
        size: 20,
        color: (darkModeType == 1) ? windowBarDarkMode() : noteBarDarkMode(note, color),
      )
    );
  }
}

class ColorPad extends StatefulWidget {
  final Color? color;
  const ColorPad({super.key, this.color});

  @override
  State<ColorPad> createState() => _ColorPadState();
}

class _ColorPadState extends State<ColorPad> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            Navigator.pop(context, widget.color);
          });
        },
        child: Container(
          color: widget.color,
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}

class DeleteNoteButton extends StatelessWidget {
  final void Function() onPressed;
  final Note note;
  const DeleteNoteButton({required this.onPressed, required this.note, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        Icons.delete,
        size: 25,
        color: cardDarkMode(note)
      )
    );
  }
}

class DeleteFolderButton extends StatelessWidget {
  final void Function() onPressed;
  const DeleteFolderButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        Icons.delete,
        size: 25,
        color: windowBodyDarkMode()
      )
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const ConfirmButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.pop(context, true), 
      icon: const Icon(
        Icons.check,
        size: 25,
        color: Colors.black,
      )
    );
  }
}

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const CancelButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.pop(context, false), 
      icon: const Icon(
        Icons.close,
        size: 25,
        color: Colors.black,
      )
    );
  }
}

class ReturnButton extends StatelessWidget {
  final void Function() onPressed;
  final Note? note;
  final Color color;
  const ReturnButton({super.key, required this.onPressed, required this.note, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        onPressed: onPressed, 
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: noteBarDarkMode(note, color),
        )
      ),
    );
  }
}

class ReturnButton2 extends StatelessWidget {
  final void Function()? onPressed;
  const ReturnButton2({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.pop(context, false),
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: windowBarDarkMode(),
        )
      ),
    );
  }
}

class FolderButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const FolderButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        Icons.folder_open,
        size: 20,
        color: windowBarDarkMode(),
      )
    );
  }
}

class MoveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Note note;
  const MoveButton({this.onPressed, required this.note, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.pop(context, false), 
      icon: Icon(
        Icons.drive_file_move_outline,
        size: 25,
        color: cardDarkMode(note),
      )
    );
  }
}