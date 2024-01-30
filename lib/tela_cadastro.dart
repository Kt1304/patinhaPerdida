import 'package:entrada_dados/home_navigation.dart';
import 'package:entrada_dados/tela_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class tela_cadastro extends StatefulWidget {
  const tela_cadastro({Key? key}) : super(key: key);

  @override
  _tela_cadastroState createState() => _tela_cadastroState();
}

class _tela_cadastroState extends State<tela_cadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        centerTitle: true,
        title: const Text("Cadastre-se"),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode
            .disabled, //permite a verificação de dados após o envio do formulário.
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: "Digite seu nome",
                ),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return "Digite seu nome";
                  }
                  if (valor.length <= 5) {
                    return "Digite seu nome completo";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Digite seu e-mail",
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return "Digite seu e-mail";
                  }
                  if (!RegExp(
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$') // essa é uma das maneiras de verificar um endereço válido. Também é possível utilizar a biblioteca no pubstac chamada email_validator.
                      .hasMatch(valor)) {
                    return "Digite um e-mail válido";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: "Digite sua senha",
                ),
                obscureText: true,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return "Digite sua senha";
                  }
                  if (valor.length < 10) {
                    return "Sua senha deve conter ao menos 10 caracteres";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: ElevatedButton(
                child: const Text("Cadastrar-se"),
                onPressed: () {
                  cadastrar();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  sair() async {
    await _firebaseAuth.signOut().then(
          (user) => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => HomeNavigation())),
        );
  }

  cadastrar() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _senhaController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Cadastro realizado com sucesso"),
          ),
        );

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => tela_login(),
            ));

        // ignore: use_build_context_synchronously
      }
    } catch (error) {
      // Handle registration errors
      String errorMessage = "Erro ao cadastrar";
      if (error is FirebaseAuthException) {
        errorMessage = error.message ?? "Erro ao cadastrar";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "O email inserido já está em uso. Utilize outro e-mail e tente novamente"),
        ),
      );
    }
  }
}