import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

void main() => runApp(App());

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
  GraphQLClient client;

  @override
  void initState() {
    client = GraphQLClient(
      link: HttpLink(uri: 'http://bengkelrobot.net:8005/graphql'),
      cache: InMemoryCache(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter GraphQL'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Query'),
              onPressed: () {
                executeQuery();
              },
            ),
            RaisedButton(
              child: Text('Mutation'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MutationPage();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> executeQuery() async {
    var queryProfile = r'''
    query {
      allProfile {
        id
        name
        email
        age
      }
    }
    ''';
    var options = QueryOptions(
      documentNode: gql(queryProfile),
    );
    var result = await client.query(options);
    if (result.hasException) {
      debugPrint('result.hasException: ${result.exception.toString()}');
      return;
    }
    debugPrint('result.query: ${result.data}');
  }
}

class MutationPage extends StatefulWidget {
  @override
  _MutationPageState createState() => _MutationPageState();
}

class _MutationPageState extends State<MutationPage> {
  final client = GraphQLClient(
    link: HttpLink(uri: 'http://bengkelrobot.net:8005/graphql'),
    cache: InMemoryCache(),
  );
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerAge = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mutation'),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controllerName,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: controllerEmail,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: controllerAge,
              decoration: InputDecoration(
                labelText: 'Age',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text('Submit'),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () async {
                  const mutationProfile = r'''
                  mutation CreateProfile($input: CreateProfileInput) {
                    createProfile(input: $input) {
                      id
                      name
                      email
                      age
                    }
                  }  
                  ''';
                  var mapInput = {
                    'name': controllerName.text,
                    'email': controllerEmail.text,
                    'age': controllerAge.text,
                  };
                  var options = MutationOptions(
                    documentNode: gql(mutationProfile),
                    variables: {
                      'input': mapInput,
                    },
                  );
                  var result = await client.mutate(options);
                  if (result.hasException) {
                    debugPrint('result.hasException: ${result.exception.toString()}');
                    return;
                  }
                  debugPrint('result.mutate: ${result.data}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
