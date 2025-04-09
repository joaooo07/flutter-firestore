import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Analitys {
  FirebaseFirestore firebase = FirebaseFirestore.instance;

  void incrementarAcessoTotal() {
    _incrementar('acesso_total');
  }

  void incrementarListaAdd() {
    _incrementar("listas_adicionadas");
  }

  void incrementarAtualizacaoManual() {
    _incrementar('atualizacao_manual');
  }

  _incrementar(String field) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firebase.collection('analytics').doc('geral').get();
    Map<String, dynamic> document = {};
    if (snapshot.data() != null) {
      document = snapshot.data()!;
    }

    // Caso o campo que queremos somar tenha dados, somamos, se não inicializamos com o valor 1
    if (document[field] != null) {
      document[field] = document[field] + 1;
    } else {
      document[field] = 1;
    }

    // Atualizamos no Firestore
    firebase.collection("analytics").doc("geral").set(document);
  }
}
