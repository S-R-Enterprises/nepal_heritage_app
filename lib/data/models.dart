import 'package:flutter/material.dart';

/// Unsplash URLs copied verbatim from the `IMG` object in `App.tsx`.
class Img {
  const Img._();

  static const String hero =
      'https://images.unsplash.com/photo-1648298470994-7065f521375c?w=800&h=500&fit=crop&auto=format';
  static const String pashupati =
      'https://images.unsplash.com/photo-1507743617593-0a422c9bb7f5?w=600&h=400&fit=crop&auto=format';
  static const String boudha =
      'https://images.unsplash.com/photo-1647172122108-202c8497fdbd?w=600&h=400&fit=crop&auto=format';
  static const String patan =
      'https://images.unsplash.com/photo-1731052368947-9f262c4e9f4c?w=600&h=400&fit=crop&auto=format';
  static const String tower =
      'https://images.unsplash.com/photo-1648298471396-5f8a2614b20d?w=600&h=400&fit=crop&auto=format';
  static const String mountains =
      'https://images.unsplash.com/photo-1580424917967-a8867a6e676e?w=600&h=400&fit=crop&auto=format';
  static const String annapurna =
      'https://images.unsplash.com/photo-1553886334-43d24f24d3bd?w=600&h=400&fit=crop&auto=format';
  static const String aerial =
      'https://images.unsplash.com/photo-1511215579272-6192432f83bc?w=600&h=400&fit=crop&auto=format';
  static const String village =
      'https://images.unsplash.com/photo-1718179634911-8551f8b0cccf?w=600&h=400&fit=crop&auto=format';
  static const String festival =
      'https://images.unsplash.com/photo-1726326477267-f36f1740ad8e?w=600&h=400&fit=crop&auto=format';
  static const String dance =
      'https://images.unsplash.com/photo-1763733593970-6b618d8253ff?w=600&h=400&fit=crop&auto=format';
  static const String flagGirl =
      'https://images.unsplash.com/photo-1763733595401-6fa630bd57ee?w=600&h=400&fit=crop&auto=format';
  static const String streetFlags =
      'https://images.unsplash.com/photo-1761124739751-69f609332fa0?w=600&h=400&fit=crop&auto=format';

  // Avatars.
  static const String avatarUser =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=88&h=88&fit=crop&auto=format';
  static const String avatarUserLarge =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop&auto=format';
  static const String avatarAarav =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&auto=format';
  static const String avatarAaravLarge =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&h=120&fit=crop&auto=format';
  static const String avatarAaravSmall =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop&auto=format';
  static const String avatarPriya =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&auto=format';
  static const String avatarBibek =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&auto=format';
}

class HeritageSite {
  const HeritageSite({
    required this.name,
    required this.location,
    required this.rating,
    required this.image,
    required this.entryFee,
  });

  final String name;
  final String location;
  final double rating;
  final String image;
  final String entryFee;
}

class HiddenGem {
  const HiddenGem({
    required this.name,
    required this.location,
    required this.distance,
    required this.category,
    required this.image,
    required this.rating,
  });

  final String name;
  final String location;
  final String distance;
  final String category;
  final String image;
  final double rating;
}

class Festival {
  const Festival({
    required this.name,
    required this.date,
    required this.month,
    required this.color,
    required this.image,
    required this.description,
  });

  final String name;
  final String date;
  final String month;
  final Color color;
  final String image;
  final String description;
}

class Guide {
  const Guide({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.price,
    required this.avatar,
  });

  final String name;
  final String specialty;
  final double rating;
  final String price;
  final String avatar;
}

class Review {
  const Review({
    required this.name,
    required this.date,
    required this.rating,
    required this.text,
    this.flag,
  });

  final String name;
  final String date;
  final int rating;
  final String text;

  /// Optional emoji flag shown in place of an avatar on the guide screen.
  final String? flag;
}

enum TicketStatus { active, used }

class Ticket {
  const Ticket({
    required this.site,
    required this.date,
    required this.reference,
    required this.adults,
    required this.status,
  });

  final String site;
  final String date;
  final String reference;
  final int adults;
  final TicketStatus status;
}

class BookingRecord {
  const BookingRecord({
    required this.name,
    required this.type,
    required this.date,
    required this.status,
    required this.image,
  });

  final String name;
  final String type;
  final String date;
  final String status;
  final String image;
}

class Hotel {
  const Hotel({
    required this.name,
    required this.stars,
    required this.price,
    required this.distance,
    required this.availability,
  });

  final String name;
  final int stars;
  final String price;
  final String distance;
  final String availability;

  bool get isScarce => availability.contains('Last');
}

enum PaymentMethod { esewa, khalti, card }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.esewa => 'eSewa',
        PaymentMethod.khalti => 'Khalti',
        PaymentMethod.card => 'Card',
      };

  String get logo => switch (this) {
        PaymentMethod.esewa => 'eSewa',
        PaymentMethod.khalti => 'Khalti',
        PaymentMethod.card => '\u{1F4B3}',
      };

  Color get color => switch (this) {
        PaymentMethod.esewa => const Color(0xFF60BB46),
        PaymentMethod.khalti => const Color(0xFF5C2D91),
        PaymentMethod.card => const Color(0xFF1A56DB),
      };
}
