import 'package:entrada_dados/home_navigation.dart';
import 'package:entrada_dados/tela_inicial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class tela_login extends StatefulWidget {
  const tela_login({super.key});

  @override
  State<tela_login> createState() => _tela_loginState();
}

class _tela_loginState extends State<tela_login> {
  final TextEditingController _emailController =
      TextEditingController(); // CONTROLADOR DO TEXT
  final TextEditingController _senhaController =
      TextEditingController(); // CONTROLADOR DO TEXT

  final _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    //libera a memoria destri os componentes aberto
    // TODO: implement dispose

    _emailController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Tela de Login"),
        centerTitle: true, // centraliza o titulo
      ),

      //como deixo o fundo da tela toda branca?
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // alinhamento das colunas ao centro
        children: [
          Container(
            width: 120,
            height: 120,
            child: Image.asset('assets/images/Patinha.png'),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: _emailController, //Controlador do campo de texto
              keyboardType: TextInputType.text, // parametro para tipo de texto
              decoration: const InputDecoration(
                // Declarando a decoração do input
                labelText: "Email",
              ),
              style: const TextStyle(
                  fontSize: 22), // tamanho dos caracteres do input
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20), // espaçamento entre os campos
            child: TextField(
              controller: _senhaController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
              ),
              style: const TextStyle(fontSize: 22),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(100, 55),
            ),
            // como altera o tamanho do botao?

            child: const Text("Entrar"),
            onPressed: () {
              login();
            },
          ),
        ],
      ),
    );
  }

  login() async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: _emailController.text, password: _senhaController.text);
      if (userCredential != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeNavigation(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        //ajustar para validação.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Usuário ou senha inválidos"),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Usuário ou senha inválidos! Tente novamente."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}