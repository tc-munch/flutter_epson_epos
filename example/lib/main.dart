import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:epson_epos/epson_epos.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<EpsonPrinterModel> printers = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('EPSON ePOS'),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(onPressed: onDiscoveryTCP, child: Text('Discovery TCP')),
                    Flexible(
                        child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        final printer = printers[index];
                        return ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text('${printer.model} | ${printer.series}'),
                          subtitle: Text('${printer.address}'),
                          trailing: TextButton(
                              onPressed: () {
                                //onGetPrinterSetting(printer);
                                //onSetPrinterSetting(printer);
                                onPrintTest(printer);
                              },
                              child: Text('Print Test')),
                        );
                      },
                      itemCount: printers.length,
                      primary: false,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ))
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  buildPrinter() {}

  onDiscoveryTCP() async {
    try {
      List<EpsonPrinterModel>? data = await EpsonEPOS.onDiscovery(type: EpsonEPOSPortType.TCP);
      if (data != null && data.length > 0) {
        data.forEach((element) {
          print(element.toJson());
        });
        setState(() {
          printers = data;
        });
      }
    } catch (e) {
      log("Error: " + e.toString());
    }
  }

  void onGetPrinterSetting(EpsonPrinterModel printer) async {
    try {
      await EpsonEPOS.getPaperWidth(printer);
      await EpsonEPOS.getPrinterSetting(printer);
    } catch (e) {
      log("Error: " + e.toString());
    }
  }

  void onSetPrinterSetting(EpsonPrinterModel printer) async {
    try {
      await EpsonEPOS.setPrinterSetting(printer, paperWidth: 80);
    } catch (e) {
      log("Error: " + e.toString());
    }
  }

  void onPrintTest(EpsonPrinterModel printer) async {
    EpsonEPOSCommand command = EpsonEPOSCommand();
    List<Map<String, dynamic>> commands = [];
    commands.add(command.addTextAlign(EpsonEPOSTextAlign.LEFT));
    commands.add(command.addFeedLine(2));
    commands.add(command.addTextStyle(false, true, true));
    commands.add(command.append('EPSON ePOS Testing\n'));
    commands.add(command.addTextFont(EpsonEPOSFont.FONT_B));
    commands.add(command.addTextStyle(true, false, false));
    commands.add(command.append('FONT B\n'));
    commands.add(command.addPageLine());
    commands.add(command.addPageRectangle());

    commands.add(command.addBarcode("01209457", EpsonEPOSBarcodeType.BARCODE_CODE39, EpsonEPOSHRI.HRI_BELOW, EpsonEPOSFont.FONT_A, 2, 100));
    //commands.add(command.appendBitmap(data, width, height, posX, posY))

    commands.add(command.addFeedLine(2));
    commands.add(command.addCut(EpsonEPOSCut.CUT_FEED));
    await EpsonEPOS.onPrint(printer, commands);
  }
}
