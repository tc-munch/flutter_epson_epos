import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

import 'enums.dart';
import 'helpers.dart';
import 'models.dart';

class EpsonEPOS {
  static const MethodChannel _channel = const MethodChannel('epson_epos');

  static EpsonEPOSHelper _eposHelper = EpsonEPOSHelper();

  static bool _isPrinterPlatformSupport({bool throwError = false}) {
    if (Platform.isAndroid) return true;
    if (throwError) {
      throw PlatformException(code: "platformNotSupported", message: "Device not supported");
    }
    return false;
  }

  static Future<List<EpsonPrinterModel>?> onDiscovery({EpsonEPOSPortType type = EpsonEPOSPortType.ALL}) async {
    if (!_isPrinterPlatformSupport(throwError: true)) return null;
    String printType = _eposHelper.getPortType(type);
    final Map<String, dynamic> params = {"type": printType};
    String? rep = await _channel.invokeMethod('onDiscovery', params);
    if (rep != null) {
      try {
        final response = EpsonPrinterResponse.fromRawJson(rep);
        List<dynamic> prs = response.content;
        if (prs.length > 0) {
          return prs.map((e) {
            final modelName = e['model'];
            final modelSeries = _eposHelper.getSeries(modelName);
            return EpsonPrinterModel(address: e['address'], type: printType, model: modelName, series: modelSeries?.id);
          }).toList();
        }
      } catch (e) {
        throw e;
      }
    }
    return [];
  }

  static Future<dynamic> onPrint(EpsonPrinterModel printer, List<Map<String, dynamic>> commands) async {
    final Map<String, dynamic> params = {"address": printer.address, "type": printer.type, "series": printer.series, "commands": commands};
    return await _channel.invokeMethod('onPrint', params);
  }

  static Future<int> getPaperWidth(EpsonPrinterModel printer) async {
    final Map<String, dynamic> params = {"address": printer.address, "type": printer.type, "series": printer.series};
    String rep = await _channel.invokeMethod('getPaperWidth', params);
    final response = EpsonPrinterResponse.fromRawJson(rep);
    if (!response.success) {
      throw Exception(response.message);
    }
    return response.content;
  }

  static Future<dynamic> getPrinterSetting(EpsonPrinterModel printer) async {
    final Map<String, dynamic> params = {"address": printer.address, "type": printer.type, "series": printer.series};
    return await _channel.invokeMethod('getPrinterSetting', params);
  }

  static Future<dynamic> setPrinterSetting(EpsonPrinterModel printer, {int? paperWidth, int? printDensity, int? printSpeed}) async {
    final Map<String, dynamic> params = {
      "address": printer.address,
      "type": printer.type,
      "series": printer.series,
      "paper_width": paperWidth,
      "print_density": printDensity,
      "print_speed": printSpeed
    };
    return await _channel.invokeMethod('setPrinterSetting', params);
  }
}
