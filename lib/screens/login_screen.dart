import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  // Declarar las variables del cerebro de la animación
  StateMachineController? _controller;
  // State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  SMINumber? _numLook;

  Timer? _typingDebounce;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Agregar listeners a los focus nodes
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        if (_isHandsUp != null) {
          _isHandsUp?.change(false);
          _numLook?.value = 50;
        }
      }
    });
    _passwordFocus.addListener(() {
        _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'animated_login_bear.riv',
                  stateMachines: const ['Login Machine'],
                  // Al iniciar la animación
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard, 
                      'Login Machine'
                      );
                      // Verificar que inició bien
                    if (_controller == null) return;
                    // Agregar el controlador al artboard
                    artboard.addController(_controller!);
                    // Vincular variables
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('trigSuccess');
                    _trigFail = _controller!.findSMI('trigFail');
                    _numLook = _controller!.findSMI('numLook');
                  }
                )
              ),
              SizedBox(height: 10),
              TextField(
                focusNode: _emailFocus,
                // Vincular SMIs a inputs del email
                onChanged: (value) {
                  if (_isChecking == null) return;
                  _isChecking!.change(true);
                  final look = (value.length / 80.0 * 100.0).clamp(
                    0.0, 
                    100.0
                  );
                  _numLook?.value = look;
                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(const Duration(seconds: 3), () {
                    if (!mounted) return;
                    _isChecking!.change(false);
                  });
                },
                // Configurar el teclado para email
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                )
              ),
              SizedBox(height: 10),
              TextField(
                focusNode: _passwordFocus,
                // Vincular SMIs a inputs del password
                onChanged: (value) {
                  if (_isChecking != null) {
                    _isChecking!.change(false);
                  }
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel();
  }
}
