import 'package:flutter/material.dart';
class ServiceCard {
  final String title;
  final String price;
  final String rating;
  final String bookings;
  final String duration;
  final Color imageColor;
  final String image;

  const ServiceCard({
    required this.title,
    required this.price,
    required this.rating,
    required this.bookings,
    required this.duration,
    required this.imageColor,
    required this.image,
  });

  ServiceCard copyWith({
    String? title,
    String? price,
    String? rating,
    String? bookings,
    String? duration,
    Color? imageColor,
  }) {
    return ServiceCard(
      title: title ?? this.title,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      bookings: bookings ?? this.bookings,
      duration: duration ?? this.duration,
      imageColor: imageColor ?? this.imageColor,
      image: image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'rating': rating,
      'bookings': bookings,
      'duration': duration,
      'imageColor': imageColor.value,
      'image': image,
    };
  }

  factory ServiceCard.fromMap(Map<String, dynamic> map) {
    return ServiceCard(
      title: map['title'] as String,
      price: map['price'] as String,
      rating: map['rating'] as String,
      bookings: map['bookings'] as String,
      duration: map['duration'] as String,
      imageColor: Color(map['imageColor'] as int),
      image: map['image'] as String,
    );
  }

  @override
  String toString() => 'ServiceCard(title: $title, price: $price, rating: $rating, bookings: $bookings, duration: $duration, imageColor: $imageColor, image: $image)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCard &&
        other.title == title &&
        other.price == price &&
        other.rating == rating &&
        other.bookings == bookings &&
        other.duration == duration &&
        other.imageColor == imageColor &&
        other.image == image;
  }

  @override
  int get hashCode => title.hashCode ^ price.hashCode ^ rating.hashCode ^ bookings.hashCode ^ duration.hashCode ^ imageColor.hashCode ^ image.hashCode;
}
