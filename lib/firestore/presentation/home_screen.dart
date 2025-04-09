import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_first/firestore/presentation/analitys.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];
  // Instancia do firebase para acessar o banco de dados
  FirebaseFirestore db = FirebaseFirestore.instance;
  Analitys analitys = Analitys();

  @override
  void initState() {
    analitys.incrementarAcessoTotal();
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listin - Feira Colaborativa"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                analitys.incrementarAtualizacaoManual();
                return refresh();
              },
              child: ListView(
                children: List.generate(
                  listListins.length,
                  (index) {
                    Listin model = listListins[index];
                    return ListTile(
                      leading: const Icon(Icons.list_alt_rounded),
                      title: Text(model.name),
                      subtitle: Text(model.id),
                    );
                  },
                ),
              ),
            ),
    );
  }

  showFormModal() {
    // Labels à serem mostradas no Modal
    String title = "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Listin
    TextEditingController nameController = TextEditingController();

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(label: Text("Nome do Listin")),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        //Puxando o NameController para pegar o texto que o usuario digitou
                        //usando a biblioteca UUID para gerar um ID unico
                        //Comando utilizado para instalar a biblioteca UUID (flutter pub add uuid)
                        Listin listin =
                            Listin(id: Uuid().v1(), name: nameController.text);
                        //criando uma coleção chamada listin no bd, com o id gerado e o nome que o usuario digita
                        // O set sobreescreve o documento ou escreve um novo caso não exista
                        db
                            .collection("listins")
                            .doc(listin.id)
                            .set(listin.toMap());

                        analitys.incrementarListaAdd();

                        refresh();

                        Navigator.pop(context);
                      },
                      child: Text(confirmationButton)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Listin> temp = [];
    //Mostrando na tela as informações que estão no banco de dados
    //QuerySnapshot é como tirar uma foto do banco de dados, ou seja,
    //ele pega os dados que estão lá no momento
    // Adicionando os dados do banco de dados na lista listListins
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await db.collection("listins").get();

    for (var doc in snapshot.docs) {
      //criando uma lista temporaria para armazenar as informações e depois adicionar na lista listListins
      temp.add(Listin.fromMap(doc.data()));
    }
    setState(() {
      listListins = temp;
    });

    // //Puxando a coleção listin do banco de dados e transformando em uma lista de Listin
    // db.collection("listins").snapshots().listen((snapshot) {
    //   listListins.clear();
    //   for (var doc in snapshot.docs) {
    //     listListins.add(Listin.fromMap(doc.data()));
    //   }
    //   setState(() {});
    // });
  }
}
