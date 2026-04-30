import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;
  
  static final supabase = Supabase.instance.client;
  bool _isSyncing = false;
  bool _isOnline = false;
  final List<void Function(bool isOnline)> _listeners = [];
  
  SyncService._internal();
  
  factory SyncService() {
    return _instance;
  }
  
  void addListener(void Function(bool isOnline) listener) {
    _listeners.add(listener);
  }
  
  void removeListener(void Function(bool isOnline) listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_isOnline);
    }
  }
  
  Future<void> startMonitoring() async {
    // Verificar conexão inicial
    await _checkConnection();
    
    // Monitorar mudanças de conectividade
    Connectivity().onConnectivityChanged.listen((result) async {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        print('🌐 Conexão detectada! Sincronizando dados pendentes...');
        await syncPendingData();
        await syncFromCloud();
      } else if (wasOnline && !_isOnline) {
        print('📡 Conexão perdida. Operando offline.');
      }
      
      _notifyListeners();
    });
  }
  
  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    _notifyListeners();
    
    if (_isOnline) {
      print('🌐 Conexão inicial detectada, sincronizando...');
      await syncPendingData();
      await syncFromCloud();
    } else {
      print('📡 Operando offline. Dados serão sincronizados quando houver conexão.');
    }
  }
  
  Future<void> syncPendingData() async {
    if (_isSyncing) {
      print('⚠️ Sincronização já em andamento');
      return;
    }
    
    if (!_isOnline) {
      print('📡 Offline, sincronização adiada');
      return;
    }

    _isSyncing = true;
    
    try {
      final pendentes = HiveService.instance.getPendentes();

      if (pendentes.isEmpty) {
        print('📭 Nenhum dado pendente para sincronizar');
        _isSyncing = false;
        return;
      }

      print('🔄 Sincronizando ${pendentes.length} registros...');

      for (var item in pendentes) {
        try {
          print('📤 Enviando: ${item['id']} - ${item['variedade']} Bloco ${item['bloco']} Cacho ${item['cacho']}.${item['numeroAmostra']}');
          
          await supabase.from('apontamentos').upsert({
            'id': item['id'],
            'variedade': item['variedade'],
            'bloco': item['bloco'],
            'cacho': item['cacho'],
            'numero_amostra': item['numeroAmostra'],
            'numero_frutos': item['numeroFrutos'],
            'peso_medio_frutos': item['pesoMedioFrutos'],
            'data_criacao': item['dataCriacao'],
            'data_sincronizacao': DateTime.now().toIso8601String(),
          });
          
          await HiveService.instance.marcarSincronizado(item['id']);
          print('✅ Sincronizado: ${item['id']}');
        } catch (e) {
          print('❌ Erro ao sincronizar ${item['id']}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> syncFromCloud() async {
    if (!_isOnline) return;

    try {
      print('📥 Buscando dados da nuvem...');
      
      final response = await supabase
          .from('apontamentos')
          .select()
          .order('data_criacao', ascending: false);

      for (var cloudItem in response) {
        final localItem = HiveService.instance.get(cloudItem['id']);
        
        if (localItem == null) {
          final novoRegistro = {
            'id': cloudItem['id'],
            'variedade': cloudItem['variedade'],
            'bloco': cloudItem['bloco'],
            'cacho': cloudItem['cacho'],
            'numeroAmostra': cloudItem['numero_amostra'],
            'numeroFrutos': cloudItem['numero_frutos'],
            'pesoMedioFrutos': cloudItem['peso_medio_frutos'],
            'dataCriacao': cloudItem['data_criacao'],
            'dataSincronizacao': cloudItem['data_sincronizacao'],
            'sincronizado': true,
          };
          await HiveService.instance.put(cloudItem['id'], novoRegistro);
          print('📥 Importado da nuvem: ${cloudItem['id']}');
        }
      }
    } catch (e) {
      print('❌ Erro ao sincronizar da nuvem: $e');
    }
  }
  
  bool get isOnline => _isOnline;
}