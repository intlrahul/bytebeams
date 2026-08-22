import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_spacing.dart';
import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:bytebeams/features/geofences/presentation/geofence_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class GeofencePage extends StatelessWidget {
  const GeofencePage({required this.createBloc, super.key});
  final GeofenceBloc Function() createBloc;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createBloc()..add(const GeofencesStarted()),
    child: const _GeofenceView(),
  );
}

final class _GeofenceView extends StatelessWidget {
  const _GeofenceView();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<GeofenceBloc, GeofenceState>(
        builder: (context, state) => SparkeeAppScaffold(
          title: 'Geofences',
          body: state.isLoading && state.geofences.isEmpty
              ? const SparkeeLoadingState(label: 'Loading saved geofences')
              : Column(
                  children: [
                    if (state.failure != null)
                      const SparkeeInlineNotice(
                        label: 'Geofences could not be saved.',
                      ),
                    Expanded(
                      child: state.geofences.isEmpty
                          ? const SparkeeEmptyState(
                              title: 'No geofences',
                              message: 'Create a circular operational area.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(SparkeeSpacing.md),
                              itemCount: state.geofences.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: SparkeeSpacing.sm),
                              itemBuilder: (_, index) => _GeofenceCard(
                                geofence: state.geofences[index],
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(SparkeeSpacing.md),
                      child: SparkeePrimaryButton(
                        label: 'Add geofence',
                        onPressed: () => _openForm(context),
                      ),
                    ),
                  ],
                ),
        ),
      );
}

final class _GeofenceCard extends StatelessWidget {
  const _GeofenceCard({required this.geofence});
  final Geofence geofence;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(geofence.displayName),
      subtitle: Text(
        '${geofence.radiusMeters.round()} m • ${geofence.vehicleCount} vehicles${geofence.isActive ? '' : ' • inactive'}',
      ),
      trailing: geofence.isActive
          ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _openForm(context, geofence: geofence);
                }
                if (value == 'deactivate') {
                  context.read<GeofenceBloc>().add(
                    GeofenceDeactivated(geofence.id),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
              ],
            )
          : null,
    ),
  );
}

Future<void> _openForm(BuildContext context, {Geofence? geofence}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<GeofenceBloc>(),
        child: _GeofenceForm(geofence: geofence),
      ),
    );

final class _GeofenceForm extends StatefulWidget {
  const _GeofenceForm({this.geofence});
  final Geofence? geofence;
  @override
  State<_GeofenceForm> createState() => _GeofenceFormState();
}

final class _GeofenceFormState extends State<_GeofenceForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.geofence?.displayName.replaceAll(' (demo)', '') ?? '',
  );
  late final TextEditingController _latitude = TextEditingController(
    text: widget.geofence?.latitude.toString() ?? '',
  );
  late final TextEditingController _longitude = TextEditingController(
    text: widget.geofence?.longitude.toString() ?? '',
  );
  late final TextEditingController _radius = TextEditingController(
    text: widget.geofence?.radiusMeters.toStringAsFixed(0) ?? '',
  );
  @override
  void dispose() {
    _name.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _radius.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        SparkeeSpacing.md,
        SparkeeSpacing.md,
        SparkeeSpacing.md,
        MediaQuery.viewInsetsOf(context).bottom + SparkeeSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.geofence == null ? 'Add geofence' : 'Edit geofence',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _latitude,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(labelText: 'Latitude'),
          ),
          TextField(
            controller: _longitude,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(labelText: 'Longitude'),
          ),
          TextField(
            controller: _radius,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Radius (m)'),
          ),
          const SizedBox(height: SparkeeSpacing.md),
          SparkeePrimaryButton(
            label: 'Save',
            onPressed: () {
              final draft = GeofenceDraft(
                displayName: _name.text,
                latitude: double.tryParse(_latitude.text) ?? double.nan,
                longitude: double.tryParse(_longitude.text) ?? double.nan,
                radiusMeters: double.tryParse(_radius.text) ?? double.nan,
              );
              final bloc = context.read<GeofenceBloc>();
              final geofence = widget.geofence;
              bloc.add(
                geofence == null
                    ? GeofenceCreated(draft)
                    : GeofenceEdited(geofence.id, draft),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
