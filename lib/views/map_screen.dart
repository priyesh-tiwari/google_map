import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/location_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Map'),
        elevation: 2,
      ),
      body: Consumer<LocationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null) {
            return const Center(
              child: Text('No location data available'),
            );
          }

          _updateMarkersAndPolylines(viewModel);

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                viewModel.currentLocation!.latitude,
                viewModel.currentLocation!.longitude,
              ),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          );
        },
      ),
    );
  }

  void _updateMarkersAndPolylines(LocationViewModel viewModel) {
    _markers.clear();
    _polylines.clear();

    // Add current location marker
    if (viewModel.currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            viewModel.currentLocation!.latitude,
            viewModel.currentLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: viewModel.currentLocation!.formattedAddress,
          ),
        ),
      );
    }

    // Add history markers and path
    if (viewModel.locationHistory.length > 1) {
      List<LatLng> pathPoints = [];
      
      for (int i = 0; i < viewModel.locationHistory.length; i++) {
        final location = viewModel.locationHistory[i];
        pathPoints.add(LatLng(location.latitude, location.longitude));
        
        if (i > 0) { // Don't add marker for current location again
          _markers.add(
            Marker(
              markerId: MarkerId('history_$i'),
              position: LatLng(location.latitude, location.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              alpha: 0.7,
              infoWindow: InfoWindow(
                title: 'Location ${i + 1}',
                snippet: location.formattedAddress,
              ),
            ),
          );
        }
      }

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('location_path'),
          points: pathPoints,
          color: Colors.blue,
          width: 3,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}