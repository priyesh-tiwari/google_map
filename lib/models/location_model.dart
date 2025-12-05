class LocationModel {
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? postalCode;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.postalCode,
    required this.timestamp,
  });

  String get formattedCoordinates => 
      'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';

  String get formattedAddress {
    List<String> parts = [];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.isEmpty ? 'Address unavailable' : parts.join(', ');
  }
}