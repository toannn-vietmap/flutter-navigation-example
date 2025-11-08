import 'package:anti_mitm/native_flutter_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/extension/color_extension.dart';
import 'constants/route.dart';
import 'features/map_screen/bloc/bloc.dart';
import 'features/routing_screen/bloc/bloc.dart';

String? nextRoute;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var isNoConnectToProxy = await AntiMitm.performSecurityCheck(autoBlock: true);

  if (!isNoConnectToProxy) {
    AntiMitm.blockAllConnections();
  }

  try {
    await dotenv.load(fileName: ".env");
    Vietmap.getInstance(dotenv.env['VIETMAP_API_KEY'] ?? '');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => MapBloc()),
      BlocProvider(create: (context) => RoutingBloc()),
    ],
    child: MaterialApp.router(
      title: 'VietMap Flutter GL',
      routerConfig: route,
      theme: ThemeData(
          useMaterial3: false,
          primarySwatch: MaterialColor(
            vietmapColor.value,
            <int, Color>{
              50: vietmapColor.withOpacityValue(0.05),
              100: vietmapColor.withOpacityValue(0.1),
              200: vietmapColor.withOpacityValue(0.2),
              300: vietmapColor.withOpacityValue(0.3),
              400: vietmapColor.withOpacityValue(0.4),
              500: vietmapColor,
              600: vietmapColor.withOpacityValue(0.6),
              700: vietmapColor.withOpacityValue(0.7),
              800: vietmapColor.withOpacityValue(0.8),
              900: vietmapColor.withOpacityValue(0.9),
            },
          ),
          primaryColor: vietmapColor,
          primaryColorLight: vietmapColor,
          fontFamily: GoogleFonts.montserrat().fontFamily),
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
    ),
  ));
}
