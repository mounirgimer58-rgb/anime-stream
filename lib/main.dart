import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AnimeStreamApp());
}

// ============================================================
// APP
// ============================================================

class AnimeStreamApp extends StatefulWidget {
  const AnimeStreamApp({super.key});

  @override
  State<AnimeStreamApp> createState() => _AnimeStreamAppState();
}

class _AnimeStreamAppState extends State<AnimeStreamApp> {
  Locale _locale = const Locale('en');

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime Stream',
      locale: _locale,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF09090F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF09090F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF15151F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF171721),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF8B5CF6),
              width: 1.2,
            ),
          ),
        ),
      ),
      home: AnimeHomePage(
        locale: _locale,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

class Anime {
  final int id;
  final String title;
  final String image;
  final String synopsis;
  final double score;
  final int? episodes;
  final String type;
  final String status;
  final String? year;
  final List<String> genres;

  const Anime({
    required this.id,
    required this.title,
    required this.image,
    required this.synopsis,
    required this.score,
    required this.episodes,
    required this.type,
    required this.status,
    required this.year,
    required this.genres,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    final jpg = images is Map<String, dynamic>
        ? images['jpg'] as Map<String, dynamic>?
        : null;

    final genresJson = json['genres'];

    return Anime(
      id: (json['mal_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? 'Unknown Anime').toString(),
      image: (jpg?['large_image_url'] ??
              jpg?['image_url'] ??
              jpg?['small_image_url'] ??
              '')
          .toString(),
      synopsis: (json['synopsis'] ?? '').toString(),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      episodes: (json['episodes'] as num?)?.toInt(),
      type: (json['type'] ?? 'TV').toString(),
      status: (json['status'] ?? '').toString(),
      year: (json['year'] as num?)?.toString(),
      genres: genresJson is List
          ? genresJson
              .whereType<Map>()
              .map((item) => (item['name'] ?? '').toString())
              .where((name) => name.isNotEmpty)
              .toList()
          : <String>[],
    );
  }
}

class AnimeEpisode {
  final int number;
  final String title;
  final String? aired;
  final bool filler;

  const AnimeEpisode({
    required this.number,
    required this.title,
    required this.aired,
    required this.filler,
  });

  factory AnimeEpisode.fromJson(Map<String, dynamic> json) {
    return AnimeEpisode(
      number: (json['mal_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? 'Episode').toString(),
      aired: json['aired']?.toString(),
      filler: json['filler'] == true,
    );
  }
}

// ============================================================
// API SERVICE
// ============================================================

class JikanService {
  static const String baseUrl = 'https://api.jikan.moe/v4';

  Future<List<Anime>> getTopAnime() async {
    final uri = Uri.parse('$baseUrl/top/anime?limit=24');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load anime');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['data'];

    if (list is! List) {
      return <Anime>[];
    }

    return list
        .whereType<Map>()
        .map((item) => Anime.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<List<Anime>> searchAnime(String query) async {
    final uri = Uri.parse(
      '$baseUrl/anime?q=${Uri.encodeQueryComponent(query)}&limit=24',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Search failed');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['data'];

    if (list is! List) {
      return <Anime>[];
    }

    return list
        .whereType<Map>()
        .map((item) => Anime.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<Anime> getAnime(int id) async {
    final uri = Uri.parse('$baseUrl/anime/$id/full');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load anime details');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return Anime.fromJson(
      Map<String, dynamic>.from(
        data['data'] as Map,
      ),
    );
  }

  Future<List<AnimeEpisode>> getEpisodes(
    int id, {
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/anime/$id/episodes?page=$page',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load episodes');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['data'];

    if (list is! List) {
      return <AnimeEpisode>[];
    }

    return list
        .whereType<Map>()
        .map(
          (item) => AnimeEpisode.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}

// ============================================================
// TRANSLATIONS
// ============================================================

class AppStrings {
  final String language;

  const AppStrings(this.language);

  String get home {
    switch (language) {
      case 'ar':
        return 'الرئيسية';
      case 'fr':
        return 'Accueil';
      case 'ja':
        return 'ホーム';
      default:
        return 'Home';
    }
  }

  String get search {
    switch (language) {
      case 'ar':
        return 'البحث';
      case 'fr':
        return 'Recherche';
      case 'ja':
        return '検索';
      default:
        return 'Search';
    }
  }

  String get favorites {
    switch (language) {
      case 'ar':
        return 'المفضلة';
      case 'fr':
        return 'Favoris';
      case 'ja':
        return 'お気に入り';
      default:
        return 'Favorites';
    }
  }

  String get settings {
    switch (language) {
      case 'ar':
        return 'الإعدادات';
      case 'fr':
        return 'Paramètres';
      case 'ja':
        return '設定';
      default:
        return 'Settings';
    }
  }

  String get popular {
    switch (language) {
      case 'ar':
        return 'الأكثر شعبية';
      case 'fr':
        return 'Populaires';
      case 'ja':
        return '人気';
      default:
        return 'Popular';
    }
  }

  String get anime {
    switch (language) {
      case 'ar':
        return 'الأنمي';
      case 'fr':
        return 'Anime';
      case 'ja':
        return 'アニメ';
      default:
        return 'Anime';
    }
  }

  String get searchAnime {
    switch (language) {
      case 'ar':
        return 'ابحث عن أنمي...';
      case 'fr':
        return 'Rechercher un anime...';
      case 'ja':
        return 'アニメを検索...';
      default:
        return 'Search anime...';
    }
  }

  String get noResults {
    switch (language) {
      case 'ar':
        return 'لا توجد نتائج';
      case 'fr':
        return 'Aucun résultat';
      case 'ja':
        return '結果がありません';
      default:
        return 'No results';
    }
  }

  String get episodes {
    switch (language) {
      case 'ar':
        return 'الحلقات';
      case 'fr':
        return 'Épisodes';
      case 'ja':
        return 'エピソード';
      default:
        return 'Episodes';
    }
  }

  String get synopsis {
    switch (language) {
      case 'ar':
        return 'القصة';
      case 'fr':
        return 'Synopsis';
      case 'ja':
        return 'あらすじ';
      default:
        return 'Synopsis';
    }
  }

  String get information {
    switch (language) {
      case 'ar':
        return 'معلومات';
      case 'fr':
        return 'Informations';
      case 'ja':
        return '情報';
      default:
        return 'Information';
    }
  }

  String get languageTitle {
    switch (language) {
      case 'ar':
        return 'اللغة';
      case 'fr':
        return 'Langue';
      case 'ja':
        return '言語';
      default:
        return 'Language';
    }
  }

  String get chooseLanguage {
    switch (language) {
      case 'ar':
        return 'اختر اللغة';
      case 'fr':
        return 'Choisir la langue';
      case 'ja':
        return '言語を選択';
      default:
        return 'Choose language';
    }
  }

  String get account {
    switch (language) {
      case 'ar':
        return 'الحساب';
      case 'fr':
        return 'Compte';
      case 'ja':
        return 'アカウント';
      default:
        return 'Account';
    }
  }

  String get appName {
    return 'Anime Stream';
  }

  String get loading {
    switch (language) {
      case 'ar':
        return 'جارٍ التحميل...';
      case 'fr':
        return 'Chargement...';
      case 'ja':
        return '読み込み中...';
      default:
        return 'Loading...';
    }
  }

  String get error {
    switch (language) {
      case 'ar':
        return 'حدث خطأ أثناء تحميل البيانات';
      case 'fr':
        return 'Une erreur est survenue';
      case 'ja':
        return 'データの読み込み中にエラーが発生しました';
      default:
        return 'An error occurred while loading data';
    }
  }

  String get retry {
    switch (language) {
      case 'ar':
        return 'إعادة المحاولة';
      case 'fr':
        return 'Réessayer';
      case 'ja':
        return '再試行';
      default:
        return 'Retry';
    }
  }

  String get watch {
    switch (language) {
      case 'ar':
        return 'مشاهدة';
      case 'fr':
        return 'Regarder';
      case 'ja':
        return '見る';
      default:
        return 'Watch';
    }
  }

  String get noFavorites {
    switch (language) {
      case 'ar':
        return 'لم تضف أي أنمي إلى المفضلة';
      case 'fr':
        return 'Aucun anime dans vos favoris';
      case 'ja':
        return 'お気に入りはありません';
      default:
        return 'No favorite anime yet';
    }
  }

  String get settingsTitle {
    switch (language) {
      case 'ar':
        return 'الإعدادات والحساب';
      case 'fr':
        return 'Paramètres et compte';
      case 'ja':
        return '設定とアカウント';
      default:
        return 'Settings & Account';
    }
  }

  String get theme {
    switch (language) {
      case 'ar':
        return 'المظهر';
      case 'fr':
        return 'Apparence';
      case 'ja':
        return 'テーマ';
      default:
        return 'Theme';
    }
  }

  String get darkMode {
    switch (language) {
      case 'ar':
        return 'الوضع الداكن';
      case 'fr':
        return 'Mode sombre';
      case 'ja':
        return 'ダークモード';
      default:
        return 'Dark mode';
    }
  }

  String get about {
    switch (language) {
      case 'ar':
        return 'حول التطبيق';
      case 'fr':
        return 'À propos';
      case 'ja':
        return 'アプリについて';
      default:
        return 'About';
    }
  }

  String get version {
    switch (language) {
      case 'ar':
        return 'الإصدار';
      case 'fr':
        return 'Version';
      case 'ja':
        return 'バージョン';
      default:
        return 'Version';
    }
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class AnimeHomePage extends StatefulWidget {
  final Locale locale;
  final ValueChanged<String> onLanguageChanged;

  const AnimeHomePage({
    super.key,
    required this.locale,
    required this.onLanguageChanged,
  });

  @override
  State<AnimeHomePage> createState() => _AnimeHomePageState();
}

class _AnimeHomePageState extends State<AnimeHomePage> {
  final JikanService _service = JikanService();

  int _currentIndex = 0;

  final Set<int> _favoriteIds = <int>{};
  final List<Anime> _favorites = <Anime>[];

  late List<Widget> _pages;

  AppStrings get strings => AppStrings(widget.locale.languageCode);

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  @override
  void didUpdateWidget(covariant AnimeHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.locale != widget.locale) {
      _buildPages();
    }
  }

  void _buildPages() {
    _pages = [
      HomeTab(
        service: _service,
        strings: strings,
        isFavorite: _isFavorite,
        onFavorite: _toggleFavorite,
      ),
      SearchTab(
        service: _service,
        strings: strings,
        isFavorite: _isFavorite,
        onFavorite: _toggleFavorite,
      ),
      FavoritesTab(
        favorites: _favorites,
        strings: strings,
        isFavorite: _isFavorite,
        onFavorite: _toggleFavorite,
      ),
      SettingsTab(
        strings: strings,
        locale: widget.locale,
        onLanguageChanged: widget.onLanguageChanged,
      ),
    ];
  }

  bool _isFavorite(int id) {
    return _favoriteIds.contains(id);
  }

  void _toggleFavorite(Anime anime) {
    setState(() {
      if (_favoriteIds.contains(anime.id)) {
        _favoriteIds.remove(anime.id);
        _favorites.removeWhere((item) => item.id == anime.id);
      } else {
        _favoriteIds.add(anime.id);
        _favorites.add(anime);
      }

      _buildPages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF111118),
          indicatorColor: const Color(0xFF33205E),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: strings.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search),
              label: strings.search,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border),
              selectedIcon: const Icon(Icons.favorite),
              label: strings.favorites,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: strings.account,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME TAB
// ============================================================

class HomeTab extends StatefulWidget {
  final JikanService service;
  final AppStrings strings;
  final bool Function(int) isFavorite;
  final void Function(Anime) onFavorite;

  const HomeTab({
    super.key,
    required this.service,
    required this.strings,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<Anime>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.getTopAnime();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _future = widget.service.getTopAnime();
          });
          await _future;
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildHero(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  widget.strings.popular,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Anime>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: ErrorView(
                      message: widget.strings.error,
                      retryText: widget.strings.retry,
                      onRetry: () {
                        setState(() {
                          _future = widget.service.getTopAnime();
                        });
                      },
                    ),
                  );
                }

                final anime = snapshot.data ?? <Anime>[];

                if (anime.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(widget.strings.noResults),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AnimeCard(
                          anime: anime[index],
                          strings: widget.strings,
                          isFavorite:
                              widget.isFavorite(anime[index].id),
                          onFavorite: () {
                            widget.onFavorite(anime[index]);
                          },
                        );
                      },
                      childCount: anime.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 190,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.60,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Anime Stream',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 190,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF29184A),
            Color(0xFF131323),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Icon(
              Icons.movie_filter_rounded,
              size: 180,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ANIME STREAM',
                  style: TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.strings.popular,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Discover your next favorite anime.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.explore_outlined),
                  label: Text(widget.strings.anime),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SEARCH TAB
// ============================================================

class SearchTab extends StatefulWidget {
  final JikanService service;
  final AppStrings strings;
  final bool Function(int) isFavorite;
  final void Function(Anime) onFavorite;

  const SearchTab({
    super.key,
    required this.service,
    required this.strings,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _controller = TextEditingController();

  Future<List<Anime>>? _future;

  void _search() {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _future = null;
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _future = widget.service.searchAnime(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Text(
              widget.strings.search,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: widget.strings.searchAnime,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final future = _future;

    if (future == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 70,
              color: Colors.white.withOpacity(0.20),
            ),
            const SizedBox(height: 12),
            Text(
              widget.strings.searchAnime,
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Anime>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: widget.strings.error,
            retryText: widget.strings.retry,
            onRetry: _search,
          );
        }

        final results = snapshot.data ?? <Anime>[];

        if (results.isEmpty) {
          return Center(
            child: Text(widget.strings.noResults),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 190,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 0.60,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final anime = results[index];

            return AnimeCard(
              anime: anime,
              strings: widget.strings,
              isFavorite: widget.isFavorite(anime.id),
              onFavorite: () {
                widget.onFavorite(anime);
              },
            );
          },
        );
      },
    );
  }
}

// ============================================================
// FAVORITES TAB
// ============================================================

class FavoritesTab extends StatelessWidget {
  final List<Anime> favorites;
  final AppStrings strings;
  final bool Function(int) isFavorite;
  final void Function(Anime) onFavorite;

  const FavoritesTab({
    super.key,
    required this.favorites,
    required this.strings,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.18),
              ),
              const SizedBox(height: 18),
              Text(
                strings.noFavorites,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                strings.favorites,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.60,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final anime = favorites[index];

                return AnimeCard(
                  anime: anime,
                  strings: strings,
                  isFavorite: isFavorite(anime.id),
                  onFavorite: () => onFavorite(anime),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SETTINGS TAB
// ============================================================

class SettingsTab extends StatelessWidget {
  final AppStrings strings;
  final Locale locale;
  final ValueChanged<String> onLanguageChanged;

  const SettingsTab({
    super.key,
    required this.strings,
    required this.locale,
    required this.onLanguageChanged,
  });

  void _showLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.chooseLanguage),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageTile(
                context,
                'العربية',
                'ar',
                '🇩🇿',
              ),
              _languageTile(
                context,
                'English',
                'en',
                '🇬🇧',
              ),
              _languageTile(
                context,
                'Français',
                'fr',
                '🇫🇷',
              ),
              _languageTile(
                context,
                '日本語',
                'ja',
                '🇯🇵',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile(
    BuildContext context,
    String title,
    String code,
    String flag,
  ) {
    final selected = locale.languageCode == code;

    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(title),
      trailing: selected
          ? const Icon(
              Icons.check_circle,
              color: Color(0xFF8B5CF6),
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        onLanguageChanged(code);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          Text(
            strings.settingsTitle,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          _buildProfileCard(),
          const SizedBox(height: 18),
          _sectionTitle(strings.settings),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF28203D),
                    child: Icon(Icons.language),
                  ),
                  title: Text(strings.languageTitle),
                  subtitle: Text(_languageName()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context),
                ),
                const Divider(
                  height: 1,
                  indent: 72,
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF28203D),
                    child: Icon(Icons.dark_mode_outlined),
                  ),
                  title: Text(strings.theme),
                  subtitle: Text(strings.darkMode),
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle(strings.about),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF28203D),
                child: Icon(Icons.info_outline),
              ),
              title: Text(strings.appName),
              subtitle: Text('${strings.version} 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }

  String _languageName() {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      case 'ja':
        return '日本語';
      default:
        return 'English';
    }
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF281A45),
            Color(0xFF171525),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anime Fan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Welcome to Anime Stream',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ANIME CARD
// ============================================================

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final AppStrings strings;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const AnimeCard({
    super.key,
    required this.anime,
    required this.strings,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnimeDetailsPage(
              anime: anime,
              strings: strings,
              initialFavorite: isFavorite,
              onFavorite: onFavorite,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimeImage(
                    url: anime.image,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withOpacity(0.55),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.pinkAccent
                                : Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (anime.score > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xFFFFD166),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              anime.score.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 3),
              child: Text(
                anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                _metaText(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _metaText() {
    final parts = <String>[];

    if (anime.type.isNotEmpty) {
      parts.add(anime.type);
    }

    if (anime.episodes != null) {
      parts.add('${anime.episodes} eps');
    }

    if (anime.year != null) {
      parts.add(anime.year!);
    }

    return parts.join(' • ');
  }
}

// ============================================================
// ANIME IMAGE
// ============================================================

class AnimeImage extends StatelessWidget {
  final String url;

  const AnimeImage({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _placeholder();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFF1B1B25),
          child: const Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1B1B25),
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 45,
          color: Colors.white24,
        ),
      ),
    );
  }
}

// ============================================================
// ANIME DETAILS
// ============================================================

class AnimeDetailsPage extends StatefulWidget {
  final Anime anime;
  final AppStrings strings;
  final bool initialFavorite;
  final VoidCallback onFavorite;

  const AnimeDetailsPage({
    super.key,
    required this.anime,
    required this.strings,
    required this.initialFavorite,
    required this.onFavorite,
  });

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  final JikanService _service = JikanService();

  late Future<Anime> _detailsFuture;
  late Future<List<AnimeEpisode>> _episodesFuture;

  late bool _isFavorite;

  @override
  void initState() {
    super.initState();

    _isFavorite = widget.initialFavorite;

    _detailsFuture = _service.getAnime(widget.anime.id);
    _episodesFuture = _service.getEpisodes(widget.anime.id);
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    widget.onFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Anime>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          final anime = snapshot.data ?? widget.anime;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                backgroundColor: const Color(0xFF09090F),
                actions: [
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _isFavorite
                          ? Colors.pinkAccent
                          : Colors.white,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildCover(anime),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildDetails(
                  anime,
                  snapshot.hasError,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCover(Anime anime) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimeImage(
          url: anime.image,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.05),
                const Color(0xFF09090F).withOpacity(0.15),
                const Color(0xFF09090F),
              ],
              stops: const [
                0.0,
                0.55,
                1.0,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(
    Anime anime,
    bool detailsError,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            anime.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(anime),
          const SizedBox(height: 18),
          if (anime.genres.isNotEmpty)
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: anime.genres.map(
                (genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF211A31),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD8C9FF),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          const SizedBox(height: 24),
          Text(
            widget.strings.synopsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            anime.synopsis.isEmpty
                ? 'No synopsis available.'
                : anime.synopsis,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.55,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.strings.episodes,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (detailsError)
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildEpisodes(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Anime anime) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (anime.score > 0)
          _infoChip(
            Icons.star_rounded,
            anime.score.toStringAsFixed(1),
          ),
        if (anime.type.isNotEmpty)
          _infoChip(
            Icons.movie_outlined,
            anime.type,
          ),
        if (anime.episodes != null)
          _infoChip(
            Icons.video_library_outlined,
            '${anime.episodes} eps',
          ),
        if (anime.year != null)
          _infoChip(
            Icons.calendar_today_outlined,
            anime.year!,
          ),
      ],
    );
  }

  Widget _infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF171720),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFFBFA7FF),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodes() {
    return FutureBuilder<List<AnimeEpisode>>(
      future: _episodesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(25),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF15151F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white54,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.strings.error,
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final episodes =
            snapshot.data ?? <AnimeEpisode>[];

        if (episodes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF15151F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              widget.strings.noResults,
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          );
        }

        return Column(
          children: episodes.map(
            (episode) {
              return _episodeTile(episode);
            },
          ).toList(),
        );
      },
    );
  }

  Widget _episodeTile(AnimeEpisode episode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF281C43),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${episode.number}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          episode.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: episode.filler
            ? const Text(
                'Filler',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 11,
                ),
              )
            : episode.aired != null
                ? Text(
                    episode.aired!,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  )
                : null,
        trailing: IconButton(
          onPressed: () {
            _showWatchMessage(episode);
          },
          icon: const Icon(
            Icons.play_circle_outline,
            color: Color(0xFFA78BFA),
          ),
        ),
      ),
    );
  }

  void _showWatchMessage(AnimeEpisode episode) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15151F),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.strings.watch} ${episode.number}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  episode.title,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF211A31),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Episode information is available from Jikan. '
                    'A video player/source can be connected here later.',
                    style: TextStyle(
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class ErrorView extends StatelessWidget {
  final String message;
  final String retryText;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.retryText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: Colors.white30,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryText),
            ),
          ],
        ),
      ),
    );
  }
}
