import 'package:chatgpt/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_model.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  List<UserQuery> userQueries = [];
  List<UserQuery> get getUserQueries {
    return userQueries;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String chosenModelId}) async {
    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      chatList.addAll(await ApiService.sendMessageGPT(
        message: msg,
        modelId: chosenModelId,
      ));
    } else {
      chatList.addAll(await ApiService.sendMessage(
        message: msg,
        modelId: chosenModelId,
      ));
    }
    notifyListeners();
  }

  void saveUserQuery(String query, String response) {
    userQueries.add(UserQuery(query: query, response: response));
    notifyListeners();
    saveUserQueriesToStorage();
  }

  void deleteUserQueries() {
    userQueries.clear();
    notifyListeners();
    saveUserQueriesToStorage();
  }

  Future<void> saveUserQueriesToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userQueriesJson =
        userQueries.map((query) => jsonEncode(query.toJson())).toList();
    await prefs.setStringList('userQueries', userQueriesJson);
  }

  Future<void> loadUserQueriesFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? userQueriesJson = prefs.getStringList('userQueries');
    if (userQueriesJson != null) {
      userQueries = userQueriesJson
          .map((json) => UserQuery.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    }
  }
}

class UserQuery {
  final String query;
  final String response;

  UserQuery({required this.query, required this.response});

  factory UserQuery.fromJson(Map<String, dynamic> json) => UserQuery(
        query: json["query"],
        response: json["response"],
      );

  Map<String, dynamic> toJson() => {
        "query": query,
        "response": response,
      };
}
