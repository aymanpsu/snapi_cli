import 'package:cli_dialog/cli_dialog.dart';
import 'package:enough_ascii_art/enough_ascii_art.dart' as art;
import 'package:console_bars/console_bars.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// enum RequestType { GET, POST, PUT, DELETE }

// enum AuthType { noAuth, barir, basicAuth }

enum InputType { text, boolean, options }

List<String> restRequestTypes = ['GET', 'POST', 'UPDATE', 'DELETE'];
List<String> restAuthTypes = ['noAuth', 'barir', 'basicAuth'];

void run() async {
  // Show cli signature
  await initTheCli();
  // Ask for end point name
  String endPointName = askFor('end point name', InputType.text);
  // Ask for the base url
  String baseUrl = askFor('base URL', InputType.text);
  // Ask for request type
  String requestType = askFor('request type', InputType.options, restRequestTypes);
  // Ask for end point url
  String endPointUrl = askFor('end point URL', InputType.text);
  // Ask for Authorization
  String authtype = askFor('authorization type', InputType.options, restAuthTypes);
  // call the endpoint amd show result
  await callTheEndpoint(endPointName, baseUrl, endPointUrl, requestType, authtype);
}

Future<void> initTheCli() async {
  var fontText = await File('./fonts/big.flf').readAsString();
  var splashText = art.renderFiglet(
    'SNAPI',
    art.Font.text(fontText),
  );
  var createdBy = art.renderUnicode(
      'v1.0 Created by Ayman Albasha', art.UnicodeFont.doublestruck);
  var mainFeature = art.renderUnicode(
      'Test your REST APIs by using SNAPI cli', art.UnicodeFont.normal);
  print(splashText);
  print(createdBy);
  print(mainFeature);
}

String askFor(String target, InputType type, [List<String>? existOptions]) {
  String inputValue = '';

  switch (type) {
    case InputType.text:
      inputValue = textCliInput('What is the $target?');
      break;
    case InputType.options:
      inputValue = multiChoiceCliInput('What is the $target?', existOptions!);
      break;
    default:
  }
  return inputValue;
}

String textCliInput(String question) {
  // Show text input in the cli
  final dialog = CLI_Dialog(questions: [
    [question, 'name']
  ]);
  // catch user input
  final answer = dialog.ask()['name'];
  return answer;
}

String multiChoiceCliInput(String question, List<String> options) {
  // Show multi choice input in the cli
  final listQuestions = [
    [
      {'question': question, 'options': options},
      'multiAnswers'
    ]
  ];
  // catch user input
  final multiAnswersQuestionDialog = CLI_Dialog(listQuestions: listQuestions);
  final dialog = multiAnswersQuestionDialog.ask();
  final answer = dialog['multiAnswers'];
  return answer;
}

Future<void> callTheEndpoint(String endPointName, String baseUrl,
    String endpointUrl, String type, String authType,
    [String? auth]) async {
  final Stopwatch stopwatch = Stopwatch();

  try {
    stopwatch.start();
    var response = await http.get(Uri.parse(baseUrl + endpointUrl));
    await loadingCliprogress();
    stopwatch.stop();
    if (response.statusCode == 200) {
      displayResult(endPointName, response.reasonPhrase, response.statusCode,
          stopwatch.elapsed.inMilliseconds, response.bodyBytes.length);
    } else {
      throw Exception(
          'Failed to load response!! \nStatus code: ${response.statusCode}');
    }
  } catch (e) {
    print(
        "\n-------------------------------------------\n🎉 Result of test 🎉\nAPI name: $endPointName\nError: $e\n-------------------------------------------");
  }
}

void displayResult(endPointName, requestStatusName, requestStatusNumber,
    responseTime, responseSize) {
  print(
      "\n-------------------------------------------\n🎉 Result of test 🎉\nEndpoint name: $endPointName\nRequest status: 📗 $requestStatusName $requestStatusNumber\nResponse time: $responseTime ms \nResponse size: $responseSize B \n-------------------------------------------");
}

Future<void> loadingCliprogress() async {
  final p = FillingBar(
    desc: "Loading",
    total: 100,
    percentage: true,
    scale: 0.3,
  );
  for (var i = 0; i < 100; i++) {
    p.increment();
    sleep(Duration(milliseconds: 5));
  }
}
