import 'package:bloc/bloc.dart';
import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';
import 'package:front_end/features/meeting/domain/usecases/create_meeting_usecase.dart';
import 'package:front_end/features/meeting/domain/usecases/get_meetings_by_date_usecase.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_state.dart';

part 'meeting_event.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final CreateMeetingUsecase createMeetingUsecase;
  final GetMeetingsByDateUsecase getMeetingsByDateUsecase;

  MeetingBloc(this.createMeetingUsecase, this.getMeetingsByDateUsecase) : super(CreateMeetingInitial()) {
    on<CreateMeetingEvent>(_onCreateMeeting);
    on<GetMeetingByDateEvent>(_onGetMeetingByDate);
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
        endTime: event.endTime,
        participants: event.participants,
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

  void _onGetMeetingByDate(GetMeetingByDateEvent event, Emitter<MeetingState> emit) async {
    emit(Loading());
    try {
      final result = await getMeetingsByDateUsecase(event.date);

      result.fold(
        (failure) => emit(Failure(failure.toString())),
        (meetings) => emit(Success(meetings)),
      );
    } catch (e) {
      emit(Failure(e.toString()));
    }
  }
}
