// lib/features/meeting/data/models/transcript_model.dart
import '../../domain/entities/transcript.dart';

class TranscriptModel extends Transcript {
  const TranscriptModel({
    required super.transcriptId,
    required super.meetingId,
    super.audioPath,
    required super.status,
    super.segments,
    super.totalSegments,
    super.totalDuration,
    super.language,
    super.errorMessage,
    required super.createdAt,
    super.updatedAt,
    super.completedAt,
  });

  factory TranscriptModel.fromJson(Map<String, dynamic> json) {
    return TranscriptModel(
      transcriptId: json['transcriptId'],
      meetingId: json['meetingId'],
      audioPath: json['audioPath'],
      status: _parseStatus(json['status']),
      segments: json['segments'] != null
          ? (json['segments'] as List)
              .map((s) => TranscriptSegmentModel.fromJson(s))
              .toList()
          : null,
      totalSegments: json['totalSegments'],
      totalDuration: json['totalDuration']?.toDouble(),
      language: json['language'],
      errorMessage: json['errorMessage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  static TranscriptionStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'QUEUED':
        return TranscriptionStatus.queued;
      case 'PROCESSING':
        return TranscriptionStatus.processing;
      case 'UPLOADING':
        return TranscriptionStatus.uploading;
      case 'COMPLETED':
        return TranscriptionStatus.completed;
      case 'FAILED':
        return TranscriptionStatus.failed;
      default:
        return TranscriptionStatus.queued;
    }
  }
}

class TranscriptSegmentModel extends TranscriptSegment {
  const TranscriptSegmentModel({
    required super.start,
    required super.end,
    required super.text,
    required super.speaker,
    required super.words,
  });

  factory TranscriptSegmentModel.fromJson(Map<String, dynamic> json) {
    return TranscriptSegmentModel(
      start: json['start'].toDouble(),
      end: json['end'].toDouble(),
      text: json['text'],
      speaker: json['speaker'],
      words: (json['words'] as List)
          .map((w) => TranscriptWordModel.fromJson(w))
          .toList(),
    );
  }
}

class TranscriptWordModel extends TranscriptWord {
  const TranscriptWordModel({
    required super.word,
    required super.start,
    required super.end,
    required super.score,
    required super.speaker,
  });

  factory TranscriptWordModel.fromJson(Map<String, dynamic> json) {
    return TranscriptWordModel(
      word: json['word'],
      start: json['start'].toDouble(),
      end: json['end'].toDouble(),
      score: json['score'].toDouble(),
      speaker: json['speaker'],
    );
  }
}