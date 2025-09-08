import 'dart:math';
import 'package:flutter/material.dart';

class Friend {
  Friend({required this.id, required this.name, required this.code});
  final String id;
  String name;
  String code;
}

class SimpleCommunity {
  SimpleCommunity({required this.id, required this.name, required this.code});
  final String id;
  String name;
  String code;
}

class SocialState extends ChangeNotifier {
  SocialState();

  /// Demo-Daten
  SocialState.demo() {
    friends.addAll([
      Friend(id: _id(), name: 'You',   code: _friendCode()),
      Friend(id: _id(), name: 'Bernd', code: _friendCode()),
      Friend(id: _id(), name: 'Peter', code: _friendCode()),
    ]);
    communities.addAll([
      SimpleCommunity(id: _id(), name: 'Mindful Monday', code: _communityCode()),
      SimpleCommunity(id: _id(), name: 'Local Helpers',  code: _communityCode()),
    ]);
    incomingFriendRequests.addAll([
      Friend(id: _id(), name: 'Alex', code: _friendCode()),
      Friend(id: _id(), name: 'Kim',  code: _friendCode()),
    ]);
    communityInvites.addAll([
      SimpleCommunity(id: _id(), name: 'GreenSteps', code: _communityCode()),
    ]);
  }

  // ---- Daten ----
  final List<Friend> friends = [];
  final List<Friend> outgoingFriendRequests = [];
  final List<Friend> incomingFriendRequests = [];

  final List<SimpleCommunity> communities = [];
  final List<SimpleCommunity> communityInvites = [];

  // ---- Freunde ----
  void sendFriendRequestByName(String name) {
    outgoingFriendRequests.add(Friend(id: _id(), name: name, code: _friendCode()));
    notifyListeners();
  }

  void addFriendByCode(String code, {String fallbackName = 'Freund'}) {
    if (friends.any((f) => f.code.toUpperCase() == code.toUpperCase())) return;
    friends.add(Friend(id: _id(), name: fallbackName, code: code.toUpperCase()));
    notifyListeners();
  }

  void acceptIncoming(Friend f) {
    incomingFriendRequests.removeWhere((x) => x.id == f.id);
    friends.add(f);
    notifyListeners();
  }

  void declineIncoming(Friend f) {
    incomingFriendRequests.removeWhere((x) => x.id == f.id);
    notifyListeners();
  }

  void cancelOutgoing(Friend f) {
    outgoingFriendRequests.removeWhere((x) => x.id == f.id);
    notifyListeners();
  }

  void removeFriend(Friend f) {
    friends.removeWhere((x) => x.id == f.id);
    notifyListeners();
  }

  // ---- Communities ----
  void joinCommunityByCode(String code) {
    if (communities.any((c) => c.code.toUpperCase() == code.toUpperCase())) return;
    communities.add(SimpleCommunity(
      id: _id(),
      name: 'Community $code',
      code: code.toUpperCase(),
    ));
    notifyListeners();
  }

  void joinCommunityByName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;

    if (communities.any((c) => c.name.toLowerCase() == clean.toLowerCase())) return;

    communities.add(SimpleCommunity(
      id: _id(),
      name: clean,
      code: _communityCode(), // generiert zufälligen Code
    ));
    notifyListeners();
  }

  SimpleCommunity createCommunity(String name) {
    final c = SimpleCommunity(
      id: _id(),
      name: name.isEmpty ? 'Neue Community' : name,
      code: _communityCode(),
    );
    communities.add(c);
    notifyListeners();
    return c;
  }

  void acceptCommunityInvite(SimpleCommunity c) {
    communityInvites.removeWhere((x) => x.id == c.id);
    if (!communities.any((m) => m.code == c.code)) communities.add(c);
    notifyListeners();
  }

  void declineCommunityInvite(SimpleCommunity c) {
    communityInvites.removeWhere((x) => x.id == c.id);
    notifyListeners();
  }

  // ---- Provider (InheritedNotifier) ----
  static SocialState of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<SocialScope>()
        : context.getInheritedWidgetOfExactType<SocialScope>();
    assert(scope != null,
    'SocialScope not found. Wrap your app with SocialScope.provide(...)');
    return scope!.notifier!;
  }
}

class SocialScope extends InheritedNotifier<SocialState> {
  const SocialScope({
    super.key,
    required SocialState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  /// Bequeme Factory zum Einhüllen der App
  static Widget provide({
    required SocialState state,
    required Widget child,
  }) {
    return SocialScope(notifier: state, child: child);
  }
}

// ---- kleine Helfer zur Code/ID-Generierung ----
final _rnd = Random.secure();
String _id() => DateTime.now().microsecondsSinceEpoch.toString() + _rnd.nextInt(999).toString();
const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
String _seg(int n) => List.generate(n, (_) => _chars[_rnd.nextInt(_chars.length)]).join();
String _friendCode()    => '${_seg(2)}${_rnd.nextInt(9)}${_rnd.nextInt(9)}-${_seg(3)}';
String _communityCode() => '${_seg(2)}${_rnd.nextInt(9)}-${_seg(2)}${_rnd.nextInt(9)}';
