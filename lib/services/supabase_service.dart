import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/apontamento.dart';

class SupabaseService {
  static SupabaseClient get supabase => Supabase.instance.client;

  Future<void> inserirApontamento(Apontamento apontamento) async {
    try {
      await supabase.from('apontamentos').insert(apontamento.toJson());
    } catch (e) {
      throw Exception('Erro ao sincronizar: $e');
    }
  }

  Future<List<Map<String, dynamic>>> buscarApontamentos() async {
    try {
      final response = await supabase
          .from('apontamentos')
          .select()
          .order('data_criacao', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Erro ao buscar dados: $e');
    }
  }

  Future<void> atualizarApontamento(String id, Map<String, dynamic> dados) async {
    try {
      await supabase
          .from('apontamentos')
          .update(dados)
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar: $e');
    }
  }

  Future<void> deletarApontamento(String id) async {
    try {
      await supabase
          .from('apontamentos')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar: $e');
    }
  }
}