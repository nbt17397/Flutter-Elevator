import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../config/theme/my_theme.dart';
import '../../components/custom_scaffold.dart';
import '../../components/m_text_form_field.dart';
import '../authentication/bloc/authentication_bloc.dart';
import 'bloc/login_bloc.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginBloc _loginBloc;
  late AuthenticationBloc _authenticationBloc;
  final _formSignInKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool rememberPassword = false;
  bool _obscureText = true;
  late Box _settingsBox;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc();
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    // Lấy box 'settings' (Đảm bảo đã openBox trong main.dart)
    _settingsBox = Hive.box('settings');
    _loadRememberedData();
  }

  /// Tải dữ liệu từ Hive và điền vào Controller
  void _loadRememberedData() {
    final String? savedEmail = _settingsBox.get('remember_email');
    final String? savedPass = _settingsBox.get('remember_password');

    if (savedEmail != null && savedPass != null) {
      setState(() {
        _usernameController.text = savedEmail;
        _passwordController.text = savedPass;
        rememberPassword = true;
      });
    }
  }

  /// Xử lý việc lưu hoặc xóa thông tin đăng nhập trong Hive
  void _handleRememberMe() {
    if (rememberPassword) {
      _settingsBox.put('remember_email', _usernameController.text);
      _settingsBox.put('remember_password', _passwordController.text);
    } else {
      _settingsBox.delete('remember_email');
      _settingsBox.delete('remember_password');
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onLogin() {
    if (_formSignInKey.currentState!.validate()) {
      // Cập nhật trạng thái ghi nhớ trước khi thực hiện login
      _handleRememberMe();

      _loginBloc.add(Login(
        user: _usernameController.text,
        password: _passwordController.text,
      ));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _loginBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'AMVi',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      MTextFormField(
                        labelText: 'Email',
                        hintText: 'Enter Email',
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onLogin(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        obscureText: _obscureText,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: _toggle,
                            child: Icon(_obscureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value ?? false;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Xử lý quên mật khẩu
                            },
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      BlocConsumer<LoginBloc, LoginState>(
                        bloc: _loginBloc,
                        listener: (context, state) {
                          if (state is LoginSuccess) {
                            _authenticationBloc.add(
                                LoggedIn(accessToken: state.accessToken));
                          }
                          if (state is LoginError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error)),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is LoginLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onLogin,
                              child: Text('Sign in',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme.surface,
                                  )),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 35.0),
                      _buildSignUpSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.withOpacity(0.5))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Sign up with', style: TextStyle(color: Colors.black45)),
            ),
            Expanded(child: Divider(color: Colors.grey.withOpacity(0.5))),
          ],
        ),
        const SizedBox(height: 25.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Don\'t have an account? ',
                style: TextStyle(color: Colors.black45)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (e) => const SignUpScreen()),
              ),
              child: Text(
                'Sign up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: lightColorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}