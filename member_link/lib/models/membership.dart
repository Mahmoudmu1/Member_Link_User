class Membership {
  String? id;
  String? name;
  String? description;
  String? price;
  String? duration;
  String? benefits;
  String? terms;
  String? membershipFilename;
  double? membershipRating;
  int? membershipsold;

  Membership({
    this.id,
    this.name,
    this.description,
    this.price,
    this.duration,
    this.benefits,
    this.terms,
    this.membershipFilename,
    this.membershipRating,
    this.membershipsold,
  });

  // Convert JSON to Membership object
  Membership.fromJson(Map<String, dynamic> json) {
    id = json['membership_id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    duration = json['duration'];
    benefits = json['benefits'];
    terms = json['terms'];
    membershipFilename = json['membership_filename'];
    membershipRating = json['membership_rating'] != null
        ? double.tryParse(json['membership_rating'].toString())
        : null;
    membershipsold = json['membership_sold'] != null
        ? int.tryParse(json['membership_sold'].toString())
        : null;
  }

  // Convert Membership object to JSON
  Map<String, dynamic> toJson() {
    return {
      'membership_id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'benefits': benefits,
      'terms': terms,
      'membership_filename': membershipFilename,
      'membership_rating': membershipRating?.toString(),
      'membership_sold': membershipsold?.toString(),
    };
  }
}
