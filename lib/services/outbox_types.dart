class OutboxTypes {
  // Waste
  static const String wasteCreate = 'waste.create';

  // Budget/Transactions
  static const String transactionCreate = 'transaction.create';
  static const String transactionUpdate = 'transaction.update';

  // Profile
  static const String profileUpdate = 'profile.update';

  // Missions/Gamification
  static const String missionProgressUpdate = 'mission.progress.update';
  static const String missionClaimReward = 'mission.claim.reward';
  
  // Services
  static const String serviceOfferCreate = 'service.offer_create';
  static const String serviceRequestCreate = 'service.request_create';
  static const String serviceMessageSend = 'service.message_send';
  static const String serviceRate = 'service.rate';
}
