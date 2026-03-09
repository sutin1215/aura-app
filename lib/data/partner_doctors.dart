// ── Shared partner doctor roster ─────────────────────────────────────────────
class PartnerDoctor {
  final String name;
  final String specialty;
  final String providerCode;
  final String hiddenUid;
  final String emoji;
  final String bio;
  final double rating;
  final int experience; // years
  final String availability;

  const PartnerDoctor({
    required this.name,
    required this.specialty,
    required this.providerCode,
    required this.hiddenUid,
    required this.emoji,
    required this.bio,
    required this.rating,
    required this.experience,
    required this.availability,
  });
}

const kPartnerDoctors = [
  PartnerDoctor(
    name: 'Dr. Sarah Kang',
    specialty: 'General Practice',
    providerCode: 'KANG-2024',
    hiddenUid: 'partner_dr_kang',
    emoji: '👩‍⚕️',
    bio:
        'Over 12 years helping patients achieve their best health through personalised care.',
    rating: 4.9,
    experience: 12,
    availability: 'Mon – Fri',
  ),
  PartnerDoctor(
    name: 'Dr. James Lim',
    specialty: 'Cardiology',
    providerCode: 'LIM-2024',
    hiddenUid: 'partner_dr_lim',
    emoji: '👨‍⚕️',
    bio:
        'Specialist in heart health and preventative cardiology with 15 years of clinical experience.',
    rating: 4.8,
    experience: 15,
    availability: 'Mon, Wed, Fri',
  ),
  PartnerDoctor(
    name: 'Dr. Aisha Patel',
    specialty: 'Endocrinology',
    providerCode: 'PATEL-2024',
    hiddenUid: 'partner_dr_patel',
    emoji: '👩‍⚕️',
    bio:
        'Expert in diabetes management, thyroid conditions and hormonal health.',
    rating: 4.8,
    experience: 10,
    availability: 'Tue, Thu, Sat',
  ),
  PartnerDoctor(
    name: 'Dr. Michael Chen',
    specialty: 'Mental Health',
    providerCode: 'CHEN-2024',
    hiddenUid: 'partner_dr_chen',
    emoji: '👨‍⚕️',
    bio:
        'Dedicated to mental wellness with a compassionate, evidence-based approach.',
    rating: 4.9,
    experience: 9,
    availability: 'Mon – Thu',
  ),
  PartnerDoctor(
    name: 'Dr. Priya Nair',
    specialty: 'Nutrition & Dietetics',
    providerCode: 'NAIR-2024',
    hiddenUid: 'partner_dr_nair',
    emoji: '👩‍⚕️',
    bio:
        'Helping patients build sustainable nutrition habits and reach their weight goals.',
    rating: 4.7,
    experience: 8,
    availability: 'Mon, Tue, Fri',
  ),
  PartnerDoctor(
    name: 'Dr. Omar Hassan',
    specialty: 'Physiotherapy',
    providerCode: 'HASSAN-2024',
    hiddenUid: 'partner_dr_hassan',
    emoji: '👨‍⚕️',
    bio:
        'Specialising in sports injuries, rehabilitation and chronic pain management.',
    rating: 4.8,
    experience: 11,
    availability: 'Tue – Sat',
  ),
];

// Lookup by provider code (case-insensitive)
PartnerDoctor? doctorByCode(String code) {
  final upper = code.trim().toUpperCase();
  try {
    return kPartnerDoctors.firstWhere(
      (d) => d.providerCode.toUpperCase() == upper,
    );
  } catch (_) {
    return null;
  }
}
