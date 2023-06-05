import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:letschat/models/chat_user.dart';
import 'package:letschat/models/messages.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing firestore cloud database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

// varible for storing the currnet user info
  static late ChatUser me;

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase Messaging Token

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) => {
          if (t != null) {me.pushToken = t},
          log("PushToken: $t")
        });

    // for handling FOREGROUND MESSAGES
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notifications
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        // "data": {
        //   "some_data": "User ID : ${me.id}",
        // },
      };

      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'applicaton/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAistiFqw:APA91bGCEPl6gYVDSTZVzqztpbiIFYzITeF7HM1K2uk-8gYd57K5OCeb2V56k1cpaD3u2et-PL6vhquX5ak8sfgulMQybTD3Buk3Tz8Db2VhQhrxKu1e6m5tNbhuRvC4lfrQ3pPUumG4',
              },
              body: jsonEncode(body));
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log("\nsendPushNotificatoinE: $e");
    }
  }

  // checking if a user exists
  static Future<bool> userExits() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding a chat user to our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('data: ${data.docs}');
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //  if user exists

      log('user exists: ${data.docs.first.data()}');
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      // if user doesnot exists
      return false;
    }
  }

  // for getting the current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        // for setting user status to active
        APIs.updateActiveStatus(true);
        log("My Data: ${user.data()}");
      } else {
        await createUer().then(
          (value) => getSelfInfo(),
        );
      }
    });
  }

  // if user does not exists
  static Future<void> createUer() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey iam using Lets Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore databases
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

// for getting all users form firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\n UsesIds: $userIds');
    return firestore
        .collection('users')
        // .where('id', isNotEqualTo: user.uid)
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        .snapshots();
  }

  // for adding an user to my users when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatuser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_user')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatuser, msg, type));
  }

  // for  updating the informations
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // for updating the user profile picture
  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log("Extension: $ext");
    // storage file ref   with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) => {
              log("Data Transferred: ${p0.bytesTransferred / 1000} Kb"),
            });
    // updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

// update online or last active status

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  // ******************Chat Screen Related APIs*******************//

  // chats(collection)--->conversation_id(doc)-->messages(collection)-->messages(doc)

  // useful for getting  conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${(user.uid)}_$id'
      : '${id}_${user.uid}';

  // for getting the messages of all the specific conversation from the firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending the message
  static Future<void> sendMessage(
      ChatUser chatuser, String msg, Type type) async {
    // message sending time also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        fromId: user.uid,
        read: '',
        toId: chatuser.id,
        message: msg,
        type: type,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatuser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatuser, type == Type.text ? msg : 'image'));
  }

  //update read status  of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only  last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log("Extension: $ext");
    // storage file ref   with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) => {
              log("Data Transferred: ${p0.bytesTransferred / 1000} Kb"),
            });
    // updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

// delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    // if its image
    if (message.type == Type.image) {
      await storage.refFromURL(message.message).delete();
    }
  }

  // update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'message': updatedMsg});
  }
}
