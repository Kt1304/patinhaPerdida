import 'package:entrada_dados/login_cadastro_telas.dart';
import 'package:entrada_dados/relato.dart';
import 'package:entrada_dados/tela_inicial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

final _firebaseAuth = FirebaseAuth.instance;

class _HomeNavigationState extends State<HomeNavigation> {
  int _telaAtual = 0;

  List<Widget> telas = const [
    tela_inicial(),
    Relato(),
    LoginCadastroTelas(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: telas[_telaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _telaAtual,
        onTap: (tela) {
          setState(() {
            _telaAtual = tela;
          });
        },
        type: BottomNavigationBarType.shifting,
        fixedColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
              backgroundColor: Colors.yellow[600],
              icon: const Icon(Icons.home),
              label: "Home"),
          BottomNavigationBarItem(
              backgroundColor: Colors.yellow[700],
              icon: const Icon(Icons.edit_document),
              label: "Relato"),
          BottomNavigationBarItem(
              backgroundColor: Colors.yellow[600],
              icon: const Icon(Icons.add_reaction),
              label: "Login/Cadastro"),
        ],
      ),
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () => sair(), child: const Icon(Icons.exit_to_app)),
          const Text("Sair"),
        ],
      ),
    );
  }

  sair() async {
    await _firebaseAuth.signOut().then(
          (user) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeNavigation()),
          ),
        );
  }
}