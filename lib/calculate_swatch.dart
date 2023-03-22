import 'dart:math';

import 'package:meta/meta.dart';

@immutable
class RGBColor {

  final int red;
  final int blue;
  final int green;

  const RGBColor({
    required this.red,
    required this.blue,
    required this.green,
  });

  factory RGBColor.fromHex(String hex) {
    if(6 != hex.length) {
      throw InvalidColorError();
    }
    int? red = int.tryParse(hex.substring(0, 2), radix: 16);
    if(null == red) { throw InvalidColorError(); }
    int? green = int.tryParse(hex.substring(2, 4), radix: 16);
    if(null == green) { throw InvalidColorError(); }
    int? blue = int.tryParse(hex.substring(4), radix: 16);
    if(null == blue) { throw InvalidColorError(); }
    return RGBColor(
      red: red,
      green: green,
      blue: blue,
    );
  }

  HSLColor get toHSL {
    final double scaledRed = red / 255.0;
    final double scaledGreen = green / 255.0;
    final double scaledBlue = blue / 255.0;
    final double channelMax = max(max(scaledRed, scaledGreen), scaledBlue);
    final double channelMin = min(min(scaledRed, scaledGreen), scaledBlue);
    final double channelDiff = channelMax - channelMin;
    final double hue = 0.0 == channelDiff ? 0.0 : (
      channelMax == scaledRed ? 60.0 * (((scaledGreen - scaledBlue) / channelDiff) % 6.0) : (
        channelMax == scaledGreen ? 60.0 * ((scaledBlue - scaledRed) / channelDiff + 2.0) :
          60.0 * ((scaledRed - scaledGreen) / channelDiff + 4.0)
      )
    );
    final double lightness = (channelMax + channelMin) / 2;
    final double saturation = (0.0 == channelDiff) ? 0.0 : channelDiff / (1.0 - (2.0*lightness - 1.0).abs());
    return HSLColor(
      hue: hue,
      saturation: saturation,
      lightness: lightness,
    );
  }

  String get hex => "${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}";

}

@immutable
class HSLColor {

  final double hue;
  final double saturation;
  final double lightness;

  const HSLColor({
    required this.hue,
    required this.saturation,
    required this.lightness,
  });

  RGBColor get toRGB {
    final double c = (1.0 - (2.0*lightness - 1.0).abs()) * saturation;
    final double x = c * (1.0 - ((hue / 60.0) % 2.0 - 1.0).abs());
    final double m = lightness - c / 2.0;
    final double scaledRed = hue < 60.0 ? c : (hue < 120.0 ? x : (hue < 240.0 ? 0.0 : (hue < 300.0 ? x : c)));
    final double scaledGreen = hue < 60.0 ? x : (hue < 180.0 ? c : (hue < 240.0 ? x : 0.0));
    final double scaledBlue = hue < 120.0 ? 0.0 : (hue < 180.0 ? x : (hue < 300.0 ? c : x));
    final int red = ((scaledRed + m) * 255.0).round();
    final int green = ((scaledGreen + m) * 255.0).round();
    final int blue = ((scaledBlue + m) * 255.0).round();
    return RGBColor(
      red: red,
      green: green,
      blue: blue,
    );
  }

  HSLColor withHue(double newHue) => HSLColor(
    hue: newHue,
    saturation: saturation,
    lightness: lightness,
  );

  HSLColor withSaturation(double newSaturation) => HSLColor(
    hue: hue,
    saturation: newSaturation,
    lightness: lightness,
  );

  HSLColor withLightness(double newLightness) => HSLColor(
    hue: hue,
    saturation: saturation,
    lightness: newLightness,
  );

}

class InvalidColorError extends Error {}

List<int> getValidShades() => <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

int getClosestValidShade(int shade) {
  final int closestValidShade = getValidShades().reduce((carry, item) => (carry - shade).abs() < (item - shade).abs() ? carry : item);
  return closestValidShade;
}