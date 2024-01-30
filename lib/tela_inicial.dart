import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrada_dados/model/relato_model.dart';
import 'package:entrada_dados/relato.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class tela_inicial extends StatefulWidget {
  const tela_inicial({super.key});

  @override
  State<tela_inicial> createState() => _tela_inicialState();
}

class _tela_inicialState extends State<tela_inicial> {
  var auth = FirebaseAuth.instance;
  var firestore = FirebaseFirestore.instance;

  String _getPorteText(String? porte) {
  switch (porte) {
    case 'p':
      return 'Pequeno';
    case 'm':
      return 'Médio';
    case 'g':
      return 'Grande';
    default:
      return 'Não especificado';
  }
}

  String _formatarData(DateTime data) {
    initializeDateFormatting("pt_BR");

    var formatador = DateFormat.yMd("pt_BR");

    return formatador.format(data);
  }

  List<Widget> _carrossel(List<dynamic> fotos) {
    List<Widget> imagens = List.empty(growable: true);
    for (String imagem in fotos) {
      Padding temp = Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Image.network(
          imagem,
          fit: BoxFit.cover,
          width: 200,
        ),
      );
      imagens.add(temp);
    }
    return imagens;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        centerTitle: true,
        title: Text("Patinha Perdida"),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("Relatos")
                  .doc(auth.currentUser!.uid)
                  .collection("relato")
                  .orderBy("data", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Erro ao recuperar os dados",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<DocumentSnapshot> documentos = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    novoRelato relato =
                        novoRelato.fromFirestore(documentos[index]);

                    return Card(
                      child: Column(
                        children: [
                          relato.fotos != null
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _carrossel(relato.fotos!),
                                  ),
                                )
                              : Container(),
                          ListTile(
                            title: Text("Cor do pelo: ${relato.cor!}"),
                            subtitle: Text(_formatarData(relato.data!)),
                          ),
                          ListTile(
                            title: Text('Desnutrido: ${relato.desnutrido! ? "Sim" : "Não"}'),
                          ),
                          ListTile(
                            title: Text('Machucado: ${relato.machucado! ? "Sim" : "Não"}'),
                          ),
                          ListTile(
                            title: Text('Coleira: ${relato.coleira! ? "Sim" : "Não"}'),
                          ),
                          ListTile(
                            title: Text('Docil: ${relato.docil! ? "Sim" : "Não"}'),
                          ),
                          ListTile(
                            title: Text('Porte: ${_getPorteText(relato.porte)}'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
