import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Widget highlightAsteriskWords(
  String text, {
  TextStyle? styleHighlight,
  TextStyle? styleNormal,
  RegExp? regExp,
  TextAlign textAlign = TextAlign.start,
  void Function(String)? onPressed,
}) {
  RegExp regExps = regExp ?? RegExp(r'\*(.*?)\*');
  List<InlineSpan> children = [];

  text.splitMapJoin(
    regExps,
    onMatch: (Match match) {
      children.add(
        TextSpan(
          text: match.group(1),
          style: styleHighlight ?? const TextStyle(fontWeight: FontWeight.bold),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onPressed != null) {
                var t = match.group(0);
                try {
                  onPressed(t?.substring(1, t.length - 1) ?? '');
                } on Exception catch (_) {
                  onPressed(t ?? '');
                }
              }
            },
        ),
      );
      return '';
    },
    onNonMatch: (String text) {
      children.add(TextSpan(text: text, style: styleNormal));
      return text;
    },
  );

  return RichText(
    text: TextSpan(children: children),
    textAlign: textAlign,
  );
}

class MarkTextWidget extends StatelessWidget {
  final String text;
  final String symbol;
  final void Function(String) onPressed;
  final EdgeInsetsGeometry? padding;
  final TextStyle? styleHighlight;
  final Color? colorHighlight;
  final TextStyle? styleNormal;
  final Color? colorNormal;
  final TextAlign textAlign;

  /// ```
  /// // Primer parámetro
  /// String param1 = r'\$';
  ///
  /// // Segundo parámetro
  /// String param2 = r'\$';
  ///
  /// // Expresión regular con parámetros
  /// RegExp regex = RegExp('$param1(.*?)$param2');
  /// ```
  final RegExp? regExp;

  const MarkTextWidget({
    super.key,
    required this.text,
    this.symbol = r'\*',
    required this.onPressed,
    this.styleHighlight,
    this.colorHighlight,
    this.styleNormal,
    this.colorNormal,
    this.padding,
    this.regExp,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final String param = '\\$symbol';
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: highlightAsteriskWords(
        text,
        regExp: regExp ?? RegExp('$param(.*?)$param'),
        textAlign: textAlign,
        styleHighlight: styleHighlight?.copyWith(color: colorHighlight),
        styleNormal: styleNormal?.copyWith(color: colorNormal),
        onPressed: onPressed,
      ),
    );
  }

  factory MarkTextWidget.simple({
    required String text,
    String symbol = '*',
    void Function(String)? onPressed,
    EdgeInsetsGeometry? padding,
    TextStyle? styleHighlight,
    Color? colorHighlight,
    TextStyle? styleNormal,
    Color? colorNormal,
    TextAlign textAlign = TextAlign.start,
    RegExp? regExp,
  }) {
    return MarkTextWidget(
      text: text,
      symbol: symbol,
      onPressed: onPressed ?? (_) {},
      padding: padding,
      styleHighlight: styleHighlight,
      colorHighlight: colorHighlight,
      styleNormal: styleNormal,
      colorNormal: colorNormal,
      textAlign: textAlign,
      regExp: regExp,
    );
  }
}

// ***********************************************************************

class TextWithUrlsRemarks extends StatelessWidget {
  final String text;
  final TextStyle? styleHighlight;
  final TextStyle? styleNormal;
  final void Function(String) onPressed;

  TextWithUrlsRemarks({
    required this.text,
    this.styleHighlight,
    this.styleNormal,
    required this.onPressed,
    super.key,
  });

  // Expresión regular simple para detectar URLs
  final urlRegExp = RegExp(
    r'((https?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w-./?%&=]*)?)',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    int start = 0;

    // Buscar todas las coincidencias de URL en el texto
    for (final match in urlRegExp.allMatches(text)) {
      // Agregar texto normal antes de la URL
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final url = text.substring(match.start, match.end);

      // Agregar texto de la URL con estilo resaltado y acción al pulsar
      spans.add(
        TextSpan(
          text: url,
          style: styleHighlight?.copyWith(decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => onPressed(url),
        ),
      );

      start = match.end;
    }

    // Agregar el texto restante después de la última URL
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(style: styleNormal, children: spans),
    );
  }
}
