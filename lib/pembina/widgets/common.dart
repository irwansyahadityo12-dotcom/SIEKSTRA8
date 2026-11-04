import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/profile_screen.dart';
import '../screens/main_shell.dart';

void push(BuildContext c, Widget w) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));
void goTab(BuildContext c, int i) {
  Navigator.of(c).popUntil((r) => r.isFirst);
  tabIndex.value = i;
}

/// Kerangka halaman: header SIEKSTRA-8 + judul + isi + (opsional) tombol bawah.
class Screen extends StatelessWidget {
  final String? title, subtitle, tag;
  final Widget? trailing, bottom;
  final List<Widget> children;
  final bool back;
  const Screen({super.key, this.title, this.subtitle, this.tag, this.trailing, this.bottom, this.back = false, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
              AppHeader(tag: tag),
              if (back)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              const SizedBox(height: 14),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title!, style: T.h1),
                        if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle!, style: T.body.copyWith(fontSize: 14))),
                      ]),
                    ),
                    if (trailing != null) Padding(padding: const EdgeInsets.only(left: 8), child: trailing!),
                  ]),
                ),
              ...children,
            ]),
          ),
          if (bottom != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              color: AppColors.bg,
              child: bottom,
            ),
        ]),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final String? tag;
  const AppHeader({super.key, this.tag});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.school_rounded, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('SIEKSTRA-8', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
            if (tag != null) ...[const SizedBox(width: 6), Pill(tag!, AppColors.redSoft, AppColors.red)],
          ]),
          const Text('Kelola kegiatan dan anggota ekskul', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      ),
      GestureDetector(
        onTap: () => push(context, const ProfileScreen()),
        child: Stack(children: [
          const CircleAvatar(radius: 22, backgroundColor: AppColors.primary, child: Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
          Positioned(
              right: 0,
              bottom: 0,
              child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
        ]),
      ),
    ]);
  }
}

class SCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color, border;
  final VoidCallback? onTap;
  final double bottom;
  const SCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.border, this.onTap, this.bottom = 12});
  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(20);
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: r,
        border: Border.all(color: border ?? AppColors.line),
        boxShadow: const [BoxShadow(color: Color(0x0F1E3A8A), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Material(color: Colors.transparent, child: InkWell(borderRadius: r, onTap: onTap, child: Padding(padding: padding, child: child))),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final IconData? icon;
  const Pill(this.text, this.bg, this.fg, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Flexible(child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12))),
        ]),
      );
}

class Btn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color bg, fg;
  final bool expand;
  final double h;
  const Btn(this.label, {super.key, this.icon, this.onTap, this.bg = AppColors.primary, this.fg = Colors.white, this.expand = false, this.h = 46});
  const Btn.soft(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46})
      : bg = AppColors.soft,
        fg = AppColors.primary;
  const Btn.danger(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46})
      : bg = AppColors.redSoft,
        fg = AppColors.red;
  const Btn.success(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46})
      : bg = AppColors.green,
        fg = Colors.white;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: h,
        width: expand ? double.infinity : null,
        child: ElevatedButton(
          onPressed: onTap ?? () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );
}

class Avatar extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final double size;
  const Avatar(this.text, {super.key, this.bg = AppColors.soft, this.fg = AppColors.primary, this.size = 48});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: size * 0.33)),
      );
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final double size;
  const IconBox(this.icon, {super.key, this.bg = AppColors.soft, this.fg = AppColors.primary, this.size = 48});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.3)),
        child: Icon(icon, color: fg, size: size * 0.5),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(children: [
          Expanded(child: Text(text, style: T.h2)),
          if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
        ]),
      );
}

class SearchField extends StatelessWidget {
  final String hint;
  final IconData? trailing;
  const SearchField(this.hint, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.muted),
            suffixIcon: trailing == null ? null : Icon(trailing, color: AppColors.muted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.line)),
          ),
        ),
      );
}

/// Baris chip filter horizontal.
class Chips extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<int>? onChanged;
  const Chips(this.labels, {super.key, this.onChanged});
  @override
  State<Chips> createState() => _ChipsState();
}

class _ChipsState extends State<Chips> {
  int sel = 0;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < widget.labels.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => sel = i);
                    widget.onChanged?.call(i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel == i ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel == i ? AppColors.primary : AppColors.line),
                    ),
                    child: Text(widget.labels[i], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel == i ? Colors.white : AppColors.primary)),
                  ),
                ),
              ),
          ]),
        ),
      );
}

/// Baris ikon + judul + subjudul + info kanan (dipakai di jadwal, aktivitas, menu profil).
class InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconFg;
  final String title, subtitle;
  final String? top, bottom;
  final Color? bottomColor;
  final VoidCallback? onTap;
  const InfoRow(this.icon, this.title, this.subtitle, {super.key, this.iconBg = AppColors.soft, this.iconFg = AppColors.primary, this.top, this.bottom, this.bottomColor, this.onTap});
  @override
  Widget build(BuildContext context) => SCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          IconBox(icon, bg: iconBg, fg: iconFg),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: T.title),
              const SizedBox(height: 2),
              Text(subtitle, style: T.body),
            ]),
          ),
          if (top != null)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(top!, style: T.title),
              if (bottom != null) Text(bottom!, style: TextStyle(fontSize: 13, color: bottomColor ?? AppColors.muted, fontWeight: FontWeight.w600)),
            ]),
        ]),
      );
}

class FieldTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool chevron;
  const FieldTile(this.icon, this.label, this.value, {super.key, this.chevron = true});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF5F7FF), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
        child: Row(children: [
          IconBox(icon, bg: AppColors.soft, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: T.body.copyWith(fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
            ]),
          ),
          if (chevron)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
              child: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            ),
        ]),
      );
}

class AchievementBanner extends StatelessWidget {
  final String label, title, subtitle, tag;
  const AchievementBanner({super.key, required this.label, required this.title, required this.subtitle, this.tag = 'Bulan Ini'});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE02828), Color(0xFFB91C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x33DC2626), blurRadius: 16, offset: Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFDE047)),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              ]),
            ),
            const Spacer(),
            Text(tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      );
}

class Bar extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  const Bar(this.value, this.color, {super.key, this.track = const Color(0xFFE5E9F5)});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: value, minHeight: 8, color: color, backgroundColor: track),
      );
}
