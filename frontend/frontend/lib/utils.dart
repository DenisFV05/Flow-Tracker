import 'package:flutter/material.dart';

// Colores de blanco a negro en escala de grises
const primaryColor = Color(0xFFFFFFFF);          // Blanco puro
const canvasColor = Color(0xFFCCCCCC);           // Gris claro
const scaffoldBackgroundColor = Color(0xFF999999); // Gris medio
const accentCanvasColor = Color(0xFF666666);     // Gris oscuro
const white = Color(0xFFFFFFFF);                 // Blanco (para textos)
final actionColor = const Color(0xFF333333).withOpacity(0.6); // Gris muy oscuro con opacidad
final divider = Divider(color: Colors.black.withOpacity(0.2), height: 1); // Divider ligero
const bgIcons = Color(0xFF00B089); // FF = opacidad, 00 = R, B0 = G, 89 = B

// Función para obtener títulos según índice
String getTitleByIndex(int index) {
  switch (index) {
    case 0: return 'Home';
    case 1: return 'Search';
    case 2: return 'People';
    case 3: return 'Favorites';
    case 4: return 'Custom iconWidget';
    case 5: return 'Profile';
    case 6: return 'Settings';
    default: return 'Not found page';
  }
}
