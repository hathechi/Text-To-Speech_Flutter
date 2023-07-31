import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final contentController = TextEditingController();
  List listVoice = [
    "banmai (female northern)",
    "lannhi (female southern)",
    'leminh (male northern)',
    "myan (female middle)",
    "thuminh (female northern)",
    "giahuy (male middle)",
    "linhsan (female southern)"
  ];
  String data = "";
  String mp3 = "";
  final player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  void initState() {
    super.initState();
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  void callApi({String? text, String? voice}) async {
    setState(() {
      mp3 = "";
    });
    var url = Uri.parse(dotenv.env['URL_API']!);
    var headers = {
      'api-key': dotenv.env['API_KEY']!,
      'speed': '',
      'voice': voice!.split(" ")[0]
    };
    var body = text;

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Yêu cầu thành công
      print('Response body: ${response.body}');
      var a = jsonDecode(response.body);
      print(a["async"]);

      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          if (!a["async"].isEmpty) {
            isLoading = false;
            mp3 = a["async"];
          }
        });
      });
      // Phát tệp âm thanh từ bộ nhớ tạm
    } else {
      // Xử lý lỗi
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: isLoading
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: Image.asset(
                          'assets/images/logo.png',
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 236, 236, 236),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: TextFormField(
                          maxLength: 500,
                          maxLines: 5,
                          controller: contentController,
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                              onTap: () {
                                contentController.text = "";
                              },
                              child: const Icon(Icons.delete_forever),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            hintText: "Content...",
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 22, top: 14),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 233, 233, 233),
                        ),
                        child: DropdownButton(
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          value: data.isEmpty ? listVoice[0] : data,
                          items: listVoice.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              data = value.toString();
                              print("Get Voice $data");
                            });
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 56,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.resolveWith<
                                OutlinedBorder>((_) {
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              );
                            }),
                            elevation: const MaterialStatePropertyAll(3),
                            backgroundColor: const MaterialStatePropertyAll(
                                Color.fromARGB(255, 7, 102, 255)),
                          ),
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            callApi(text: contentController.text, voice: data);
                          },
                          child: Text(
                            "Convert".toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: mp3 != "" ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              // ElevatedButton(
                              //   onPressed: () {
                              //     player.play(
                              //       UrlSource(mp3),
                              //     );
                              //   },
                              //   child: const Text('Play Audio'),
                              // ),
                              // ElevatedButton(
                              //     onPressed: () {
                              //       player.stop();
                              //     },
                              //     child: const Text('Stop Audio')),
                              // ElevatedButton(
                              //     onPressed: () {
                              //       player.pause();
                              //     },
                              //     child: const Text('Pause ')),
                              // ElevatedButton(
                              //     onPressed: () {
                              //       player.resume();
                              //     },
                              //     child: const Text('Resume')),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    child: IconButton(
                                      icon: Icon(
                                        isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      onPressed: () {
                                        if (isPlaying) {
                                          player.pause();
                                        } else {
                                          player.play(UrlSource(mp3));
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  CircleAvatar(
                                    radius: 25,
                                    child: IconButton(
                                      icon: const Icon(Icons.stop),
                                      onPressed: () {
                                        player.stop();
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  CircleAvatar(
                                    radius: 25,
                                    child: IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () async {
                                        final Uri _url = Uri.parse(mp3);
                                        await launchUrl(_url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                min: 0,
                                max: duration.inSeconds.toDouble(),
                                value: position.inSeconds.toDouble(),
                                onChanged: (value) {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  player.seek(position);
                                  player.resume();
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formatTime(position.inSeconds)),
                                    Text(formatTime(
                                        (duration - position).inSeconds)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
