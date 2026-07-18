import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import '../services/user_service.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final username = TextEditingController();
  final fullname = TextEditingController();
  final whatsapp = TextEditingController();
  final address = TextEditingController();
  final detail = TextEditingController();
  final _userService = UserService();

  bool _isSubmitting = false;

  @override
  void dispose() {
    username.dispose();
    fullname.dispose();
    whatsapp.dispose();
    address.dispose();
    detail.dispose();
    super.dispose();
  }

  Widget field(
      IconData icon, String label, String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black87),
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? "Wajib diisi" : null,
        ),
      ),
    );
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _userService.saveCurrentUserAddress(
        name: fullname.text.trim(),
        phone: whatsapp.text.trim(),
        address: address.text.trim(),
        addressDetail: detail.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat berhasil disimpan')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: const RouteSettings(name: '/dashboard'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/Rectangle5.png',
                width: MediaQuery.of(context).size.width,
                height: 446,
                fit: BoxFit.fill,
              ),
            ),
            SingleChildScrollView(
              child: Column(children: [
                const SizedBox(height: 16),
                Image.network(
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/eco-payhood-22spxq/assets/s17g1tokkf9m/design_lok_home.png',
                    height: 180),
                Text("Alamat Pengambilan",
                    style: GoogleFonts.montserrat(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                      "Masukkan alamat lengkap tempat sampah akan diambil.",
                      textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff7CC17E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(children: [
                        Text("Alamat Kontak",
                            style: GoogleFonts.montserrat(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        field(Icons.account_circle, "Nama Pengguna",
                            "Masukkan Nama Pengguna", username),
                        field(Icons.account_circle, "Nama Lengkap",
                            "Masukkan Nama Lengkap", fullname),
                        field(Icons.phone_android_outlined, "Nomor WhatsApp",
                            "Masukkan Nomor WhatsApp", whatsapp),
                        field(
                            Icons.location_on,
                            "Nama Jalan, Gedung, Nomor Rumah",
                            "Masukkan alamat",
                            address),
                        field(Icons.location_on, "Rincian Lainnya",
                            "Masukkan rincian lainnya", detail),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 320,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: _isSubmitting ? null : _submitAddress,
                            child: Text(
                              _isSubmitting
                                  ? 'Menyimpan...'
                                  : 'Simpan & Konfirmasi',
                            ),
                          ),
                        )
                      ]),
                    ),
                  ),
                )
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
