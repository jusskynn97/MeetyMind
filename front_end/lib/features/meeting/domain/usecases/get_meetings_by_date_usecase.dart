import 'package:dartz/dartz.dart';
import 'package:front_end/features/meeting/domain/entities/meeting.dart';
import 'package:front_end/features/meeting/domain/repositories/meeting_repository.dart';

class GetMeetingsByDateUsecase {
  final MeetingRepository repository;

  GetMeetingsByDateUsecase(this.repository);

  Future<Either<Exception, List<Meeting>>> call(DateTime date) async {
    try {
      final meetings = await repository.getMeetingsByDate(date);
      return Right(meetings.cast<Meeting>());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}