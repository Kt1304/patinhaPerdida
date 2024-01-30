import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrada_dados/dao/relatoDAO.dart';
import 'package:entrada_dados/home_navigation.dart';
import 'package:entrada_dados/model/relato_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class Relato extends StatefulWidget {
  const Relato({super.key, this.id});
  final String? id;

  @override
  State<Relato> createState() => _RelatoState();
}

class _RelatoState extends State<Relato> {
  final TextEditingController _corcontroller = TextEditingController();
  final TextEditingController _portecontroller = TextEditingController();
  final TextEditingController _latcontroller = TextEditingController();
  final TextEditingController _longcontroller = TextEditingController();
  final TextEditingController _datacontroller = TextEditingController();

  var auth = FirebaseAuth.instance;
  var firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _docil = false;
  bool _machucado = false;
  bool _desnutrido = false;
  bool _coleira = false;
  XFile? _imagem;
  bool _carregando = false;
  final List<File> _imagens = List.empty(growable: true);

  Future<void> _abrirCalendario(BuildContext context) async {
    final DateTime? data = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        initialDate: DateTime.now()
        //initialDate: DateTime.parse("2024-02-01")
        );

    if (data != null) {
      setState(() {
        _datacontroller.text = DateFormat("dd/MM/yyyy").format(data).toString();
      });
    }
  }

  _capturarFoto({bool camera = true}) async {
    XFile? temp;
    final ImagePicker picker = ImagePicker();

    if (camera) {
      temp = await picker.pickImage(source: ImageSource.camera);
    } else {
      temp = await picker.pickImage(source: ImageSource.gallery);
    }

    if (temp != null) {
      setState(() {
        _imagem = temp;
      });
    }
  }

  String _gerarNome() {
    final agora = DateTime.now();
    return agora.microsecondsSinceEpoch.toString();
  }

  Future<List<String>?> _salvarFoto(String id) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference pastaFotos = pastaRaiz.child(id).child("fotos");
    Reference arquivo;
    List<String> temp = List.empty(growable: true);

    try {
      for (File foto in _imagens) {
        arquivo = pastaFotos.child("${_gerarNome()}.jpg");
        TaskSnapshot task = await arquivo.putFile(foto);
        String url = await task.ref.getDownloadURL();
        temp.add(url);
      }

      return temp;
    } catch (e) {
      setState(() {
        _carregando = false;
      });
      print(e);
      return null;
    }
  }

  _salvarRelato({novoRelato? novorelato}) async {
    setState(() {
      _carregando = true;
    });

    final FirebaseAuth auth = FirebaseAuth.instance;
    String uID = auth.currentUser!.uid;
    String cor = _corcontroller.text;
    DateTime data = DateFormat("dd/MM/yyyy").parse(_datacontroller.text);

    final navigator = Navigator.of(context);
    List<String>? fotos = await _salvarFoto(uID);

    if (novorelato == null) {
      novoRelato novorelato = novoRelato(
          cor,
          _portecontroller.text,
          _docil,
          _machucado,
          _desnutrido,
          _coleira,
          data,
          _latcontroller.text,
          _longcontroller.text,
          fotos);

      RelatoDAO().addAnotacao(novorelato, uID);
    } else {}
    setState(() {
      _carregando = false;
    });

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeNavigation(),
      ),
    );
  }

  _adicionarFoto() {
    setState(() {
      _imagens.add(File(_imagem!.path));
    });
  }

  List<Widget> _carrossel() {
    List<Widget> imagens = List.empty(growable: true);
    for (File imagem in _imagens) {
      Padding temp = Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Image.file(
          imagem,
          fit: BoxFit.cover,
          width: 200,
        ),
      );
      imagens.add(temp);
    }
    return imagens;
  }

  Future<void> getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      _latcontroller.text = posicao.latitude.toString();
      _longcontroller.text = posicao.longitude.toString();
    } catch (e) {
      print("deu ruim kk");
    }
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;
    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor habilite a localização no smartphone');
    }

    permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _datacontroller.dispose();
    _portecontroller.dispose();
    _longcontroller.dispose();
    _latcontroller.dispose();
    _corcontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      // _recuperarAnotacao(widget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        title: Text("Relato"),
        actions: [
          IconButton(
            //se der erro depois o salvarAnotacao tava comentado
            onPressed: () => _salvarRelato(),
            icon: const Icon(Icons.save),
          )
        ],
      ),

      //aqui era um Form
      //ta dando problema junto do _formKey porque ele não é mais um Form e não ta pegando a imagem para salvar
      //SingleChildScrollView resolve o do overflowed
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //cor
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 22, right: 22, bottom: 30),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Digite a cor da pelagem",
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return "Por favor digite uma cor";
                    }

                    if (valor.length < 4) {
                      return "Nome não pode ser menor que 4 caracteres";
                    }

                    return null;
                  },
                  controller: _corcontroller,
                ),
              ),

              //porte
              const Text("Porte"),

              RadioListTile(
                  title: const Text("Pequeno"),
                  value: "p",
                  groupValue: _portecontroller.text,
                  activeColor: Colors.yellow[800],
                  onChanged: (String? valor) {
                    setState(() {
                      _portecontroller.text = valor.toString();
                    });
                  }),
              RadioListTile(
                  title: const Text("Medio"),
                  value: "m",
                  groupValue: _portecontroller.text,
                  activeColor: Colors.yellow[800],
                  onChanged: (String? valor) {
                    setState(() {
                      _portecontroller.text = valor.toString();
                    });
                  }),
              RadioListTile(
                  title: const Text("Grande"),
                  value: "g",
                  groupValue: _portecontroller.text,
                  activeColor: Colors.yellow[800],
                  onChanged: (String? valor) {
                    setState(() {
                      _portecontroller.text = valor.toString();
                    });
                  }),

              //boleans de switch pra falar sim ou não do animal

              SwitchListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("O cachorro era dócil?"),
                    Text(_docil ? "Sim" : "Não"),
                  ],
                ),
                value: _docil,
                activeColor: Colors.yellow[600],
                onChanged: (bool valor) {
                  setState(() {
                    _docil = valor;
                  });
                },
              ),

              SwitchListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("O cachorro estava machucado?"),
                    Text(_machucado ? "Sim" : "Não"),
                  ],
                ),
                value: _machucado,
                activeColor: Colors.yellow[600],
                onChanged: (bool valor) {
                  setState(() {
                    _machucado = valor;
                  });
                },
              ),

              SwitchListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("O cachorro esta desnutrido?"),
                    Text(_desnutrido ? "Sim" : "Não"),
                  ],
                ),
                value: _desnutrido,
                activeColor: Colors.yellow[600],
                onChanged: (bool valor) {
                  setState(() {
                    _desnutrido = valor;
                  });
                },
              ),

              SwitchListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("O cachorro usava coleira?"),
                    Text(_coleira ? "Sim" : "Não"),
                  ],
                ),
                value: _coleira,
                activeColor: Colors.yellow[600],
                onChanged: (bool valor) {
                  setState(() {
                    _coleira = valor;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _datacontroller,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text(
                          "Data",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.orange,
                          ),
                          onTap: () => _abrirCalendario(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _capturarFoto();
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.orange,
                    ),
                    label: const Text(
                      "Câmera",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _capturarFoto(camera: false);
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.orange,
                    ),
                    label: const Text("Galeria",
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.map,
                    color: Colors.orange,
                  ),
                  label: const Text(
                    "Pegar Posição",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => getPosicao(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    TextButton.icon(
                      onPressed: () => _adicionarFoto(),
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.orange,
                      ),
                      label: const Text(
                        "Adiconar foto",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _carrossel(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
