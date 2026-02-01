import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeguardian_ci_new/core/services/api_service_impl.dart';

// ════════════════════════════════════════════════════════════════════════════
// AUTH BLOC EVENTS
// ════════════════════════════════════════════════════════════════════════════

abstract class AuthEvent {}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;

  AuthRegisterEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  AuthLoginEvent({required this.email, required this.password});
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckTokenEvent extends AuthEvent {}

// ════════════════════════════════════════════════════════════════════════════
// AUTH BLOC STATES
// ════════════════════════════════════════════════════════════════════════════

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final Map<String, dynamic>? user;

  AuthSuccess({required this.message, this.user});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}

class AuthLoggedIn extends AuthState {
  final Map<String, dynamic> user;

  AuthLoggedIn({required this.user});
}

class AuthLoggedOut extends AuthState {}

// ════════════════════════════════════════════════════════════════════════════
// AUTH BLOC
// ════════════════════════════════════════════════════════════════════════════

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService = ApiService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckTokenEvent>(_onCheckToken);
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await apiService.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
      );

      await apiService.saveToken(result['token']);
      emit(AuthLoggedIn(user: result['user']));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    }
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await apiService.login(
        email: event.email,
        password: event.password,
      );

      await apiService.saveToken(result['token']);
      emit(AuthLoggedIn(user: result['user']));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await apiService.logout();
      emit(AuthLoggedOut());
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    }
  }

  Future<void> _onCheckToken(
    AuthCheckTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await apiService.getProfile();
      emit(AuthLoggedIn(user: result['profile']));
    } catch (e) {
      emit(AuthLoggedOut());
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// USAGE EXEMPLE DANS UN SCREEN
// ════════════════════════════════════════════════════════════════════════════

/*

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedIn) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Mot de passe'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLoginEvent(
                        email: emailController.text,
                        password: passwordController.text,
                      ));
                    },
                    child: Text('Connexion'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

*/
