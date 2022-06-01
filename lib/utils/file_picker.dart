import 'dart:io';

import "package:file_picker/file_picker.dart";

class CustomFilePicker {
  File? currentFile;
  String get filepath => currentFile!.path;

  Future<String>? get content async => await currentFile!.readAsString();

  open() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ["md", "txt", "html"]);

    if (result != null) {
      currentFile = File(result.files.single.path!);
    }
  }

  save(content) async {
    if (await currentFile!.exists()) {
      await currentFile!.writeAsString(content.toString());
    }
  }

  close() async {
    if (await currentFile!.exists()) {
      currentFile = null;
    }
  }

  saveAs(String content) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'file.md',
    );

    currentFile = File(outputFile!);

    await currentFile!.writeAsString(content);

    // User canceled the picker
  }
}
