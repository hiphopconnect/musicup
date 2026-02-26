// lib/widgets/track_management_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/section_card.dart';

class TrackManagementWidget extends StatefulWidget {
  final List<Track> tracks;
  final ValueChanged<List<Track>> onTracksChanged;
  final ScrollController? scrollController;
  final bool enableValidation;

  const TrackManagementWidget({
    super.key,
    required this.tracks,
    required this.onTracksChanged,
    this.scrollController,
    this.enableValidation = true,
  });

  @override
  State<TrackManagementWidget> createState() => _TrackManagementWidgetState();
}

class _TrackManagementWidgetState extends State<TrackManagementWidget> {
  List<TextEditingController> _trackTitleControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeTrackControllers();
  }

  @override
  void didUpdateWidget(TrackManagementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tracks != widget.tracks) {
      _updateTrackControllers();
    }
  }

  @override
  void dispose() {
    for (var controller in _trackTitleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeTrackControllers() {
    _trackTitleControllers = widget.tracks.map((track) {
      return TextEditingController(text: track.title);
    }).toList();
  }

  void _updateTrackControllers() {
    for (var controller in _trackTitleControllers) {
      controller.dispose();
    }
    _trackTitleControllers = widget.tracks.map((track) {
      return TextEditingController(text: track.title);
    }).toList();
  }

  void _reorderTracks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<Track> updatedTracks = List.from(widget.tracks);
    final Track track = updatedTracks.removeAt(oldIndex);
    updatedTracks.insert(newIndex, track);

    _updateAllTrackNumbers(updatedTracks);
    widget.onTracksChanged(updatedTracks);
  }

  void _updateAllTrackNumbers(List<Track> tracksList) {
    for (int i = 0; i < tracksList.length; i++) {
      tracksList[i] = Track(
        trackNumber: (i + 1).toString().padLeft(2, '0'),
        title: tracksList[i].title,
      );
    }
  }

  void _addTrack() {
    final List<Track> updatedTracks = List.from(widget.tracks);
    updatedTracks.add(Track(
      trackNumber: (updatedTracks.length + 1).toString().padLeft(2, '0'),
      title: '',
    ));

    widget.onTracksChanged(updatedTracks);

    // Scroll to bottom after adding track
    if (widget.scrollController != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.scrollController!.animateTo(
          widget.scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _removeTrack(int index) {
    if (widget.tracks.length <= 1) return;

    final List<Track> updatedTracks = List.from(widget.tracks);
    updatedTracks.removeAt(index);
    _updateAllTrackNumbers(updatedTracks);

    widget.onTracksChanged(updatedTracks);
  }

  void _updateTrackTitle(int index, String newTitle) {
    final List<Track> updatedTracks = List.from(widget.tracks);
    updatedTracks[index] = Track(
      trackNumber: updatedTracks[index].trackNumber,
      title: newTitle,
    );
    widget.onTracksChanged(updatedTracks);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.trackListTitle(widget.tracks.length),
      child: Column(
        children: [
          // Add track button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addTrack,
              icon: const Icon(Icons.add),
              label: Text(l10n.addTrack),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: DS.md),

          // Tracks list
          if (widget.tracks.isNotEmpty) ...[
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: widget.tracks.length,
                onReorder: _reorderTracks,
                itemBuilder: (context, index) {
                  final track = widget.tracks[index];
                  return Card(
                    key: ValueKey('track_$index'),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    child: Padding(
                      padding: const EdgeInsets.all(DS.xs),
                      child: Row(
                        children: [
                          // Track number
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.darkGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                track.trackNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: DS.sm),

                          // Track title input
                          Expanded(
                            child: TextField(
                              controller: index < _trackTitleControllers.length
                                  ? _trackTitleControllers[index]
                                  : TextEditingController(text: track.title),
                              maxLength: 150,
                              decoration: InputDecoration(
                                labelText: 'Track ${track.trackNumber}',
                                border: const OutlineInputBorder(),
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: DS.sm,
                                  vertical: DS.xs,
                                ),
                              ),
                              onChanged: (value) => _updateTrackTitle(index, value),
                            ),
                          ),
                          const SizedBox(width: DS.xs),

                          // Delete button
                          if (widget.tracks.length > 1)
                            IconButton(
                              onPressed: () => _removeTrack(index),
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              tooltip: l10n.removeTrack,
                            ),

                          // Drag handle
                          const Icon(
                            Icons.drag_handle,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DS.md),
                child: Text(
                  l10n.noTracksAdded,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
