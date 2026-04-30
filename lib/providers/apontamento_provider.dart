import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/hive_service.dart';
import '../services/sync_service.dart';

class ApontamentoProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _apontamentos = [];
  bool _isLoading = false;
  final SyncService _syncService = SyncService.instance;

  List<Map<String, dynamic>> get apontamentos => _apontamentos;
  bool get isLoading => _isLoading;

  ApontamentoProvider() {
    carregarApontamentos();
  }

  Future<void> carregarApontamentos() async {
    _isLoading = true;
    notifyListeners();
    
    _apontamentos = HiveService.instance.getAll();
    _apontamentos.sort((a, b) => 
      DateTime.parse(b['dataCriacao']).compareTo(DateTime.parse(a['dataCriacao']))
    );
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> salvarApontamento({
    required String variedade,
    required int bloco,
    required int cacho,
    required int numeroAmostra,
    required int numeroFrutos,
    double? pesoMedioFrutos,
  }) async {
    final id = const Uuid().v4();
    final apontamento = {
      'id': id,
      'variedade': variedade,
      'bloco': bloco,
      'cacho': cacho,
      'numeroAmostra': numeroAmostra,
      'numeroFrutos': numeroFrutos,
      'pesoMedioFrutos': pesoMedioFrutos,
      'dataCriacao': DateTime.now().toIso8601String(),
      'dataSincronizacao': null,
      'sincronizado': false,
    };

    print('📝 Salvando localmente: ${apontamento['cacho']}.${apontamento['numeroAmostra']}');
    await HiveService.instance.put(id, apontamento);
    await carregarApontamentos();
    
    // Tentar sincronizar imediatamente se estiver online
    if (_syncService.isOnline) {
      print('🔄 Online, sincronizando imediatamente...');
      await _syncService.syncPendingData();
    } else {
      print('📡 Offline, dados salvos localmente. Sincronizará quando houver conexão.');
    }
  }

  Future<void> atualizarApontamento(String id, {
    int? numeroFrutos,
    double? pesoMedioFrutos,
  }) async {
    final apontamento = HiveService.instance.get(id);
    if (apontamento != null) {
      if (numeroFrutos != null) apontamento['numeroFrutos'] = numeroFrutos;
      if (pesoMedioFrutos != null) apontamento['pesoMedioFrutos'] = pesoMedioFrutos;
      apontamento['sincronizado'] = false;
      await HiveService.instance.put(id, apontamento);
      await carregarApontamentos();
      
      if (_syncService.isOnline) {
        await _syncService.syncPendingData();
      }
    }
  }

  Future<void> deletarApontamento(String id) async {
    await HiveService.instance.delete(id);
    await carregarApontamentos();
  }
}