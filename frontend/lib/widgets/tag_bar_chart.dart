import 'package:flutter/material.dart';

/// CustomPainter per dibuixar un gràfic de barres amb les etiquetes seleccionades.
/// Cada etiqueta té un color únic que es mostra tant a la barra com a la llista lateral.
class TagBarChartPainter extends CustomPainter {
  final Map<String, int> tagData; // tag -> count
  final Map<String, Color> tagColors; // tag -> color
  final Set<String> selectedTags;

  TagBarChartPainter({
    required this.tagData,
    required this.tagColors,
    required this.selectedTags,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedTags.isEmpty) {
      // Dibuixar missatge "Selecciona etiquetes"
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Selecciona etiquetes de la barra lateral',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
      return;
    }

    final filteredData = <String, int>{};
    for (final tag in selectedTags) {
      if (tagData.containsKey(tag)) {
        filteredData[tag] = tagData[tag]!;
      }
    }

    if (filteredData.isEmpty) return;

    final maxCount = filteredData.values.reduce((a, b) => a > b ? a : b);
    final barCount = filteredData.length;

    // Marges
    const leftMargin = 50.0;
    const bottomMargin = 80.0;
    const topMargin = 20.0;
    const rightMargin = 20.0;

    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    // Dibuixar eixos
    final axisPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2;

    // Eix Y
    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(leftMargin, size.height - bottomMargin),
      axisPaint,
    );

    // Eix X
    canvas.drawLine(
      Offset(leftMargin, size.height - bottomMargin),
      Offset(size.width - rightMargin, size.height - bottomMargin),
      axisPaint,
    );

    // Dibuixar línies de referència (gridlines)
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 5; i++) {
      final y = topMargin + chartHeight * (1 - i / 5);
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width - rightMargin, y),
        gridPaint,
      );

      // Etiqueta Y
      final label = (maxCount * i / 5).round().toString();
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 8, y - tp.height / 2));
    }

    // Dibuixar barres
    final barWidth = (chartWidth / barCount) * 0.6;
    final barSpacing = chartWidth / barCount;

    int index = 0;
    filteredData.forEach((tag, count) {
      final barHeight = maxCount > 0 ? (count / maxCount) * chartHeight : 0.0;
      final x = leftMargin + index * barSpacing + (barSpacing - barWidth) / 2;
      final y = topMargin + chartHeight - barHeight;

      final color = tagColors[tag] ?? Colors.blue;

      // Ombra de la barra
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2, y + 2, barWidth, barHeight),
          const Radius.circular(6),
        ),
        shadowPaint,
      );

      // Gradient de la barra
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withOpacity(0.7)],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(6),
        ),
        barPaint,
      );

      // Valor a sobre de la barra
      final valuePainter = TextPainter(
        text: TextSpan(
          text: count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(x + (barWidth - valuePainter.width) / 2, y - valuePainter.height - 4),
      );

      // Nom del tag a sota de la barra (rotat)
      final tagPainter = TextPainter(
        text: TextSpan(
          text: tag,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      tagPainter.layout();

      canvas.save();
      final tagX = x + barWidth / 2;
      final tagY = size.height - bottomMargin + 8;
      canvas.translate(tagX, tagY);
      canvas.rotate(0.5); // Rotar lleugerament
      tagPainter.paint(canvas, Offset.zero);
      canvas.restore();

      index++;
    });
  }

  @override
  bool shouldRepaint(covariant TagBarChartPainter oldDelegate) {
    return oldDelegate.selectedTags != selectedTags ||
        oldDelegate.tagData != tagData;
  }
}
