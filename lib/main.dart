import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttergraphqlsample/form_profile.dart';
import 'package:graphql/client.dart';

void main() => runApp(App());

enum Status {
  loading,
  success,
  failure,
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  HttpLink link;
  GraphQLClient client;
  InMemoryCache inMemoryCache;
  StreamController<Status> streamController;
  List<dynamic> listData;

  @override
  initState() {
    streamController = StreamController<Status>();
    listData = [];
    link = HttpLink(uri: 'http://bengkelrobot.net:8005/graphql');
    inMemoryCache = InMemoryCache();
    client = GraphQLClient(
      link: link,
      cache: inMemoryCache,
      defaultPolicies: DefaultPolicies(
        watchQuery: Policies(fetch: FetchPolicy.noCache),
        query: Policies(fetch: FetchPolicy.noCache),
        mutate: Policies(fetch: FetchPolicy.noCache),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllProfiles();
    });
    super.initState();
  }

  void _loadAllProfiles() async {
    streamController.add(Status.loading);
    var queryAllProfiles = r'''
    {
      allProfile {
        id
        name
        email
        age
      } 
    }
    ''';
    var queryOptions = QueryOptions(
      documentNode: gql(queryAllProfiles),
    );
    try {
      var queryResult = await client.query(queryOptions);
      listData.clear();
      listData.addAll(queryResult.data['allProfile']);
      streamController.add(Status.success);
    } on Exception catch (error) {
      streamController.add(Status.failure);
      debugPrint('$error');
    }
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('GraphQL Demo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              _loadAllProfiles();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: streamController.stream,
        initialData: Status.loading,
        builder: (BuildContext context, AsyncSnapshot<Status> snapshot) {
          var status = snapshot.data;
          if (status == Status.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (status == Status.failure) {
            return Center(
              child: Text('Error fetch all profiles'),
            );
          } else if (status == Status.success) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              itemBuilder: (context, index) {
                var item = listData[index];
                return GestureDetector(
                  onTap: () {
                    // TODO: buat fitur edit dan delete profile
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item['name']),
                          Text(
                            item['email'],
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            item['age'].toString(),
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: listData.length,
            );
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FormProfile();
              },
            ),
          );
          if (result != null && result) {
            scaffoldState.currentState.showSnackBar(
              SnackBar(content: Text('Profile has been submitted')),
            );
            _loadAllProfiles();
          }
        },
      ),
    );
  }
}
