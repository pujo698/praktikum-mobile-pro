import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:babbbb/main.dart';

void main() {
  testWidgets('CatatanKu Pro app loads correctly', (WidgetTester tester) async {
    // Jalankan aplikasi
    await tester.pumpWidget(const CatatanKuPro());

    // Pastikan halaman login muncul
    expect(find.text('CatatanKu Pro'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
