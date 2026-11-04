import 'package:flutter/material.dart';
import '../theme.dart';
import '../shell.dart';

void push(BuildContext c, Widget w) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));
void toast(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

/// Kerangka halaman admin: header + (opsional) tautan kembali + judul + isi.
class AdminScreen extends StatelessWidget {
  final String? back, eyebrow, title, subtitle;
  final Widget? trailing;
  final List<Widget> children;
  const AdminScreen({super.key, this.back, this.eyebrow, this.title, this.subtitle, this.trailing, required this.children});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const AdminHeader(),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
              if (back != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Row(children: [
                      const Icon(Icons.arrow_back, size: 18, color: C.primary),
                      const SizedBox(width: 6),
                      Text(back!, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              if (eyebrow != null) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(eyebrow!, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.6))),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title!, style: T.h1),
                      if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(subtitle!, style: T.body.copyWith(fontSize: 14))),
                    ])),
                    if (trailing != null) Padding(padding: const EdgeInsets.only(left: 8), child: trailing),
                  ]),
                ),
              ...children,
            ]),
          ),
        ]),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
        child: Row(children: [
          Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(14)), child: const Text('8', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [Text('SIEKSTRA-8', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), SizedBox(width: 6), Pill('ADMIN', C.soft, C.primary)]),
              const Text('SMKN 8 Malang', style: TextStyle(fontSize: 12, color: C.muted)),
            ]),
          ),
          IconButton(onPressed: () => toast(context, 'Pencarian'), icon: const Icon(Icons.search, color: C.ink)),
          IconButton(
            onPressed: () => toast(context, 'Tidak ada notifikasi baru'),
            icon: Stack(children: [const Icon(Icons.notifications_none_rounded, color: C.ink), Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.red, shape: BoxShape.circle)))]),
          ),
          GestureDetector(onTap: () => goTab(context, 5), child: const CircleAvatar(radius: 18, backgroundColor: C.primary, child: Icon(Icons.person_outline, color: Colors.white, size: 20))),
        ]),
      );
}

class SCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color, border;
  final double borderWidth, bottom;
  final VoidCallback? onTap;
  const SCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.border, this.borderWidth = 1, this.bottom = 12, this.onTap});
  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(20);
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(color: color ?? Colors.white, borderRadius: r, border: Border.all(color: border ?? C.line, width: borderWidth), boxShadow: const [BoxShadow(color: Color(0x0D1E3A8A), blurRadius: 12, offset: Offset(0, 4))]),
      child: Material(color: Colors.transparent, child: InkWell(borderRadius: r, onTap: onTap, child: Padding(padding: padding, child: child))),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  const Panel({super.key, required this.child, this.color, this.padding = const EdgeInsets.all(12)});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: padding, decoration: BoxDecoration(color: color ?? C.field, borderRadius: BorderRadius.circular(14)), child: child);
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final IconData? icon;
  final bool dot;
  const Pill(this.text, this.bg, this.fg, {super.key, this.icon, this.dot = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot) ...[CircleAvatar(radius: 3.5, backgroundColor: fg), const SizedBox(width: 5)],
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
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
  const Btn(this.label, {super.key, this.icon, this.onTap, this.bg = C.primary, this.fg = Colors.white, this.expand = false, this.h = 46});
  const Btn.soft(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46}) : bg = C.soft, fg = C.primary;
  const Btn.gray(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46}) : bg = const Color(0xFFEEF1F7), fg = C.ink;
  const Btn.danger(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46}) : bg = C.redSoft, fg = C.red;
  const Btn.warn(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46}) : bg = C.orangeSoft, fg = C.orange;
  const Btn.white(this.label, {super.key, this.icon, this.onTap, this.expand = false, this.h = 46}) : bg = Colors.white, fg = C.primary;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: h,
        width: expand ? double.infinity : null,
        child: ElevatedButton(
          onPressed: onTap ?? () => toast(context, label),
          style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: fg, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final double size;
  const IconBox(this.icon, {super.key, this.bg = C.soft, this.fg = C.primary, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.3)), child: Icon(icon, color: fg, size: size * 0.5));
}

class Avatar extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final double size;
  const Avatar(this.text, {super.key, this.bg = C.soft, this.fg = C.primary, this.size = 48});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, alignment: Alignment.center, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: size * 0.34)));
}

/// Foto placeholder (ganti dengan Image.asset bila sudah ada gambar).
class Photo extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final String? label;
  final double w, h;
  const Photo({super.key, this.icon = Icons.image_outlined, this.bg = const Color(0xFFD6E0F5), this.label, this.w = 64, this.h = 64});
  @override
  Widget build(BuildContext context) => Container(
        width: w == 0 ? double.infinity : w,
        height: h,
        padding: const EdgeInsets.all(8),
        alignment: label != null ? Alignment.bottomLeft : Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: label != null ? Text(label!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.ink)) : Icon(icon, color: C.ink.withValues(alpha: 0.4), size: h * 0.45),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? action;
  final Color? iconColor;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.icon, this.action, this.iconColor, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Row(children: [
          if (icon != null) ...[Icon(icon, size: 18, color: iconColor ?? C.primary), const SizedBox(width: 8)],
          Expanded(child: Text(text, style: T.title.copyWith(fontSize: 16, fontWeight: FontWeight.w800))),
          if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 13))),
        ]),
      );
}

class SearchBox extends StatelessWidget {
  final String hint;
  final bool filter;
  const SearchBox(this.hint, {super.key, this.filter = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: C.muted, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: C.ink),
            suffixIcon: filter ? const Icon(Icons.tune, color: C.muted) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)),
          ),
        ),
      );
}

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
                    decoration: BoxDecoration(color: sel == i ? C.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel == i ? C.primary : C.line)),
                    child: Text(widget.labels[i], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel == i ? Colors.white : C.muted)),
                  ),
                ),
              ),
          ]),
        ),
      );
}

/// Tab segmented (abu-abu dengan tab terpilih putih).
class SegTabs extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<int>? onChanged;
  const SegTabs(this.labels, {super.key, this.onChanged});
  @override
  State<SegTabs> createState() => _SegTabsState();
}

class _SegTabsState extends State<SegTabs> {
  int sel = 0;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: const Color(0xFFE9EDF6), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          for (var i = 0; i < widget.labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => sel = i);
                  widget.onChanged?.call(i);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(color: sel == i ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(widget.labels[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel == i ? C.primary : C.muted))),
                ),
              ),
            ),
        ]),
      );
}

class StatBox extends StatelessWidget {
  final String label, value, sub;
  final Color? valueColor, subColor;
  final IconData? icon;
  final Color iconBg, iconFg;
  final String? badge;
  final Color badgeBg, badgeFg;
  const StatBox(this.label, this.value, this.sub, {super.key, this.valueColor, this.subColor, this.icon, this.iconBg = C.soft, this.iconFg = C.primary, this.badge, this.badgeBg = C.soft, this.badgeFg = C.primary});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: C.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (icon != null)
            Row(children: [IconBox(icon!, bg: iconBg, fg: iconFg, size: 38), const Spacer(), if (badge != null) Pill(badge!, badgeBg, badgeFg)])
          else
            Text(label, style: T.body.copyWith(fontWeight: FontWeight.w600)),
          if (icon != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(label, style: T.body.copyWith(fontSize: 14))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: valueColor ?? C.ink)),
          Text(sub, style: TextStyle(fontSize: 12, color: subColor ?? C.muted)),
        ]),
      );
}

class Bar extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  const Bar(this.value, this.color, {super.key, this.track = const Color(0xFFE5E9F5)});
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: value, minHeight: 8, color: color, backgroundColor: track));
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final Color bg, border, fg;
  const InfoCard(this.icon, this.title, this.body, {super.key, this.bg = Colors.white, this.border = C.line, this.fg = C.primary});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 4, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: T.title.copyWith(fontSize: 16)), const SizedBox(height: 4), Text(body, style: T.body.copyWith(fontSize: 14))])),
        ]),
      );
}

/// Baris "label : nilai" dengan ikon.
class KV extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const KV(this.icon, this.label, this.value, {super.key, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: C.primary),
          const SizedBox(width: 8),
          Text('$label ', style: T.body.copyWith(fontSize: 14)),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor ?? C.ink))),
        ]),
      );
}

class DropField extends StatelessWidget {
  final IconData? icon;
  final String text;
  const DropField(this.text, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line)),
        child: Row(children: [
          if (icon != null) ...[Icon(icon, size: 18, color: C.primary), const SizedBox(width: 8)],
          Expanded(child: Text(text, style: T.title, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.keyboard_arrow_down, color: C.muted),
        ]),
      );
}

class HeroBanner extends StatelessWidget {
  final List<Widget> children;
  const HeroBanner({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF0B3AA8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x331D4ED8), blurRadius: 16, offset: Offset(0, 8))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}
