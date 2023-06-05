import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letschat/api/apis.dart';
import 'package:letschat/helpers/my_date_util.dart';
import 'package:letschat/models/chat_user.dart';
import 'package:letschat/models/messages.dart';
import 'package:letschat/widgets/dialogs/profile_dialog.dart';
import '../main.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null--> no change)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: InkWell(
          onTap: () {
            //for navigating to chat screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }
                return ListTile(
                    // user Profile Picture
                    // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(user: widget.user));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.3),
                        child: CachedNetworkImage(
                          width: mq.height *
                              0.055, //also working without width and height
                          height: mq.height * 0.055,
                          imageUrl: widget.user.image,
                          // placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                    ),
                    // username
                    title: Text(widget.user.name),
                    //last message
                    subtitle: Text(
                        _message != null
                            ? _message!.type == Type.image
                                ? 'Image'
                                : _message!.message
                            : widget.user.about,
                        maxLines: 1),

                    // last message time

                    trailing: _message == null
                        ? null //show nothing when no message is sent
                        : _message!.read.isNotEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? //show for unread message
                            Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(30)),
                              )
                            : //message sent time
                            Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: const TextStyle(color: Colors.black54),
                              ));
              })),
    );
  }
}
