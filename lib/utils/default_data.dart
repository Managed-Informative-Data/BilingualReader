import '../models/word_list.dart';
import '../models/text_entry.dart';
import '../data/dict/default_word_list.dart';
import '../data/text/default_story.dart';

class DefaultData {
  static const String defaultListId = 'default_chinese_beginner';
  static const String defaultStoryId = 'default_little_prince';

  static final WordList beginnerChineseList = defaultBeginnerList;
  static final TextEntry defaultStory = defaultLittlePrinceStory;
}
