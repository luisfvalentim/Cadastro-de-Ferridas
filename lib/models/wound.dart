class Wound {
  final int? id;
  final int? imagemId;
  final String? imagemUrl;
  final int? pacienteId;
  final String? sexo;
  final String? corPele;
  final int? idade;
  final String? dataNascimento;

  final int? localizacaoAnatomicaId;
  final String? localizacaoAnatomica;
  final List<int>? localizacoes;
  final List<String>? localizacoesDescricao;
  final Map<int, String?>? localizacoesObservacao;

  final String? causa;
  final String? causaOutro;
  final String? origem;
  final String? origemOutro;
  final double? comprimento;
  final double? largura;
  final double? extensaoLesao;
  final String? evolucao;
  final String? forma;
  final String? dataRegistro;

  final List<int>? tiposTecido;
  final List<String>? tiposTecidoDescricao;
  final Map<int, String?>? tiposTecidoObservacao;

  Wound({
    this.id,
    this.imagemId,
    this.imagemUrl,
    this.pacienteId,
    this.sexo,
    this.corPele,
    this.idade,
    this.dataNascimento,
    this.localizacaoAnatomicaId,
    this.localizacaoAnatomica,
    this.localizacoes,
    this.localizacoesDescricao,
    this.localizacoesObservacao,
    this.causa,
    this.causaOutro,
    this.origem,
    this.origemOutro,
    this.comprimento,
    this.largura,
    this.extensaoLesao,
    this.evolucao,
    this.forma,
    this.dataRegistro,
    this.tiposTecido,
    this.tiposTecidoDescricao,
    this.tiposTecidoObservacao,
  });

  factory Wound.fromJson(Map<String, dynamic> json) {
    double? _parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    return Wound(
      id: json['id'],
      imagemId: json['imagem_id'],
      imagemUrl: json['imagem_url'],
      pacienteId: json['paciente_id'],
      sexo: json['paciente']?['sexo'],
      corPele: json['paciente']?['cor_pele'],
      idade: json['paciente']?['idade'],
      dataNascimento: json['paciente']?['data_nascimento'],
      localizacaoAnatomicaId: json['localizacao_anatomica_id'],
      localizacaoAnatomica: json['localizacao']?['descricao'],
      localizacoes:
          (json['localizacoes'] as List<dynamic>?)
              ?.map((e) => e['id'] as int)
              .toList(),
      localizacoesDescricao:
          (json['localizacoes'] as List<dynamic>?)
              ?.map((e) => e['descricao'] as String)
              .toList(),
      localizacoesObservacao: (json['localizacoes'] as List<dynamic>?)
          ?.fold<Map<int, String?>>({}, (map, e) {
            map[e['id']] = e['pivot']?['observacao'];
            return map;
          }),
      causa: json['causa'],
      causaOutro: json['causa_outro'],
      origem: json['origem'],
      origemOutro: json['origem_outro'],
      comprimento: _parseDouble(json['comprimento']),
      largura: _parseDouble(json['largura']),
      extensaoLesao: _parseDouble(json['extensao_lesao']),
      evolucao: json['evolucao'],
      forma: json['forma'],
      dataRegistro: json['data_registro'],
      tiposTecido:
          (json['tipos_tecido'] as List<dynamic>?)
              ?.map((e) => e['id'] as int)
              .toList(),
      tiposTecidoDescricao:
          (json['tipos_tecido'] as List<dynamic>?)
              ?.map((e) => e['descricao'] as String)
              .toList(),
      tiposTecidoObservacao: (json['tipos_tecido'] as List<dynamic>?)
          ?.fold<Map<int, String?>>({}, (map, e) {
            map[e['id']] = e['pivot']?['observacao'];
            return map;
          }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagem_id': imagemId,
      'imagem_url': imagemUrl,
      'paciente_id': pacienteId,
      'paciente': {
        'sexo': sexo,
        'cor_pele': corPele,
        'idade': idade,
        'data_nascimento': dataNascimento,
      },
      'localizacao_anatomica_id': localizacaoAnatomicaId,
      'localizacoes':
          (localizacoes ?? [])
              .map(
                (id) => {
                  'id': id,
                  if (localizacoesObservacao != null &&
                      localizacoesObservacao![id] != null &&
                      localizacoesObservacao![id]!.isNotEmpty)
                    'observacao': localizacoesObservacao![id],
                },
              )
              .toList(),
      'causa': causa,
      'causa_outro': causaOutro,
      'origem': origem,
      'origem_outro': origemOutro,
      'comprimento': comprimento,
      'largura': largura,
      'extensao_lesao': extensaoLesao,
      'evolucao': evolucao,
      'forma': forma,
      'data_registro': dataRegistro,
      'tipos_tecido': (tiposTecido ?? [])
          .map(
            (id) => {
              'id': id,
              if (tiposTecidoObservacao != null &&
                  tiposTecidoObservacao![id]?.isNotEmpty == true)
                'observacao': tiposTecidoObservacao![id],
            },
          )
          .toList(),
    };
  }
}
