import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AnimeStreamApp());
}

class AnimeStreamApp extends StatelessWidget {
  const AnimeStreamApp({super.key});

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
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

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
    return Anime(
      id: j['mal_id'] ?? 0,
      title: j['title'] ?? 'Unknown',
      image: j['images']?['jpg']?['large_image_url'] ??
          j['images']?['jpg']?['image_url'] ??
          '',
      synopsis: j['synopsis'] ?? 'لا توجد قصة متاحة.',
      score: ((j['score'] ?? 0) as num).toDouble(),
      episodes: j['episodes'],
      year: (j['year'] ?? j['aired']?['prop']?['from'] ?? '').toString(),
      status: j['status'] ?? '',
      genres: genres,
    );
  }
}

class Api {
  static const base = 'https://api.jikan.moe/v4';

  static Future<List<Anime>> topAnime() async {
  final r = await http.get(
    Uri.parse('$base/top/anime?limit=12'),
  );

  if (r.statusCode != 200) {
    throw Exception('API error: ${r.statusCode}');
  }

  final body = jsonDecode(r.body);
  final data = body['data'] as List;

  return data.map((x) => Anime.fromJson(x)).toList();
   {
    final r = await http.get(Uri.parse('$base/top/anime?limit=12'));
    if (r.statusCode != 200) throw Exception('API error');
    final data = jsonDecode(r.body)['data'] as List;
    return data.map((x) => Anime.fromJson(x)).toList();
  }

  static Future<List<Anime>> search(String q) async {
    final r = await http.get(Uri.parse(
      '$base/anime?q=${Uri.encodeQueryComponent(q)}&limit=12',
    ));
    if (r.statusCode != 200) throw Exception('API error');
    final data = jsonDecode(r.body)['data'] as List;
    return data.map((x) => Anime.fromJson(x)).toList();
  }

  static Future<Anime> details(int id) async {
    final r = await http.get(Uri.parse('$base/anime/$id/full'));
    if (r.statusCode != 200) throw Exception('API error');
    return Anime.fromJson(jsonDecode(r.body)['data']);
  }

  static Future<List<Map<String, dynamic>>> episodes(int id) async {
    final r = await http.get(Uri.parse('$base/anime/$id/episodes?limit=25'));
    if (r.satusCode != 200) return [];
    final data = jsonDecode(r.body)['data'] as List;
    return data.cast<Map<String, dynamic>>();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final Set<int> favorites = {};
  List<Anime> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try {
      final a = await Api.topAnime();
      setState(() { items = a; loading = false; });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'تعذر تحميل الأنميات. تأكد من اتصال الإنترنت.';
      });
    }
  }

  void openAnime(Anime a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          anime: a,
          isFavorite: favorites.contains(a.id),
          onFavorite: () {
            setState(() {
              if (favorites.contains(a.id)) {
                favorites.remove(a.id);
              } else {
                favorites.add(a.id);
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
      _home(),
      SearchPage(onOpen: openAnime),
      FavoritesPage(
        items: items.where((a) => favorites.contains(a.id)).toList(),
        onOpen: openAnime,
      ),
      const SettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        backgroundColor: const Color(0xFF0B1020),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _home() {
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Anime Stream',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              ),
              IconButton(
                onPressed: () => setState(() => tab = 1),
                icon: const Icon(Icons.search, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isNotEmpty) _HeroCard(anime: items.first, onTap: () => openAnime(items.first)),
          const SizedBox(height: 24),
          const SectionTitle('الأكثر شعبية'),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ))
          else if (error != null)
            _ErrorBox(error!, onRetry: load)
          else
            SizedBox(
              height: 275,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => AnimeCard(
                  anime: items[i],
                  onTap: () => openAnime(items[i]),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const SectionTitle('التصنيفات'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: ['أكشن', 'مغامرة', 'كوميديا', 'دراما', 'رعب', 'خيال', 'رياضة']
                .map((x) => Chip(
                      label: Text(x),
                      avatar: const Icon(Icons.local_fire_department, size: 17),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const SectionTitle('جميع الأنميات'),
          const SizedBox(height: 12),
          ...items.map((a) => AnimeListTile(anime: a, onTap: () => openAnime(a))),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;
  const _HeroCard({required this.anime, required this.onTap});

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
              const Text('أنمي مميز', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(anime.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                Text(' ${anime.score}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Text(anime.status, style: const TextStyle(color: Colors.white70)),
              ]),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow),
                label: const Text('عرض التفاصيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800));
}

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;
  const AnimeCard({required this.anime, required this.onTap, super.key});

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
                child: Image.network(anime.image, fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFF151B2D),
                    child: Icon(Icons.image_not_supported_outlined),
                  )),
              ),
            ),
            const SizedBox(height: 8),
            Text(anime.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star, size: 15, color: Colors.amber),
              Text(' ${anime.score}'),
            ]),
          ],
        ),
      ),
    );
  }
}

class AnimeListTile extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;
  const AnimeListTile({required this.anime, required this.onTap, super.key});
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF0D1426),
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(anime.image, width: 58, height: 76, fit: BoxFit.cover),
      ),
      title: Text(anime.title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${anime.score} ⭐  •  ${anime.episodes ?? "?"} حلقة'),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class SearchPage extends StatefulWidget {
  final void Function(Anime) onOpen;
  const SearchPage({required this.onOpen, super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  List<Anime> results = [];
  bool loading = false;

  Future<void> search() async {
    if (controller.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      results = await Api.search(controller.text.trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('البحث', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 16),
      TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => search(),
        decoration: InputDecoration(
          hintText: 'اكتب اسم الأنمي...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(onPressed: search, icon: const Icon(Icons.arrow_forward)),
          filled: true,
          fillColor: const Color(0xFF11182B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 18),
      if (loading) const Center(child: CircularProgressIndicator()),
      ...results.map((a) => AnimeListTile(anime: a, onTap: () => widget.onOpen(a))),
    ],
  );
}

class FavoritesPage extends StatelessWidget {
  final List<Anime> items;
  final void Function(Anime) onOpen;
  const FavoritesPage({required this.items, required this.onOpen, super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('المفضلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 16),
      if (items.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 70),
          child: Center(child: Text('لم تضف أي أنمي للمفضلة بعد.')),
        ),
      ...items.map((a) => AnimeListTile(anime: a, onTap: () => onOpen(a))),
    ],
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: const [
      Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      SizedBox(height: 18),
      Card(child: ListTile(leading: Icon(Icons.dark_mode), title: Text('الوضع الداكن'), trailing: Icon(Icons.check))),
      Card(child: ListTile(leading: Icon(Icons.language), title: Text('اللغة'), trailing: Text('العربية'))),
      Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('حول التطبيق'), subtitle: Text('Anime Stream • Flutter'))),
    ],
  );
}

class DetailPage extends StatefulWidget {
  final Anime anime;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const DetailPage({required this.anime, required this.isFavorite, required this.onFavorite, super.key});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Anime anime;
  List<Map<String, dynamic>> eps = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    anime = widget.anime;
    load();
  }

  Future<void> load() async {
    try {
      final a = await Api.details(anime.id);
      final e = await Api.episodes(anime.id);
      if (mounted) setState(() { anime = a; eps = e; loading = false; });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 310,
            pinned: true,
            backgroundColor: const Color(0xFF070B16),
            actions: [
              IconButton(onPressed: widget.onFavorite, icon: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.isFavorite ? Colors.redAccent : Colors.white,
              )),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 18, bottom: 14, end: 60),
              title: Text(anime.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(anime.image, fit: BoxFit.cover),
                  DecoratedBox(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, const Color(0xFF070B16).withOpacity(.98)],
                      stops: const [0.35, 1],
                    ),
                  )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 22),
                    const SizedBox(width: 5),
                    Text('${anime.score}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 16),
                    Text('${anime.episodes ?? "?"} حلقة'),
                    const SizedBox(width: 16),
                    Text(anime.year),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: anime.genres.take(6).map((g) => Chip(label: Text(g))).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(
                            title: Text('المشاهدة'),
                            content: Text('هذه النسخة هي واجهة تطبيق. أضف رابط الفيديو أو مزود البث الخاص بك لبدء تشغيل الحلقات.'),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('مشاهدة الآن'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      onPressed: widget.onFavorite,
                      icon: Icon(widget.isFavorite ? Icons.favorite : Icons.add),
                    ),
                  ]),
                  const SizedBox(height: 26),
                  const SectionTitle('قصة الأنمي'),
                  const SizedBox(height: 8),
                  Text(
                    anime.synopsis,
                    style: const TextStyle(fontSize: 15.5, height: 1.65, color: Colors.white70),
                  ),
                  const SizedBox(height: 26),
                  const SectionTitle('المعلومات'),
                  const SizedBox(height: 12),
                  _InfoGrid(anime: anime),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionTitle('الحلقات'),
                      if (loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!loading && eps.isEmpty)
                    const Text('لا توجد قائمة حلقات متاحة من المصدر.'),
                  ...eps.map((e) => EpisodeTile(
                    number: e['mal_id'] ?? 0,
                    title: e['title']?.toString() ?? 'حلقة',
                    aired: e['aired']?.toString() ?? '',
                  )),
                  if (!loading && eps.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.expand_more),
                        label: const Text('المزيد من الحلقات'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Anime anime;
  const _InfoGrid({required this.anime});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF0D1426),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white10),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Info('التقييم', '${anime.score}'),
        _Info('الحلقات', '${anime.episodes ?? "?"}'),
        _Info('السنة', anime.year),
        _Info('الحالة', anime.status.isEmpty ? '-' : anime.status),
      ],
    ),
  );
}
class _Info extends StatelessWidget {
  final String a, b;
  const _Info(this.a, this.b);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(a, style: const TextStyle(color: Colors.white54)),
      const SizedBox(height: 5),
      Text(b, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800)),
    ]),
  );
}

class EpisodeTile extends StatelessWidget {
  final dynamic number;
  final String title;
  final String aired;
  const EpisodeTile({required this.number, required this.title, required this.aired, super.key});
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF0D1426),
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      leading: Container(
        width: 44, height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)]),
        ),
        child: Text('$number', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(aired.length > 10 ? aired.substring(0, 10) : aired),
      trailing: IconButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('الحلقة $number'),
            content: const Text('اربط زر التشغيل بمصدر الفيديو المرخّص الخاص بك لبدء المشاهدة.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))],
          ),
        ),
        icon: const Icon(Icons.play_circle_outline, size: 30),
      ),
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;
  const _ErrorBox(this.text, {required this.onRetry});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(text, textAlign: TextAlign.center),
    const SizedBox(height: 10),
    OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
  ]);
}
