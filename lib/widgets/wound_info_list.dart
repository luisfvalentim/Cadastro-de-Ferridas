import 'package:cadastro_dados/custom/custom_info_row.dart';
import 'package:flutter/material.dart';
import '../models/wound.dart';
import '../constats/wound_constants.dart';

class WoundInfoList extends StatelessWidget {
  final Wound wound;

  const WoundInfoList({super.key, required this.wound});

  String labelFromMap(Map<String, String> map, String? key) {
    if (key == null) return 'N/A';
    return map[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInfoRow(label: 'Idade', value: wound.idade?.toString() ?? 'N/A'),
        CustomInfoRow(
          label: 'Id Paciente',
          value: wound.pacienteId?.toString() ?? 'N/A',
        ),
        CustomInfoRow(label: 'Sexo', value: wound.sexo ?? 'N/A'),
        CustomInfoRow(label: 'Cor da Pele', value: wound.corPele ?? 'N/A'),
        CustomInfoRow(
          label: 'Localizações',
          value:
              (wound.localizacoesDescricao != null &&
                      wound.localizacoesDescricao!.isNotEmpty)
                  ? wound.localizacoesDescricao!
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final loc = entry.value;
                        final id = wound.localizacoes?[index];
                        if (loc.toLowerCase() == 'outro' &&
                            wound.localizacoesObservacao != null &&
                            id != null &&
                            wound.localizacoesObservacao![id] != null &&
                            wound.localizacoesObservacao![id]!.isNotEmpty) {
                          return wound.localizacoesObservacao![id]!;
                        }
                        return loc;
                      })
                      .join(', ')
                  : 'N/A',
        ),
        CustomInfoRow(
          label: 'Formato',
          value: labelFromMap(WoundConstants.formasLabels, wound.forma),
        ),
        CustomInfoRow(
          label: 'Origem',
          value:
              (wound.origem?.toLowerCase() == 'outro' &&
                      (wound.origemOutro?.isNotEmpty ?? false))
                  ? wound.origemOutro!
                  : labelFromMap(WoundConstants.origensLabels, wound.origem),
        ),

        CustomInfoRow(
          label: 'Causa',
          value:
              (wound.causa?.toLowerCase() == 'outro' &&
                      (wound.causaOutro?.isNotEmpty ?? false))
                  ? wound.causaOutro!
                  : labelFromMap(WoundConstants.causasLabels, wound.causa),
        ),
        CustomInfoRow(
          label: 'Extensão da Lesão',
          value: '${wound.extensaoLesao ?? 'N/A'} cm²',
        ),
        CustomInfoRow(label: 'Evolução', value: wound.evolucao ?? 'N/A'),
        CustomInfoRow(
          label: 'Data de Registro',
          value: wound.dataRegistro ?? 'N/A',
        ),
        CustomInfoRow(
          label: 'Tipos de Tecido',
          value:
              (wound.tiposTecidoDescricao != null &&
                      wound.tiposTecidoDescricao!.isNotEmpty)
                  ? wound.tiposTecidoDescricao!
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final descricao = entry.value;

                        if (descricao.toLowerCase() == 'outro') {
                          final id = wound.tiposTecido?[index];
                          final obs = wound.tiposTecidoObservacao?[id];
                          return obs != null && obs.isNotEmpty ? obs : 'Outro';
                        }

                        return descricao;
                      })
                      .join(', ')
                  : 'N/A',
        ),
      ],
    );
  }
}
