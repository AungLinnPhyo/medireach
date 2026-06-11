// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localPatientsStreamHash() =>
    r'6b1e7e9e4288f9fadfc3ab1436b49c4900582dc0';

/// See also [localPatientsStream].
@ProviderFor(localPatientsStream)
final localPatientsStreamProvider =
    AutoDisposeStreamProvider<List<PatientEntity>>.internal(
      localPatientsStream,
      name: r'localPatientsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localPatientsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalPatientsStreamRef =
    AutoDisposeStreamProviderRef<List<PatientEntity>>;
String _$outboxQueueStreamHash() => r'76ebb338ad1474bd1d912d347a9cae86f56b8e22';

/// See also [outboxQueueStream].
@ProviderFor(outboxQueueStream)
final outboxQueueStreamProvider =
    AutoDisposeStreamProvider<List<OfflineOutboxItem>>.internal(
      outboxQueueStream,
      name: r'outboxQueueStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$outboxQueueStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OutboxQueueStreamRef =
    AutoDisposeStreamProviderRef<List<OfflineOutboxItem>>;
String _$patientFormControllerHash() =>
    r'd7ec80c403c1fef7cb261dffbdf4531a8f61ddac';

/// See also [PatientFormController].
@ProviderFor(PatientFormController)
final patientFormControllerProvider =
    AutoDisposeAsyncNotifierProvider<PatientFormController, void>.internal(
      PatientFormController.new,
      name: r'patientFormControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$patientFormControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PatientFormController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
