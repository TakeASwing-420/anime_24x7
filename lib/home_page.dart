import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dbms_helper.dart';
import 'package:flutter_mongo/chatsection.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                labelText: 'User Name',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
                contentPadding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Colors.black,
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
            ),
            SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                  ),
                ),
                contentPadding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
              cursorColor: Colors.black,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String loginResult =
                    await DBMSHelper.loginUser(username, password);
                print(loginResult);

                if (loginResult == "Login successful") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDashboardPage(
                          username: username, isMusicPlaying: true),
                    ),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String username = "";
  String favanime = "";
  String password = "";
  String confirmPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                ),
                onChanged: (value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Favorite Anime',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                ),
                onChanged: (value) {
                  setState(() {
                    favanime = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Confirm Your Password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  String registrationResult = await DBMSHelper.registerUser(
                    username,
                    password,
                    confirmPassword,
                    favanime,
                  );
                  print(registrationResult);

                  if (registrationResult == "Registration successful") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDashboardPage(
                            username: username, isMusicPlaying: true),
                      ),
                    );
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDashboardPage extends StatefulWidget {
  final String username;
  final bool isMusicPlaying;

  UserDashboardPage({
    Key? key,
    required this.username,
    required this.isMusicPlaying,
  }) : super(key: key);

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final List<String> animeImages = [
    'assets/images/639813.jpg',
    'assets/images/peakpx (1).jpg',
    'assets/images/peakpx (2).jpg',
    'assets/images/peakpx.jpg',
    'assets/images/wp1937304-your-name-wallpapers.png',
    'assets/images/peakpx (3).jpg',
  ];
  final int _totalPages = 6;
  final double _scaleFactor = 1.0;

  String _searchAnime = "";
  List<Map<String, dynamic>> _usersWithSimilarAnime = [];

  @override
  void initState() {
    super.initState();
    _searchUsersWithSimilarAnime(); // Initial search
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(fontFamily: 'CustomFont', fontSize: 25),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _logout(context);
            },
            child: Text(
              'LOG OUT',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.red, width: 2.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Search Users with Similar Anime:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search Anime',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchAnime = value;
                          _searchUsersWithSimilarAnime();
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _usersWithSimilarAnime.map((user) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(user['username']),
                                Text(user['favoriteAnime'],
                                    style: TextStyle(
                                        backgroundColor: Colors.yellow)),
                                Container(
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyWidget(
                                              username: user['username']),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.all(2),
                                    ),
                                    child: Text(
                                      'Connect',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          backgroundColor: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
              color: Colors.black,
              child: CarouselSlider.builder(
                itemCount: _totalPages,
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                ),
                itemBuilder: (context, index, _) {
                  return Transform.scale(
                    scale: _scaleFactor,
                    child: Image.asset(
                      animeImages[index],
                      fit: BoxFit.fitWidth,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _searchUsersWithSimilarAnime() async {
    try {
      final users = await DBMSHelper.getUsersWithSimilarFavoriteAnime(
          _searchAnime); // Replace with your actual method
      setState(() {
        _usersWithSimilarAnime = users;
      });
    } catch (e) {
      // Handle error if fetching users fails
      print('Error fetching users: $e');
      setState(() {
        _usersWithSimilarAnime = [];
      });
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
