import 'dart:io';
import 'dart:math';

import 'package:calculate_swatch/calculate_swatch.dart';

int main(List<String> arguments) {
  if(arguments.isEmpty) {
    stderr.write("No color specified\n");
    return 1;
  }
  final int? forcedShade = arguments.length > 1 ? int.tryParse(arguments[1]) : null;
  try {
    RGBColor rgbColor = RGBColor.fromHex(arguments[0]);
    print("Input color: #${rgbColor.hex}");
    print("RGB values:");
    print(" - red:   ${rgbColor.red}");
    print(" - green: ${rgbColor.green}");
    print(" - blue:  ${rgbColor.blue}");
    HSLColor hslColor = rgbColor.toHSL;
    print("HSL values:");
    print(" - hue:        ${hslColor.hue.toStringAsFixed(0)}");
    print(" - saturation: ${(hslColor.saturation*100.0).toStringAsFixed(2)}%");
    print(" - lightness:  ${(hslColor.lightness*100.0).toStringAsFixed(2)}%");
    if(0.0 == hslColor.lightness || 1.0 == hslColor.lightness) {
      stderr.write("Color lightness cannot be 0.0 (black) or 1.0 (white)");
      return 3;
    }
    print("");
    final int colorShade = forcedShade ?? getClosestValidShade((hslColor.lightness*1000).floor());
    final double gamma = log(hslColor.lightness) / log(colorShade / 1000.0);
    Map<int, RGBColor> shades = {
      for (int shade in getValidShades())
        shade: hslColor.withLightness(pow(shade / 1000.0, gamma).toDouble()).toRGB,
    };
    print("Calculated swatch:");
    for(int shade in shades.keys) {
      print(" - ${shade.toString().padLeft(3)}: #${shades[shade]!.hex}");
    }
  } on InvalidColorError {
    stderr.write("Invalid color\n");
    return 2;
  }
  return 0;
}
