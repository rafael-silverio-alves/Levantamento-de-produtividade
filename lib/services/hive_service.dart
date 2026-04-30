import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  static HiveService get instance => _instance;
  
  late Box<Map> _box;
  bool _isInitialized = false;
  
  HiveService._internal();
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    _box = await Hive.openBox('apontamentos');
    _isInitialized = true;
    print('✅ HiveService inicializado');
  }
  
  Box<Map> get box {
    if (!_isInitialized) {
      throw Exception('HiveService não foi inicializado. Chame init() primeiro.');
    }
    return _box;
  }
  
  Future<void> put(String key, Map<String, dynamic> value) async {
    await box.put(key, value);
  }
  
  Map<String, dynamic>? get(String key) {
    final result = box.get(key);
    if (result == null) return null;
    return Map<String, dynamic>.from(result);
  }
  
  List<Map<String, dynamic>> getAll() {
    final List<Map<String, dynamic>> result = [];
    for (var item in box.values) {
      result.add(Map<String, dynamic>.from(item));
    }
    return result;
  }
  
  List<Map<String, dynamic>> getPendentes() {
    final List<Map<String, dynamic>> result = [];
    for (var item in box.values) {
      final map = Map<String, dynamic>.from(item);
      if (map['sincronizado'] == false) {
        result.add(map);
      }
    }
    return result;
  }
  
  Future<void> delete(String key) async {
    await box.delete(key);
  }
  
  Future<void> marcarSincronizado(String id) async {
    final item = box.get(id);
    if (item != null) {
      item['sincronizado'] = true;
      item['dataSincronizacao'] = DateTime.now().toIso8601String();
      await box.put(id, item);
    }
  }
}