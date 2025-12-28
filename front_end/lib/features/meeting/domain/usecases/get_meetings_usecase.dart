import 'package:dartz/dartz.dart';
import 'package:front_end/features/meeting/domain/entities/meeting.dart';
import 'package:front_end/features/meeting/domain/repositories/meeting_repository.dart';

class GetMeetingsUsecase {
  final MeetingRepository repository;

  GetMeetingsUsecase(this.repository);

  Future<Either<Exception, List<Meeting>>> call(DateTime date) async {
    try {
      final meetings = await repository.fetchMeetings(date);
      return Right(meetings.cast<Meeting>());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}