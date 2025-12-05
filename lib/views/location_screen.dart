import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/location_viewmodel.dart';
import 'map_screen.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
            tooltip: 'View Map',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LocationViewModel>().getCurrentLocation();
            },
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Consumer<LocationViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildPermissionStatus(context, viewModel),
              if (viewModel.errorMessage != null)
                _buildErrorBanner(context, viewModel),
              if (viewModel.currentLocation != null)
                _buildCurrentLocation(context, viewModel),
              const Divider(height: 1),
              _buildHistoryHeader(context, viewModel),
              Expanded(
                child: _buildLocationHistory(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionStatus(BuildContext context, LocationViewModel viewModel) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (viewModel.permissionStatus) {
      case LocationPermissionStatus.granted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Location Permission Granted';
        break;
      case LocationPermissionStatus.denied:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Location Permission Denied';
        break;
      case LocationPermissionStatus.permanentlyDenied:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Location Permission Permanently Denied';
        break;
      case LocationPermissionStatus.restricted:
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'Location Permission Restricted';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (viewModel.permissionStatus == LocationPermissionStatus.denied)
            ElevatedButton(
              onPressed: () => viewModel.checkAndRequestPermissions(),
              child: const Text('Grant'),
            ),
          if (viewModel.permissionStatus == LocationPermissionStatus.permanentlyDenied)
            ElevatedButton(
              onPressed: () => viewModel.openSettings(),
              child: const Text('Settings'),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, LocationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.red.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocation(BuildContext context, LocationViewModel viewModel) {
    final location = viewModel.currentLocation!;
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm:ss a');

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.pin_drop, 'Coordinates', location.formattedCoordinates),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_city, 'Address', location.formattedAddress),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Last Updated', dateFormat.format(location.timestamp)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader(BuildContext context, LocationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Location History (${viewModel.locationHistory.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (viewModel.locationHistory.isNotEmpty)
            TextButton.icon(
              onPressed: () => viewModel.clearHistory(),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationHistory(BuildContext context, LocationViewModel viewModel) {
    if (viewModel.isLoading && viewModel.locationHistory.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.locationHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No location history yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Move around to see your location history',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: viewModel.locationHistory.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final location = viewModel.locationHistory[index];
        final dateFormat = DateFormat('MMM dd, hh:mm a');
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            location.formattedAddress,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                location.formattedCoordinates,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                dateFormat.format(location.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Could navigate to detailed view or map
          },
        );
      },
    );
  }
}
