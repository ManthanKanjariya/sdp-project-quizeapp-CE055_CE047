import 'dart:io';
import 'package:flutter/material.dart';
import '../../resources/api_provider.dart';
import '../../models/category.dart';
import '../../models/question.dart';
import 'error.dart';
import '../pages/quizpage/quiz_page.dart';

class QuizOptionsDialog extends StatefulWidget {
  final Category category;

  const QuizOptionsDialog({Key? key, required this.category}) : super(key: key);

  @override
  _QuizOptionsDialogState createState() => _QuizOptionsDialogState();
}

class _QuizOptionsDialogState extends State<QuizOptionsDialog> {
  late int _noOfQuestions;
  late String _difficulty;
  late bool processing;

  @override
  void initState() {
    super.initState();
    _noOfQuestions = 10;
    _difficulty = "easy";
    processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            child: Text(
              widget.category.name,
              style: Theme.of(context).textTheme.headline6!.copyWith(),
            ),
          ),
          SizedBox(height: 10.0),
          Text("Select Total Number of Questions"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 16.0,
              spacing: 16.0,
              children: <Widget>[
                SizedBox(width: 0.0),
                ActionChip(
                  label: Text("10",
                      style: TextStyle(
                          color: _noOfQuestions == 10
                              ? Colors.white
                              : Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  backgroundColor:
                      _noOfQuestions == 10 ? Colors.green : Colors.grey[200],
                  onPressed: () => _selectNumberOfQuestions(10),
                ),

                ActionChip(
                  label: Text("20",
                      style: TextStyle(
                          color: _noOfQuestions == 10
                              ? Colors.white
                              : Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  backgroundColor:
                  _noOfQuestions == 20 ? Colors.green : Colors.grey[200],
                  onPressed: () => _selectNumberOfQuestions(20),
                ),




              ],
            ),
          ),
          SizedBox(height: 20.0),
          Text("Select Difficulty"),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 16.0,
              spacing: 16.0,
              children: <Widget>[
                SizedBox(width: 0.0),

                ActionChip(
                  label: Text("easy",
                      style: TextStyle(
                          color: _difficulty == "easy"
                              ? Colors.white
                              : Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  backgroundColor:
                      _difficulty == "null" ? Colors.green : Colors.grey[200],
                  onPressed: () => _selectDifficulty("null"),
                ),

                ActionChip(
                  label: Text("Hard",
                      style: TextStyle(
                          color: _difficulty == "hard"
                              ? Colors.white
                              : Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  backgroundColor:
                  _difficulty == "hard" ? Colors.green : Colors.grey[200],
                  onPressed: () => _selectDifficulty("hard"),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.0),
          processing
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonTheme(
                    height: 50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minWidth: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      textColor: Colors.white,
                      elevation: 0.0,
                      child: Text("Enter the Quiz",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _startQuiz,
                    ),
                  ),
                ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  _selectNumberOfQuestions(int i) {
    setState(() {
      _noOfQuestions = i;
    });
  }

  _selectDifficulty(String s) {
    setState(() {
      _difficulty = s;
    });
  }

  void _startQuiz() async {
    setState(() {
      processing = true;
    });
    try {
      List<Question> questions =
          await getQuestions(widget.category, _noOfQuestions, _difficulty);
      Navigator.pop(context);
      if (questions.length < 1) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ErrorPage(
                  message:
                      "There are not enough questions in the category, with the options you selected.",
                )));
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => QuizPage(
                    questions: questions,
                    category: widget.category,
                  )));
    } on SocketException catch (_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ErrorPage(
                    message:
                        "Can't reach the servers, \n Please check your internet connection.",
                  )));
    } catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ErrorPage(
                    message: "Unexpected error trying to connect to the API",
                  )));
    }
    setState(() {
      processing = false;
    });
  }
}
