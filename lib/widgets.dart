import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontStyle? style;
  final Color color;
  final int? maxlines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  const MyText(
      {required this.text,
      required this.fontSize,
      required this.color,
      this.style,
      this.textAlign,
      this.overflow,
      this.fontWeight,
      this.maxlines,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxlines,
      textAlign: textAlign,
      style: GoogleFonts.urbanist(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          fontStyle: style),
    );
  }
}
