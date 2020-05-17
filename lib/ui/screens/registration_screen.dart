import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/bloc/user_bloc.dart';
import 'package:flash_chat/ui/components/app_logo.dart';
import 'package:flash_chat/ui/components/bloc_provider.dart';
import 'package:flash_chat/ui/components/form_field_validators.dart';
import 'package:flash_chat/ui/components/primary_button.dart';
import 'package:flash_chat/ui/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

class RegistrationScreen extends StatefulWidget {
  static final String name = 'RegistrationScreen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  User _user = User();
  String _password;


  final _formKey = GlobalKey<FormState>();
  FocusNode _emailFieldFocusNode;
  FocusNode _passwordFieldFocusNode;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFieldFocusNode = FocusNode();
    _passwordFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                child: AppLogo(
                  height: 200.0,
                ),
                tag: AppLogo.tag,
              ),
              SizedBox(
                height: 48.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        _user.displayName = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your display name',
                      ),
                      validator: TextFormFieldValidator.empty('This field cannot be empty'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_emailFieldFocusNode);
                      },
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    SizedBox(height: 8.0,),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFieldFocusNode,
                      onChanged: (value) {
                        _user.email = value;
                      },
                      autocorrect: false,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your email',
                      ),
                      validator: TextFormFieldValidator.email('Type a valid email'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_passwordFieldFocusNode),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      obscureText: true,
                      onChanged: (value) {
                        _password = value;
                      },
                      focusNode: _passwordFieldFocusNode,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your password',
                      ),
                      validator: TextFormFieldValidator.empty('Type your password'),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) => _handleRegisterSubmit(context),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              PrimaryButton(
                text: 'Register',
                onTap: _handleRegisterSubmit,
                color: Theme.of(context).primaryColor,
                loading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordFieldFocusNode.dispose();
    _emailFieldFocusNode.dispose();
    super.dispose();
  }

  _handleRegisterSubmit(BuildContext context) async {
    if (_formKey.currentState.validate() == false || _isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await BlocProvider.of<UserBloc>(context).registerUser(_user, _password);
      Navigator.popAndPushNamed(context, ChatScreen.name);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
