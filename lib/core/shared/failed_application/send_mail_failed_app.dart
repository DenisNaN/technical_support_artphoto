import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/mailru.dart';

Future<void> sendEmailNewTrouble({Object? error, StackTrace? stack, String? flutterErrorDetails}) async{
  final smtpServer = mailru('FailedAppArtphoto@mail.ru', 'BbbQ14rmMvdQfCwZiPkb');
  final message = Message()
    ..from = Address('FailedAppArtphoto@mail.ru')
    ..recipients.addAll(['Pigarev-Denis@mail.ru'])
    ..subject = 'Ошибка: ${error ?? 'flutterErrorDetails'}'
    ..text = 'StackTrace: ${stack ?? ''}${flutterErrorDetails ?? ''}';

  try {
    await send(message, smtpServer);
  } on MailerException catch (e) {
    debugPrint('Message not sent.');
    for (var p in e.problems) {
      debugPrint('Problem: ${p.code}: ${p.msg}');
    }
  }
}