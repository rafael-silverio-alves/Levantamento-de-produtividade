import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/apontamento_provider.dart';

class ApontamentosScreen extends StatefulWidget {
  const ApontamentosScreen({super.key});

  @override
  State<ApontamentosScreen> createState() => _ApontamentosScreenState();
}

class _ApontamentosScreenState extends State<ApontamentosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroFrutosController = TextEditingController();
  final TextEditingController _pesoMedioController = TextEditingController();
  
  final List<String> variedades = ['Coronel', 'Kardeal', 'Compack'];
  final List<int> blocos = List.generate(10, (i) => i + 1);
  
  String? selectedVariedade;
  int? selectedBloco;
  int currentCacho = 1;
  int currentNumeroAmostra = 1;
  List<Map<String, dynamic>> _registrosPendentes = [];

  @override
  void dispose() {
    _numeroFrutosController.dispose();
    _pesoMedioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Apontamentos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_registrosPendentes.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _salvarTodosRegistros,
                  tooltip: 'Salvar todos',
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_registrosPendentes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCard(
                        title: 'Configuração da Área',
                        icon: Icons.agriculture,
                        children: [
                          _buildDropdownField(
                            label: 'Variedade',
                            icon: Icons.eco,
                            value: selectedVariedade,
                            items: variedades,
                            onChanged: (value) => setState(() => selectedVariedade = value),
                            validator: (value) => value == null ? 'Selecione a variedade' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            label: 'Bloco',
                            icon: Icons.crop_square,
                            value: selectedBloco,
                            items: blocos,
                            onChanged: (value) => setState(() => selectedBloco = value),
                            validator: (value) => value == null ? 'Selecione o bloco' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildCard(
                        title: 'Apontamento Atual',
                        icon: Icons.edit_note,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStepperField(
                                  label: 'Cacho',
                                  value: currentCacho,
                                  min: 1,
                                  max: 6,
                                  onChanged: (value) => setState(() => currentCacho = value),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStepperField(
                                  label: 'Amostra',
                                  value: currentNumeroAmostra,
                                  min: 1,
                                  max: 10,
                                  onChanged: (value) => setState(() => currentNumeroAmostra = value),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Número de Frutos',
                            icon: Icons.numbers,
                            controller: _numeroFrutosController,
                            keyboardType: TextInputType.number,
                            isOptional: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Digite um número válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Peso Médio dos Frutos',
                            icon: Icons.scale,
                            controller: _pesoMedioController,
                            keyboardType: TextInputType.number,
                            isOptional: true,
                            suffixText: 'g',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Adicionadas: ${_registrosPendentes.length} amostras | '
                                'Bloco ${selectedBloco ?? '-'} | Cacho $currentCacho',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              _buildActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.toString(), style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildStepperField({
    required String label,
    required int value,
    required int min,
    required int max,
    required void Function(int) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.green.shade700),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Container(
                width: 50,
                child: Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.green.shade700),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
    bool isOptional = false,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isOptional ? '$label (opcional)' : label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _adicionarAmostra,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Adicionar Amostra',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _adicionarAmostra() {
    // Validar campos principais
    if (selectedVariedade == null) {
      _showError('Selecione a variedade');
      return;
    }
    if (selectedBloco == null) {
      _showError('Selecione o bloco');
      return;
    }
    
    // Validar número de frutos
    if (_numeroFrutosController.text.isEmpty) {
      _showError('Digite o número de frutos');
      return;
    }
    
    final numeroFrutos = int.tryParse(_numeroFrutosController.text);
    if (numeroFrutos == null) {
      _showError('Número de frutos inválido');
      return;
    }
    
    // Peso médio (opcional)
    double? pesoMedio;
    if (_pesoMedioController.text.isNotEmpty) {
      pesoMedio = double.tryParse(_pesoMedioController.text);
      if (pesoMedio == null) {
        _showError('Peso médio inválido');
        return;
      }
    }
    
    // Adicionar à lista pendente
    setState(() {
      _registrosPendentes.add({
        'variedade': selectedVariedade,
        'bloco': selectedBloco,
        'cacho': currentCacho,
        'amostra': currentNumeroAmostra,
        'numeroFrutos': numeroFrutos,
        'pesoMedio': pesoMedio,
      });
    });
    
    // Limpar campos
    _numeroFrutosController.clear();
    _pesoMedioController.clear();
    
    // Mostrar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Amostra ${currentCacho}.${currentNumeroAmostra} adicionada'),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 500),
      ),
    );
    
    // Avançar para a próxima amostra
    _avancarProximaAmostra();
  }
  
  void _avancarProximaAmostra() {
    setState(() {
      if (currentNumeroAmostra < 10) {
        currentNumeroAmostra++;
      } else if (currentCacho < 6) {
        currentCacho++;
        currentNumeroAmostra = 1;
      }
    });
  }
  
  void _salvarTodosRegistros() async {
    if (_registrosPendentes.isEmpty) {
      _showError('Nenhum registro para salvar');
      return;
    }
    
    final provider = Provider.of<ApontamentoProvider>(context, listen: false);
    
    for (var registro in _registrosPendentes) {
      try {
        await provider.salvarApontamento(
          variedade: registro['variedade']!,
          bloco: registro['bloco']!,
          cacho: registro['cacho']!,
          numeroAmostra: registro['amostra']!,
          numeroFrutos: registro['numeroFrutos']!,
          pesoMedioFrutos: registro['pesoMedio'],
        );
        print('✅ Salvo: ${registro['cacho']}.${registro['amostra']}');
      } catch (e) {
        print('❌ Erro ao salvar: $e');
        _showError('Erro ao salvar: $e');
        return;
      }
    }
    
    final count = _registrosPendentes.length;
    setState(() {
      _registrosPendentes.clear();
    });
    
    _showSuccess('$count registro(s) salvo(s) com sucesso!');
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}