import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AnimeStreamApp());
}

// =========================
// LANGUAGE
// =========================

enum AppLanguage { ar, en, fr, ja }

class AppText {
  static String t(AppLanguage lang, String key) {
    const data = {
      'app': {
        AppLanguage.ar: 'Anime Stream',
        AppLanguage.en: 'Anime Stream',
        AppLanguage.fr: 'Anime Stream',
        AppLanguage.ja: 'Anime Stream',
      },
      'home': {
        AppLanguage.ar: 'الرئيسية',
        AppLanguage.en: 'Home',
        AppLanguage.fr: 'Accueil',
        AppLanguage.ja: 'ホーム',
      },
      'search': {
        AppLanguage.ar: 'بحث',
        AppLanguage.en: 'Search',
        AppLanguage.fr: 'Recherche',
        AppLanguage.ja: '検索',
      },
      'favorites': {
        AppLanguage.ar: 'المفضلة',
        AppLanguage.en: 'Favorites',
        AppLanguage.fr: 'Favoris',
        AppLanguage.ja: 'お気に入り',
      },
      'account': {
        AppLanguage.ar: 'حسابي',
        AppLanguage.en: 'Account',
        AppLanguage.fr: 'Compte',
        AppLanguage.ja: 'アカウント',
      },
      'popular': {
        AppLanguage.ar: 'الأكثر شعبية',
        AppLanguage.en: 'Most Popular',
        AppLanguage.fr: 'Les plus populaires',
        AppLanguage.ja: '人気作品',
      },
      'categories': {
        AppLanguage.ar: 'التصنيفات',
        AppLanguage.en: 'Categories',
        AppLanguage.fr: 'Catégories',
        AppLanguage.ja: 'カテゴリー',
      },
      'all': {
        AppLanguage.ar: 'جميع الأنميات',
        AppLanguage.en: 'All Anime',
        AppLanguage.fr: 'Tous les anime',
        AppLanguage.ja: 'すべてのアニメ',
      },
      'featured': {
        AppLanguage.ar: 'أنمي مميز',
        AppLanguage.en: 'Featured Anime',
        AppLanguage.fr: 'Anime à la une',
        AppLanguage.ja: 'おすすめアニメ',
      },
      'details': {
        AppLanguage.ar: 'عرض التفاصيل',
        AppLanguage.en: 'View Details',
        AppLanguage.fr: 'Voir les détails',
        AppLanguage.ja: '詳細を見る',
      },
      'story': {
        AppLanguage.ar: 'قصة الأنمي',
        AppLanguage.en: 'Synopsis',
        AppLanguage.fr: 'Synopsis',
        AppLanguage.ja: 'あらすじ',
      },
      'information': {
        AppLanguage.ar: 'المعلومات',
        AppLanguage.en: 'Information',
        AppLanguage.fr: 'Informations',
        AppLanguage.ja: '情報',
      },
      'episodes': {
        AppLanguage.ar: 'الحلقات',
        AppLanguage.en: 'Episodes',
        AppLanguage.fr: 'Épisodes',
        AppLanguage.ja: 'エピソード',
      },
      'watch': {
        AppLanguage.ar: 'مشاهدة الآن',
        AppLanguage.en: 'Watch Now',
        AppLanguage.fr: 'Regarder',
        AppLanguage.ja: '今すぐ見る',
      },
      'language': {
        AppLanguage.ar: 'اللغة',
        AppLanguage.en: 'Language',
        AppLanguage.fr: 'Langue',
        AppLanguage.ja: '言語',
      },
      'dark': {
        AppLanguage.ar: 'الوضع الداكن',
        AppLanguage.en: 'Dark Mode',
        AppLanguage.fr: 'Mode sombre',
        AppLanguage.ja: 'ダークモード',
      },
      'about': {
        AppLanguage.ar: 'حول التطبيق',
        AppLanguage.en: 'About',
        AppLanguage.fr: 'À propos',
        AppLanguage.ja: 'アプリについて',
      },
      'noFavorites': {
        AppLanguage.ar: 'لم تضف أي أنمي للمفضلة بعد.',
        AppLanguage.en: 'You have no favorites yet.',
        AppLanguage.fr: 'Aucun favori pour le moment.',
        AppLanguage.ja: 'お気に入りはまだありません。',
      },
      'searchHint': {
        AppLanguage.ar: 'اكتب اسم الأنمي...',
        AppLanguage.en: 'Enter anime name...',
        AppLanguage.fr: 'Entrez le nom de l’anime...',
        AppLanguage.ja: 'アニメ名を入力...',
      },
      'noSynopsis': {
        AppLanguage.ar: 'لا توجد قصة متاحة.',
        AppLanguage.en: 'No synopsis available.',
        AppLanguage.fr: 'Aucun synopsis disponible.',
        AppLanguage.ja: 'あらすじはありません。',
      },
      'loadingError': {
        AppLanguage.ar: 'تعذر تحميل الأنميات. تأكد من اتصال الإنترنت.',
        AppLanguage.en: 'Could not load anime. Check your internet connection.',
        AppLanguage.fr: 'Impossible de charger les anime. Vérifiez votre connexion.',
        AppLanguage.ja: 'アニメを読み込めません。インターネット接続を確認してください。',
      },
      'retry': {
        AppLanguage.ar: 'إعادة المحاولة',
        AppLanguage.en: 'Retry',
        AppLanguage.fr: 'Réessayer',
        AppLanguage.ja: '再試行',
      },
      'episodesCount': {
        AppLanguage.ar: 'حلقة',
        AppLanguage.en: 'episodes',
        AppLanguage.fr: 'épisodes',
        AppLanguage.ja: '話',
      },
      'score': {
        AppLanguage.ar: 'التقييم',
        AppLanguage.en: 'Score',
        AppLanguage.fr: 'Note',
        AppLanguage.ja: '評価',
      },
      'year': {
        AppLanguage.ar: 'السنة',
        AppLanguage.en: 'Year',
        AppLanguage.fr: 'Année',
        AppLanguage.ja: '年',
      },
      'status': {
        AppLanguage.ar: 'الحالة',
        AppLanguage.en: 'Status',
        AppLanguage.fr: 'Statut',
        AppLanguage.ja: '状態',
      },
      'watchMessage': {
        AppLanguage.ar:
            'هذه النسخة هي واجهة التطبيق. أضف مصدر فيديو مرخّص لبدء المشاهدة.',
        AppLanguage.en:
            'This version is the app interface. Add a licensed video source to start watching.',
        AppLanguage.fr:
            'Cette version est l’interface de l’application. Ajoutez une source vidéo autorisée.',
        AppLanguage.ja:
            'これはアプリのインターフェースです。視聴するには許可された動画ソースを追加してください。',
      },
      'ok': {
        AppLanguage.ar: 'حسنًا',
        AppLanguage.en: 'OK',
        AppLanguage.fr: 'OK',
        AppLanguage.ja: 'OK',
      },
    };

    return data[key]?[lang] ?? key;
  }

  static String languageName(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return 'العربية';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.ja:
        return '日本語';
    }
  }
}

// =========================
// APP
// =========================

class AnimeStreamApp extends StatefulWidget {
  const AnimeStreamApp({super.key});

  @override
  State<AnimeStreamApp> createState() => _AnimeStreamAppState();
}

class _AnimeStreamAppState extends State<AnimeStreamApp> {
  AppLanguage language = AppLanguage.ar;

  void changeLanguage(AppLanguage value) {
    setState(() {
      language = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime Stream',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B16),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(
        language: language,
        onLanguageChanged: changeLanguage,
      ),
    );
  }
}

// =========================
// ANIME MODEL
// =========================

class Anime {
  final int id;
  final String title;
  final String image;
  final String synopsis;
  final double score;
  final int? episodes;
  final String year;
  final String status;
  final List<String> genres;

  Anime({
    required this.id,
    required this.title,
    required this.image,
    required this.synopsis,
    required this.score,
    required this.episodes,
    required this.year,
    required this.status,
    required this.genres,
  });

  factory Anime.fromJson(Map<String, dynamic> j) {
    final genres = (j['genres'] as List? ?? [])
        .map((x) => x['name'].toString())
        .toList();

    String year = '';

    if (j['year'] != null) {
      year = j['year'].toString();
    } else {
      final from = j['aired']?['prop']?['from'];
      if (from != null) {
        year = from.toString().substring(0, 4);
      }
    }

    return Anime(
      id: j['mal_id'] ?? 0,
      title: j['title'] ?? 'Unknown',
      image: j['images']?['jpg']?['large_image_url'] ??
          j['images']?['jpg']?['image_url'] ??
          '',
      synopsis: j['synopsis'] ?? 'لا توجد قصة متاحة.',
      score: ((j['score'] ?? 0) as num).toDouble(),
      episodes: j['episodes'],
      year: year,
      status: j['status'] ?? '',
      genres: genres,
    );
  }
}

// =========================
// API
// =========================

class Api {
  static const base = 'https://api.jikan.moe/v4';

  static Future<List<Anime>> topAnime() async {
    final response = await http.get(
      Uri.parse('$base/top/anime?limit=12'),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final data = decoded['data'] as List;

    return data
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Anime>> search(String query) async {
    final response = await http.get(
      Uri.parse(
        '$base/anime?q=${Uri.encodeQueryComponent(query)}&limit=12',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final data = decoded['data'] as List;

    return data
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Anime> details(int id) async {
    final response = await http.get(
      Uri.parse('$base/anime/$id/full'),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    return Anime.fromJson(decoded['data']);
  }

  static Future<List<Map<String, dynamic>>> episodes(int id) async {
    final response = await http.get(
      Uri.parse('$base/anime/$id/episodes?limit=25'),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final decoded = jsonDecode(response.body);
    final data = decoded['data'] as List;

    return data.cast<Map<String, dynamic>>();
  }
}

// =========================
// HOME
// =========================

class HomePage extends StatefulWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  const HomePage({
    required this.language,
    required this.onLanguageChanged,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final Set<int> favorites = {};
  List<Anime> items = [];
  bool loading = true;
  String? error;

  String tr(String key) => AppText.t(widget.language, key);

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await Api.topAnime();

      if (!mounted) return;

      setState(() {
        items = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = tr('loadingError');
      });
    }
  }

  void openAnime(Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          anime: anime,
          language: widget.language,
          isFavorite: favorites.contains(anime.id),
          onFavorite: () {
            setState(() {
              if (favorites.contains(anime.id)) {
                favorites.remove(anime.id);
              } else {
                favorites.add(anime.id);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      SearchPage(
        language: widget.language,
        onOpen: openAnime,
      ),
      FavoritesPage(
        language: widget.language,
        items: items.where((a) => favorites.contains(a.id)).toList(),
        onOpen: openAnime,
      ),
      SettingsPage(
        language: widget.language,
        onLanguageChanged: widget.onLanguageChanged,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) {
          setState(() {
            tab = index;
          });
        },
        backgroundColor: const Color(0xFF0B1020),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: tr('search'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: tr('favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: tr('account'),
          ),
        ],
      ),
    );
  }

  Widget homePage() {
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('app'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    tab = 1;
                  });
                },
                icon: const Icon(Icons.search, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (items.isNotEmpty)
            HeroCard(
              anime: items.first,
              language: widget.language,
              onTap: () => openAnime(items.first),
            ),

          const SizedBox(height: 24),

          SectionTitle(tr('popular')),

          const SizedBox(height: 12),

          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            ErrorBox(
              text: error!,
              retryText: tr('retry'),
              onRetry: load,
            )
          else
            SizedBox(
              height: 275,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  return AnimeCard(
                    anime: items[index],
                    onTap: () => openAnime(items[index]),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          SectionTitle(tr('categories')),

          const SizedBox(height: 12),

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              'Action',
              'Adventure',
              'Comedy',
              'Drama',
              'Horror',
              'Fantasy',
              'Sports',
            ]
                .map(
                  (category) => Chip(
                    label: Text(category),
                    avatar: const Icon(
                      Icons.local_fire_department,
                      size: 17,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

          SectionTitle(tr('all')),

          const SizedBox(height: 12),

          ...items.map(
            (anime) => AnimeListTile(
              anime: anime,
              onTap: () => openAnime(anime),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// HERO
// =========================

class HeroCard extends StatelessWidget {
  final Anime anime;
  final AppLanguage language;
  final VoidCallback onTap;

  const HeroCard({
    required this.anime,
    required this.language,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 245,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(anime.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(.46),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                AppText.t(language, 'featured'),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  Text(
                    ' ${anime.score}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      anime.status,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  AppText.t(language, 'details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// SECTION TITLE
// =========================

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// =========================
// ANIME CARD
// =========================

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;

  const AnimeCard({
    required this.anime,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
            child: ClipRRect(
  borderRadius: BorderRadius.circular(18),
  child: Image.network(
    anime.image,
    height: 210,
    width: 150,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      height: 210,
      width: 150,
      color: const Color(0xFF151A2A),
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
      ),
    ),
  ),
),
const SizedBox(height: 8),
Text(
  anime.title,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    fontWeight: FontWeight.w700,
  ),
),
const SizedBox(height: 4),
Row(
  children: [
    const Icon(
      Icons.star,
      color: Colors.amber,
      size: 16,
    ),
    const SizedBox(width: 4),
    Text(
      anime.score.toString(),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
      ),
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}

// =========================
// ANIME LIST TILE
// =========================

class AnimeListTile extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;

  const AnimeListTile({
    required this.anime,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            anime.image,
            width: 55,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported,
            ),
          ),
        ),
        title: Text(
          anime.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '⭐ ${anime.score} • ${anime.year}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// =========================
// SEARCH PAGE
// =========================

class SearchPage extends StatefulWidget {
  final AppLanguage language;
  final ValueChanged<Anime> onOpen;

  const SearchPage({
    required this.language,
    required this.onOpen,
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();

  List<Anime> results = [];
  bool loading = false;
  String? error;

  String tr(String key) => AppText.t(widget.language, key);

  Future<void> search() async {
    final query = controller.text.trim();

    if (query.isEmpty) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await Api.search(query);

      if (!mounted) return;

      setState(() {
        results = data;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = tr('loadingError');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        Text(
          tr('search'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => search(),
          decoration: InputDecoration(
            hintText: tr('searchHint'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: search,
              icon: const Icon(Icons.arrow_forward),
            ),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          )
        else if (error != null)
          ErrorBox(
            text: error!,
            retryText: tr('retry'),
            onRetry: search,
          )
        else
          ...results.map(
            (anime) => AnimeListTile(
              anime: anime,
              onTap: () => widget.onOpen(anime),
            ),
          ),
      ],
    );
  }
}

// =========================
// FAVORITES PAGE
// =========================

class FavoritesPage extends StatelessWidget {
  final AppLanguage language;
  final List<Anime> items;
  final ValueChanged<Anime> onOpen;

  const FavoritesPage({
    required this.language,
    required this.items,
    required this.onOpen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = AppText.t(language, 'favorites');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                AppText.t(language, 'noFavorites'),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...items.map(
            (anime) => AnimeListTile(
              anime: anime,
              onTap: () => onOpen(anime),
            ),
          ),
      ],
    );
  }
}

// =========================
// SETTINGS PAGE
// =========================

class SettingsPage extends StatelessWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  const SettingsPage({
    required this.language,
    required this.onLanguageChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        Text(
          AppText.t(language, 'account'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              AppText.t(language, 'language'),
            ),
            trailing: DropdownButton<AppLanguage>(
              value: language,
              underline: const SizedBox(),
              items: AppLanguage.values.map(
                (item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      AppText.languageName(item),
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(
              AppText.t(language, 'dark'),
            ),
            trailing: const Icon(Icons.check),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              AppText.t(language, 'about'),
            ),
            subtitle: const Text('Anime Stream 1.0'),
          ),
        ),
      ],
    );
  }
}

// =========================
// DETAIL PAGE
// =========================

class DetailPage extends StatefulWidget {
  final Anime anime;
  final AppLanguage language;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const DetailPage({
    required this.anime,
    required this.language,
    required this.isFavorite,
    required this.onFavorite,
    super.key,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool favorite;
  List<Map<String, dynamic>> episodes = [];
  bool loadingEpisodes = true;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
    loadEpisodes();
  }

  Future<void> loadEpisodes() async {
    final result = await Api.episodes(widget.anime.id);

    if (!mounted) return;

    setState(() {
      episodes = result;
      loadingEpisodes = false;
    });
  }

  String tr(String key) => AppText.t(widget.language, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anime.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                favorite = !favorite;
              });
              widget.onFavorite();
            },
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              widget.anime.image,
              height: 360,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 360,
                color: const Color(0xFF151A2A),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.anime.title,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.star, size: 16),
                label: Text(
                  '${tr('score')}: ${widget.anime.score}',
                ),
              ),
              if (widget.anime.year.isNotEmpty)
                Chip(
                  label: Text(
                    '${tr('year')}: ${widget.anime.year}',
                  ),
                ),
              Chip(
                label: Text(widget.anime.status),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            tr('story'),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.anime.synopsis.isEmpty
                ? tr('noSynopsis')
                : widget.anime.synopsis,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr('episodes'),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (loadingEpisodes)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (episodes.isEmpty)
            Text(
              'No episodes available.',
              style: const TextStyle(
                color: Colors.white70,
              ),
            )
          else
            ...episodes.map(
              (episode) => EpisodeTile(
                episode: episode,
                language: widget.language,
              ),
            ),
        ],
      ),
    );
  }
}

// =========================
// EPISODE TILE
// =========================

class EpisodeTile extends StatelessWidget {
  final Map<String, dynamic> episode;
  final AppLanguage language;

  const EpisodeTile({
    required this.episode,
    required this.language,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final number = episode['mal_id'] ?? 0;
    final title = episode['title'] ?? 'Episode $number';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            number.toString(),
          ),
class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;

  const AnimeCard({
    required this.anime,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 210,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  anime.image,
                  width: 150,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 150,
                    height: 210,
                    color: const Color(0xFF151A2A),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  anime.score.toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
