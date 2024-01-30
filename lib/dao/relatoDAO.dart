import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrada_dados/model/relato_model.dart';

class RelatoDAO{
  final CollectionReference colecao =
      FirebaseFirestore.instance.collection("Relatos");

   Future<void> addAnotacao(novoRelato relato, String doc) {
    //anotacao é uma sub coleção
    return colecao.doc(doc).collection("relato").add(relato.toFirestore());
  }
}