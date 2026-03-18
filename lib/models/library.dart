class Library {
  final int id;
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String addressLine3;
  final String postcode;
  final double latitude;
  final double longitude;
  final String websiteUrl;
  final String mondayStaffedHours;
  final String mondayUnstaffedHours;
  final String tuesdayStaffedHours;
  final String tuesdayUnstaffedHours;
  final String wednesdayStaffedHours;
  final String wednesdayUnstaffedHours;
  final String thursdayStaffedHours;
  final String thursdayUnstaffedHours;
  final String fridayStaffedHours;
  final String fridayUnstaffedHours;
  final String saturdayStaffedHours;
  final String saturdayUnstaffedHours;
  final String sundayStaffedHours;
  final String sundayUnstaffedHours;

  Library({
    required this.id,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.addressLine3,
    required this.postcode,
    required this.latitude,
    required this.longitude,
    required this.websiteUrl,
    required this.mondayStaffedHours,
    required this.mondayUnstaffedHours,
    required this.tuesdayStaffedHours,
    required this.tuesdayUnstaffedHours,
    required this.wednesdayStaffedHours,
    required this.wednesdayUnstaffedHours,
    required this.thursdayStaffedHours,
    required this.thursdayUnstaffedHours,
    required this.fridayStaffedHours,
    required this.fridayUnstaffedHours,
    required this.saturdayStaffedHours,
    required this.saturdayUnstaffedHours,
    required this.sundayStaffedHours,
    required this.sundayUnstaffedHours,
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'] as int,
      name: json['name'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      addressLine3: json['addressLine3'] as String,
      postcode: json['postcode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      websiteUrl: json['websiteUrl'] as String,
      mondayStaffedHours: json['mondayStaffedHours'] as String,
      mondayUnstaffedHours: json['mondayUnstaffedHours'] as String,
      tuesdayStaffedHours: json['tuesdayStaffedHours'] as String,
      tuesdayUnstaffedHours: json['tuesdayUnstaffedHours'] as String,
      wednesdayStaffedHours: json['wednesdayStaffedHours'] as String,
      wednesdayUnstaffedHours: json['wednesdayUnstaffedHours'] as String,
      thursdayStaffedHours: json['thursdayStaffedHours'] as String,
      thursdayUnstaffedHours: json['thursdayUnstaffedHours'] as String,
      fridayStaffedHours: json['fridayStaffedHours'] as String,
      fridayUnstaffedHours: json['fridayUnstaffedHours'] as String,
      saturdayStaffedHours: json['saturdayStaffedHours'] as String,
      saturdayUnstaffedHours: json['saturdayUnstaffedHours'] as String,
      sundayStaffedHours: json['sundayStaffedHours'] as String,
      sundayUnstaffedHours: json['sundayUnstaffedHours'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'addressLine3': addressLine3,
      'postcode': postcode,
      'latitude': latitude,
      'longitude': longitude,
      'websiteUrl': websiteUrl,
      'mondayStaffedHours': mondayStaffedHours,
      'mondayUnstaffedHours': mondayUnstaffedHours,
      'tuesdayStaffedHours': tuesdayStaffedHours,
      'tuesdayUnstaffedHours': tuesdayUnstaffedHours,
      'wednesdayStaffedHours': wednesdayStaffedHours,
      'wednesdayUnstaffedHours': wednesdayUnstaffedHours,
      'thursdayStaffedHours': thursdayStaffedHours,
      'thursdayUnstaffedHours': thursdayUnstaffedHours,
      'fridayStaffedHours': fridayStaffedHours,
      'fridayUnstaffedHours': fridayUnstaffedHours,
      'saturdayStaffedHours': saturdayStaffedHours,
      'saturdayUnstaffedHours': saturdayUnstaffedHours,
      'sundayStaffedHours': sundayStaffedHours,
      'sundayUnstaffedHours': sundayUnstaffedHours,
    };
  }
}
