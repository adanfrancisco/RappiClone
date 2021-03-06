import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/core.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final String _apiKey = "";

List<SingleChildWidget> get providers => [
      ...independentServices,
      ...uiConsumableProviders,
      ...dependentServices,
    ];

List<SingleChildWidget> independentServices = [
  Provider(
    create: (_) => AuthenticationService(auth: _auth, firestore: _firestore),
  ),
  Provider(
    create: (_) => AddressRepository(
      firestore: _firestore,
      auth: _auth,
      apikey: _apiKey,
    ),
  ),
];

List<SingleChildWidget> uiConsumableProviders = [
  StreamProvider<User>(
    create: (context) =>
        Provider.of<AuthenticationService>(context, listen: false)
            .onAuthStateChanged,
  ),
];

List<SingleChildWidget> dependentServices = [
  ChangeNotifierProxyProvider2<AuthenticationService, User, UserViewModel>(
    create: (_) => UserViewModel(),
    update: (_, auth, user, model) => model
      ..authenticationService = auth
      ..currentUser = user,
  ),
  ChangeNotifierProxyProvider<AddressRepository, AddressViewModel>(
    create: (_) => AddressViewModel(),
    update: (_, apis, model) => model..api = apis,
  ),
];
