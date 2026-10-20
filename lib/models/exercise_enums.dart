T _parseEnum<T extends Enum>(
  List<T> values,
  String Function(T) valueOf,
  Object? json,
  String field,
) {
  if (json is! String) {
    throw FormatException('$field must be a string', json?.toString());
  }
  return values.firstWhere(
    (e) => valueOf(e) == json,
    orElse: () => throw FormatException('Unknown $field: $json'),
  );
}

enum ExerciseCategory {
  strength('strength'),
  cardio('cardio'),
  olympic('olympic'),
  plyometrics('plyometrics'),
  stretching('stretching');

  const ExerciseCategory(this.value);

  final String value;

  static ExerciseCategory fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'category');

  String toJson() => value;
}

enum ForceType {
  push('push'),
  pull('pull'),
  dynamic('dynamic'),
  static('static');

  const ForceType(this.value);

  final String value;

  static ForceType fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'force_type');

  String toJson() => value;
}

enum Mechanic {
  compound('compound'),
  isolation('isolation');

  const Mechanic(this.value);

  final String value;

  static Mechanic fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'mechanic');

  String toJson() => value;
}

enum Difficulty {
  beginner('beginner'),
  intermediate('intermediate'),
  advanced('advanced');

  const Difficulty(this.value);

  final String value;

  static Difficulty fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'difficulty');

  String toJson() => value;
}

enum BodyPart {
  back('back'),
  chest('chest'),
  core('core'),
  fullBody('full_body'),
  lowerArms('lower_arms'),
  lowerLegs('lower_legs'),
  shoulders('shoulders'),
  upperArms('upper_arms'),
  upperLegs('upper_legs');

  const BodyPart(this.value);

  final String value;

  static BodyPart fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'body_part');

  String toJson() => value;
}

enum ExerciseGoal {
  core('core'),
  endurance('endurance'),
  hypertrophy('hypertrophy'),
  mobility('mobility'),
  power('power'),
  rehabilitation('rehabilitation'),
  strength('strength');

  const ExerciseGoal(this.value);

  final String value;

  static ExerciseGoal fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'goals');

  String toJson() => value;
}

enum Muscle {
  abductors('abductors'),
  adductors('adductors'),
  anteriorDeltoid('anterior_deltoid'),
  bicepsBrachii('biceps_brachii'),
  brachialis('brachialis'),
  brachioradialis('brachioradialis'),
  erectorSpinae('erector_spinae'),
  forearmExtensors('forearm_extensors'),
  forearmFlexors('forearm_flexors'),
  forearms('forearms'),
  gastrocnemius('gastrocnemius'),
  gluteusMaximus('gluteus_maximus'),
  gluteusMedius('gluteus_medius'),
  hamstrings('hamstrings'),
  hipFlexors('hip_flexors'),
  lateralDeltoid('lateral_deltoid'),
  latissimusDorsi('latissimus_dorsi'),
  obliques('obliques'),
  pectoralisMajor('pectoralis_major'),
  posteriorDeltoid('posterior_deltoid'),
  quadratusLumborum('quadratus_lumborum'),
  quadriceps('quadriceps'),
  rectusAbdominis('rectus_abdominis'),
  rhomboids('rhomboids'),
  serratusAnterior('serratus_anterior'),
  soleus('soleus'),
  supraspinatus('supraspinatus'),
  transverseAbdominis('transverse_abdominis'),
  trapezius('trapezius'),
  tricepsBrachii('triceps_brachii');

  const Muscle(this.value);

  final String value;

  static const _withoutImage = {
    'forearms',
    'quadratus_lumborum',
    'supraspinatus',
  };

  static Muscle fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'muscle');

  String toJson() => value;

  String? get imageAsset => _withoutImage.contains(value)
      ? null
      : 'assets/images/muscles/${value.replaceAll('_', '-')}.webp';
}

enum Equipment {
  abCrunchMachine('ab_crunch_machine'),
  abWheel('ab_wheel'),
  airBike('air_bike'),
  assistedPullupMachine('assisted_pullup_machine'),
  backExtensionMachine('back_extension_machine'),
  barbell('barbell'),
  battleRope('battle_rope'),
  bicepCurlMachine('bicep_curl_machine'),
  cable('cable'),
  chestFlyMachine('chest_fly_machine'),
  chestPressMachine('chest_press_machine'),
  climbingRope('climbing_rope'),
  dipMachine('dip_machine'),
  dipStation('dip_station'),
  donkeyCalfRaiseMachine('donkey_calf_raise_machine'),
  dumbbell('dumbbell'),
  elliptical('elliptical'),
  ezBar('ez_bar'),
  flatBench('flat_bench'),
  gluteHamDeveloper('glute_ham_developer'),
  hackSquat('hack_squat'),
  hipAbductionMachine('hip_abduction_machine'),
  hipAdductionMachine('hip_adduction_machine'),
  hipThrustMachine('hip_thrust_machine'),
  jumpRope('jump_rope'),
  kettlebell('kettlebell'),
  latPulldownMachine('lat_pulldown_machine'),
  legCurl('leg_curl'),
  legExtension('leg_extension'),
  legPress('leg_press'),
  loopBand('loop_band'),
  pecDeck('pec_deck'),
  plateLoadedLateralRaiseMachine('plate_loaded_lateral_raise_machine'),
  plates('plates'),
  plyoBox('plyo_box'),
  preacherCurlMachine('preacher_curl_machine'),
  pullUpBar('pull_up_bar'),
  resistanceBand('resistance_band'),
  rings('rings'),
  rower('rower'),
  seatedCalfRaiseMachine('seated_calf_raise_machine'),
  shoulderPressMachine('shoulder_press_machine'),
  shrugMachine('shrug_machine'),
  slamBall('slam_ball'),
  sled('sled'),
  smithMachine('smith_machine'),
  stabilityBall('stability_ball'),
  stairClimber('stair_climber'),
  standingCalfRaiseMachine('standing_calf_raise_machine'),
  stationaryBike('stationary_bike'),
  suspensionTrainer('suspension_trainer'),
  trapBar('trap_bar'),
  treadmill('treadmill'),
  tricepExtensionMachine('tricep_extension_machine'),
  wristRoller('wrist_roller');

  const Equipment(this.value);

  final String value;

  static Equipment fromJson(Object? json) =>
      _parseEnum(values, (e) => e.value, json, 'equipment');

  String toJson() => value;

  String get imageAsset =>
      'assets/images/equipment/${value.replaceAll('_', '-')}.webp';
}
