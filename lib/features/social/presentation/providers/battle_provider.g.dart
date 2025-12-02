// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$battleSessionHash() => r'5129b0c47a912f075d75283b6f2c8032c9dd48ac';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [battleSession].
@ProviderFor(battleSession)
const battleSessionProvider = BattleSessionFamily();

/// See also [battleSession].
class BattleSessionFamily extends Family<AsyncValue<BattleSession>> {
  /// See also [battleSession].
  const BattleSessionFamily();

  /// See also [battleSession].
  BattleSessionProvider call(
    String battleId,
  ) {
    return BattleSessionProvider(
      battleId,
    );
  }

  @override
  BattleSessionProvider getProviderOverride(
    covariant BattleSessionProvider provider,
  ) {
    return call(
      provider.battleId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'battleSessionProvider';
}

/// See also [battleSession].
class BattleSessionProvider extends AutoDisposeStreamProvider<BattleSession> {
  /// See also [battleSession].
  BattleSessionProvider(
    String battleId,
  ) : this._internal(
          (ref) => battleSession(
            ref as BattleSessionRef,
            battleId,
          ),
          from: battleSessionProvider,
          name: r'battleSessionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$battleSessionHash,
          dependencies: BattleSessionFamily._dependencies,
          allTransitiveDependencies:
              BattleSessionFamily._allTransitiveDependencies,
          battleId: battleId,
        );

  BattleSessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.battleId,
  }) : super.internal();

  final String battleId;

  @override
  Override overrideWith(
    Stream<BattleSession> Function(BattleSessionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BattleSessionProvider._internal(
        (ref) => create(ref as BattleSessionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        battleId: battleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<BattleSession> createElement() {
    return _BattleSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BattleSessionProvider && other.battleId == battleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, battleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BattleSessionRef on AutoDisposeStreamProviderRef<BattleSession> {
  /// The parameter `battleId` of this provider.
  String get battleId;
}

class _BattleSessionProviderElement
    extends AutoDisposeStreamProviderElement<BattleSession>
    with BattleSessionRef {
  _BattleSessionProviderElement(super.provider);

  @override
  String get battleId => (origin as BattleSessionProvider).battleId;
}

String _$battleControllerHash() => r'59fbe042889ddde6adcb985b07a0be27276eaab8';

/// See also [BattleController].
@ProviderFor(BattleController)
final battleControllerProvider =
    AutoDisposeNotifierProvider<BattleController, void>.internal(
  BattleController.new,
  name: r'battleControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$battleControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BattleController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
