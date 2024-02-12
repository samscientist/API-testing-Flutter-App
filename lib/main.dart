import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('API Post Request'),
        ),
        body: const Center(
          child: PostRequestForm(),
        ),
      ),
    );
  }
}

class PostRequestForm extends StatefulWidget {
  const PostRequestForm({super.key});

  @override
  _PostRequestFormState createState() => _PostRequestFormState();
}

class _PostRequestFormState extends State<PostRequestForm> { // _PostRequestFormState는 PostRequestForm의 상태 표현
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController(text: 'https://...'); // URL을 입력받기 위한 컨트롤러
  final _bodyController = TextEditingController(text: '{\n    "contexts": [\n        "겨울"\n    ]\n}'); // HTTP 요청 본문을 입력받기 위한 컨트롤러
  String? _responseBody; // HTTP 응답 본문을 저장할 변수
  bool _applyFormat = false; // 응답 본문을 서식에 맞게 표시할지 여부 결정하는 플래그
  bool _isLoading = false; // HTTP 요청이 실행 중인지 여부 나타내는 플래그

  Future<void> _sendPostRequest(String url, String body) async { // HTTP POST 요청 송신 및 응답 수신 메소드
    setState(() { // 상태 변경
      _isLoading = true; // 로딩 상태 시작
    });
    try {
      final response = await http.post( // HTTP POST 요청 송신 및 응답 수신
        Uri.parse(url), // URL을 파싱
        headers: {"Content-Type": "application/json"}, // 헤더 설정
        body: body, // 요청 본문 설정
      );
      setState(() { // 상태 변경
        _responseBody = response.body; // 응답 본문 저장
      });
    } catch (e) { // 예외 처리
      showDialog( // 대화 상자 표시
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'), // 대화 상자의 제목 설정
          content: Text('An error occurred: $e'), // 대화 상자의 내용 설정
        ),
      );
    } finally {
      setState(() { // 상태 변경
        _isLoading = false; // 로딩 상태 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) { /// build 메소드에서는 위젯의 UI 정의
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[ // 여러 자식 위젯 배열
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
            ),
            validator: (value) { // 유효성 검사
              if (value == null || value.isEmpty) {
                return 'Please enter a URL';
              }
              return null;
            },
          ),

          SizedBox(
            height: 200,
            child: TextField(
              controller: _bodyController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'to Send',
                border: OutlineInputBorder(), // 외곽선 설정
              ),
              style: const TextStyle(fontSize: 18), // 텍스트 스타일 설정
              scrollPhysics: const ScrollPhysics(), 
            ),
          ),

          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) { // 폼의 유효성 검사
                _sendPostRequest(_urlController.text, _bodyController.text); // HTTP POST 요청 메소드 호출
              }
            },
            child: const Text('Send POST Request'), // 버튼의 텍스트 설정
          ),
          if (_isLoading)
            const CircularProgressIndicator(), // 로딩 중일 경우 진행 표시기 표시
          if (_responseBody != null)
            SwitchListTile(
              title: const Text('Apply Format'), // 레이블 텍스트 설정
              value: _applyFormat,
              onChanged: (bool value) {
                setState(() { // 상태 변경
                  _applyFormat = value; // 서식 적용 여부 변경
                });
              },
            ),
          if (_responseBody != null)
            Expanded(
              child: SingleChildScrollView(
                child: _applyFormat
                  ? Text(_responseBody!.replaceAll("\\n", "\n")) // 서식을 적용하여 응답 본문 표시
                  : Text(_responseBody!), // 응답 본문 표시
              ),
            ),
        ],
      ),
    );
  }
}
