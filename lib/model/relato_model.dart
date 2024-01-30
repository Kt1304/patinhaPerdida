import 'package:cloud_firestore/cloud_firestore.dart';

class novoRelato{
  String? id;
  String? cor;
  String? porte;
  bool? docil;
  bool? machucado;
  bool? desnutrido;
  bool? coleira;
  DateTime? data;
  String? latitude;
  String? longitude;
  List<dynamic>? fotos;

  novoRelato(this.cor,this.porte, this.docil, this.machucado, this.desnutrido,this.coleira,this.data,this.latitude,this.longitude, this.fotos);

  Map<String, dynamic> toFirestore(){
    return{
      "cor": cor,
      "porte": porte,
      "docil": docil,
      "machucado": machucado,
      "desnutrido": desnutrido,
      "coleira": coleira,
      "data" : data,
      "latitude": latitude,
      "longitude": longitude,
      "fotos": fotos,
    };
  }

  novoRelato.fromJson(String id, Map<String, dynamic> json)
    : id = id,
      cor = json["cor"],
      porte = json["porte"],
      docil = json["docil"],
      machucado = json["machucado"],
      desnutrido = json["desnutrido"],
      coleira = json["coleira"],
      data = (json["data"] as Timestamp).toDate(),
      latitude = json["latitude"],
      longitude = json ["longitude"],
      fotos = json["fotos"];

factory novoRelato.fromFirestore(DocumentSnapshot doc) {
  final dados = doc.data() as Map<String, dynamic>;
  return novoRelato.fromJson(doc.id, dados);
}

}