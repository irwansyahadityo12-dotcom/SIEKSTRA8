import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PembinaRecordFormScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> fields;
  final Map<String, String> initialValues;
  final String submitLabel;

  const PembinaRecordFormScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    this.initialValues = const {},
    this.submitLabel = 'Simpan',
  });

  @override
  State<PembinaRecordFormScreen> createState() => _PembinaRecordFormScreenState();
}

class _PembinaRecordFormScreenState extends State<PembinaRecordFormScreen> {
  final _key = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields
        .map((field) => TextEditingController(text: widget.initialValues[field] ?? ''))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(
        back: true,
        tag: 'PMR',
        title: widget.title,
        subtitle: widget.subtitle,
        children: [
          SCard(
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('INFORMASI KEGIATAN', style: T.label),
                  const SizedBox(height: 14),
                  for (var i = 0; i < widget.fields.length; i++) ...[
                    Text(widget.fields[i], style: T.title),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _controllers[i],
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: widget.fields[i].toLowerCase().contains('deskripsi') ||
                              widget.fields[i].toLowerCase().contains('keterangan')
                          ? 3
                          : 1,
                      decoration: InputDecoration(
                        hintText: 'Masukkan ${widget.fields[i].toLowerCase()}',
                        filled: true,
                        fillColor: const Color(0xFFF1F4FD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? '${widget.fields[i]} wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                  Btn(widget.submitLabel, icon: Icons.save_outlined, expand: true, h: 52,
                      onTap: _save),
                ],
              ),
            ),
          ),
          const InfoRow(Icons.info_outline, 'Mode frontend', 'Data masih berupa simulasi lokal dan belum disimpan ke Supabase.'),
        ],
      );

  void _save() {
    if (!_key.currentState!.validate()) return;
    final result = <String, String>{};
    for (var i = 0; i < widget.fields.length; i++) {
      result[widget.fields[i]] = _controllers[i].text.trim();
    }
    Navigator.of(context).pop(result);
  }
}
