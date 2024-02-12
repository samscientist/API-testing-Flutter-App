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

class _PostRequestFormState extends State<PostRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController(text: 'https://...');
  final _bodyController = TextEditingController(text: '{\n    "contexts": [\n        "겨울"\n    ]\n}');
  String? _responseBody;
  bool _applyFormat = false;
  bool _isLoading = false;

  Future<void> _sendPostRequest(String url, String body) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      setState(() {
        _responseBody = response.body;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
            ),
            validator: (value) {
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
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
              scrollPhysics: const ScrollPhysics(), 
            ),
          ),

          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _sendPostRequest(_urlController.text, _bodyController.text);
              }
            },
            child: const Text('Send POST Request'),
          ),
          if (_isLoading)
            const CircularProgressIndicator(),
          if (_responseBody != null)
            SwitchListTile(
              title: const Text('Apply Format'),
              value: _applyFormat,
              onChanged: (bool value) {
                setState(() {
                  _applyFormat = value;
                });
              },
            ),
          if (_responseBody != null)
            Expanded(
              child: SingleChildScrollView(
                child: _applyFormat
                  ? Text(_responseBody!.replaceAll("\\n", "\n"))
                  : Text(_responseBody!),
              ),
            ),
        ],
      ),
    );
  }
}
