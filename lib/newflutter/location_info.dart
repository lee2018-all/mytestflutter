class LocationInfo {
  String? address;
  double? longitude;
  double? latitude;
  String? countries;
  String? provinces;
  String? city;
  String? county;
  String? street;
  bool isFromMockProvider;

  LocationInfo({
    this.address,
    this.longitude,
    this.latitude,
    this.countries,
    this.provinces,
    this.city,
    this.county,
    this.street,
    this.isFromMockProvider = false,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      address: json['address'],
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      countries: json['countries'],
      provinces: json['provinces'],
      city: json['city'],
      county: json['county'],
      street: json['street'],
      isFromMockProvider: json['isFromMockProvider'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'countries': countries,
      'provinces': provinces,
      'city': city,
      'county': county,
      'street': street,
      'isFromMockProvider': isFromMockProvider,
    };
  }

  String toJsonString() {
    return toJson().toString();
  }

  @override
  String toString() {
    return 'LocationInfo{address: $address, lat: $latitude, lng: $longitude, isMock: $isFromMockProvider}';
  }
}