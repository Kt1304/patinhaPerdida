import 'package:entrada_dados/tela_cadastro.dart';
import 'package:entrada_dados/tela_login.dart';
import 'package:flutter/material.dart';

class LoginCadastroTelas extends StatefulWidget {
  const LoginCadastroTelas({Key? key}) : super(key: key);

  @override
  State<LoginCadastroTelas> createState() => _LoginCadastroTelasState();
}

class _LoginCadastroTelasState extends State<LoginCadastroTelas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 350)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => tela_login(),
                        ));
                  },
                  icon: const Icon(
                    Icons.login,
                    color: Colors.orange,
                    size: 32,
                  ),
                  label: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => tela_cadastro(),
                        ));
                  },
                  icon: const Icon(
                    Icons.add_reaction,
                    color: Colors.orange,
                    size: 32,
                  ),
                  label: const Text(
                    "Cadastrar-se",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
