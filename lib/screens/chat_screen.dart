import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/api/apis.dart';
import 'package:letschat/helpers/my_date_util.dart';
import 'package:letschat/screens/view_profile_screen.dart';

import '../main.dart';
import '../models/chat_user.dart';
import '../models/messages.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  // for handling messages text changes
  final _textController = TextEditingController();

  // for showing or hiding emojis
  bool _showEmojis = false;
  // for uploading multiple photos
  bool _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // remove keyborad on tapp
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          // if emojis is on on & back button is pressed close the emojis
          // or simple close the screen on back button
          onWillPop: () {
            if (_showEmojis) {
              setState(() {
                _showEmojis = !_showEmojis;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            // app Bar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 200, 219, 235),
            body: Column(children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    // using swithc case to check whether data have loaded or not
                    switch (snapshot.connectionState) {
                      // if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      // if some or all of the data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              // padding: EdgeInsets.only(top: mq.height * 0.05),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              });
                        } else {
                          return const Center(
                              child: Text("Say Hii 👋",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black87)));
                        }
                    }
                  },
                ),
              ),

              // circular progess indicator while multiple image in uplaoding

              if (_isUploading)
                const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))),
              // chat input field
              _chatInput(),

              // show emojis on keyboard button click or viceversa
              if (_showEmojis)
                SizedBox(
                  height: mq.height * 0.35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor: const Color.fromARGB(255, 200, 219, 235),
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                )
            ]),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  // back button
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.black87)),
                  // user  profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.3),
                    child: CachedNetworkImage(
                      width: mq.height *
                          0.05, //also working without width and height
                      height: mq.height * 0.05,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  // for adding some space
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // username
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      // for adding some space
                      const SizedBox(height: 2),

                      // last seen time of user
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  )
                ],
              );
            }));
  }

  // bottom chart input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.02),
      child: Row(children: [
        // input text and buttons
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              // emoji button
              IconButton(
                  onPressed: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      _showEmojis = !_showEmojis;
                    });
                  },
                  icon: const Icon(Icons.emoji_emotions,
                      color: Colors.blue, size: 26)),

              // for writing the message
              Expanded(
                  child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onTap: () {
                  if (_showEmojis) setState(() => _showEmojis = !_showEmojis);
                },
                decoration: const InputDecoration(
                    hintText: "Type Something.....",
                    hintStyle: TextStyle(color: Colors.blue),
                    border: InputBorder.none),
              )),
              // pick image from gallery button
              IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick multiple images.
                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);

                    // uploading & sending images one by one
                    for (var i in images) {
                      log("image path ${i.path}");
                      setState(() => _isUploading = true);
                      await APIs.sendChatImage(widget.user, File(i.path));
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.image, color: Colors.blue, size: 26)),
              // pick  image from camera button
              IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      log("image path ${image.path}");
                      setState(() => _isUploading = true);
                      await APIs.sendChatImage(widget.user, File(image.path));
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_rounded,
                      color: Colors.blue, size: 26)),

              // for adding some space
              SizedBox(width: mq.width * 0.02),
            ]),
          ),
        ),

        // send message button
        MaterialButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              if (_list.isEmpty) {
                // on first message (add user to my_user collection of chat user)
                APIs.sendFirstMessage(
                    widget.user, _textController.text, Type.text);
              } else {
                // simply send message
                APIs.sendMessage(widget.user, _textController.text, Type.text);
              }
              _textController.text = '';
            }
          },
          color: Colors.green,
          shape: const CircleBorder(),
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
          minWidth: 0,
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
        )
      ]),
    );
  }
}
