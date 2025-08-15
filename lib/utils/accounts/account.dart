import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:hive/hive.dart';

abstract class Account {
  final bool isLogin = false;
  late final DefaultCookieJar cookieJar;
  String? accessKey;
  String? refresh;
  late final Set<AccountType> type;

  final int mid = 0;
  late String csrf;
  final Map<String, String> headers = const {};

  bool activited = false;

  Future<void> delete();
  Future<void> onChange();

  Map<String, dynamic>? toJson();
}

@HiveType(typeId: 9)
class LoginAccount implements Account {
  @override
  final bool isLogin = true;
  @override
  @HiveField(0)
  late final DefaultCookieJar cookieJar;
  @override
  @HiveField(1)
  String? accessKey;
  @override
  @HiveField(2)
  String? refresh;
  @override
  @HiveField(3)
  late final Set<AccountType> type;

  @override
  bool activited = false;

  @override
  late final int mid = int.parse(_midStr);

  @override
  late final Map<String, String> headers = {
    ...Constants.baseHeaders,
    'x-bili-mid': _midStr,
    'x-bili-aurora-eid': IdUtils.genAuroraEid(mid),
  };

  @override
  late String csrf =
      cookieJar.domainCookies['bilibili.com']!['/']!['bili_jct']!.cookie.value;

  @override
  Future<void> delete() => _box.delete(_midStr);

  @override
  Future<void> onChange() => _box.put(_midStr, this);

  @override
  Map<String, dynamic>? toJson() => {
    'cookies': cookieJar.toJson(),
    'accessKey': accessKey,
    'refresh': refresh,
    'type': type.map((i) => i.index).toList(),
  };

  late final String _midStr = cookieJar
      .domainCookies['bilibili.com']!['/']!['DedeUserID']!
      .cookie
      .value;

  late final Box<LoginAccount> _box = Accounts.account;

  LoginAccount(
    this.cookieJar,
    this.accessKey,
    this.refresh, [
    Set<AccountType>? type,
  ]) : type = type ?? {} {
    cookieJar.setBuvid3();
  }

  LoginAccount.fromJson(Map json) {
    cookieJar = BiliCookieJar.fromJson(json['cookies'])..setBuvid3();
    accessKey = json['accessKey'];
    refresh = json['refresh'];
    type =
        (json['type'] as Iterable?)
            ?.map((i) => AccountType.values[i])
            .toSet() ??
        {};
  }

  @override
  int get hashCode => mid.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is LoginAccount && mid == other.mid);
}

class AnonymousAccount implements Account {
  @override
  final bool isLogin = false;
  @override
  late final DefaultCookieJar cookieJar;
  @override
  String? accessKey;
  @override
  String? refresh;
  @override
  Set<AccountType> type = {};
  @override
  final int mid = 0;
  @override
  String csrf = '';
  @override
  final Map<String, String> headers = Constants.baseHeaders;

  @override
  bool activited = false;

  @override
  Future<void> delete() async {
    await cookieJar.deleteAll();
    cookieJar.setBuvid3();
  }

  @override
  Future<void> onChange() async {}

  @override
  Map<String, dynamic>? toJson() => null;

  static final _instance = AnonymousAccount._();

  AnonymousAccount._() {
    cookieJar = DefaultCookieJar(ignoreExpires: true)..setBuvid3();
  }

  factory AnonymousAccount() => _instance;

  @override
  int get hashCode => cookieJar.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnonymousAccount && cookieJar == other.cookieJar);
}

extension BiliCookie on Cookie {
  void setBiliDomain([String domain = '.bilibili.com']) {
    this
      ..domain = domain
      ..httpOnly = false
      ..path = '/';
  }
}

extension BiliCookieJar on DefaultCookieJar {
  Map<String, String> toJson() {
    final cookies = domainCookies['bilibili.com']?['/'] ?? {};
    return {for (var i in cookies.values) i.cookie.name: i.cookie.value};
  }

  List<Cookie> toList() =>
      domainCookies['bilibili.com']?['/']?.entries
          .map((i) => i.value.cookie)
          .toList() ??
      [];

  void setBuvid3() {
    domainCookies['bilibili.com'] ??= {'/': {}};
    domainCookies['bilibili.com']!['/']!['buvid3'] ??= SerializableCookie(
      Cookie('buvid3', IdUtils.genBuvid3())..setBiliDomain(),
    );
  }

  static DefaultCookieJar fromJson(Map json) =>
      DefaultCookieJar(ignoreExpires: true)
        ..domainCookies['bilibili.com'] = {
          '/': {
            for (var i in json.entries)
              i.key: SerializableCookie(
                Cookie(i.key, i.value)..setBiliDomain(),
              ),
          },
        };

  static DefaultCookieJar fromList(List cookies) =>
      DefaultCookieJar(ignoreExpires: true)
        ..domainCookies['bilibili.com'] = {
          '/': {
            for (var i in cookies)
              i['name']!: SerializableCookie(
                Cookie(i['name']!, i['value']!)..setBiliDomain(),
              ),
          },
        };
}

class NoAccount implements Account {
  @override
  String? accessKey;

  @override
  bool activited = false;

  @override
  DefaultCookieJar cookieJar = DefaultCookieJar();

  @override
  String csrf = '';

  @override
  String? refresh;

  @override
  Set<AccountType> type = const {};

  @override
  Future<void> delete() {
    return Future.value();
  }

  @override
  final Map<String, String> headers = const {};

  @override
  bool isLogin = false;

  @override
  int mid = 0;

  @override
  Future<void> onChange() {
    return Future.value();
  }

  @override
  Map<String, dynamic>? toJson() {
    return null;
  }

  NoAccount._();

  static final _instance = NoAccount._();

  factory NoAccount() => _instance;
}
