import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/src/toolbar.dart';

class ModalInputUrl extends StatefulWidget {
  const ModalInputUrl({
    super.key,
    required this.toolbar,
    required this.leftText,
    required this.selection,
    this.onActionCompleted,
  });

  final Toolbar toolbar;
  final String leftText;
  final TextSelection selection;
  final VoidCallback? onActionCompleted;

  @override
  State<ModalInputUrl> createState() => _ModalInputUrlState();
}

class _ModalInputUrlState extends State<ModalInputUrl> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the text field with the currently selected text
    // from the editor.
    final String fullText = widget.toolbar.controller.text;
    _textController.text = widget.selection.textInside(fullText);
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    String text = _textController.text.trim();
    String url = _urlController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please provide text",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(milliseconds: 700),
        ),
      );
      return;
    }

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please input a url",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(milliseconds: 700),
        ),
      );
      return;
    }

    // Add scheme if missing
    if (!url.contains(RegExp(r'https?:\/\/(www\.)?([^\s]+)'))) {
      url = "http://$url";
    }

    // Build: [text](url)
    final String result = "[$text]($url)";

    widget.toolbar.action(
      "${widget.leftText}$result",
      "",
      textSelection: widget.selection,
      replace: true,
    );

    Navigator.pop(context);
    widget.onActionCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      padding: const EdgeInsets.all(30),
      width: double.maxFinite,
      constraints: const BoxConstraints(
        maxWidth: 500, // Maximum width in logical pixels
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Text",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextField(
            controller: _textController,
            autocorrect: false,
            autofocus: true,
            cursorRadius: const Radius.circular(16),
            decoration: const InputDecoration(
              hintText: "Text for the link",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
            ),
            style: const TextStyle(fontSize: 16),
            enableInteractiveSelection: true,
            // Optionally move focus to URL on submit
            onSubmitted: (_) {
              FocusScope.of(context).nextFocus();
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Link",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextField(
            controller: _urlController,
            autocorrect: false,
            cursorRadius: const Radius.circular(16),
            decoration: const InputDecoration(
              hintText: "Input your url.",
              helperText: "example: https://example.com",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
            ),
            style: const TextStyle(fontSize: 16),
            enableInteractiveSelection: true,
            onSubmitted: (_) => _submit(context),
          ),
          // TextButtons to submit and cancel the form
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _submit(context),
                child: const Text("Insert"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
