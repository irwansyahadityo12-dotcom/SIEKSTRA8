import 'package:flutter/material.dart';
import 'theme.dart';

class Ekskul {
  final String name, category, desc, coach, schedule, place;
  final int filled, quota; // quota 0 = tanpa kuota
  final IconData icon;
  final Color color, colorBg;
  final List<Color> photo;
  const Ekskul({
    required this.name,
    required this.category,
    required this.desc,
    required this.coach,
    required this.schedule,
    required this.place,
    required this.filled,
    required this.quota,
    required this.icon,
    required this.color,
    required this.colorBg,
    required this.photo,
  });
  double get ratio => quota == 0 ? 1 : filled / quota;
  bool get full => quota != 0 && filled >= quota;
  bool get almostFull => quota != 0 && ratio >= .9;
}

const ekskulList = <Ekskul>[
  Ekskul(
    name: 'Robotik SMKN 8 Malang',
    category: 'Vokasi & Keahlian',
    desc: 'mengembangkan potensi, keterampilan, dan kreativitas siswa dalam bidang teknologi, rekayasa (engineering), serta pemrograman.',
    coach: 'M Rafi Haryo Putra',
    schedule: 'Rabu & Sabtu',
    place: 'Robotik',
    filled: 85,
    quota: 100,
    icon: Icons.smart_toy_outlined,
    color: C.primary,
    colorBg: C.soft,
    photo: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
  ),
  Ekskul(
    name: 'Volly Ball SMKN 8 Malang',
    category: 'Olahraga',
    desc: 'melatih teknik dasar, membangun solidaritas, serta mewadahi minat dan bakat siswa dalam bidang olahraga.',
    coach: 'Soni Subakti, S.Pd',
    schedule: 'Selasa & Jumat',
    place: 'Volly',
    filled: 48,
    quota: 50,
    icon: Icons.sports_volleyball_outlined,
    color: C.brown,
    colorBg: C.amberBg,
    photo: [Color(0xFF7C2D12), Color(0xFFF59E0B)],
  ),
  Ekskul(
    name: 'Badan Dakwah Islam SMKN 8 Malang',
    category: 'Keagamaan',
    desc: 'sebagai wadah pembinaan kerohanian Islam untuk mempererat ukhuwah islamiyah (persaudaraan Islam) dan membentuk karakter siswa yang berakhlak mulia.',
    coach: 'Muzakki, S.Pd',
    schedule: 'Kamis & Sabtu',
    place: 'Masjid Ulil Albab',
    filled: 35,
    quota: 40,
    icon: Icons.mosque_outlined,
    color: C.teal,
    colorBg: Color(0xFFE0F2F7),
    photo: [Color(0xFF065F46), Color(0xFF34D399)],
  ),
  Ekskul(
    name: 'Pramuka Gugus Depan 08',
    category: 'Kepemimpinan',
    desc: 'membentuk generasi muda yang berkarakter, berwawasan kebangsaan, disiplin, serta memiliki keterampilan dan etos kerja yang tangguh.',
    coach: 'Dra. Roem Anjarwati',
    schedule: 'Jumat Sore',
    place: 'Lapangan Utama',
    filled: 120,
    quota: 0,
    icon: Icons.local_fire_department_outlined,
    color: C.brown,
    colorBg: C.amberBg,
    photo: [Color(0xFF78350F), Color(0xFFB45309)],
  ),
  Ekskul(
    name: 'PMR Wira SMKN 8',
    category: 'Kepemimpinan & Sosial',
    desc: 'Kesiapsiagaan medis sekolah, penanganan gawat darurat P3K, tanggap bencana, dan agenda donor darah.',
    coach: 'Rezaldi Hafidz Fadilla',
    schedule: 'Senin & Kamis',
    place: 'UKS Terpadu',
    filled: 45,
    quota: 60,
    icon: Icons.add_rounded,
    color: C.red,
    colorBg: C.redBg,
    photo: [Color(0xFF991B1B), Color(0xFFF87171)],
  ),
  Ekskul(
    name: 'Futsal SMKN 8 Malang',
    category: 'Olahraga',
    desc: 'Olahraga prestasi pembinaan atlet turnamen antar-SMK se-Jawa Timur, fisik prima & strategi tanding.',
    coach: 'Coach Jurgen Ibra',
    schedule: 'Selasa & Sabtu',
    place: 'Lapangan Futsal Semi Indoor',
    filled: 38,
    quota: 40,
    icon: Icons.sports_soccer_outlined,
    color: C.brown,
    colorBg: C.amberBg,
    photo: [Color(0xFF1E3A8A), Color(0xFFFBBF24)],
  ),
];
