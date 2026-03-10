class WoundConstants {
  static const List<String> sexos = ['Masculino', 'Feminino', 'Outro'];

  static const List<String> coresPele = [
    'Branca',
    'Preta',
    'Amarela',
    'Parda',
    'Indígena',
  ];

  static const Map<String, int> localizacoesMap = {
    'cabeça': 1,
    'face': 2,
    'Membros superiores: região clavicular': 3,
    'Membros superiores: braço': 4,
    'Membros superiores: antebraço': 5,
    'Membros superiores: mão': 6,
    'Membro inferior: região trocantérica': 7,
    'Membro inferior: região proximal da coxa': 8,
    'Membro inferior: terço médio da coxa': 9,
    'Membro inferior: região distal da coxa': 10,
    'Membro inferior: anterior da coxa': 11,
    'Membro inferior: lateral da coxa': 12,
    'Membro inferior: posterior da coxa': 13,
    'Membro inferior: face interna': 14,
    'Membro inferior: região patelar': 15,
    'Membro inferior: região proximal da perna': 16,
    'Membro inferior: terço médio': 17,
    'Membro inferior: região distal da perna': 18,
    'Membro inferior: face posterior': 19,
    'Membro inferior: face anterior': 20,
    'Membro inferior: face externa': 21,
    'Membro inferior: região maleolar': 22,
    'Membro inferior: região dorsal do pé': 23,
    'Membro inferior: região plantar do pé': 24,
    'Membro inferior: calcanhar': 25,
    'Região sacrococcígea': 26,
    'Região torácica': 27,
    'Região abdominal': 28,
    'Região dorsal': 29,
  };

  static const List<String> formas = [
    'arredondada/oval',
    'irregular',
    'linear',
  ];

  static const Map<String, String> formasLabels = {
    'arredondada/oval': 'Arredondada/Oval',
    'irregular': 'Irregular',
    'linear': 'Linear',
  };

  static const List<String> tiposTecido = [
    'granulação',
    'necrose',
    'esfacelo',
    'fibrina',
    'epitelização',
  ];

  static const Map<String, String> tiposTecidoLabels = {
    'granulação': 'Granulação',
    'necrose': 'Necrose',
    'esfacelo': 'Esfacelo',
    'fibrina': 'Fibrina',
    'epitelização': 'Epitelização',
  };

  // Só este é necessário como Map
  static const Map<String, int> tiposTecidoMap = {
    'granulação': 1,
    'necrose': 2,
    'esfacelo': 3,
    'fibrina': 4,
    'epitelização': 5,
  };

  static const List<String> causas = ['Intencional', 'Não intencional'];

  static const Map<String, String> causasLabels = {
    'Intencional': 'Intencional',
    'Não intencional': 'Não intencional',
    'outro': 'Outro',
  };

  static const List<String> origens = [
    'neoplasia',
    'úlcera venosa',
    'úlcera arterial',
    'lesão por pressão',
    'parasitária',
  ];

  static const Map<String, String> origensLabels = {
    'neoplasia': 'Neoplasia',
    'úlcera venosa': 'Úlcera venosa',
    'úlcera arterial': 'Úlcera arterial',
    'lesão por pressão': 'Lesão por pressão',
    'parasitária': 'Parasitária',
    'outro': 'Outro',
  };

  static const List<String> faixaExtensoesLesao = [
    'Pequena: Até 3 cm²',
    'Média: De 3,1 a 10 cm²',
    'Grande: De 10,1 a 25 cm²',
    'Muito grande: Acima de 25 cm²',
  ];

  static const List<String> faixasIdade = ['< 20', '20-59', '60+'];

  /// Filtros disponíveis para busca de feridas (labels na mesma ordem).
  static const List<String> filtrosDisponiveis = [
    'idade',
    'sexo',
    'cor_pele',
    'localizacao_anatomica_id',
    'forma',
    'origem',
    'causa',
    'tipo_tecido',
    'extensao_lesao',
    'paciente_id',
  ];

  static const List<String> filtrosDisponiveisLabels = [
    'Idade',
    'Sexo',
    'Cor da Pele',
    'Localização Anatômica',
    'Forma',
    'Origem',
    'Causa',
    'Tipo de Tecido',
    'Extensão da Lesão',
    'ID do Paciente',
  ];
}
