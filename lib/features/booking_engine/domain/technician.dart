
class Technician {
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final int jobs;
  final int experience;
  final int pricePerVisit;
  final double distanceKm;
  final String distanceLabel;
  final bool isTopRated;

  const Technician({required this.name, required this.specialty, required this.rating, required this.reviews, required this.jobs, required this.experience, required this.pricePerVisit, required this.distanceKm, required this.distanceLabel, required this.isTopRated});

  Technician copyWith({String? name, String? specialty, double? rating, int? reviews, int? jobs, int? experience, int? pricePerVisit, double? distanceKm, String? distanceLabel, bool? isTopRated}) {
    return Technician(name: name ?? this.name, specialty: specialty ?? this.specialty, rating: rating ?? this.rating, reviews: reviews ?? this.reviews, jobs: jobs ?? this.jobs, experience: experience ?? this.experience, pricePerVisit: pricePerVisit ?? this.pricePerVisit, distanceKm: distanceKm ?? this.distanceKm, distanceLabel: distanceLabel ?? this.distanceLabel, isTopRated: isTopRated ?? this.isTopRated);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'specialty': specialty, 'rating': rating, 'reviews': reviews, 'jobs': jobs, 'experience': experience, 'pricePerVisit': pricePerVisit, 'distanceKm': distanceKm, 'distanceLabel': distanceLabel, 'isTopRated': isTopRated};
  }

  factory Technician.fromMap(Map<String, dynamic> map) {
    return Technician(name: map['name'] as String, specialty: map['specialty'] as String, rating: map['rating'] as double, reviews: map['reviews'] as int, jobs: map['jobs'] as int, experience: map['experience'] as int, pricePerVisit: map['pricePerVisit'] as int, distanceKm: map['distanceKm'] as double, distanceLabel: map['distanceLabel'] as String, isTopRated: map['isTopRated'] as bool);
  }

  @override
  String toString() => 'Technician(name: $name, specialty: $specialty, rating: $rating, reviews: $reviews, jobs: $jobs, experience: $experience, pricePerVisit: $pricePerVisit, distanceKm: $distanceKm, distanceLabel: $distanceLabel, isTopRated: $isTopRated)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Technician && other.name == name && other.specialty == specialty && other.rating == rating && other.reviews == reviews && other.jobs == jobs && other.experience == experience && other.pricePerVisit == pricePerVisit && other.distanceKm == distanceKm && other.distanceLabel == distanceLabel && other.isTopRated == isTopRated;
  }

  @override
  int get hashCode => name.hashCode ^ specialty.hashCode ^ rating.hashCode ^ reviews.hashCode ^ jobs.hashCode ^ experience.hashCode ^ pricePerVisit.hashCode ^ distanceKm.hashCode ^ distanceLabel.hashCode ^ isTopRated.hashCode;
}
