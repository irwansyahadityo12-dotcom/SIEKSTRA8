import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/gemini_service.dart';
import '../../app/session.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class GeminiAiScreen extends StatefulWidget {
  const GeminiAiScreen({super.key});

  @override
  State<GeminiAiScreen> createState() => _GeminiAiScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _GeminiAiScreenState extends State<GeminiAiScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Rekomendasi ekskul untuk jurusan RPL',
    'Bantu buat draf izin tidak hadir ekskul',
    'Tips mempersiapkan seleksi & lomba robotik',
    'Jadwal umum ekskul di SMKN 8 Malang',
    'Cara membagi waktu antara tugas & ekskul',
  ];

  @override
  void initState() {
    super.initState();
    _initWelcomeMessage();
  }

  void _initWelcomeMessage() {
    final name = currentUserName;
    _messages.add(
      _ChatMessage(
        text: '✨ **Halo $name!**\n\n'
            'Saya adalah **Gemini AI**, asisten cerdas resmi untuk **SIEKSTRA-8 SMKN 8 Malang**.\n\n'
            'Ada yang ingin kamu tanyakan hari ini seputar kegiatan ekstrakurikuler, rekomendasi minat bakat, pembuatan surat izin, atau persiapan lomba?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final query = presetText ?? _textController.text.trim();
    if (query.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: query, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Bangun riwayat obrolan untuk konteks
    final history = _messages
        .take(_messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    try {
      final reply = await GeminiService.sendMessage(
        message: query,
        history: history,
      );

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: reply, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: '⚠️ Terjadi kesalahan: $e',
              isUser: false,
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mulai Percakapan Baru?'),
        content: const Text('Riwayat percakapan saat ini akan dibersihkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _initWelcomeMessage();
              });
            },
            child: const Text('Bersihkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: GeminiService.apiKey);
    String selectedModel = GeminiService.activeModel;
    bool isTesting = false;
    String? testResult;
    bool? testSuccess;

    final availableOptions = [
      'gemini-1.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-pro',
      'gemini-pro',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.key, color: C.primary),
              SizedBox(width: 8),
              Text('Google Gemini API Key', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan API Key dari Google AI Studio (aistudio.google.com). Kunci ini gratis.',
                  style: TextStyle(fontSize: 12.5, color: C.muted),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'AIzaSy...',
                    labelText: 'Gemini API Key',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        controller.clear();
                        setDialogState(() {
                          testResult = null;
                          testSuccess = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    side: BorderSide(color: C.primary.withOpacity(0.5)),
                  ),
                  onPressed: isTesting
                      ? null
                      : () async {
                          final testKey = controller.text.trim();
                          if (testKey.isEmpty) {
                            setDialogState(() {
                              testResult = 'Masukkan API Key terlebih dahulu.';
                              testSuccess = false;
                            });
                            return;
                          }
                          setDialogState(() {
                            isTesting = true;
                            testResult = null;
                          });
                          final res = await GeminiService.testApiKeyConnection(testKey);
                          setDialogState(() {
                            isTesting = false;
                            testSuccess = res['success'] == true;
                            testResult = res['message']?.toString() ?? '';
                          });
                        },
                  icon: isTesting
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.network_check, size: 18),
                  label: Text(
                    isTesting ? 'Sedang menguji...' : 'Uji Koneksi API Key Google',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (testResult != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: testSuccess == true ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: testSuccess == true ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          testSuccess == true ? Icons.check_circle : Icons.error_outline,
                          size: 16,
                          color: testSuccess == true ? C.green : C.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            testResult!,
                            style: TextStyle(
                              fontSize: 11,
                              color: testSuccess == true ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text('Pilihan Model:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: availableOptions.contains(selectedModel) ? selectedModel : 'gemini-1.5-flash',
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: availableOptions.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(m, style: const TextStyle(fontSize: 12.5)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedModel = val);
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  '*Jika API Key belum diset atau Google API bermasalah, asisten akan otomatis menjawab dengan Mode Pengetahuan Cerdas SIEKSTRA-8.',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: C.muted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: C.primary),
              onPressed: () async {
                final key = controller.text.trim();
                GeminiService.setApiKey(key);
                GeminiService.setModel(selectedModel);
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      key.isNotEmpty
                          ? 'Pengaturan API Key disimpan. Mode cerdas aktif.'
                          : 'API Key dikosongkan. Beralih ke Mode Asisten Lokal SIEKSTRA.',
                    ),
                  ),
                );
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF2563EB), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    tx('Gemini AI', size: 16, w: FontWeight.w800, color: C.text),
                    const SizedBox(width: 6),
                    Pill('SIEKSTRA', size: 9, bg: C.purpleBg, fg: C.purple),
                  ],
                ),
                ValueListenableBuilder<String>(
                  valueListenable: GeminiService.apiKeyNotifier,
                  builder: (_, key, __) {
                    final isLive = key.isNotEmpty;
                    return ValueListenableBuilder<String>(
                      valueListenable: GeminiService.activeModelNotifier,
                      builder: (_, model, __) {
                        return Row(
                          children: [
                            Icon(Icons.circle, size: 7, color: isLive ? C.green : C.amber),
                            const SizedBox(width: 4),
                            tx(
                              isLive ? 'Online • $model' : 'Mode Asisten Cerdas',
                              size: 10.5,
                              color: C.muted,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaturan API Key',
            icon: const Icon(Icons.settings_outlined, color: C.muted),
            onPressed: _showApiKeyDialog,
          ),
          IconButton(
            tooltip: 'Hapus Chat',
            icon: const Icon(Icons.refresh_outlined, color: C.muted),
            onPressed: _clearChat,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Banner Info Singkat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF))),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: C.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: tx(
                    'Tanyakan seputar ekskul SMKN 8 Malang, draf izin, jadwal, dan tips kompetisi.',
                    size: 11.5,
                    color: C.primary,
                  ),
                ),
              ],
            ),
          ),

          // Daftar Pesan Chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingBubble();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Quick Chips Rekomendasi Pertanyaan
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: C.primary),
                  ),
                  backgroundColor: C.soft,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => _handleSend(prompt),
                );
              },
            ),
          ),

          // Area Input Chat
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _handleSend(),
                              decoration: const InputDecoration(
                                hintText: 'Ketik pertanyaan untuk Gemini AI...',
                                hintStyle: TextStyle(fontSize: 13, color: C.muted),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: C.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : () => _handleSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? C.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: isUser ? Colors.white : C.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : C.muted,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Teks disalin ke papan klip'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy_outlined, size: 13, color: C.muted),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: C.soft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userInitials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: C.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: C.primary),
                ),
                SizedBox(width: 10),
                Text(
                  'Gemini sedang berpikir...',
                  style: TextStyle(fontSize: 12, color: C.muted, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
