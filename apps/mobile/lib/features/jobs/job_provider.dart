import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobsState {
  const JobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Map<String, dynamic>> jobs;
  final bool isLoading;
  final String? error;

  JobsState copyWith({
    List<Map<String, dynamic>>? jobs,
    bool? isLoading,
    String? error,
  }) {
    return JobsState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JobsNotifier extends StateNotifier<JobsState> {
  JobsNotifier() : super(const JobsState());

  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: false, error: null);
  }

  Future<void> acceptJob(String jobId) async {
    final updated = state.jobs
        .map((j) => j['id'] == jobId ? {...j, 'status': 'accepted'} : j)
        .toList();
    state = state.copyWith(jobs: updated);
  }

  Future<void> completeJob(String jobId) async {
    final updated = state.jobs
        .map((j) => j['id'] == jobId ? {...j, 'status': 'completed'} : j)
        .toList();
    state = state.copyWith(jobs: updated);
  }

  Future<void> createJob({
    required String serviceType,
    required String address,
    required DateTime scheduleStart,
    required DateTime scheduleEnd,
    required int priceTotalCents,
    String? notes,
  }) async {
    final job = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'service_type': serviceType,
      'address': address,
      'schedule_start': scheduleStart.toIso8601String(),
      'schedule_end': scheduleEnd.toIso8601String(),
      'price_total_cents': priceTotalCents,
      'notes': notes ?? '',
      'status': 'pending',
    };
    state = state.copyWith(jobs: [job, ...state.jobs]);
  }
}

final jobsProvider = StateNotifierProvider<JobsNotifier, JobsState>((ref) {
  return JobsNotifier();
});
