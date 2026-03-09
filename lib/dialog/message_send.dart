import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageSend extends StatelessWidget {
  final String title, positiveBtnText, negativeBtnText;
  final GestureTapCallback positiveBtnPressed;
  final TextEditingController textMessage;

// declare a GlobalKey
  final _formKey = GlobalKey<FormState>();
  // declare a variable to keep track of the input text

  MessageSend({
    super.key,
    required this.title,
    required this.positiveBtnText,
    required this.negativeBtnText,
    required this.positiveBtnPressed,
    required this.textMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      key: _formKey,
      textDirection: TextDirection.rtl,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          // Bottom rectangular box
          margin: const EdgeInsets.only(
              top: 30), // to push the box half way below circle
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(
              top: 40, left: 12, right: 12), // spacing inside the box
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: textMessage,
                maxLines: 7,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                    // icon: Icon(Icons.send_and_archive, size: 25),
                    border: UnderlineInputBorder(),
                    labelText: 'الرسالة .....',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              OverflowBar(
                overflowAlignment: OverflowBarAlignment.center,
                spacing: 12,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      negativeBtnText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    onPressed: positiveBtnPressed,
                    child: Text(
                      positiveBtnText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const CircleAvatar(
          // Top Circle with icon
          maxRadius: 40.0,
          child: Icon(
            Icons.send_and_archive_rounded,
            size: 45,
          ),
        ),
      ],
    );
  }
}
