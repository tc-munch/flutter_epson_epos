import 'enums.dart';

class EpsonEPOSCommand {
  String _enumText(dynamic enumName) {
    List<String> ns = enumName.toString().split('.');
    if (ns.length > 0) {
      return ns.last;
    }
    return enumName.toString();
  }

  Map<String, dynamic> append(dynamic data) {
    return {"id": "appendText", "value": data};
  }

  Map<String, dynamic> addFeedLine(dynamic data) {
    return {"id": "addFeedLine", "value": data};
  }

  Map<String, dynamic> addLineSpace(dynamic data) {
    return {"id": "addLineSpace", "value": data};
  }

  Map<String, dynamic> addCut(EpsonEPOSCut data) {
    final cutData = _enumText(data);
    return {"id": "addCut", "value": cutData};
  }

  Map<String, dynamic> addTextSize(int width, int height) {
    return {"id": "addTextSize", "width": width, "height": height};
  }

  /// Use this API at the "beginning of a line." If this API is used elsewhere, it will be ignored.
  ///
  /// Setting of this API is also applied to the barcode/2D symbol/raster image/NV logo.
  ///
  /// When specifying alignment in the page mode, use addPagePosition instead of this API.
  ///
  Map<String, dynamic> addTextAlign(EpsonEPOSTextAlign data) {
    final cutData = _enumText(data);
    return {"id": "addTextAlign", "value": cutData};
  }

  Map<String, dynamic> appendBitmap(dynamic data, int width, int height, int posX, int posY) {
    Map<String, dynamic> cmd = {"id": "addImage", "value": data};
    cmd['width'] = width;
    cmd['height'] = height;
    cmd['posX'] = posX;
    cmd['posY'] = posY;

    return cmd;
  }

  Map<String, dynamic> addTextFont(EpsonEPOSFont font) {
    return {"id": "addTextFont", "value": font.index};
  }

  Map<String, dynamic> addTextStyle(bool reverse, bool underline, bool bold, ) {
    return {"id": "addTextStyle", "value": 0, "reverse": reverse, "underline": underline, "bold": bold};
  }

  Map<String, dynamic> addPageLine() {
    return {"id": "addPageLine", "value": 0};
  }

  Map<String, dynamic> addPageRectangle() {
    return {"id": "addPageRectangle", "value": 0};
  }

  Map<String, dynamic> addBarcode(String data, EpsonEPOSBarcodeType type, EpsonEPOSHRI hri, EpsonEPOSFont font, int width, int height) {
    return {"id": "addBarcode", "value": data, "type": type.index, "hri": hri.index, "font": font.index, "width": width, "height": height};
  }
}
