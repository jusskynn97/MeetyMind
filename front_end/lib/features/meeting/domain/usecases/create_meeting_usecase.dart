import 'package:dartz/dartz.dart';
import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';
import 'package:front_end/features/meeting/domain/repositories/meeting_repository.dart';

class CreateMeetingUsecase {
  final MeetingRepository repository;

  CreateMeetingUsecase(this.repository);

  Future<Either<Exception, void>> call(MeetingCreateRequest request) async {
    try {
      await repository.createMeeting(request);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}