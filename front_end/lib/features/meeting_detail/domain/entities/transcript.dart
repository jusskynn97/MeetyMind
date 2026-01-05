class Transcript {
  final String transcriptId;
  final String meetingId;
  final String? audioPath;
  final TranscriptionStatus status;
  final List<TranscriptSegment>? segments;
  final int? totalSegments;
  final double? totalDuration;
  final String? language;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const Transcript({
    required this.transcriptId,
    required this.meetingId,
    this.audioPath,
    required this.status,
    this.segments,
    this.totalSegments,
    this.totalDuration,
    this.language,
    this.errorMessage,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });
}

enum TranscriptionStatus {
  queued,
  processing,
  uploading,
  completed,
  failed
}

class TranscriptSegment {
  final double start;
  final double end;
  final String text;
  final String speaker;
  final List<TranscriptWord> words;

  const TranscriptSegment({
    required this.start,
    required this.end,
    required this.text,
    required this.speaker,
    required this.words,
  });
}

class TranscriptWord {
  final String word;
  final double start;
  final double end;
  final double score;
  final String speaker;

  const TranscriptWord({
    required this.word,
    required this.start,
    required this.end,
    required this.score,
    required this.speaker,
  });
}