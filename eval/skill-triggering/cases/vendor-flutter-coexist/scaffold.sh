#!/bin/bash
# A Flutter app already on BLoC + feature folders, so the request lands in a real project.
mkdir -p lib/features/auth/presentation/bloc lib/core
cat > pubspec.yaml <<'YAML'
name: shop_app
environment:
  sdk: ">=3.5.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.0.0
  http: ^1.2.0
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^10.0.0
YAML
cat > lib/core/api_client.dart <<'DART'
import 'package:http/http.dart' as http;
class ApiClient {
  ApiClient(this.baseUrl);
  final String baseUrl;
  Future<http.Response> get(String path) => http.get(Uri.parse('$baseUrl$path'));
}
DART
cat > lib/features/auth/presentation/bloc/auth_bloc.dart <<'DART'
import 'package:flutter_bloc/flutter_bloc.dart';
sealed class AuthEvent {}
final class LoginRequested extends AuthEvent {}
sealed class AuthState {}
final class AuthInitial extends AuthState {}
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial());
}
DART
