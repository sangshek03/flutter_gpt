import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final _openAI = OpenAI.instance.build(
      token: "api_token",
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  final ChatUser current_user =
      ChatUser(id: "1", firstName: "Abhishek", lastName: "Verma");

  final ChatUser gpt_user =
      ChatUser(id: "2", firstName: "chat", lastName: "gpt");

  List<ChatMessage> message_list = <ChatMessage>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 42, 43, 42),
        title: const Text(
          'chatGpt',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: DashChat(
          messageOptions: const MessageOptions(
              currentUserContainerColor: Color.fromARGB(255, 31, 33, 31)),
          currentUser: current_user,
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: message_list),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      message_list.insert(0, m);
    });

    List<Messages> messageHistory = message_list.reversed.map((m) {
      if (m.user == current_user) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();

    final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: messageHistory,
        maxToken: 200);

    final response = await _openAI.onChatCompletion(request: request);

    for (var elment in response!.choices) {
      if (elment.message != null) {
        setState(() {
          message_list.insert(
              0,
              ChatMessage(
                  user: gpt_user,
                  createdAt: DateTime.now(),
                  text: elment.message!.content));
        });
      }
    }
  }
}
