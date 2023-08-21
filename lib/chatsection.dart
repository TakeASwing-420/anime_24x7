import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_mongo/home_page.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_mongo/dbms_helper.dart';
import 'dart:convert';
import 'dart:math';

class MyWidget extends StatefulWidget {
  final String username;

  const MyWidget({Key? key, required this.username}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _isMusicPlaying = false;
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  TextEditingController _searchController = TextEditingController();
  List<String> _recommendedAnime = [];

  @override
  void initState() {
    super.initState();
    _pauseMusic();
  }

  @override
  void dispose() {
    if (_isMusicPlaying) {
      _resumeMusic();
    }
    super.dispose();
  }

  void _pauseMusic() {
    if (FlameAudio.bgm.isPlaying) {
      setState(() {
        _isMusicPlaying = true;
        FlameAudio.bgm.pause();
      });
    }
  }

  void _resumeMusic() {
    if (_isMusicPlaying) {
      setState(() {
        _isMusicPlaying = false;
        FlameAudio.bgm.resume();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _pauseMusic(); // Pause the music when the widget is built
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to UserDashboardPage when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardPage(
              username: widget.username,
              isMusicPlaying: true,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            backgroundColor: Colors.red,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    _fetchRecommendedAnime(value);
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search for anime recommendations...',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _recommendedAnime.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(_recommendedAnime[index]),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.search),
                    color: Colors.green,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildMessageButton("Messages"),
                  _buildGlowingButton("Forums"),
                  _connectionclosemethod("Connection Settings"),
                ],
              ),
            ),
            Expanded(
              child: Chat(
                messages: _messages,
                onSendPressed: _handleSendPressed,
                user: _user,
                theme: const DefaultChatTheme(
                  inputBackgroundColor: Colors.deepPurpleAccent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingButton(String text) {
    return InkWell(
      onTap: () {
        // Add your button press logic here
      },
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
            fontFamily: "CustomFont",
            color: Colors.amber.withOpacity(0.7),
          ),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton(String text) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _fetchRecommendedAnime(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for anime...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recommendedAnime.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_recommendedAnime[index]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
            fontFamily: "CustomFont",
            color: Colors.amber,
          ),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
        ),
      ),
    );
  }

  Widget _connectionclosemethod(String text) {
    return InkWell(
      onTap: () {
        // Add your button press logic here
      },
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
            fontFamily: "CustomFont",
            color: Colors.amber.withOpacity(0.7),
          ),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
        ),
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _fetchRecommendedAnime(String animeName) async {
    try {
      List<String> recommendations =
          await DBMSHelper.getAnimeRecommendations(animeName);
      print(
          'Recommended Anime List: $recommendations'); // Debug print statement
      setState(() {
        _recommendedAnime = recommendations;
      });
    } catch (e) {
      print('Error fetching recommended anime: $e');
    }
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
