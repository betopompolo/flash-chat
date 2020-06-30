import 'package:flash_chat/domain/user.dart';
import 'package:flash_chat/domain/user_bloc.dart';
import 'package:flash_chat/ui/components/app_logo.dart';
import 'package:flash_chat/ui/components/bloc_provider.dart';
import 'package:flash_chat/ui/components/form_field_validators.dart';
import 'package:flash_chat/ui/components/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

class LoginScreen extends StatefulWidget {
  static final String name = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  User _user = User();
  String _password = '';

  bool _loadingLogin = false;
  String _errorMessage;

  final _formKey = GlobalKey<FormState>();
  FocusNode _passwordFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _passwordFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _passwordFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            right: 24.0,
            left: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: AppLogo.tag,
                child: AppLogo(
                  height: 200.0,
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              AnimatedCrossFade(
                firstChild: Container(),
                secondChild: Column(
                  children: <Widget>[
                    Text(
                      _errorMessage ?? '',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).errorColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.0,),
                  ],
                ),
                crossFadeState: _errorMessage == null
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: Duration(
                  milliseconds: 200,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your email',
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        _user.email = value;
                      },
                      validator:
                          TextFormFieldValidator.email('Type a valid email'),
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      onFieldSubmitted: (value) => _passwordFieldFocusNode.requestFocus(),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      obscureText: true,
                      onChanged: (value) {
                        _password = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your password',
                      ),
                      validator: TextFormFieldValidator.empty(
                        'Your password is required',
                      ),
                      textInputAction: TextInputAction.done,
                      focusNode: _passwordFieldFocusNode,
                      onFieldSubmitted: (value) => _login(context),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              PrimaryButton(
                text: 'Log In',
                onTap: () => _login(context),
                color: Theme.of(context).primaryColor,
                loading: _loadingLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    if (_formKey.currentState.validate() == false || _loadingLogin) {
      return;
    }

    try {
      setState(() {
        _loadingLogin = true;
      });
      await BlocProvider.of<UserBloc>(context).login(_user, _password);
      Navigator.pop(context);
    } catch (error) {
      _showLoginErrorMessage(error.message);
      setState(() {
        _loadingLogin = false;
      });
    }
  }

  _showLoginErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    Future.delayed(
      Duration(seconds: 5),
      () {
        setState(() {
          _errorMessage = null;
        });
      }
    );
  }
}
