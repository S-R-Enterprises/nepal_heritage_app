import 'package:flutter/widgets.dart';

/// A country the app can be used from.
///
/// [iso] is the ISO 3166-1 alpha-2 code. It doubles as the flag affordance: the
/// UI draws it inside a tinted rounded badge rather than using an emoji flag
/// glyph, so nothing in the app depends on the platform's regional-indicator
/// font coverage.
class Country {
  const Country({
    required this.iso,
    required this.name,
    required this.dialCode,
    this.nsnLength = 9,
  });

  final String iso;
  final String name;

  /// International dialling prefix, including the leading `+`.
  final String dialCode;

  /// Typical length of the national significant number, used for a soft length
  /// check on the phone field. Not every carrier follows it exactly, so the
  /// validator accepts a small tolerance either way.
  final int nsnLength;

  /// `+977 · Nepal`, the form shown in the country-code picker.
  String get pickerLabel => '$dialCode · $name';

  /// Badge fill for the [iso] chip, derived from the code so every country gets
  /// a stable, distinguishable tint without shipping flag artwork.
  Color get badgeColor => _badgePalette[iso.codeUnitAt(0) % _badgePalette.length];

  static const List<Color> _badgePalette = <Color>[
    Color(0xFF2C5F2D),
    Color(0xFF6E8F5A),
    Color(0xFF8C6A1F),
    Color(0xFF1E2B18),
    Color(0xFF3F6B7A),
    Color(0xFF7A4A3A),
    Color(0xFF4A5C44),
    Color(0xFF5B4B8A),
  ];

  @override
  String toString() => 'Country($iso, $dialCode)';
}

/// The full ISO 3166-1 list, sorted by English name.
class Countries {
  const Countries._();

  static const List<Country> all = <Country>[
    Country(iso: 'AF', name: 'Afghanistan', dialCode: '+93', nsnLength: 9),
    Country(iso: 'AL', name: 'Albania', dialCode: '+355', nsnLength: 9),
    Country(iso: 'DZ', name: 'Algeria', dialCode: '+213', nsnLength: 9),
    Country(iso: 'AD', name: 'Andorra', dialCode: '+376', nsnLength: 6),
    Country(iso: 'AO', name: 'Angola', dialCode: '+244', nsnLength: 9),
    Country(iso: 'AG', name: 'Antigua and Barbuda', dialCode: '+1', nsnLength: 10),
    Country(iso: 'AR', name: 'Argentina', dialCode: '+54', nsnLength: 10),
    Country(iso: 'AM', name: 'Armenia', dialCode: '+374', nsnLength: 8),
    Country(iso: 'AW', name: 'Aruba', dialCode: '+297', nsnLength: 7),
    Country(iso: 'AU', name: 'Australia', dialCode: '+61', nsnLength: 9),
    Country(iso: 'AT', name: 'Austria', dialCode: '+43', nsnLength: 7),
    Country(iso: 'AZ', name: 'Azerbaijan', dialCode: '+994', nsnLength: 9),
    Country(iso: 'BS', name: 'Bahamas', dialCode: '+1', nsnLength: 10),
    Country(iso: 'BH', name: 'Bahrain', dialCode: '+973', nsnLength: 8),
    Country(iso: 'BD', name: 'Bangladesh', dialCode: '+880', nsnLength: 10),
    Country(iso: 'BB', name: 'Barbados', dialCode: '+1', nsnLength: 10),
    Country(iso: 'BY', name: 'Belarus', dialCode: '+375', nsnLength: 9),
    Country(iso: 'BE', name: 'Belgium', dialCode: '+32', nsnLength: 9),
    Country(iso: 'BZ', name: 'Belize', dialCode: '+501', nsnLength: 7),
    Country(iso: 'BJ', name: 'Benin', dialCode: '+229', nsnLength: 8),
    Country(iso: 'BT', name: 'Bhutan', dialCode: '+975', nsnLength: 8),
    Country(iso: 'BO', name: 'Bolivia', dialCode: '+591', nsnLength: 8),
    Country(iso: 'BA', name: 'Bosnia and Herzegovina', dialCode: '+387', nsnLength: 8),
    Country(iso: 'BW', name: 'Botswana', dialCode: '+267', nsnLength: 7),
    Country(iso: 'BR', name: 'Brazil', dialCode: '+55', nsnLength: 11),
    Country(iso: 'BN', name: 'Brunei', dialCode: '+673', nsnLength: 7),
    Country(iso: 'BG', name: 'Bulgaria', dialCode: '+359', nsnLength: 9),
    Country(iso: 'BF', name: 'Burkina Faso', dialCode: '+226', nsnLength: 8),
    Country(iso: 'BI', name: 'Burundi', dialCode: '+257', nsnLength: 8),
    Country(iso: 'KH', name: 'Cambodia', dialCode: '+855', nsnLength: 9),
    Country(iso: 'CM', name: 'Cameroon', dialCode: '+237', nsnLength: 9),
    Country(iso: 'CA', name: 'Canada', dialCode: '+1', nsnLength: 10),
    Country(iso: 'CV', name: 'Cape Verde', dialCode: '+238', nsnLength: 7),
    Country(iso: 'CF', name: 'Central African Republic', dialCode: '+236', nsnLength: 8),
    Country(iso: 'TD', name: 'Chad', dialCode: '+235', nsnLength: 8),
    Country(iso: 'CL', name: 'Chile', dialCode: '+56', nsnLength: 9),
    Country(iso: 'CN', name: 'China', dialCode: '+86', nsnLength: 11),
    Country(iso: 'CO', name: 'Colombia', dialCode: '+57', nsnLength: 10),
    Country(iso: 'KM', name: 'Comoros', dialCode: '+269', nsnLength: 7),
    Country(iso: 'CG', name: 'Congo', dialCode: '+242', nsnLength: 9),
    Country(iso: 'CD', name: 'Congo, Democratic Republic of the', dialCode: '+243', nsnLength: 9),
    Country(iso: 'CR', name: 'Costa Rica', dialCode: '+506', nsnLength: 8),
    Country(iso: 'CI', name: "Côte d'Ivoire", dialCode: '+225', nsnLength: 10),
    Country(iso: 'HR', name: 'Croatia', dialCode: '+385', nsnLength: 8),
    Country(iso: 'CU', name: 'Cuba', dialCode: '+53', nsnLength: 8),
    Country(iso: 'CY', name: 'Cyprus', dialCode: '+357', nsnLength: 8),
    Country(iso: 'CZ', name: 'Czechia', dialCode: '+420', nsnLength: 9),
    Country(iso: 'DK', name: 'Denmark', dialCode: '+45', nsnLength: 8),
    Country(iso: 'DJ', name: 'Djibouti', dialCode: '+253', nsnLength: 8),
    Country(iso: 'DM', name: 'Dominica', dialCode: '+1', nsnLength: 10),
    Country(iso: 'DO', name: 'Dominican Republic', dialCode: '+1', nsnLength: 10),
    Country(iso: 'EC', name: 'Ecuador', dialCode: '+593', nsnLength: 9),
    Country(iso: 'EG', name: 'Egypt', dialCode: '+20', nsnLength: 10),
    Country(iso: 'SV', name: 'El Salvador', dialCode: '+503', nsnLength: 8),
    Country(iso: 'GQ', name: 'Equatorial Guinea', dialCode: '+240', nsnLength: 9),
    Country(iso: 'ER', name: 'Eritrea', dialCode: '+291', nsnLength: 7),
    Country(iso: 'EE', name: 'Estonia', dialCode: '+372', nsnLength: 8),
    Country(iso: 'SZ', name: 'Eswatini', dialCode: '+268', nsnLength: 8),
    Country(iso: 'ET', name: 'Ethiopia', dialCode: '+251', nsnLength: 9),
    Country(iso: 'FJ', name: 'Fiji', dialCode: '+679', nsnLength: 7),
    Country(iso: 'FI', name: 'Finland', dialCode: '+358', nsnLength: 9),
    Country(iso: 'FR', name: 'France', dialCode: '+33', nsnLength: 9),
    Country(iso: 'GA', name: 'Gabon', dialCode: '+241', nsnLength: 7),
    Country(iso: 'GM', name: 'Gambia', dialCode: '+220', nsnLength: 7),
    Country(iso: 'GE', name: 'Georgia', dialCode: '+995', nsnLength: 9),
    Country(iso: 'DE', name: 'Germany', dialCode: '+49', nsnLength: 10),
    Country(iso: 'GH', name: 'Ghana', dialCode: '+233', nsnLength: 9),
    Country(iso: 'GR', name: 'Greece', dialCode: '+30', nsnLength: 10),
    Country(iso: 'GD', name: 'Grenada', dialCode: '+1', nsnLength: 10),
    Country(iso: 'GT', name: 'Guatemala', dialCode: '+502', nsnLength: 8),
    Country(iso: 'GN', name: 'Guinea', dialCode: '+224', nsnLength: 9),
    Country(iso: 'GY', name: 'Guyana', dialCode: '+592', nsnLength: 7),
    Country(iso: 'HT', name: 'Haiti', dialCode: '+509', nsnLength: 8),
    Country(iso: 'HN', name: 'Honduras', dialCode: '+504', nsnLength: 8),
    Country(iso: 'HK', name: 'Hong Kong', dialCode: '+852', nsnLength: 8),
    Country(iso: 'HU', name: 'Hungary', dialCode: '+36', nsnLength: 9),
    Country(iso: 'IS', name: 'Iceland', dialCode: '+354', nsnLength: 7),
    Country(iso: 'IN', name: 'India', dialCode: '+91', nsnLength: 10),
    Country(iso: 'ID', name: 'Indonesia', dialCode: '+62', nsnLength: 10),
    Country(iso: 'IR', name: 'Iran', dialCode: '+98', nsnLength: 10),
    Country(iso: 'IQ', name: 'Iraq', dialCode: '+964', nsnLength: 10),
    Country(iso: 'IE', name: 'Ireland', dialCode: '+353', nsnLength: 9),
    Country(iso: 'IL', name: 'Israel', dialCode: '+972', nsnLength: 9),
    Country(iso: 'IT', name: 'Italy', dialCode: '+39', nsnLength: 10),
    Country(iso: 'JM', name: 'Jamaica', dialCode: '+1', nsnLength: 10),
    Country(iso: 'JP', name: 'Japan', dialCode: '+81', nsnLength: 10),
    Country(iso: 'JO', name: 'Jordan', dialCode: '+962', nsnLength: 9),
    Country(iso: 'KZ', name: 'Kazakhstan', dialCode: '+7', nsnLength: 10),
    Country(iso: 'KE', name: 'Kenya', dialCode: '+254', nsnLength: 9),
    Country(iso: 'KI', name: 'Kiribati', dialCode: '+686', nsnLength: 7),
    Country(iso: 'XK', name: 'Kosovo', dialCode: '+383', nsnLength: 8),
    Country(iso: 'KW', name: 'Kuwait', dialCode: '+965', nsnLength: 8),
    Country(iso: 'KG', name: 'Kyrgyzstan', dialCode: '+996', nsnLength: 9),
    Country(iso: 'LA', name: 'Laos', dialCode: '+856', nsnLength: 9),
    Country(iso: 'LV', name: 'Latvia', dialCode: '+371', nsnLength: 8),
    Country(iso: 'LB', name: 'Lebanon', dialCode: '+961', nsnLength: 7),
    Country(iso: 'LS', name: 'Lesotho', dialCode: '+266', nsnLength: 8),
    Country(iso: 'LR', name: 'Liberia', dialCode: '+231', nsnLength: 7),
    Country(iso: 'LY', name: 'Libya', dialCode: '+218', nsnLength: 9),
    Country(iso: 'LT', name: 'Lithuania', dialCode: '+370', nsnLength: 8),
    Country(iso: 'LU', name: 'Luxembourg', dialCode: '+352', nsnLength: 9),
    Country(iso: 'MK', name: 'North Macedonia', dialCode: '+389', nsnLength: 8),
    Country(iso: 'MG', name: 'Madagascar', dialCode: '+261', nsnLength: 9),
    Country(iso: 'MW', name: 'Malawi', dialCode: '+265', nsnLength: 9),
    Country(iso: 'MY', name: 'Malaysia', dialCode: '+60', nsnLength: 9),
    Country(iso: 'MV', name: 'Maldives', dialCode: '+960', nsnLength: 7),
    Country(iso: 'ML', name: 'Mali', dialCode: '+223', nsnLength: 8),
    Country(iso: 'MT', name: 'Malta', dialCode: '+356', nsnLength: 8),
    Country(iso: 'MH', name: 'Marshall Islands', dialCode: '+692', nsnLength: 7),
    Country(iso: 'MR', name: 'Mauritania', dialCode: '+222', nsnLength: 8),
    Country(iso: 'MU', name: 'Mauritius', dialCode: '+230', nsnLength: 8),
    Country(iso: 'MX', name: 'Mexico', dialCode: '+52', nsnLength: 10),
    Country(iso: 'FM', name: 'Micronesia', dialCode: '+691', nsnLength: 7),
    Country(iso: 'MD', name: 'Moldova', dialCode: '+373', nsnLength: 8),
    Country(iso: 'MC', name: 'Monaco', dialCode: '+377', nsnLength: 8),
    Country(iso: 'MN', name: 'Mongolia', dialCode: '+976', nsnLength: 8),
    Country(iso: 'ME', name: 'Montenegro', dialCode: '+382', nsnLength: 8),
    Country(iso: 'MA', name: 'Morocco', dialCode: '+212', nsnLength: 9),
    Country(iso: 'MZ', name: 'Mozambique', dialCode: '+258', nsnLength: 9),
    Country(iso: 'MM', name: 'Myanmar', dialCode: '+95', nsnLength: 10),
    Country(iso: 'NA', name: 'Namibia', dialCode: '+264', nsnLength: 9),
    Country(iso: 'NR', name: 'Nauru', dialCode: '+674', nsnLength: 7),
    Country(iso: 'NP', name: 'Nepal', dialCode: '+977', nsnLength: 10),
    Country(iso: 'NL', name: 'Netherlands', dialCode: '+31', nsnLength: 9),
    Country(iso: 'NZ', name: 'New Zealand', dialCode: '+64', nsnLength: 8),
    Country(iso: 'NI', name: 'Nicaragua', dialCode: '+505', nsnLength: 8),
    Country(iso: 'NE', name: 'Niger', dialCode: '+227', nsnLength: 8),
    Country(iso: 'NG', name: 'Nigeria', dialCode: '+234', nsnLength: 10),
    Country(iso: 'NO', name: 'Norway', dialCode: '+47', nsnLength: 8),
    Country(iso: 'OM', name: 'Oman', dialCode: '+968', nsnLength: 8),
    Country(iso: 'PK', name: 'Pakistan', dialCode: '+92', nsnLength: 10),
    Country(iso: 'PW', name: 'Palau', dialCode: '+680', nsnLength: 7),
    Country(iso: 'PS', name: 'Palestine', dialCode: '+970', nsnLength: 9),
    Country(iso: 'PA', name: 'Panama', dialCode: '+507', nsnLength: 8),
    Country(iso: 'PG', name: 'Papua New Guinea', dialCode: '+675', nsnLength: 7),
    Country(iso: 'PY', name: 'Paraguay', dialCode: '+595', nsnLength: 9),
    Country(iso: 'PE', name: 'Peru', dialCode: '+51', nsnLength: 9),
    Country(iso: 'PH', name: 'Philippines', dialCode: '+63', nsnLength: 10),
    Country(iso: 'PL', name: 'Poland', dialCode: '+48', nsnLength: 9),
    Country(iso: 'PT', name: 'Portugal', dialCode: '+351', nsnLength: 9),
    Country(iso: 'QA', name: 'Qatar', dialCode: '+974', nsnLength: 8),
    Country(iso: 'RO', name: 'Romania', dialCode: '+40', nsnLength: 9),
    Country(iso: 'RU', name: 'Russia', dialCode: '+7', nsnLength: 10),
    Country(iso: 'RW', name: 'Rwanda', dialCode: '+250', nsnLength: 9),
    Country(iso: 'KN', name: 'Saint Kitts and Nevis', dialCode: '+1', nsnLength: 10),
    Country(iso: 'LC', name: 'Saint Lucia', dialCode: '+1', nsnLength: 10),
    Country(iso: 'VC', name: 'Saint Vincent and the Grenadines', dialCode: '+1', nsnLength: 10),
    Country(iso: 'WS', name: 'Samoa', dialCode: '+685', nsnLength: 7),
    Country(iso: 'SM', name: 'San Marino', dialCode: '+378', nsnLength: 10),
    Country(iso: 'ST', name: 'Sao Tome and Principe', dialCode: '+239', nsnLength: 7),
    Country(iso: 'SA', name: 'Saudi Arabia', dialCode: '+966', nsnLength: 9),
    Country(iso: 'SN', name: 'Senegal', dialCode: '+221', nsnLength: 9),
    Country(iso: 'RS', name: 'Serbia', dialCode: '+381', nsnLength: 8),
    Country(iso: 'SC', name: 'Seychelles', dialCode: '+248', nsnLength: 7),
    Country(iso: 'SL', name: 'Sierra Leone', dialCode: '+232', nsnLength: 8),
    Country(iso: 'SG', name: 'Singapore', dialCode: '+65', nsnLength: 8),
    Country(iso: 'SK', name: 'Slovakia', dialCode: '+421', nsnLength: 9),
    Country(iso: 'SI', name: 'Slovenia', dialCode: '+386', nsnLength: 8),
    Country(iso: 'SB', name: 'Solomon Islands', dialCode: '+677', nsnLength: 7),
    Country(iso: 'SO', name: 'Somalia', dialCode: '+252', nsnLength: 7),
    Country(iso: 'ZA', name: 'South Africa', dialCode: '+27', nsnLength: 9),
    Country(iso: 'SS', name: 'South Sudan', dialCode: '+211', nsnLength: 9),
    Country(iso: 'ES', name: 'Spain', dialCode: '+34', nsnLength: 9),
    Country(iso: 'LK', name: 'Sri Lanka', dialCode: '+94', nsnLength: 9),
    Country(iso: 'SD', name: 'Sudan', dialCode: '+249', nsnLength: 9),
    Country(iso: 'SR', name: 'Suriname', dialCode: '+597', nsnLength: 7),
    Country(iso: 'SE', name: 'Sweden', dialCode: '+46', nsnLength: 9),
    Country(iso: 'CH', name: 'Switzerland', dialCode: '+41', nsnLength: 9),
    Country(iso: 'SY', name: 'Syria', dialCode: '+963', nsnLength: 9),
    Country(iso: 'TW', name: 'Taiwan', dialCode: '+886', nsnLength: 9),
    Country(iso: 'TJ', name: 'Tajikistan', dialCode: '+992', nsnLength: 9),
    Country(iso: 'TZ', name: 'Tanzania', dialCode: '+255', nsnLength: 9),
    Country(iso: 'TH', name: 'Thailand', dialCode: '+66', nsnLength: 9),
    Country(iso: 'TL', name: 'Timor-Leste', dialCode: '+670', nsnLength: 7),
    Country(iso: 'TG', name: 'Togo', dialCode: '+228', nsnLength: 8),
    Country(iso: 'TO', name: 'Tonga', dialCode: '+676', nsnLength: 5),
    Country(iso: 'TT', name: 'Trinidad and Tobago', dialCode: '+1', nsnLength: 10),
    Country(iso: 'TN', name: 'Tunisia', dialCode: '+216', nsnLength: 8),
    Country(iso: 'TR', name: 'Türkiye', dialCode: '+90', nsnLength: 10),
    Country(iso: 'TM', name: 'Turkmenistan', dialCode: '+993', nsnLength: 8),
    Country(iso: 'TV', name: 'Tuvalu', dialCode: '+688', nsnLength: 5),
    Country(iso: 'UG', name: 'Uganda', dialCode: '+256', nsnLength: 9),
    Country(iso: 'UA', name: 'Ukraine', dialCode: '+380', nsnLength: 9),
    Country(iso: 'AE', name: 'United Arab Emirates', dialCode: '+971', nsnLength: 9),
    Country(iso: 'GB', name: 'United Kingdom', dialCode: '+44', nsnLength: 10),
    Country(iso: 'US', name: 'United States', dialCode: '+1', nsnLength: 10),
    Country(iso: 'UY', name: 'Uruguay', dialCode: '+598', nsnLength: 9),
    Country(iso: 'UZ', name: 'Uzbekistan', dialCode: '+998', nsnLength: 9),
    Country(iso: 'VU', name: 'Vanuatu', dialCode: '+678', nsnLength: 7),
    Country(iso: 'VA', name: 'Vatican City', dialCode: '+39', nsnLength: 10),
    Country(iso: 'VE', name: 'Venezuela', dialCode: '+58', nsnLength: 10),
    Country(iso: 'VN', name: 'Vietnam', dialCode: '+84', nsnLength: 9),
    Country(iso: 'YE', name: 'Yemen', dialCode: '+967', nsnLength: 7),
    Country(iso: 'ZM', name: 'Zambia', dialCode: '+260', nsnLength: 9),
    Country(iso: 'ZW', name: 'Zimbabwe', dialCode: '+263', nsnLength: 9),
  ];

  /// Preselected on the registration form — the app's home market.
  static const Country nepal = Country(
    iso: 'NP',
    name: 'Nepal',
    dialCode: '+977',
    nsnLength: 10,
  );

  static final Map<String, Country> _byIso = <String, Country>{
    for (final Country c in all) c.iso: c,
  };

  static Country? byIso(String iso) => _byIso[iso];

  /// Case-insensitive match on the English name, then on the dial code.
  static List<Country> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return all;
    }
    return all
        .where((Country c) => c.name.toLowerCase().contains(q) || c.dialCode.contains(q))
        .toList();
  }
}
