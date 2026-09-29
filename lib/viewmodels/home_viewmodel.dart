import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class HomeState {
  final bool isLoading;
  final List<ProjectModel> projects;

  HomeState({this.isLoading = false, this.projects = const []});

  HomeState copyWith({bool? isLoading, List<ProjectModel>? projects}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState();
  }

  void loadDummyProjects() {
    state = state.copyWith(isLoading: true);
    
    Future.delayed(const Duration(seconds: 1), () {
      
      // 🔴 DATA: ADD YOUR REAL PROJECTS HERE 🔴
      // Change the title, description, etc. to match your real flutter projects
      final myProjects = [
        ProjectModel(
          title: "Bhagwant Digital News",
          description: "A comprehensive news platform with User and Reporter roles. Users can browse categorized news, while Reporters can directly upload news through the app.",
          imageUrl: "assets/project1.png",
          playStoreLink: "https://play.google.com/store/apps/details?id=com.bhagwantdigital.news",
        ),
        ProjectModel(
          title: "Constroplus",
          description: "A B2B tech marketplace connecting Contractors, Developers, and Consultants in the construction industry for project finalization and registration.",
          imageUrl: "assets/project2.png",
          playStoreLink: "https://play.google.com/store/apps/details?id=com.constroplus.app",
          appStoreLink: "https://apps.apple.com/in/app/constroplus/id6752515455",
        ),
        ProjectModel(
          title: "Kande Pohe",
          description: "A premium matrimony platform designed exclusively for the Marathi community. It features personalized matchmaking, secure profiles, and seamless communication to help users find their perfect life partner.",
          imageUrl: "assets/project3.png",
        ),
        ProjectModel(
          title: "Aaple Lok",
          description: "A comprehensive home services platform offering plumbing, carpentry, and more. Features dedicated roles for Vendors to manage services and Users to book them.",
          imageUrl: "assets/project4.png",
          playStoreLink: "https://play.google.com/store/apps/details?id=com.aaplelok.homeservices",
        ),
      ];
      
      state = state.copyWith(isLoading: false, projects: myProjects);
    });
  }

  Future<bool> sendContactMessage(String name, String email, String message) async {
    const endpoint = "https://formspree.io/f/mrpbrlrd";
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'message': message,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});
