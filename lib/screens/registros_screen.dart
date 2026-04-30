import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/apontamento_provider.dart';

class RegistrosScreen extends StatefulWidget {
  const RegistrosScreen({super.key});

  @override
  State<RegistrosScreen> createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends State<RegistrosScreen> {
  String? _filtroVariedade;
  int? _filtroBloco;
  String _searchQuery = '';

  List<Map<String, dynamic>> get _registrosFiltrados {
    final provider = Provider.of<ApontamentoProvider>(context, listen: false);
    return provider.apontamentos.where((registro) {
      if (_filtroVariedade != null && registro['variedade'] != _filtroVariedade) {
        return false;
      }
      if (_filtroBloco != null && registro['bloco'] != _filtroBloco) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return registro['variedade'].toLowerCase().contains(query) ||
               registro['bloco'].toString().contains(query) ||
               registro['cacho'].toString().contains(query);
      }
      return true;
    }).toList();
  }

  void _excluirRegistro(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão', style: GoogleFonts.poppins()),
        content: Text('Tem certeza que deseja excluir este registro?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<ApontamentoProvider>(context, listen: false).deletarApontamento(id);
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registro excluído!'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editarRegistro(Map<String, dynamic> registro) {
    final formKey = GlobalKey<FormState>();
    final numeroFrutosController = TextEditingController(text: registro['numeroFrutos'].toString());
    final pesoMedioController = TextEditingController(text: registro['pesoMedioFrutos']?.toString() ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Editar Registro', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Variedade: ${registro['variedade']}', style: GoogleFonts.poppins()),
              Text('Bloco: ${registro['bloco']} | Cacho: ${registro['cacho']} | Amostra: ${registro['numeroAmostra']}', style: GoogleFonts.poppins()),
              const SizedBox(height: 16),
              TextFormField(
                controller: numeroFrutosController,
                decoration: InputDecoration(
                  labelText: 'Número de Frutos',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pesoMedioController,
                decoration: InputDecoration(
                  labelText: 'Peso Médio (g)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await Provider.of<ApontamentoProvider>(context, listen: false).atualizarApontamento(
                        registro['id'],
                        numeroFrutos: int.parse(numeroFrutosController.text),
                        pesoMedioFrutos: pesoMedioController.text.isNotEmpty 
                            ? double.parse(pesoMedioController.text) 
                            : null,
                      );
                      Navigator.pop(context);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registro atualizado!'), backgroundColor: Colors.green),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Salvar Alterações', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApontamentoProvider>(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Registros', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFiltroDropdown(
                        label: 'Variedade',
                        value: _filtroVariedade,
                        items: ['Coronel', 'Kardeal', 'Compack'],
                        onChanged: (value) => setState(() => _filtroVariedade = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFiltroDropdown(
                        label: 'Bloco',
                        value: _filtroBloco?.toString(),
                        items: List.generate(10, (i) => (i + 1).toString()),
                        onChanged: (value) => setState(() => _filtroBloco = value != null ? int.parse(value) : null),
                      ),
                    ),
                    if (_filtroVariedade != null || _filtroBloco != null || _searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _filtroVariedade = null;
                          _filtroBloco = null;
                          _searchQuery = '';
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _registrosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text('Nenhum registro encontrado', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _registrosFiltrados.length,
                        itemBuilder: (context, index) {
                          final registro = _registrosFiltrados[index];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${registro['cacho']}.${registro['numeroAmostra']}',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                ),
                              ),
                              title: Text(
                                '${registro['variedade']} - Bloco ${registro['bloco']}',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Frutos: ${registro['numeroFrutos']}${registro['pesoMedioFrutos'] != null ? ' | Peso: ${registro['pesoMedioFrutos']}g' : ''}',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  Text(
                                    dateFormat.format(DateTime.parse(registro['dataCriacao'])),
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!registro['sincronizado'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('Pendente', style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange.shade800)),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue.shade700),
                                    onPressed: () => _editarRegistro(registro),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red.shade700),
                                    onPressed: () => _excluirRegistro(registro['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
      ],
      onChanged: onChanged,
    );
  }
}