import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showCuperDialogLoading(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => true,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              elevation: 0.0,
              backgroundColor: Colors.white,
              child: Container(
                height: 100,
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/logo.png',
                            fit: BoxFit.cover, height: 40, width: 40),
                        SizedBox(
                          width: 55,
                          height: 55,
                          child: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                              strokeWidth: 0.8),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text('Loading...')
                  ],
                ),
              ),
            ),
          );
        });
  }
}
