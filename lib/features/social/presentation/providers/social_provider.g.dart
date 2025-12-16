// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupChatHash() => r'2e8661a9f3648df4e2d9a4471ded62c254b0b793';

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

/// See also [groupChat].
@ProviderFor(groupChat)
const groupChatProvider = GroupChatFamily();

/// See also [groupChat].
class GroupChatFamily extends Family<AsyncValue<List<SocialChatMessage>>> {
  /// See also [groupChat].
  const GroupChatFamily();

  /// See also [groupChat].
  GroupChatProvider call(
    String groupId,
  ) {
    return GroupChatProvider(
      groupId,
    );
  }

  @override
  GroupChatProvider getProviderOverride(
    covariant GroupChatProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'groupChatProvider';
}

/// See also [groupChat].
class GroupChatProvider
    extends AutoDisposeStreamProvider<List<SocialChatMessage>> {
  /// See also [groupChat].
  GroupChatProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupChat(
            ref as GroupChatRef,
            groupId,
          ),
          from: groupChatProvider,
          name: r'groupChatProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupChatHash,
          dependencies: GroupChatFamily._dependencies,
          allTransitiveDependencies: GroupChatFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupChatProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    Stream<List<SocialChatMessage>> Function(GroupChatRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupChatProvider._internal(
        (ref) => create(ref as GroupChatRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SocialChatMessage>> createElement() {
    return _GroupChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupChatProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupChatRef on AutoDisposeStreamProviderRef<List<SocialChatMessage>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupChatProviderElement
    extends AutoDisposeStreamProviderElement<List<SocialChatMessage>>
    with GroupChatRef {
  _GroupChatProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupChatProvider).groupId;
}

String _$typingStatusHash() => r'e9edd96cf066fcadce941a58c7157321865b9721';

/// See also [typingStatus].
@ProviderFor(typingStatus)
const typingStatusProvider = TypingStatusFamily();

/// See also [typingStatus].
class TypingStatusFamily extends Family<AsyncValue<List<String>>> {
  /// See also [typingStatus].
  const TypingStatusFamily();

  /// See also [typingStatus].
  TypingStatusProvider call(
    String groupId,
  ) {
    return TypingStatusProvider(
      groupId,
    );
  }

  @override
  TypingStatusProvider getProviderOverride(
    covariant TypingStatusProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'typingStatusProvider';
}

/// See also [typingStatus].
class TypingStatusProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [typingStatus].
  TypingStatusProvider(
    String groupId,
  ) : this._internal(
          (ref) => typingStatus(
            ref as TypingStatusRef,
            groupId,
          ),
          from: typingStatusProvider,
          name: r'typingStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$typingStatusHash,
          dependencies: TypingStatusFamily._dependencies,
          allTransitiveDependencies:
              TypingStatusFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  TypingStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    Stream<List<String>> Function(TypingStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TypingStatusProvider._internal(
        (ref) => create(ref as TypingStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _TypingStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingStatusProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TypingStatusRef on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _TypingStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<String>>
    with TypingStatusRef {
  _TypingStatusProviderElement(super.provider);

  @override
  String get groupId => (origin as TypingStatusProvider).groupId;
}

String _$groupMembersHash() => r'7ec7bbea3a6cb04bb8d390ed9bd5e07ddc500254';

/// See also [groupMembers].
@ProviderFor(groupMembers)
const groupMembersProvider = GroupMembersFamily();

/// See also [groupMembers].
class GroupMembersFamily extends Family<AsyncValue<List<Map<String, String>>>> {
  /// See also [groupMembers].
  const GroupMembersFamily();

  /// See also [groupMembers].
  GroupMembersProvider call(
    String groupId,
  ) {
    return GroupMembersProvider(
      groupId,
    );
  }

  @override
  GroupMembersProvider getProviderOverride(
    covariant GroupMembersProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'groupMembersProvider';
}

/// See also [groupMembers].
class GroupMembersProvider
    extends AutoDisposeFutureProvider<List<Map<String, String>>> {
  /// See also [groupMembers].
  GroupMembersProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupMembers(
            ref as GroupMembersRef,
            groupId,
          ),
          from: groupMembersProvider,
          name: r'groupMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupMembersHash,
          dependencies: GroupMembersFamily._dependencies,
          allTransitiveDependencies:
              GroupMembersFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, String>>> Function(GroupMembersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupMembersProvider._internal(
        (ref) => create(ref as GroupMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, String>>> createElement() {
    return _GroupMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupMembersRef
    on AutoDisposeFutureProviderRef<List<Map<String, String>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupMembersProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, String>>>
    with GroupMembersRef {
  _GroupMembersProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupMembersProvider).groupId;
}

String _$bannedMembersHash() => r'efd4ac4ef2bad59c5c6caf500868d5e0e2517437';

/// See also [bannedMembers].
@ProviderFor(bannedMembers)
const bannedMembersProvider = BannedMembersFamily();

/// See also [bannedMembers].
class BannedMembersFamily
    extends Family<AsyncValue<List<Map<String, String>>>> {
  /// See also [bannedMembers].
  const BannedMembersFamily();

  /// See also [bannedMembers].
  BannedMembersProvider call(
    String groupId,
  ) {
    return BannedMembersProvider(
      groupId,
    );
  }

  @override
  BannedMembersProvider getProviderOverride(
    covariant BannedMembersProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'bannedMembersProvider';
}

/// See also [bannedMembers].
class BannedMembersProvider
    extends AutoDisposeFutureProvider<List<Map<String, String>>> {
  /// See also [bannedMembers].
  BannedMembersProvider(
    String groupId,
  ) : this._internal(
          (ref) => bannedMembers(
            ref as BannedMembersRef,
            groupId,
          ),
          from: bannedMembersProvider,
          name: r'bannedMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bannedMembersHash,
          dependencies: BannedMembersFamily._dependencies,
          allTransitiveDependencies:
              BannedMembersFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  BannedMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, String>>> Function(BannedMembersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BannedMembersProvider._internal(
        (ref) => create(ref as BannedMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, String>>> createElement() {
    return _BannedMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BannedMembersProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BannedMembersRef
    on AutoDisposeFutureProviderRef<List<Map<String, String>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _BannedMembersProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, String>>>
    with BannedMembersRef {
  _BannedMembersProviderElement(super.provider);

  @override
  String get groupId => (origin as BannedMembersProvider).groupId;
}

String _$leaderboardHash() => r'55af767b15c4f34711579040bfd23e2cf08911a6';

/// See also [leaderboard].
@ProviderFor(leaderboard)
final leaderboardProvider =
    AutoDisposeFutureProvider<List<LeaderboardEntry>>.internal(
  leaderboard,
  name: r'leaderboardProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$leaderboardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LeaderboardRef = AutoDisposeFutureProviderRef<List<LeaderboardEntry>>;
String _$battleHistoryHash() => r'ee64efeb82389ddee3623cc71fc36dce57ffe143';

/// See also [battleHistory].
@ProviderFor(battleHistory)
final battleHistoryProvider =
    AutoDisposeFutureProvider<List<BattleHistory>>.internal(
  battleHistory,
  name: r'battleHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$battleHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BattleHistoryRef = AutoDisposeFutureProviderRef<List<BattleHistory>>;
String _$socialNotifierHash() => r'ffdc2d72ea883d2316ef6a4807f31218b48be8a1';

/// See also [SocialNotifier].
@ProviderFor(SocialNotifier)
final socialNotifierProvider = AutoDisposeStreamNotifierProvider<SocialNotifier,
    List<StudyGroup>>.internal(
  SocialNotifier.new,
  name: r'socialNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$socialNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SocialNotifier = AutoDisposeStreamNotifier<List<StudyGroup>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
