
import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/screens/main_navigation.dart';
import 'package:rick_and_morty_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
static const Color green = Color(0xFF97CE4C);
static const Color background = Color(0xFF12141A);
static const Color surface = Color(0xFF20232B);

final _formKey = GlobalKey<FormState>();
final _nameCtrl = TextEditingController();
final _emailCtrl = TextEditingController();
final _passCtrl = TextEditingController();
final _confirmCtrl = TextEditingController();

bool _registering = false;
bool _loading = false;
bool _hidePassword = true;
bool _hideConfirm = true;

@override
void dispose() {
_nameCtrl.dispose();
_emailCtrl.dispose();
_passCtrl.dispose();
_confirmCtrl.dispose();
super.dispose();
}

void _changeMode(bool register) {
setState(() {
_registering = register;
_formKey.currentState?.reset();
_nameCtrl.clear();
_emailCtrl.clear();
_passCtrl.clear();
_confirmCtrl.clear();
});
}

void _message(String text) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(text),
behavior: SnackBarBehavior.floating,
backgroundColor: surface,
),
);
}

Future<void> _submit() async {
if (!_formKey.currentState!.validate()) return;

setState(() => _loading = true);

try {
final auth = AuthService();
String? error;

if (_registering) {
error = await auth.register(
_nameCtrl.text.trim(),
_emailCtrl.text.trim(),
_passCtrl.text,
);
} else {
final success = await auth.login(
_emailCtrl.text.trim(),
_passCtrl.text,
);

if (!success) {
error = 'Correo o contraseña incorrectos. '
'Si no tienes cuenta, regístrate primero.';
}
}

if (!mounted) return;

if (error != null) {
_message(error);
return;
}

Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(
builder: (_) => const MainNavigation(),
),
(route) => false,
);
} catch (_) {
if (mounted) {
_message('No se pudo completar la operación. Inténtalo de nuevo.');
}
} finally {
if (mounted) {
setState(() => _loading = false);
}
}
}

InputDecoration _decoration(
String label,
IconData icon, {
Widget? suffix,
}) {
return InputDecoration(
labelText: label,
prefixIcon: Icon(icon, color: green),
suffixIcon: suffix,
filled: true,
fillColor: background,
labelStyle: const TextStyle(color: Colors.white70),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(color: Color(0xFF353945)),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(color: green, width: 1.5),
),
);
}

Widget _field({
required TextEditingController controller,
required String label,
required IconData icon,
required String? Function(String?) validator,
TextInputType keyboard = TextInputType.text,
bool obscure = false,
Widget? suffix,
}) {
return TextFormField(
controller: controller,
keyboardType: keyboard,
obscureText: obscure,
style: const TextStyle(color: Colors.white),
validator: validator,
decoration: _decoration(label, icon, suffix: suffix),
);
}

Widget _modeButton(String label, bool selected, VoidCallback onTap) {
return Expanded(
child: AnimatedContainer(
duration: const Duration(milliseconds: 180),
decoration: BoxDecoration(
color: selected ? green : Colors.transparent,
borderRadius: BorderRadius.circular(11),
),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(11),
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
child: Text(
label,
textAlign: TextAlign.center,
style: TextStyle(
color: selected ? background : Colors.white70,
fontWeight: FontWeight.bold,
fontSize: 13,
),
),
),
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: background,
body: Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Color(0xFF263628),
Color(0xFF171B21),
background,
],
),
),
child: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(22),
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 440),
child: Column(
children: [
Container(
width: 106,
height: 106,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: green.withValues(alpha: 0.10),
border: Border.all(color: green, width: 2),
boxShadow: [
BoxShadow(
color: green.withValues(alpha: 0.18),
blurRadius: 28,
),
],
),
child: const Icon(
Icons.travel_explore,
color: green,
size: 57,
),
),
const SizedBox(height: 20),
const Text(
'RICK AND MORTY',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 27,
letterSpacing: 2,
fontWeight: FontWeight.w900,
color: Colors.white,
),
),
const SizedBox(height: 8),
Text(
_registering
? 'Crea tu cuenta interdimensional'
    : 'Tu próxima aventura comienza aquí',
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.white70,
fontSize: 14,
),
),
const SizedBox(height: 30),
Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
color: surface,
borderRadius: BorderRadius.circular(24),
border: Border.all(color: Colors.white10),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.2),
blurRadius: 24,
offset: const Offset(0, 10),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Container(
padding: const EdgeInsets.all(5),
decoration: BoxDecoration(
color: background,
borderRadius: BorderRadius.circular(14),
),
child: Row(
children: [
_modeButton(
'Iniciar sesión',
!_registering,
() => _changeMode(false),
),
_modeButton(
'Registrarse',
_registering,
() => _changeMode(true),
),
],
),
),
const SizedBox(height: 26),
Text(
_registering
? 'Crear una cuenta'
    : '¡Qué bueno verte!',
style: const TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 7),
Text(
_registering
? 'Completa tus datos para comenzar.'
    : 'Ingresa tus credenciales para continuar.',
style: const TextStyle(
color: Colors.white60,
fontSize: 13,
),
),
const SizedBox(height: 24),
Form(
key: _formKey,
child: Column(
children: [
if (_registering) ...[
_field(
controller: _nameCtrl,
label: 'Nombre de usuario',
icon: Icons.person_outline,
validator: (value) {
if (value == null ||
value.trim().length < 3) {
return 'Usa al menos 3 caracteres.';
}
return null;
},
),
const SizedBox(height: 16),
],
_field(
controller: _emailCtrl,
label: 'Correo electrónico',
icon: Icons.email_outlined,
keyboard: TextInputType.emailAddress,
validator: (value) {
final email = value?.trim() ?? '';
if (!RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
).hasMatch(email)) {
return 'Escribe un correo válido.';
}
return null;
},
),
const SizedBox(height: 16),
_field(
controller: _passCtrl,
label: 'Contraseña',
icon: Icons.lock_outline,
obscure: _hidePassword,
suffix: IconButton(
onPressed: () => setState(
() => _hidePassword = !_hidePassword,
),
icon: Icon(
_hidePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
color: Colors.white60,
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return 'Escribe tu contraseña.';
}
if (_registering && value.length < 6) {
return 'Usa al menos 6 caracteres.';
}
return null;
},
),
if (_registering) ...[
const SizedBox(height: 16),
_field(
controller: _confirmCtrl,
label: 'Confirmar contraseña',
icon: Icons.lock_reset,
obscure: _hideConfirm,
suffix: IconButton(
onPressed: () => setState(
() => _hideConfirm = !_hideConfirm,
),
icon: Icon(
_hideConfirm
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
color: Colors.white60,
),
),
validator: (value) {
if (value != _passCtrl.text) {
return 'Las contraseñas no coinciden.';
}
return null;
},
),
],
const SizedBox(height: 25),
SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
onPressed: _loading ? null : _submit,
style: ElevatedButton.styleFrom(
backgroundColor: green,
foregroundColor: const Color(0xFF17200F),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
child: _loading
? const SizedBox(
width: 23,
height: 23,
child: CircularProgressIndicator(
strokeWidth: 2.5,
color: background,
),
)
    : Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
_registering
? Icons.person_add_alt_1
    : Icons.login,
),
const SizedBox(width: 10),
Text(
_registering
? 'CREAR CUENTA'
    : 'INICIAR SESIÓN',
style: const TextStyle(
fontWeight: FontWeight.w900,
letterSpacing: 1,
),
),
],
),
),
),
],
),
),
const SizedBox(height: 18),
TextButton(
onPressed: () => _changeMode(!_registering),
child: Text.rich(
TextSpan(
style: const TextStyle(color: Colors.white60),
children: [
TextSpan(
text: _registering
? '¿Ya tienes cuenta? '
    : '¿No tienes cuenta? ',
),
TextSpan(
text: _registering
? 'Inicia sesión'
    : 'Regístrate',
style: const TextStyle(
color: green,
fontWeight: FontWeight.bold,
),
),
],
),
),
),
],
),
),
const SizedBox(height: 24),
const Text(
'EXPLORA · DESCUBRE · VIAJA ENTRE DIMENSIONES',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white38,
fontSize: 10,
letterSpacing: 1,
),
),
],
),
),
),
),
),
),
);
}
}
