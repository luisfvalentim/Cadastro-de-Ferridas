class Wound {
  final int? id;
  final int? pacienteId;
  final String? sexo;
  final String? corPele;
  final int? idade;

  final int? localizacaoAnatomicaId;
  final String? localizacaoAnatomica;

  final String? causa;
  final String? origem;
  final double? comprimento;
  final double? largura;
  final double? extensaoLesao;
  final String? evolucao;
  final String? forma;
  final String? dataRegistro;

  final List<int>? tiposTecido;
  final List<String>? tiposTecidoDescricao;

  Wound({
    this.id,
    this.pacienteId,
    this.sexo,
    this.corPele,
    this.idade,
    this.localizacaoAnatomicaId,
    this.localizacaoAnatomica,
    this.causa,
    this.origem,
    this.comprimento,
    this.largura,
    this.extensaoLesao,
    this.evolucao,
    this.forma,
    this.dataRegistro,
    this.tiposTecido,
    this.tiposTecidoDescricao,
  });

  factory Wound.fromJson(Map<String, dynamic> json) {
    return Wound(
      id: json['id'],
      pacienteId: json['paciente_id'],
      sexo: json['paciente']?['sexo'],
      corPele: json['paciente']?['cor_pele'],
      idade: json['paciente']?['idade'],
      localizacaoAnatomicaId: json['localizacao_anatomica_id'],
      localizacaoAnatomica: json['localizacao']?['descricao'],
      causa: json['causa'],
      origem: json['origem'],
      comprimento: (json['comprimento'] as num?)?.toDouble(),
      largura: (json['largura'] as num?)?.toDouble(),
      extensaoLesao: (json['extensao_lesao'] as num?)?.toDouble(),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paciente_id': pacienteId,
      'paciente': {'sexo': sexo, 'cor_pele': corPele, 'idade': idade},
      'localizacao_anatomica_id': localizacaoAnatomicaId,
      'causa': causa,
      'origem': origem,
      'comprimento': comprimento,
      'largura': largura,
      'extensao_lesao': extensaoLesao,
      'evolucao': evolucao,
      'forma': forma,
      'data_registro': dataRegistro,
      'tipos_tecido': tiposTecido,
    };
  }
}
