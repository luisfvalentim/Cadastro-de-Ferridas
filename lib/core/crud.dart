import 'package:supabase_flutter/supabase_flutter.dart';

enum FaixaLesao { pequena, media, grande, muitoGrande }

class SupaBaseCrudService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  SupaBaseCrudService();

  Future<Map<String, dynamic>?> create(Map<String, dynamic> data) async {
    final response =
        await _supabaseClient.from('pessoas').insert(data).select().single();
    return response;
  }

  Future<List<Map<String, dynamic>>> read() async {
    final response = await _supabaseClient.from('pessoas').select();
    return response.map((item) => item).toList();
  }

  Future<List<Map<String, dynamic>>> readBySpecific(
    String _campoSelecionado,
    String _valorCampo,
  ) async {
    final response = await _supabaseClient
        .from('pessoas')
        .select()
        .ilike(_campoSelecionado!, _valorCampo ?? '');
    return response.map((item) => item).toList();
  }

  Future<List<Map<String, dynamic>>> readByCure(String valorCampo) async {
    final response = await _supabaseClient
        .from('pessoas')
        .select()
        .eq('ferida_curada', valorCampo == 'Sim' ? true : false);
    return response.map((item) => item).toList();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _supabaseClient.from('pessoas').update(data).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _supabaseClient.from('pessoas').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> readByFaixaEtaria({
    required bool menor20,
    required bool entre20e59,
    required bool maior60,
  }) async {
    final now = DateTime.now();
    final idade20 = DateTime(now.year - 20, now.month, now.day);
    final idade59 = DateTime(now.year - 59, now.month, now.day);
    final idade60 = DateTime(now.year - 60, now.month, now.day);

    final query = _supabaseClient.from('pessoas').select();

    List<String> conditions = [];

    if (menor20) {
      conditions.add("idade.gt.${idade20.toIso8601String()}");
    }

    if (entre20e59) {
      conditions.add(
        "and(idade.lte.${idade20.toIso8601String()},idade.gte.${idade59.toIso8601String()})",
      );
    }

    if (maior60) {
      conditions.add("idade.lt.${idade60.toIso8601String()}");
    }

    if (conditions.isEmpty) {
      return [];
    }

    final filtro = conditions.join(',');

    final response = await query.or(filtro);

    return response.map((item) => item).toList();
  }

  Future<List<Map<String, dynamic>>> readPorFaixa(FaixaLesao faixa) async {
    final query = _supabaseClient.from('pessoas').select();

    switch (faixa) {
      case FaixaLesao.pequena:
        return await query.lte('extensao_lesao', 3);
      case FaixaLesao.media:
        return await query.gte('extensao_lesao', 3.1).lte('extensao_lesao', 10);
      case FaixaLesao.grande:
        return await query
            .gte('extensao_lesao', 10.1)
            .lte('extensao_lesao', 25);
      case FaixaLesao.muitoGrande:
        return await query.gt('extensao_lesao', 25);
    }
  }
}
