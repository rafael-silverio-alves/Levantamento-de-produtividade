import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'screens/apontamentos_screen.dart';
import 'screens/registros_screen.dart';
import 'providers/apontamento_provider.dart';
import 'services/hive_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando app...');
  
  // 🔴 SUBSTITUA PELAS SUAS CREDENCIAIS DO SUPABASE 🔴
  await Supabase.initialize(
    url: 'https://ekwnxsdsiaowvhlohsni.supabase.co',  // Coloque sua URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrd254c2RzaWFvd3ZobG9oc25pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0Nzk4OTMsImV4cCI6MjA5MzA1NTg5M30.QbOx0482CPkS9CS2fxZ-14W88RiZ-rUCWFR57RfCUl8',                 // Coloque sua chave
  );
  
  // Inicializar HiveService
  await HiveService.instance.init();
  
  // Iniciar serviço de sincronização
  await SyncService.instance.startMonitoring();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApontamentoProvider()),
      ],
      child: MaterialApp(
        title: 'Produtividade App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    SyncService.instance.addListener(_onSyncStatusChanged);
    _updateOnlineStatus();
  }

  void _updateOnlineStatus() {
    setState(() {
      _isOnline = SyncService.instance.isOnline;
    });
  }

  void _onSyncStatusChanged(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });
  }

  @override
  void dispose() {
    SyncService.instance.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador de status da conexão
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isOnline ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: _isOnline ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _isOnline ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Produtividade App',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestão de Produção Agrícola',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              context,
              title: 'Apontamentos',
              subtitle: 'Registrar nova produção',
              icon: Icons.edit_note,
              color: Colors.green,
              route: '/apontamentos',
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              title: 'Registros',
              subtitle: 'Visualizar, editar e excluir',
              icon: Icons.list_alt,
              color: Colors.blue,
              route: '/registros',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  if (route == '/apontamentos') {
                    return const ApontamentosScreen();
                  } else {
                    return const RegistrosScreen();
                  }
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}