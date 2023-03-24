import 'dart:io';
import 'dart:math';

import 'package:calculate_swatch/calculate_swatch.dart';

int main(List<String> arguments) {
  if(arguments.isEmpty) {
    stderr.write("No color specified\n");
    return 1;
  }
  final int? forcedShade = arguments.length > 1 ? int.tryParse(arguments[1]) : null;
  if(null != forcedShade && !getValidShades().contains(forcedShade)) {
    stderr.write("Invalid shade $forcedShade.\nValid values:\n${getValidShades().map((shade) => " - $shade").join("\n")}\n");
    return 4;
  }
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
      stderr.write("Color lightness cannot be 0.0 (black) or 1.0 (white)\n");
      return 3;
    }
    print("");
    final int colorShade = forcedShade ?? getClosestValidShade(((1.0 - hslColor.lightness) * 1000.0).floor());
    final double gamma = log(hslColor.lightness) / log((1000.0 - colorShade) / 1000.0);
    Map<int, HSLColor> shades = {
      for (int shade in getValidShades())
        shade: hslColor.withLightness(pow((1000.0 - shade) / 1000.0, gamma).toDouble()),
    };
    print("Calculated swatch:");
    for(int shade in shades.keys) {
      print(" - ${shade.toString().padLeft(3)}: #${shades[shade]!.toRGB.hex} (lightness: ${(shades[shade]!.lightness*100).toStringAsFixed(2).padLeft(5)}%)");
    }
  } on InvalidColorError {
    stderr.write("Invalid color\n");
    return 2;
  }
  return 0;
}
