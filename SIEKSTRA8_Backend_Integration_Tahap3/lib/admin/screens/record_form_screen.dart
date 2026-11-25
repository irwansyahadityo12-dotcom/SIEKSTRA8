import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdminRecordFormScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<String> fields;
  final String submitLabel;
  final Map<String, String> initialValues;
  final Map<String, List<String>> fieldOptions;

  const AdminRecordFormScreen({
    super.key,
    required this.title,
    required this.description,
    required this.fields,
    this.submitLabel = 'Simpan Data',
    this.initialValues = const {},
    this.fieldOptions = const {},
  });

  @override
  State<AdminRecordFormScreen> createState() => _AdminRecordFormScreenState();
}

class _AdminRecordFormScreenState extends State<AdminRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.fields.length,
      (index) {
        final fieldName = widget.fields[index];
        final initial = widget.initialValues[fieldName];
        if (initial != null && initial.isNotEmpty) {
          return TextEditingController(text: initial);
        }
        if (widget.fieldOptions.containsKey(fieldName) &&
            widget.fieldOptions[fieldName]!.isNotEmpty) {
          return TextEditingController(text: widget.fieldOptions[fieldName]!.first);
        }
        return TextEditingController();
      },
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      back: 'Kembali',
      title: widget.title,
      subtitle: widget.description,
      children: [
        SCard(child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('INFORMASI DATA', style: T.label),
            const SizedBox(height: 14),
            for (var i = 0; i < widget.fields.length; i++) ...[
              Text(widget.fields[i], style: T.title),
              const SizedBox(height: 7),
              if (widget.fieldOptions.containsKey(widget.fields[i]))
                DropdownButtonFormField<String>(
                  value: widget.fieldOptions[widget.fields[i]]!.contains(_controllers[i].text)
                      ? _controllers[i].text
                      : (widget.fieldOptions[widget.fields[i]]!.isNotEmpty
                          ? widget.fieldOptions[widget.fields[i]]!.first
                          : null),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: C.field,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: C.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: C.primary, width: 1.5)),
                  ),
                  items: widget.fieldOptions[widget.fields[i]]!
                      .map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: T.title.copyWith(fontSize: 14))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) _controllers[i].text = val;
                  },
                )
              else
                TextFormField(
                  controller: _controllers[i],
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ${widget.fields[i].toLowerCase()}',
                    filled: true,
                    fillColor: C.field,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: C.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: C.primary, width: 1.5)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '${widget.fields[i]} wajib diisi' : null,
                ),
              const SizedBox(height: 14),
            ],
            Btn(widget.submitLabel, icon: Icons.save_outlined, expand: true, h: 52, onTap: _save),
          ]),
        )),
        const InfoCard(Icons.info_outline, 'Mode frontend', 'Form ini saat ini memvalidasi input dan menampilkan konfirmasi lokal. Penyimpanan permanen akan diaktifkan saat integrasi Supabase dilakukan.'),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final values = <String, String>{};
    for (var i = 0; i < widget.fields.length; i++) {
      values[widget.fields[i]] = _controllers[i].text.trim();
    }
    // Nilai form dikembalikan ke pemanggil agar dapat dipakai pada state lokal.
    toast(context, 'Validasi berhasil. Data belum dikirim ke database.');
    Navigator.of(context).pop(values);
  }
}
