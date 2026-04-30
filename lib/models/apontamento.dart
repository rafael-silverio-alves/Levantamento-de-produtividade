class Apontamento {
  String id;
  String variedade;
  int bloco;
  int cacho;
  int numeroAmostra;
  int numeroFrutos;
  double? pesoMedioFrutos;
  DateTime dataCriacao;
  DateTime? dataSincronizacao;
  bool sincronizado;

  Apontamento({
    required this.id,
    required this.variedade,
    required this.bloco,
    required this.cacho,
    required this.numeroAmostra,
    required this.numeroFrutos,
    this.pesoMedioFrutos,
    required this.dataCriacao,
    this.dataSincronizacao,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'variedade': variedade,
      'bloco': bloco,
      'cacho': cacho,
      'numeroAmostra': numeroAmostra,
      'numeroFrutos': numeroFrutos,
      'pesoMedioFrutos': pesoMedioFrutos,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataSincronizacao': dataSincronizacao?.toIso8601String(),
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  factory Apontamento.fromMap(Map<String, dynamic> map) {
    return Apontamento(
      id: map['id'],
      variedade: map['variedade'],
      bloco: map['bloco'],
      cacho: map['cacho'],
      numeroAmostra: map['numeroAmostra'],
      numeroFrutos: map['numeroFrutos'],
      pesoMedioFrutos: map['pesoMedioFrutos']?.toDouble(),
      dataCriacao: DateTime.parse(map['dataCriacao']),
      dataSincronizacao: map['dataSincronizacao'] != null
          ? DateTime.parse(map['dataSincronizacao'])
          : null,
      sincronizado: map['sincronizado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variedade': variedade,
      'bloco': bloco,
      'cacho': cacho,
      'numero_amostra': numeroAmostra,
      'numero_frutos': numeroFrutos,
      'peso_medio_frutos': pesoMedioFrutos,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_sincronizacao': dataSincronizacao?.toIso8601String(),
      'sincronizado': sincronizado,
    };
  }
}