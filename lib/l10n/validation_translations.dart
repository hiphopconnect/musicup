import 'package:music_up/l10n/app_localizations.dart';

String translateValidation(AppLocalizations l10n, String key) {
  return switch (key) {
    'albumNameRequired' => l10n.validationAlbumNameRequired,
    'albumNameTooLong' => l10n.validationAlbumNameTooLong,
    'artistRequired' => l10n.validationArtistRequired,
    'artistTooLong' => l10n.validationArtistTooLong,
    'genreTooLong' => l10n.validationGenreTooLong,
    'yearFormat' => l10n.validationYearFormat,
    'yearTooOld' => l10n.validationYearTooOld,
    'yearTooFuture' => l10n.validationYearTooFuture,
    'invalidMedium' => l10n.validationInvalidMedium,
    'trackNameRequired' => l10n.validationTrackNameRequired,
    'trackNameTooLong' => l10n.validationTrackNameTooLong,
    'timeFormat' => l10n.validationTimeFormat,
    'invalidTimeFormat' => l10n.validationInvalidTimeFormat,
    'minutesRange' => l10n.validationMinutesRange,
    'secondsRange' => l10n.validationSecondsRange,
    'editAlbumNameRequired' => l10n.editValidationAlbumNameRequired,
    'editArtistRequired' => l10n.editValidationArtistRequired,
    'editMediumRequired' => l10n.editValidationMediumRequired,
    'editDigitalRequired' => l10n.editValidationDigitalRequired,
    'editTrackRequired' => l10n.editValidationTrackRequired,
    _ => key,
  };
}

String translateEditValidation(AppLocalizations l10n, String key) {
  // Handle parameterized track title validation
  final trackTitleMatch = RegExp(r'^editTrackTitleRequired:(\d+)$').firstMatch(key);
  if (trackTitleMatch != null) {
    final index = int.parse(trackTitleMatch.group(1)!);
    return l10n.editValidationTrackTitleRequired(index);
  }

  return switch (key) {
    'editAlbumNameRequired' => l10n.editValidationAlbumNameRequired,
    'editArtistRequired' => l10n.editValidationArtistRequired,
    'editMediumRequired' => l10n.editValidationMediumRequired,
    'editDigitalRequired' => l10n.editValidationDigitalRequired,
    'editTrackRequired' => l10n.editValidationTrackRequired,
    _ => translateValidation(l10n, key),
  };
}
