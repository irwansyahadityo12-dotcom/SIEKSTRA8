import 'package:flutter/material.dart';
import 'theme.dart';

Widget tx(String s,
    {double size = 13,
    FontWeight w = FontWeight.w500,
    Color color = C.text,
    int? lines,
    TextAlign? align,
    double? height}) {
  return Text(s,
      maxLines: lines,
      overflow: lines != null ? TextOverflow.ellipsis : null,
      textAlign: align,
      style: TextStyle(fontSize: size, fontWeight: w, color: color, height: height));
}

class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: kBlueGradient,
          borderRadius: BorderRadius.circular(size * .3),
        ),
        child: Text('8',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * .55)),
      );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double bottom;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.borderColor,
    this.onTap,
    this.bottom = 12,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor ?? C.border),
        boxShadow: const [BoxShadow(color: Color(0x0D1D4ED8), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color fg, bg;
  final IconData? icon;
  final double size;
  const Pill(this.text, {super.key, this.fg = C.primary, this.bg = C.soft, this.icon, this.size = 11});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: size + 2, color: fg), const SizedBox(width: 4)],
          Flexible(child: tx(text, size: size, w: FontWeight.w700, color: fg, lines: 1)),
        ]),
      );
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final double size;
  const IconBox(this.icon, {super.key, this.color = C.primary, this.bg = C.soft, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * .3)),
        child: Icon(icon, color: color, size: size * .5),
      );
}

class QuotaBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const QuotaBar(this.value, {super.key, this.color = C.primary, this.height = 8});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1).toDouble(),
          minHeight: height,
          backgroundColor: C.soft,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool trailingIcon;
  const PrimaryButton(this.label,
      {super.key, this.icon, this.onPressed, this.color = C.primary, this.trailingIcon = true});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed ?? () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null && !trailingIcon) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
            if (icon != null && trailingIcon) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
          ]),
        ),
      );
}

class SoftButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color fg, bg;
  const SoftButton(this.label, {super.key, this.icon, this.onPressed, this.fg = C.text, this.bg = C.soft});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 46,
        child: TextButton(
          onPressed: onPressed ?? () {},
          style: TextButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 8)],
            Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          ]),
        ),
      );
}

class PhotoBox extends StatelessWidget {
  final double height;
  final List<Color> colors;
  final IconData icon;
  final List<Widget> overlays;
  const PhotoBox({super.key, this.height = 130, required this.colors, this.icon = Icons.image_outlined, this.overlays = const []});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Stack(children: [
            Center(child: Icon(icon, size: 44, color: Colors.white.withValues(alpha: .35))),
            ...overlays,
          ]),
        ),
      );
}

class Overlay1 extends StatelessWidget {
  final Alignment align;
  final Widget child;
  const Overlay1(this.align, this.child, {super.key});
  @override
  Widget build(BuildContext context) =>
      Align(alignment: align, child: Padding(padding: const EdgeInsets.all(10), child: child));
}

class DarkChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  const DarkChip(this.text, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .45), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13, color: Colors.white), const SizedBox(width: 4)],
          tx(text, size: 11, w: FontWeight.w600, color: Colors.white),
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final bool bar;
  const SectionTitle(this.title, {super.key, this.action, this.bar = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Row(children: [
          if (bar) Container(width: 4, height: 18, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: C.amber, borderRadius: BorderRadius.circular(4))),
          Expanded(child: tx(title, size: 16, w: FontWeight.w800)),
          if (action != null) tx(action!, size: 12, w: FontWeight.w700, color: C.primary),
        ]),
      );
}

class LabeledField extends StatelessWidget {
  final String label;
  final String? hint, helper, trailingLabel;
  final IconData? icon;
  final IconData? suffix;
  final bool obscure, readOnly;
  final int maxLines;
  final TextEditingController? controller;
  final String? initial;
  const LabeledField(this.label,
      {super.key,
      this.hint,
      this.helper,
      this.trailingLabel,
      this.icon,
      this.suffix,
      this.obscure = false,
      this.readOnly = false,
      this.maxLines = 1,
      this.controller,
      this.initial});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: tx(label, size: 12.5, w: FontWeight.w700)),
            if (trailingLabel != null) tx(trailingLabel!, size: 11, w: FontWeight.w700, color: C.primary),
          ]),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? initial : null,
            obscureText: obscure,
            readOnly: readOnly,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: C.muted, fontSize: 13),
              prefixIcon: icon == null ? null : Icon(icon, size: 19, color: C.muted),
              suffixIcon: suffix == null ? null : Icon(suffix, size: 19, color: C.muted),
              filled: true,
              fillColor: const Color(0xFFF1F4FC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.primary, width: 1.4)),
            ),
          ),
          if (helper != null) Padding(padding: const EdgeInsets.only(top: 5), child: tx(helper!, size: 10.5, color: C.muted)),
        ]),
      );
}

class AvatarDot extends StatelessWidget {
  final String text;
  final double radius;
  const AvatarDot({super.key, this.text = 'DI', this.radius = 18});
  @override
  Widget build(BuildContext context) => Stack(children: [
        CircleAvatar(radius: radius, backgroundColor: C.soft, child: tx(text, size: radius * .7, w: FontWeight.w800, color: C.primary)),
        Positioned(right: 0, bottom: 0, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: C.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
      ]);
}

/// AppBar untuk halaman utama (tab).
PreferredSizeWidget mainAppBar({Widget? badge}) => AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Row(children: [
        const BrandLogo(size: 38),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            tx('SIEKSTRA-8', size: 16, w: FontWeight.w800, color: C.primary),
            if (badge != null) ...[const SizedBox(width: 6), badge],
          ]),
          tx('SMKN 8 Malang', size: 11, color: C.muted),
        ]),
      ]),
      actions: const [Padding(padding: EdgeInsets.only(right: 16), child: AvatarDot())],
    );

/// AppBar untuk halaman detail / form.
PreferredSizeWidget subAppBar(BuildContext context, String title, {String? badge}) => AppBar(
      toolbarHeight: 64,
      titleSpacing: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          tx(title, size: 17, w: FontWeight.w800),
          if (badge != null) ...[const SizedBox(width: 6), Pill(badge, size: 10)],
        ]),
        tx('SIEKSTRA-8 • SMKN 8 Malang', size: 11, color: C.muted),
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: CircleAvatar(radius: 17, backgroundColor: C.primary, child: const Icon(Icons.person_outline, color: Colors.white, size: 18)),
        ),
      ],
    );

class StepBar extends StatelessWidget {
  final List<String> labels;
  final int current; // 0-based
  const StepBar(this.labels, this.current, {super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (int i = 0; i < labels.length; i++) ...[
        Column(children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i <= current ? C.primary : C.soft,
              shape: BoxShape.circle,
            ),
            child: i < current
                ? const Icon(Icons.check, color: Colors.white, size: 17)
                : tx('${i + 1}', size: 13, w: FontWeight.w800, color: i <= current ? Colors.white : C.muted),
          ),
          const SizedBox(height: 4),
          tx(labels[i], size: 10, w: FontWeight.w600, color: i <= current ? C.primary : C.muted),
        ]),
        if (i < labels.length - 1)
          Expanded(child: Container(height: 3, margin: const EdgeInsets.only(bottom: 18), color: i < current ? C.primary : C.soft)),
      ],
    ]);
  }
}

class CheckRow extends StatefulWidget {
  final Widget label;
  final bool initial;
  const CheckRow({super.key, required this.label, this.initial = false});
  @override
  State<CheckRow> createState() => _CheckRowState();
}

class _CheckRowState extends State<CheckRow> {
  late bool v = widget.initial;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 28,
          child: Checkbox(
            value: v,
            activeColor: C.primary,
            visualDensity: VisualDensity.compact,
            onChanged: (x) => setState(() => v = x ?? false),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: Padding(padding: const EdgeInsets.only(top: 6), child: widget.label)),
      ]);
}

class FilterChips extends StatefulWidget {
  final List<String> items;
  final ValueChanged<int>? onChanged;
  const FilterChips(this.items, {super.key, this.onChanged});
  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  int sel = 0;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () {
              setState(() => sel = i);
              widget.onChanged?.call(i);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel == i ? C.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel == i ? C.primary : C.border),
              ),
              child: tx(widget.items[i], size: 12.5, w: FontWeight.w700, color: sel == i ? Colors.white : C.text),
            ),
          ),
        ),
      );
}
