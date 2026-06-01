import 'package:flutter/material.dart';

class AppColors {
  // ☀️ Pure White Backgrounds for Extreme Outdoor Contrast
  static const Color backgroundStart = Color(
    0xFFFFFFFF,
  ); // بيضاء نقية تماماً لتعكس الشمس
  static const Color backgroundEnd = Color(
    0xFFF1F5F9,
  ); // رمادي خفيف جداً يحدد نهاية الشاشة

  // ⚡ High-Contrast Cyber Accents (Deep & Vibrant for Outdoor)
  static const Color primary = Color(
    0xFF6D28D9,
  ); // Cyber Violet (أعمق وأقوى للرؤية)
  static const Color primaryGlow = Color(
    0x266D28D9,
  ); // جلونج بنسبة 15% عشان يظهر على الأبيض
  static const Color secondary = Color(
    0xFF0369A1,
  ); // Deep Cyan/Teal (تم تغميقه لزيادة التباين)
  static const Color secondaryGlow = Color(0x260369A1);

  // 🏛️ Crisp & Defined Solids (No more fading in sunlight)
  static const Color surface = Color(
    0xFFE2E8F0,
  ); // الأسطح بقت أغمق سنة عشان تفصل عن الخلفية البيضاء
  static const Color surfaceCard = Color(
    0xFFCBD5E1,
  ); // الكروت واضحة ومحددة تماماً

  // 🥛 Enhanced Glassmorphism for Light Mode
  static const Color glassBackground = Color(
    0x14000000,
  ); // زيادة عتامة الزجاج الشفاف ليظهر في الضوء
  static const Color glassBorder = Color(0x33000000); // حدود زجاجية أثقل
  static const Color darkGlassBackground = Color(0x29000000);
  static const Color darkGlassBorder = Color(0x4D000000);

  // ✍️ Max Readability Typography (Carbon Black)
  static const Color textPrimary = Color(
    0xFF020617,
  ); // أسود كربوني شديد الداكنية لأعلى مقياس تباين
  static const Color textSecondary = Color(
    0xFF1E293B,
  ); // رمادي داكن صريح (واضح جداً في الشمس)
  static const Color textTertiary = Color(
    0xFF475569,
  ); // رمادي متوسط للتفاصيل (مفيش نصوص ممسوحة بعد اليوم)

  // 💬 Highly Visible Message Bubbles
  static const Color bubbleDeaf = Color(
    0xFFC7D2FE,
  ); // لافندر مشبع بدرجة كافية للفصل عن الخلفية
  static const Color bubbleHearing = Color(
    0xFFDDD6FE,
  ); // بنفسجي فاتح واضح وحدوده حادة
  static const Color bubbleAiState = Color(
    0xFFA7F3D0,
  ); // خلفية الذكاء الاصطناعي أصبحت أزهى

  // 🚥 Solid Semantic States for Pipeline
  static const Color stateRed = Color(
    0xFFB91C1C,
  ); // أحمر داكن وواضح (Darker Crimson)
  static const Color stateYellow = Color(
    0xFFB45309,
  ); // خردلي/عنبري غامق (يعالج مشكلة اختفاء الأصفر في الشمس)
  static const Color stateGreen = Color(0xFF047857); // أخضر زمردي غني
  static const Color stateBlue = Color(0xFF1D4ED8); // أزرق ملكي نشط جداً

  // ✨ Strong State Glows (Deep background tints)
  static const Color stateRedGlow = Color(0xFFFEE2E2); // وردي فاتح محدد
  static const Color stateYellowGlow = Color(0xFFFEF3C7); // سمنّي واضح
  static const Color stateGreenGlow = Color(0xFFD1FAE5); // تندة خضراء مريحة
  static const Color stateBlueGlow = Color(0xFFDBEAFE); // تندة زرقاء واضحة
}
