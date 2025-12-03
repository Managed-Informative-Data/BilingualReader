import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/text_entry.dart';
import '../providers/app_providers.dart';

class ToggleTranslationIntent extends Intent {
  const ToggleTranslationIntent();
}

class ReadingScreen extends ConsumerStatefulWidget {
  final TextEntry textEntry;

  const ReadingScreen({super.key, required this.textEntry});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen>
    with WidgetsBindingObserver {
  static const _fontFamilyFallback = [
    'Microsoft YaHei',
    'SimSun',
    'Segoe UI',
    'Roboto',
  ];

  bool _showOriginal = false;
  bool _showCharacters = true;
  bool _showPronunciation = true;
  bool _showMenu = false;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  late List<String> _paragraphs;
  List<int> _pageAnchors = [];
  int _totalPages = 1;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _paragraphs = widget.textEntry.content.split('\n');
    _calculatePages();

    _itemPositionsListener.itemPositions.addListener(_onScroll);

    // Restore position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.textEntry.lastReadPosition > 0) {
        // Treat lastReadPosition as index now
        int index = widget.textEntry.lastReadPosition.toInt();
        if (index < _paragraphs.length) {
          _itemScrollController.jumpTo(index: index);
        }
      }
    });
  }

  void _calculatePages() {
    _pageAnchors = [0];
    int charCount = 0;
    for (int i = 0; i < _paragraphs.length; i++) {
      charCount += _paragraphs[i].length;
      if (charCount > 300) {
        // Anchor every 300 chars
        _pageAnchors.add(i);
        charCount = 0;
      }
    }
    _totalPages = _pageAnchors.length;
    if (_totalPages == 0) _totalPages = 1;
  }

  @override
  void didUpdateWidget(ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textEntry.content != widget.textEntry.content) {
      _paragraphs = widget.textEntry.content.split('\n');
      _calculatePages();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveProgress();
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveProgress();
    }
  }

  void _saveProgress() {
    if (!mounted) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      // Find the first visible item
      final minIndex = positions
          .where((p) => p.itemTrailingEdge > 0)
          .reduce((min, p) => p.index < min.index ? p : min)
          .index;

      ref
          .read(libraryProvider.notifier)
          .updateProgress(widget.textEntry.id, minIndex.toDouble());
    }
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final firstVisible = positions
        .where((p) => p.itemTrailingEdge > 0)
        .reduce((min, p) => p.index < min.index ? p : min)
        .index;

    // Find which page this index belongs to
    int newPage = 1;
    for (int i = 0; i < _pageAnchors.length; i++) {
      if (_pageAnchors[i] <= firstVisible) {
        newPage = i + 1;
      } else {
        break;
      }
    }

    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  void _toggleTranslation() {
    setState(() {
      _showOriginal = !_showOriginal;
    });
  }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dictionary = ref.watch(activeWordsProvider);
    final substitutionService = ref.watch(substitutionServiceProvider);

    // Optimization: Create map once per build to avoid O(N) in loop
    final dictionaryMap = {
      for (var entry in dictionary) entry.word.toLowerCase(): entry,
    };

    final topPadding = MediaQuery.of(context).padding.top;
    // Increased height for slider and page info
    final appBarHeight = kToolbarHeight + topPadding + 50.0;

    final textStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 20,
          height: 1.8,
          fontFamilyFallback: _fontFamilyFallback,
        ) ??
        const TextStyle(
          fontSize: 20,
          height: 1.8,
          fontFamilyFallback: _fontFamilyFallback,
        );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveProgress();
        }
      },
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.keyT):
              const ToggleTranslationIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ToggleTranslationIntent: CallbackAction<ToggleTranslationIntent>(
              onInvoke: (ToggleTranslationIntent intent) =>
                  _toggleTranslation(),
            ),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: GestureDetector(
                          onTap: _toggleMenu,
                          behavior: HitTestBehavior.translucent,
                          child: ScrollablePositionedList.builder(
                            itemScrollController: _itemScrollController,
                            itemPositionsListener: _itemPositionsListener,
                            padding: EdgeInsets.only(
                              left: 24.0,
                              right: 24.0,
                              bottom: 32.0,
                              top: MediaQuery.of(context).padding.top + 20,
                            ),
                            itemCount: _paragraphs.length,
                            itemBuilder: (context, index) {
                              final paragraph = _paragraphs[index];
                              if (paragraph.trim().isEmpty) {
                                return const SizedBox(height: 24.0);
                              }

                              String textToDisplay = paragraph;
                              if (!_showOriginal) {
                                textToDisplay = substitutionService.processText(
                                  paragraph,
                                  dictionaryMap,
                                  showTranslation: _showCharacters,
                                  showPronunciation: _showPronunciation,
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(textToDisplay, style: textStyle),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    top: _showMenu ? 0 : -appBarHeight,
                    left: 0,
                    right: 0,
                    height: appBarHeight,
                    child: AppBar(
                      title: Text(widget.textEntry.title),
                      centerTitle: true,
                      elevation: 4,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      scrolledUnderElevation: 2,
                      actions: [
                        if (!_showOriginal) ...[
                          Tooltip(
                            message: 'Toggle Characters',
                            child: IconButton(
                              icon: Icon(
                                Icons.text_fields,
                                color: _showCharacters
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showCharacters = !_showCharacters;
                                });
                              },
                            ),
                          ),
                          Tooltip(
                            message: 'Toggle Pronunciation',
                            child: IconButton(
                              icon: Icon(
                                Icons.abc,
                                color: _showPronunciation
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPronunciation = !_showPronunciation;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Tooltip(
                          message: 'Toggle Translation (Press T)',
                          child: IconButton(
                            icon: Icon(
                              _showOriginal
                                  ? Icons.translate
                                  : Icons.compare_arrows,
                            ),
                            onPressed: _toggleTranslation,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Page $_currentPage / $_totalPages',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Slider(
                              value: _currentPage.toDouble(),
                              min: 1,
                              max: _totalPages.toDouble(),
                              onChanged: (value) {
                                final pageIndex = value.toInt() - 1;
                                if (pageIndex >= 0 &&
                                    pageIndex < _pageAnchors.length) {
                                  _itemScrollController.jumpTo(
                                    index: _pageAnchors[pageIndex],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
