import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../src/toolbar.dart';
import 'modal_select_emoji.dart';
import 'modal_input_url.dart';
import 'toolbar_item.dart';

class MarkdownToolbar extends StatelessWidget {
  /// Preview/Eye button
  final VoidCallback? onPreviewChanged;
  final TextEditingController controller;
  final VoidCallback? unfocus;
  final bool emojiConvert;
  final bool autoCloseAfterSelectEmoji;
  final Toolbar toolbar;
  final Color? toolbarBackground;
  final Color? expandableBackground;
  final bool showPreviewButton;
  final bool showEmojiSelection;
  final Color borderColor;
  final VoidCallback? onActionCompleted;
  final String? markdownSyntax;
  final bool previewed;

  const MarkdownToolbar({
    super.key,
    this.onPreviewChanged,
    this.markdownSyntax,
    required this.controller,
    this.emojiConvert = true,
    this.unfocus,
    required this.toolbar,
    this.autoCloseAfterSelectEmoji = true,
    this.toolbarBackground,
    this.expandableBackground,
    this.onActionCompleted,
    this.showPreviewButton = true,
    this.showEmojiSelection = true,
    this.borderColor = Colors.grey,
    this.previewed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      color: toolbarBackground ?? Colors.grey[200],
      width: double.maxFinite,
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // preview
            if (showPreviewButton)
              ToolbarItem(
                key: const ValueKey<String>("toolbar_view_item"),
                icon: FontAwesomeIcons.eye,
                onPressedButton: onPreviewChanged,
                tooltip: 'Show/Hide markdown preview',
              ),

            // bold
            if (!previewed)
              ToolbarItem(
                key: const ValueKey<String>("toolbar_bold_action"),
                icon: FontAwesomeIcons.bold,
                tooltip: 'Make text bold',
                onPressedButton: () {
                  toolbar.action("**", "**");
                  onActionCompleted?.call();
                },
              ),
            // italic
            if (!previewed)
              ToolbarItem(
                key: const ValueKey<String>("toolbar_italic_action"),
                icon: FontAwesomeIcons.italic,
                tooltip: 'Make text italic',
                onPressedButton: () {
                  toolbar.action("_", "_");
                  onActionCompleted?.call();
                },
              ),
            // unorder list
            if (!previewed)
              ToolbarItem(
                key: const ValueKey<String>("toolbar_unorder_list_action"),
                icon: FontAwesomeIcons.listUl,
                tooltip: 'Unordered list',
                onPressedButton: () {
                  toolbar.action("* ", "");
                  onActionCompleted?.call();
                },
              ),
            // link
            if (!previewed)
              ToolbarItem(
                key: const ValueKey<String>("toolbar_link_action"),
                icon: FontAwesomeIcons.link,
                tooltip: 'Add hyperlink',
                onPressedButton: () async {
                  if (toolbar.hasSelection) {
                    toolbar.action("[enter link description here](", ")");
                  } else {
                    await _showModalInputUrl(context,
                        "[enter link description here](", controller.selection);
                  }

                  onActionCompleted?.call();
                },
              ),
            // heading
            if (!previewed)
              ToolbarItem(
                key: const ValueKey<String>("toolbar_heading_action"),
                icon: FontAwesomeIcons.heading,
                isExpandable: true,
                tooltip: 'Insert Heading',
                expandableBackground: expandableBackground,
                items: [
                  ToolbarItem(
                    key: const ValueKey<String>("h1"),
                    icon: "H1",
                    tooltip: 'Insert Heading 1',
                    onPressedButton: () {
                      toolbar.action("# ", "");
                      onActionCompleted?.call();
                    },
                  ),
                  ToolbarItem(
                    key: const ValueKey<String>("h2"),
                    icon: "H2",
                    tooltip: 'Insert Heading 2',
                    onPressedButton: () {
                      toolbar.action("## ", "");
                      onActionCompleted?.call();
                    },
                  ),
                  ToolbarItem(
                    key: const ValueKey<String>("h3"),
                    icon: "H3",
                    tooltip: 'Insert Heading 3',
                    onPressedButton: () {
                      toolbar.action("### ", "");
                      onActionCompleted?.call();
                    },
                  ),
                  ToolbarItem(
                    key: const ValueKey<String>("h4"),
                    icon: "H4",
                    tooltip: 'Insert Heading 4',
                    onPressedButton: () {
                      toolbar.action("#### ", "");
                      onActionCompleted?.call();
                    },
                  ),
                  // Heading 5 onwards has same font
                ],
              ),
            if (previewed)
              Text(
                "Preview mode.",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Show modal to select emoji
  Future<dynamic> _showModalSelectEmoji(
      BuildContext context, TextSelection selection) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      context: context,
      builder: (context) {
        return ModalSelectEmoji(
          emojiConvert: emojiConvert,
          onChanged: (String emot) {
            if (autoCloseAfterSelectEmoji) Navigator.pop(context);
            final newSelection = toolbar.getSelection(selection);

            toolbar.action(emot, "", textSelection: newSelection);
            // change selection baseoffset if not auto close emoji
            if (!autoCloseAfterSelectEmoji) {
              selection = TextSelection.collapsed(
                offset: newSelection.baseOffset + emot.length,
              );
              unfocus?.call();
            }
            onActionCompleted?.call();
          },
        );
      },
    );
  }

  // show modal input
  Future<dynamic> _showModalInputUrl(
    BuildContext context,
    String leftText,
    TextSelection selection,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ModalInputUrl(
            toolbar: toolbar,
            leftText: leftText,
            selection: selection,
            onActionCompleted: onActionCompleted,
          ),
        );
      },
    );
  }
}
