import 'package:bloc/bloc.dart';
import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';
import 'package:front_end/features/meeting/domain/usecases/create_meeting_usecase.dart';
import 'package:front_end/features/meeting/domain/usecases/get_meetings_usecase.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_state.dart';

part 'meeting_event.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final CreateMeetingUsecase createMeetingUsecase;
  final GetMeetingsUsecase getMeetingsUsecase;

  MeetingBloc(this.createMeetingUsecase, this.getMeetingsUsecase) : super(CreateMeetingInitial()) {
    on<CreateMeetingEvent>(_onCreateMeeting);
  }

  void _onCreateMeeting(CreateMeetingEvent event, Emitter<MeetingState> emit) async {
    emit(CreateMeetingLoading());
    try {
      final createMeetingRequest = MeetingCreateRequest(
        title: event.title, 
        description: event.description, 
        location: event.location, 
        date: event.date, 
        startTime: event.startTime, 
        endTime: event.endTime
      );

      final result = await createMeetingUsecase(createMeetingRequest);

      result.fold(
        (failure) => emit(CreateMeetingFailure(failure.toString())),
        (_) => emit(CreateMeetingSuccess()),
      );
      // XÓA dòng emit(CreateMeetingSuccess()); ở đây
    } catch (e) {
      emit(CreateMeetingFailure(e.toString()));
    }
  }
}
