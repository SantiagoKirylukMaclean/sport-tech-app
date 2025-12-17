// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sport Tech';

  @override
  String get teamSportManagement => 'Team Sport Management';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter a password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordComingSoon => 'Forgot password feature coming soon';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get logout => 'Logout';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get matches => 'Matches';

  @override
  String get trainings => 'Trainings';

  @override
  String get championship => 'Championship';

  @override
  String get evaluations => 'Evaluations';

  @override
  String get notes => 'Notes';

  @override
  String get profile => 'Profile';

  @override
  String get coach => 'Coach';

  @override
  String get mister => 'Coach';

  @override
  String get team => 'Team *';

  @override
  String get admin => 'Admin';

  @override
  String get stats => 'Evaluations';

  @override
  String get more => 'More';

  @override
  String get settings => 'Settings';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get coachPanel => 'Coach Panel';

  @override
  String get superAdminPanel => 'Administration Panel';

  @override
  String get teamsManagement => 'Teams Management';

  @override
  String get clubsManagement => 'Clubs Management';

  @override
  String get sportsManagement => 'Sports Management';

  @override
  String get playersManagement => 'Players Management';

  @override
  String get welcome => 'Welcome';

  @override
  String get role => 'Role';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get noData => 'No data available';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get location => 'Location';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String get saveSuccess => 'Saved successfully';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get updateSuccess => 'Updated successfully';

  @override
  String get createSuccess => 'Created successfully';

  @override
  String get saveError => 'Error saving';

  @override
  String get deleteError => 'Error deleting';

  @override
  String get updateError => 'Error updating';

  @override
  String get createError => 'Error creating';

  @override
  String get confirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get appSettings => 'App Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System';

  @override
  String get preferences => 'Preferences';

  @override
  String get moreOptions => 'More Options';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get myNotes => 'My Notes';

  @override
  String get addNote => 'Add Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get noteContent => 'Note content';

  @override
  String get enterNoteContent => 'Enter your note...';

  @override
  String get noteContentRequired => 'Note content is required';

  @override
  String get noteCreated => 'Note created successfully';

  @override
  String get noteUpdated => 'Note updated successfully';

  @override
  String get noteDeleted => 'Note deleted successfully';

  @override
  String get confirmDeleteNote => 'Are you sure you want to delete this note?';

  @override
  String get noNotes => 'No notes yet. Create your first note!';

  @override
  String get errorLoadingStatistics => 'Error loading statistics';

  @override
  String get retry => 'Retry';

  @override
  String get noPlayerData => 'No player data';

  @override
  String get noPlayerRecordFound => 'No player record found for your account';

  @override
  String get players => 'Players';

  @override
  String get goals => 'Goals';

  @override
  String get quarters => 'Quarters';

  @override
  String get training => 'Training';

  @override
  String welcomeUser(String userName) {
    return 'Welcome, $userName!';
  }

  @override
  String roleUser(String role) {
    return 'Role: $role';
  }

  @override
  String errorLoadingTeams(String error) {
    return 'Error loading teams: $error';
  }

  @override
  String get selectTeam => 'Select Team';

  @override
  String activeTeam(String teamName) {
    return 'Active Team: $teamName';
  }

  @override
  String get noTeamsAssigned => 'No teams assigned.';

  @override
  String get noTeamsAvailable => 'No teams available';

  @override
  String get administrationPanel => 'Administration Panel';

  @override
  String get sports => 'Sports';

  @override
  String get manageSports => 'Manage sports in the system';

  @override
  String get clubs => 'Clubs';

  @override
  String get manageClubs => 'Manage clubs and organizations';

  @override
  String get teams => 'Teams';

  @override
  String get manageTeams => 'Manage teams in the system';

  @override
  String get inviteCoachAdmin => 'Invite Coach/Admin';

  @override
  String get sendInvitationsCoachAdmin =>
      'Send invitations to new coaches or administrators';

  @override
  String get invitePlayer => 'Invite Player';

  @override
  String get sendInvitationsPlayers => 'Send invitations to new players';

  @override
  String get invitations => 'Invitations';

  @override
  String get viewManageInvitations => 'View and manage pending invitations';

  @override
  String get users => 'Users';

  @override
  String get manageUsers => 'Manage system users';

  @override
  String get filters => 'Filters';

  @override
  String get refresh => 'Refresh';

  @override
  String get sport => 'Sport';

  @override
  String get allSports => 'All sports';

  @override
  String get club => 'Club';

  @override
  String get allClubs => 'All clubs';

  @override
  String get selectSportAndClub => 'Select a sport and a club to view teams';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String teamsCount(String count) {
    return 'Teams ($count)';
  }

  @override
  String get noTeamsFound => 'No teams found. Create one to get started!';

  @override
  String get newTeam => 'New team';

  @override
  String get teamCreatedSuccessfully => 'Team created successfully';

  @override
  String get assign => 'Assign';

  @override
  String get deleteTeam => 'Delete Team';

  @override
  String confirmDeleteTeam(String teamName) {
    return 'Are you sure you want to delete \"$teamName\"?';
  }

  @override
  String get teamUpdatedSuccessfully => 'Team updated successfully';

  @override
  String get teamDeletedSuccessfully => 'Team deleted successfully';

  @override
  String createdOn(String date) {
    return 'Created: $date';
  }

  @override
  String get createPlayerInvitation => 'Create Player Invitation';

  @override
  String get emailAddress => 'Email Address *';

  @override
  String get emailAddressDescription =>
      'The email address of the player you want to invite';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get playerName => 'Player Name *';

  @override
  String get fullNamePlayer => 'Full name of the player';

  @override
  String get playerNameIsRequired => 'Player name is required';

  @override
  String get playerNameMinLength => 'Player name must be at least 2 characters';

  @override
  String get jerseyNumber => 'Jersey Number';

  @override
  String get optionalJerseyNumber => 'Optional jersey/shirt number';

  @override
  String get jerseyNumberRange => 'Jersey number must be between 0 and 999';

  @override
  String get noTeamsAvailableCreateFirst =>
      'No teams available. Please create a team first.';

  @override
  String get selectTeamForPlayer => 'Select the team for this player';

  @override
  String get pleaseSelectTeam => 'Please select a team';

  @override
  String get howItWorks => 'How it works:';

  @override
  String get invitationStep1 =>
      'An invitation will be sent to the player\'s email';

  @override
  String get invitationStep2 =>
      'The player can accept and set up their account';

  @override
  String get invitationStep3 =>
      'Once accepted, they\'ll have access to the app';

  @override
  String get resetForm => 'Reset Form';

  @override
  String get creating => 'Creating...';

  @override
  String get createInvitation => 'Create Invitation';

  @override
  String failedToCreatePlayer(String error) {
    return 'Failed to create player: $error';
  }

  @override
  String playerCreatedAndInviteSent(String playerName) {
    return 'Player $playerName created and invitation sent successfully';
  }

  @override
  String playerCreatedButInviteFailed(String error) {
    return 'Player created but failed to send invite: $error';
  }

  @override
  String get sportCreatedSuccessfully => 'Sport created successfully';

  @override
  String get sportUpdatedSuccessfully => 'Sport updated successfully';

  @override
  String get sportDeletedSuccessfully => 'Sport deleted successfully';

  @override
  String get clubCreatedSuccessfully => 'Club created successfully';

  @override
  String get clubUpdatedSuccessfully => 'Club updated successfully';

  @override
  String get clubDeletedSuccessfully => 'Club deleted successfully';

  @override
  String get noTeamSelectedSelectFirst =>
      'No team selected. Please select a team first.';

  @override
  String get playerEvaluations => 'Player Evaluations';

  @override
  String get selectAPlayer => 'Select a Player';

  @override
  String get selectPlayer => 'Select a player';

  @override
  String get choosePlayerFromList =>
      'Choose a player from the list to view their evaluations';

  @override
  String get newEvaluation => 'New Evaluation';

  @override
  String get createFirstEvaluation => 'Create First Evaluation';

  @override
  String get deleteEvaluation => 'Delete evaluation';

  @override
  String evaluationForPlayer(String playerName) {
    return 'Evaluation - $playerName';
  }

  @override
  String get evaluationNotFound => 'Evaluation not found';

  @override
  String get errorNoAuthenticatedUser => 'Error: No authenticated user';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get noEvaluationsYet => 'No evaluations yet';

  @override
  String get latestEvaluation => 'Latest Evaluation';

  @override
  String get coachNotes => 'Coach Notes';

  @override
  String get evaluationHistory => 'Evaluation History';

  @override
  String evaluationsCount(String count) {
    return '$count evaluation(s)';
  }

  @override
  String get noTeamSelected => 'No Team Selected';

  @override
  String get selectTeamToViewMatches =>
      'Please select a team from the Dashboard to view and manage matches.';

  @override
  String get noMatchesYet => 'No matches yet';

  @override
  String get createFirstMatch => 'Create your first match using the + button';

  @override
  String get manageCallUp => 'Manage Call-Up';

  @override
  String get noPlayersFoundForTeam => 'No players found for this team';

  @override
  String jersey(String number) {
    return 'Jersey: $number';
  }

  @override
  String get done => 'Done';

  @override
  String get quarterResultSaved => 'Quarter result saved';

  @override
  String get saveResult => 'Save Result';

  @override
  String get addGoal => 'Add Goal';

  @override
  String assist(String assisterName) {
    return 'Assist: $assisterName';
  }

  @override
  String get none => 'None';

  @override
  String get opponentNameRequired => 'Opponent name is required';

  @override
  String get trainingSessionCreated => 'Training session created';

  @override
  String get trainingSessionUpdated => 'Training session updated';

  @override
  String get deleteSession => 'Delete Session';

  @override
  String get confirmDeleteTrainingSession =>
      'Are you sure you want to delete this training session?';

  @override
  String get trainingSessionDeleted => 'Training session deleted';

  @override
  String get pleaseSelectTeamFirst => 'Please select a team first';

  @override
  String get newSession => 'New Session';

  @override
  String get manageAttendance => 'Manage Attendance';

  @override
  String get viewDetails => 'View Details';

  @override
  String get sessionNotFound => 'Session not found';

  @override
  String get trainingSessions => 'Training Sessions';

  @override
  String get noTrainingSessions => 'No training sessions';

  @override
  String get noTrainingSessionsMessage => 'Training sessions will appear here';

  @override
  String get sessionInformation => 'Session Information';

  @override
  String get attendanceList => 'Attendance List';

  @override
  String get attendanceStatistics => 'Attendance Statistics';

  @override
  String get totalPlayers => 'Total Players';

  @override
  String get attendanceRate => 'Attendance Rate';

  @override
  String get notMarked => 'Not Marked';

  @override
  String get noPlayersInTeam => 'No players in team';

  @override
  String errorLoadingPlayers(String message) {
    return 'Error loading players: $message';
  }

  @override
  String errorUpdatingAttendance(String error) {
    return 'Error updating attendance: $error';
  }

  @override
  String get trainingAttendance => 'Training Attendance';

  @override
  String get onTime => 'On Time';

  @override
  String get late => 'Late';

  @override
  String get absent => 'Absent';

  @override
  String get trainingSessionDetails => 'Training Session Details';

  @override
  String get statistics => 'Evaluations';

  @override
  String get general => 'General';

  @override
  String get noTrainingAttendanceData =>
      'No training attendance data available';

  @override
  String get noGoalsOrAssistsData => 'No goals or assists data available';

  @override
  String get player => 'Player';

  @override
  String get assists => 'Assists';

  @override
  String get total => 'Total';

  @override
  String get noMatchesPlayedYet => 'No matches played yet';

  @override
  String get matchesPlayed => 'Matches Played';

  @override
  String get winPercentage => 'Win %';

  @override
  String get goalDifference => 'Goal Difference';

  @override
  String get cleanSheets => 'Clean Sheets';

  @override
  String get averageGoals => 'Average Goals';

  @override
  String get matchAttendance => 'Match Attendance';

  @override
  String winsDrawsLosses(String wins, String draws, String losses) {
    return '${wins}W - ${draws}D - ${losses}L';
  }

  @override
  String goalsForAgainst(String goalsFor, String goalsAgainst) {
    return '$goalsFor for - $goalsAgainst against';
  }

  @override
  String percentageOfMatches(String percentage) {
    return '$percentage% of matches';
  }

  @override
  String forAgainstAverage(String forAvg, String againstAvg) {
    return 'For: $forAvg | Against: $againstAvg';
  }

  @override
  String get seeDetails => 'See details';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get changePassword => 'Change Password';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get pleaseConfirmNewPassword => 'Please confirm your new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get invitePlayerDialog => 'Invite Player';

  @override
  String get chooseInvitationMethod =>
      'Choose how to send the invitation: via email or get a shareable link.';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get getLink => 'Get Link';

  @override
  String get mustBeLoggedIn => 'You must be logged in to send invites';

  @override
  String get pleaseEnterClubName => 'Please enter a club name';

  @override
  String get pleaseEnterSportName => 'Please enter a sport name';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get urlMustStartWithHttp => 'URL must start with http:// or https://';

  @override
  String get pleaseEnterEmail => 'Please enter an email';

  @override
  String get invalidEmailFormat => 'Invalid email';

  @override
  String get pleaseEnterPlayerName => 'Please enter player name';

  @override
  String get invitationSentSuccessfully => 'Invitation sent successfully';

  @override
  String get teamPlayers => 'Team Players';

  @override
  String get newEvaluationBreadcrumb => 'New Evaluation';

  @override
  String get detail => 'Detail';

  @override
  String get lineup => 'Lineup';

  @override
  String get attendance => 'Attendance';

  @override
  String get playerRole => 'Player';

  @override
  String get coachRole => 'Coach';

  @override
  String get adminRole => 'Administrator';

  @override
  String get accepted => 'Accepted';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get pending => 'Pending';

  @override
  String get playerAddedSuccessfully => 'Player added successfully';

  @override
  String get playerUpdatedSuccessfully => 'Player updated successfully';

  @override
  String noUrlAvailable(String label) {
    return 'No $label URL available';
  }

  @override
  String urlCopiedToClipboard(String label) {
    return '$label URL copied to clipboard';
  }

  @override
  String get copyUrl => 'Copy URL';

  @override
  String get open => 'Open';
}
