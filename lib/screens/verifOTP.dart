import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'add_address_page.dart';

class VerifOTPWidget extends StatefulWidget {
  const VerifOTPWidget({super.key});

  static String routeName = 'verifOTP';
  static String routePath = '/verifOTP';

  @override
  State<VerifOTPWidget> createState() => _VerifOTPWidgetState();
}

class _VerifOTPWidgetState extends State<VerifOTPWidget> {
  // Pengganti _model bawaan FlutterFlow
  final TextEditingController _pinCodeController = TextEditingController();
  final FocusNode _pinCodeFocusNode = FocusNode();

  // Setup StopWatchTimer untuk menghitung mundur OTP
  late final StopWatchTimer _stopWatchTimer;
  final int _timerInitialTimeMs = 60000; //60 detik (60000 ms)

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Inisialisasi timer hitung mundur
    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: _timerInitialTimeMs,
    );
    _stopWatchTimer.onStartTimer(); // Otomatis mulai timer saat masuk halaman
  }

  @override
  void dispose() {
    _pinCodeController.dispose();
    _pinCodeFocusNode.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _verifyOtp() {
    final otp = _pinCodeController.text.trim();

    if (kDebugMode) {
      debugPrint('Kode yang dimasukkan: $otp');
    }

    if (otp.length != 6) {
      _showSnackBar('Kode OTP harus 6 digit');
      return;
    }

    if (otp != '123456') {
      _showSnackBar('OTP demo salah. Gunakan 123456 untuk kelas Day 2');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor:
            Colors.white, // Mengganti primaryBackground FlutterFlow
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: const AlignmentDirectional(-1, -1),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
                    child: Text(
                      'Masukkan Kode OTP untuk \nVerifikasi ',
                      style: GoogleFonts.interTight(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(-1, -1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Kami telah mengirimkan kode OTP ke Email ',
                            style: GoogleFonts.inter(
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const TextSpan(
                            text: 'bim*******@gmail.com',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: '. Masukkan kode tersebut untuk melanjutkan.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    length: 6,
                    textStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    enableActiveFill: false,
                    autoFocus: true,
                    focusNode: _pinCodeFocusNode,
                    enablePinAutofill: false,
                    errorTextSpace: 16,
                    showCursor: true,
                    cursorColor: const Color(0xFF62B966),
                    obscureText: false,
                    hintCharacter: '-',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    pinTheme: PinTheme(
                      fieldHeight: 65,
                      fieldWidth: 50,
                      borderWidth: 2,
                      borderRadius: BorderRadius.circular(12),
                      shape: PinCodeFieldShape.box,
                      activeColor: Colors.black,
                      inactiveColor: const Color(0xFF62B966),
                      selectedColor: const Color(0xFF62B966),
                    ),
                    controller: _pinCodeController,
                    onChanged: (_) {},
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: _stopWatchTimer.rawTime.value,
                    builder: (context, snapshot) {
                      final value = snapshot.data!;
                      final displayTime = StopWatchTimer.getDisplayTime(
                        value,
                        hours: false,
                        milliSecond: false,
                      );
                      return Text(
                        displayTime,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.interTight(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Belum menerima kode? ',
                          style: GoogleFonts.inter(color: Colors.black54),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // Aksi kirim ulang OTP disini
                              debugPrint('Kirim ulang OTP dipicu...');
                              _stopWatchTimer.onResetTimer();
                              _stopWatchTimer.onStartTimer();
                            },
                            child: Text(
                              'Kirim ulang',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(327, 55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Verifikasi Kode',
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
