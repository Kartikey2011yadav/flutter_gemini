import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GenerativeModel model;
  late final ChatSession chatSession;
  final FocusNode textFieldFocus = FocusNode();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: const String.fromEnvironment('api_key'));
    chatSession = model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Gemini"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        color: const Color.fromRGBO(5, 14, 37, 1.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: chatSession.history.length,
                    itemBuilder: (context, index) {
                      final Content content = chatSession.history.toList()[index];
                      final text = content.parts
                          .whereType<TextPart>()
                          .map<String>((e) => e.text)
                          .join('');
                      return MessageWidget(
                        text: text,
                        isFromUser: content.role == 'user',
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        focusNode: textFieldFocus,
                        decoration: textFieldDecoration(),
                        controller: textController,
                        onSubmitted: (String value){
                          sendChatMessage(value);
                        },
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (!loading)
                      Container(
                        padding: const EdgeInsets.only(left: 5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightBlueAccent
                        ),
                        child: IconButton(
                          // padding: const EdgeInsets.only(left: 5),
                          onPressed: () async {
                            sendChatMessage(textController.text);
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: const CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                          color: Color.fromRGBO(5, 14, 37, 1.0),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
        contentPadding: const EdgeInsets.all(15),
        hintText: 'Enter prompt...',
        hintStyle: const TextStyle(
          color: Colors.white,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            )
        )
    );
  }

  Future<void> sendChatMessage(String message) async {
    setState(() {
      loading = true;
    });

    try {

      final response = await chatSession.sendMessage(
        Content.text(message),
      );
      final text = response.text;
      if (text == null) {
        showError('No response from API');
        return;
      } else {
        setState(() {
          loading = false;
          scrollDown();
        });
      }
    } catch (e) {
      showError(e.toString());
      setState(() {
        loading = false;
      });
    } finally {
      textController.clear();
      setState(() {
        loading = false;
      });
      textFieldFocus.requestFocus();
    }
  }

  void scrollDown() {
    WidgetsBinding.instance
        .addPostFrameCallback(
            (_) => scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(
                milliseconds: 750,
              ),
              curve: Curves.easeOutCirc,
            ));
  }

  void showError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Something went Wrong'),
            content: SingleChildScrollView(
              child: SelectableText(message),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }
}
