import 'package:flutter/material.dart';

class AddNoteButton extends StatelessWidget {
  final void Function() onPressed;
  const AddNoteButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: const Icon(
        Icons.add,
        size: 20,
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
      icon: const Icon(
        Icons.more_horiz,
        size: 20,
      )
    );
  }
}

class ChoseColorButton extends StatelessWidget {
  final void Function() onPressed;
  const ChoseColorButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: const Icon(
        Icons.palette,
        size: 20,
      )
    );
  }
}

class ColorPad extends StatefulWidget {
  final Color? color;
  Color selectedColor = Colors.white;
  ColorPad({super.key, this.color});

  Color get retrieveSelectedColor {
    return selectedColor;
  }

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
            widget.selectedColor = widget.color!;
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
  const DeleteNoteButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, 
      icon: const Icon(
        Icons.delete,
        size: 25,
      )
    );
  }
}

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context, true), 
      icon: const Icon(
        Icons.check,
        size: 25,
      )
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context, false), 
      icon: const Icon(
        Icons.close,
        size: 25,
      )
    );
  }
}

class ReturnButton extends StatelessWidget {
  final void Function() onPressed;
  const ReturnButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        onPressed: onPressed, 
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 20,
        )
      ),
    );
  }
}