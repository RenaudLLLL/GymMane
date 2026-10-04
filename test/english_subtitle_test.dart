import 'package:flutter_test/flutter_test.dart';
import 'package:gymmane/catalog/exercise_catalog.dart';
import 'package:gymmane/l10n/catalog_es.dart';
import 'package:gymmane/l10n/l10n.dart';
import 'package:gymmane/models/exercise.dart';
import 'package:gymmane/services/local_store.dart';
import 'package:gymmane/state/fit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    setAppLanguage('en');
    fit.englishSubtitles = true;
  });

  Exercise translated() => kExercises.firstWhere(
      (e) => kExerciseNameEs.containsKey(e.id) && kExerciseStepsEs.containsKey(e.id));

  test('a translated exercise keeps its English name as a subtitle', () {
    setAppLanguage('es');
    final ex = translated();
    expect(exerciseName(ex), kExerciseNameEs[ex.id]);
    expect(exerciseEnglishName(ex), ex.name);
    expect(exerciseEnglishSteps(ex), ex.steps);
  });

  test('English needs no subtitle', () {
    setAppLanguage('en');
    final ex = translated();
    expect(exerciseEnglishName(ex), isNull);
    expect(exerciseEnglishSteps(ex), isNull);
  });

  test('a language without a catalogue shows no subtitle', () {
    setAppLanguage('de');
    final ex = translated();
    expect(exerciseName(ex), ex.name);
    expect(exerciseEnglishName(ex), isNull);
  });

  test('custom exercises have no English original to show', () {
    setAppLanguage('es');
    const custom = Exercise(
      id: 'custom-1',
      name: 'Mi ejercicio',
      primary: 'chest',
      secondary: [],
      equipment: 'Other',
      difficulty: 'Beginner',
      art: '',
      steps: ['Uno'],
    );
    expect(exerciseEnglishName(custom), isNull);
    expect(exerciseEnglishSteps(custom), isNull);
  });

  test('the setting turns subtitles off and survives a restart', () async {
    SharedPreferences.setMockInitialValues({});
    await Store.instance.init();
    fit.loadFromStore();
    expect(fit.englishSubtitles, isTrue, reason: 'on by default');

    setAppLanguage('es');
    fit.toggleEnglishSubtitles();
    expect(exerciseEnglishName(translated()), isNull);

    fit.persistNow();
    fit.englishSubtitles = true;
    fit.loadFromStore();
    expect(fit.englishSubtitles, isFalse);
  });
}
