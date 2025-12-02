import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'Pixel.dart';
import 'Player.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MazeRace(), // your widget
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [
          Text('A random good idea:'),
          Text(appState.current.asLowerCase),
          
          ElevatedButton(
            onPressed: () {
              print('button pressed!');
            },
            child: Text('Next'),
          ),

          ],


      ),
    );
  }
}

class MazeRace extends StatefulWidget {
  @override
  State<MazeRace> createState() => _MazeRaceState();
}

class _MazeRaceState extends State<MazeRace> {
  //Variables used for the grid
  static int numberInRow = 11;
  int numberOfSquares = numberInRow * 15;

  List<int> barriers = [
    0, 1, 2, 3, 4, 5, 6, 7, 9, 10,
    11, 20, 21,
    22, 24, 25, 26, 27, 28, 29, 30, 31, 32,
    33, 38, 43,
    44, 45, 46, 47, 49, 51, 52, 53, 54,
    55, 60, 65,
    66, 68, 69, 70, 71, 72, 73, 74, 76,
    77, 87,
    88, 89, 90, 91, 92, 94, 96, 98,
    99, 105, 107, 109,
    110, 112, 113, 114, 115, 116, 120,
    121, 123, 124, 125, 126, 127, 128, 129, 131,
    132, 142,
    143, 144, 145, 146, 147, 148, 150, 151, 152, 153,
    154, 164,
    165, 167, 168, 170, 171, 172, 173, 175,
    176, 179, 186,
    187, 188, 190, 191, 192, 193, 194, 195, 196, 197
  ];

  int playerPosition = numberInRow * 14 + 1;
  int winPosition = 8;

  String direction = "left";
  bool playerWins = false;

  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  //Movement Timer
  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (direction == "stopped") return;

      setState(() {
        stopwatch.start();
        moveFromDirection();
      });
    });
  }

  void moveFromDirection() {
    switch (direction) {
      case "left": moveLeft(); break;
      case "right": moveRight(); break;
      case "up": moveUp(); break;
      case "down": moveDown(); break;
    }
  }

  void moveLeft() {
    if (!barriers.contains(playerPosition - 1) && playerPosition % numberInRow != 0) {
      playerPosition--;
    }
  }

  void moveRight() {
    if (!barriers.contains(playerPosition + 1) &&
        (playerPosition + 1) % numberInRow != 0) {
      playerPosition++;
    }
  }

  void moveUp() {
    if (!barriers.contains(playerPosition - numberInRow) &&
        playerPosition - numberInRow >= 0) {
      playerPosition -= numberInRow;
    }
  }

  void moveDown() {
    if (!barriers.contains(playerPosition + numberInRow) &&
        playerPosition + numberInRow < numberOfSquares) {
      playerPosition += numberInRow;
    }
  }

  String formattedTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void showAlertDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          backgroundColor: Color.fromRGBO(255, 247, 212, 1),
          title: Text(
            "Are you sure you want to start new game?",
            style: TextStyle(color: Color.fromRGBO(238, 199, 89, 1), fontSize: 20),
          ),
          actions: [
            TextButton(
              child: Text("Yes",
                  style: TextStyle(color: Color.fromRGBO(238, 199, 89, 1), fontSize: 20)),
              onPressed: () {
                setState(() {
                  playerPosition = 155;
                  direction = "left";
                  playerWins = false;
                  stopwatch.reset();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("No",
                  style: TextStyle(color: Color.fromRGBO(238, 199, 89, 1), fontSize: 20)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void showWinDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // player must tap button
    builder: (context) {
      return AlertDialog(
        title: Text("Congrats!"),
        content: Text("You won the game! Your time is ${formattedTime(stopwatch.elapsed)}"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                  playerPosition = 155;
                  direction = "left";
                  playerWins = false;
                  stopwatch.reset();
                });
                Navigator.of(context).pop();
            },
            child: Text("New Game"),
          ),
        ],
      );
    },
  );
}

  //UI -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromRGBO(255, 247, 212, 1),
        appBar: AppBar(
          title: Text('Maze Race'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(238, 199, 89, 1),
        ),
        body: Column(
          children: [
            // MAZE GRID ----------------------------------------------------
            Expanded(
              flex: 5,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberInRow),
                itemBuilder: (context, index) {
                  //Win condition
                  if (index == playerPosition && index == winPosition) {
                    direction = "stopped";
                    stopwatch.stop();
                    playerWins = true;

                    // Show dialog AFTER the frame is rendered
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showWinDialog(context);
                    });

                    return Image.asset('assets/images/mouse-winner.jpg');
                  }

                  //Cheese
                  if (index == winPosition) {
                    return Image.asset('assets/images/cheese.jpg');
                  }

                  //Player
                  if (index == playerPosition) {
                    switch (direction) {
                      case "right":
                        return Transform.flip(flipX: true, child: Player());
                      case "left":
                        return Player();
                      case "down":
                        return Transform.rotate(angle: 3 * pi / 2, child: Player());
                      case "up":
                        return Transform.rotate(angle: pi / 2, child: Player());
                      default:
                        return Player();
                    }
                  }

                  //Barriers
                  if (barriers.contains(index)) {
                    return Pixel(color: Color.fromRGBO(155, 184, 205, 1));
                  }

                  //Path
                  return Pixel(color: Color.fromRGBO(177, 195, 129, 1));
                },
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  
                    // LEFT SIDE: time + new game button
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Time: ${formattedTime(stopwatch.elapsed)}",
                          style: TextStyle(
                            color: Color.fromRGBO(238, 199, 89, 1),
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () => showAlertDialog(context),
                          child: Text(
                            "New game",
                            style: TextStyle(
                              color: Color.fromRGBO(238, 199, 89, 1),
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // RIGHT SIDE: direction buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Give direction:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(238, 199, 89, 1), 
                          ),
                        ),

                        SizedBox(height: 10), // spacing between text and buttons
    
                        IconButton(
                          iconSize: 40,
                          icon: Icon(Icons.keyboard_arrow_up),
                          onPressed: () => setState(() => direction = "up"),
                        ),
                        Row(
                          children: [
                            IconButton(
                              iconSize: 40,
                              icon: Icon(Icons.keyboard_arrow_left),
                              onPressed: () => setState(() => direction = "left"),
                            ),
                            IconButton(
                              iconSize: 40,
                              icon: Icon(Icons.keyboard_arrow_right),
                              onPressed: () => setState(() => direction = "right"),
                            ),
                          ],
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: Icon(Icons.keyboard_arrow_down),
                          onPressed: () => setState(() => direction = "down"),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ],
        ))
    );
  }
}
