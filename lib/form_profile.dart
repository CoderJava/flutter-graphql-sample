import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class FormProfile extends StatefulWidget {
  final int profileId;
  final String profileName;
  final String profileEmail;
  final int profileAge;

  FormProfile({
    this.profileId = -1,
    this.profileName = '',
    this.profileEmail = '',
    this.profileAge = -1,
  });

  @override
  _FormProfileState createState() => _FormProfileState();
}

class _FormProfileState extends State<FormProfile> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerAge = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    if (widget.profileId != -1) {
      controllerName.text = widget.profileName;
      controllerEmail.text = widget.profileEmail;
      controllerAge.text = widget.profileAge.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('Form Profile'),
      ),
      body: Container(
        width: double.infinity,
        child: Stack(
          children: [
            _buildWidgetForm(),
            isLoading
                ? Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: controllerName,
            decoration: InputDecoration(
              labelText: 'Name',
              isDense: true,
            ),
            keyboardType: TextInputType.text,
          ),
          TextField(
            controller: controllerEmail,
            decoration: InputDecoration(
              labelText: 'Email',
              isDense: true,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: controllerAge,
            decoration: InputDecoration(
              labelText: 'Age',
              isDense: true,
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8.0),
          widget.profileId == -1 ? _buildWidgetSubmitButton() : _buildWidgetEditDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildWidgetEditDeleteButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            child: Text('Edit'),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () async {
              var name = controllerName.text;
              var email = controllerEmail.text;
              var age = controllerAge.text;
              if (name.isEmpty) {
                scaffoldState.currentState.showSnackBar(
                  SnackBar(content: Text('Please fill your name')),
                );
                return;
              } else if (email.isEmpty) {
                scaffoldState.currentState.showSnackBar(
                  SnackBar(content: Text('Please fill your email')),
                );
                return;
              } else if (age.isEmpty) {
                scaffoldState.currentState.showSnackBar(
                  SnackBar(content: Text('Please fill your age')),
                );
                return;
              }
              setState(() {
                isLoading = true;
              });
              var link = HttpLink(uri: 'http://bengkelrobot.net:8005/graphql');
              var client = GraphQLClient(
                link: link,
                cache: InMemoryCache(),
                defaultPolicies: DefaultPolicies(
                  watchQuery: Policies(fetch: FetchPolicy.noCache),
                  query: Policies(fetch: FetchPolicy.noCache),
                  mutate: Policies(fetch: FetchPolicy.noCache),
                ),
              );
              var mutationCreateProfile = r'''
                    mutation EditProfile($input: EditProfileInput) {
                      editProfile(input: $input) {
                        status
                        message
                      }
                    }                 
                    ''';
              var mutationOptions = MutationOptions(
                documentNode: gql(mutationCreateProfile),
                variables: {
                  'input': {
                    'id': widget.profileId,
                    'name': name,
                    'email': email,
                    'age': int.parse(age),
                  },
                },
              );
              var queryResult = await client.mutate(mutationOptions);
              if (queryResult.hasException) {
                setState(() {
                  isLoading = false;
                });
                scaffoldState.currentState.showSnackBar(
                  SnackBar(content: Text('${queryResult.exception}')),
                );
                return;
              }
              Navigator.pop(context, {'success': true, 'message': 'Data profile has been updated'});
            },
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: RaisedButton(
            child: Text('Delete'),
            color: Colors.red[400],
            textColor: Colors.white,
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              var link = HttpLink(uri: 'http://bengkelrobot.net:8005/graphql');
              var client = GraphQLClient(
                link: link,
                cache: InMemoryCache(),
                defaultPolicies: DefaultPolicies(
                  watchQuery: Policies(fetch: FetchPolicy.noCache),
                  query: Policies(fetch: FetchPolicy.noCache),
                  mutate: Policies(fetch: FetchPolicy.noCache),
                ),
              );
              var mutationCreateProfile = '''
                    mutation {
                      deleteProfile(input: ${widget.profileId}) {
                        status
                        message
                      }
                    }
                    ''';
              var mutationOptions = MutationOptions(
                documentNode: gql(mutationCreateProfile),
              );
              var queryResult = await client.mutate(mutationOptions);
              if (queryResult.hasException) {
                setState(() {
                  isLoading = false;
                });
                scaffoldState.currentState.showSnackBar(
                  SnackBar(content: Text('${queryResult.exception}')),
                );
                return;
              }
              Navigator.pop(context, {'success': true, 'message': 'Data profile has been deleted'});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        child: Text('Submit'),
        textColor: Colors.white,
        onPressed: () async {
          var name = controllerName.text;
          var email = controllerEmail.text;
          var age = controllerAge.text;
          if (name.isEmpty) {
            scaffoldState.currentState.showSnackBar(
              SnackBar(content: Text('Please fill your name')),
            );
            return;
          } else if (email.isEmpty) {
            scaffoldState.currentState.showSnackBar(
              SnackBar(content: Text('Please fill your email')),
            );
            return;
          } else if (age.isEmpty) {
            scaffoldState.currentState.showSnackBar(
              SnackBar(content: Text('Please fill your age')),
            );
            return;
          }
          setState(() {
            isLoading = true;
          });
          var link = HttpLink(uri: 'http://bengkelrobot.net:8005/graphql');
          var client = GraphQLClient(
            link: link,
            cache: InMemoryCache(),
            defaultPolicies: DefaultPolicies(
              watchQuery: Policies(fetch: FetchPolicy.noCache),
              query: Policies(fetch: FetchPolicy.noCache),
              mutate: Policies(fetch: FetchPolicy.noCache),
            ),
          );
          var mutationCreateProfile = r'''
                    mutation CreateProfile($input: CreateProfileInput) {
                      createProfile(input: $input) {
                        id
                        name
                        email
                        age
                      }
                    }                 
                    ''';
          var mutationOptions = MutationOptions(
            documentNode: gql(mutationCreateProfile),
            variables: {
              'input': {
                'name': name,
                'email': email,
                'age': int.parse(age),
              },
            },
          );
          var queryResult = await client.mutate(mutationOptions);
          if (queryResult.hasException) {
            setState(() {
              isLoading = false;
            });
            scaffoldState.currentState.showSnackBar(
              SnackBar(content: Text('${queryResult.exception}')),
            );
            return;
          }
          Navigator.pop(context, true);
        },
        color: Colors.blue,
      ),
    );
  }
}
